#!/usr/bin/env python3
"""
Script para importar usuários e sincronizar com profiles
Usa a API REST para criar usuários e depois sincroniza a tabela profiles
"""

import os
import sys
import csv
import json
import time
from pathlib import Path

try:
    import requests
except ImportError:
    print("❌ Erro: requests não está instalado")
    print("   Execute: pip install requests")
    sys.exit(1)


class SupabaseImporter:
    def __init__(self, service_key=None):
        """Inicializa o importador"""
        self.supabase_url = "https://tlpmspfnswaxwqzmwski.supabase.co"
        self.service_key = service_key or os.environ.get('SUPABASE_SERVICE_ROLE_KEY')
        
        if not self.service_key:
            raise ValueError("SUPABASE_SERVICE_ROLE_KEY não definido")
        
        self.headers = {
            'Content-Type': 'application/json',
            'apikey': self.service_key,
            'Authorization': f'Bearer {self.service_key}',
        }

    def create_user(self, email, password, full_name, cnes):
        """Cria um usuário na API Auth"""
        url = f"{self.supabase_url}/auth/v1/admin/users"
        
        body = {
            'email': email,
            'password': password,
            'email_confirm': True,
            'user_metadata': {
                'full_name': full_name,
                'cnes': cnes if cnes else ''
            }
        }

        try:
            response = requests.post(url, json=body, headers=self.headers, timeout=30)
        except requests.Timeout:
            raise Exception("Timeout ao conectar com Supabase")
        
        if response.status_code not in [200, 201]:
            error_data = response.json() if response.headers.get('content-type') == 'application/json' else response.text
            raise Exception(f"Erro {response.status_code}: {error_data}")
        
        user_data = response.json()
        return {
            'id': user_data.get('id'),
            'email': email,
            'full_name': full_name,
            'cnes': cnes
        }

    def sync_profile(self, user_id, email, full_name, cnes):
        """Sincroniza um usuário na tabela profiles"""
        url = f"{self.supabase_url}/rest/v1/profiles"
        
        body = {
            'id': user_id,
            'email': email,
            'full_name': full_name,
            'cnes': cnes if cnes else None,
            'role': 'user',
            'disabled': False
        }

        try:
            response = requests.post(url, json=body, headers=self.headers, timeout=10)
        except requests.Timeout:
            return False
        
        return response.status_code in [200, 201, 409]  # 409 = Already exists

    def parse_csv(self, filepath):
        """Lê e parseia o arquivo CSV"""
        users = []
        encodings = ['utf-8', 'latin-1', 'iso-8859-1', 'cp1252']
        
        for encoding in encodings:
            try:
                with open(filepath, 'r', encoding=encoding) as f:
                    reader = csv.reader(f, delimiter=';')
                    next(reader, None)  # pular cabeçalho
                    
                    for i, row in enumerate(reader, start=2):
                        if not row or not row[0].strip():
                            continue
                        
                        if len(row) < 2:
                            continue
                        
                        name = row[0].strip() if len(row) > 0 else f"User {i}"
                        email = row[1].strip() if len(row) > 1 else ""
                        cnes = row[2].strip() if len(row) > 2 else ""
                        password = row[3].strip() if len(row) > 3 else cnes or "senha123"
                        
                        # Validar email
                        if not email or '@' not in email or ' / ' in email:
                            print(f"  ⚠️  Linha {i}: Email inválido, pulando...")
                            continue
                        
                        users.append({
                            'name': name,
                            'email': email.lower(),
                            'cnes': cnes,
                            'password': password
                        })
                
                return users
            except UnicodeDecodeError:
                continue
        
        raise ValueError("Não foi possível ler o arquivo")

    def import_users(self, users):
        """Importa usuários e sincroniza com profiles"""
        success_count = 0
        error_count = 0
        created_users = []

        print(f"\n🚀 Criando {len(users)} usuários...\n")

        for i, user in enumerate(users, start=1):
            progress = f"[{i}/{len(users)}]"
            
            try:
                result = self.create_user(
                    user['email'], 
                    user['password'],
                    user['name'],
                    user['cnes']
                )
                created_users.append(result)
                print(f"✅ {progress} {user['email']} criado")
                success_count += 1
                time.sleep(0.4)
            
            except Exception as error:
                print(f"❌ {progress} {user['email']}: {str(error)[:60]}")
                error_count += 1

        # Sincronizar profiles
        print(f"\n📊 Sincronizando {len(created_users)} perfis...")
        
        sync_count = 0
        for user in created_users:
            if self.sync_profile(user['id'], user['email'], user['full_name'], user['cnes']):
                sync_count += 1
                print(f"  ✅ {user['email']} sincronizado")
            time.sleep(0.2)

        return {
            'created': success_count,
            'errors': error_count,
            'synced': sync_count,
            'total': len(users)
        }


def main():
    """Função principal"""
    if len(sys.argv) < 2:
        print("Uso: python scripts/import_and_sync.py usuarios.csv [--auto]")
        sys.exit(1)

    auto_confirm = '--auto' in sys.argv
    csv_path = Path(sys.argv[1])

    if not csv_path.exists():
        print(f"❌ Arquivo não encontrado: {csv_path}")
        sys.exit(1)

    try:
        importer = SupabaseImporter()
        
        print("📥 Lendo arquivo CSV...")
        users = importer.parse_csv(csv_path)

        if not users:
            print("❌ Nenhum usuário válido encontrado")
            sys.exit(1)

        print(f"✅ {len(users)} usuários encontrados\n")
        for j, u in enumerate(users[:5], start=1):
            print(f"  {j}. {u['email']}")
        if len(users) > 5:
            print(f"  ... e mais {len(users) - 5}")

        if not auto_confirm:
            print(f"\nDeseja continuar? (s/n): ", end='')
            if input().strip().lower() != 's':
                sys.exit(0)

        result = importer.import_users(users)

        print(f"\n📊 Resultado Final:")
        print(f"   ✅ Criados: {result['created']}")
        print(f"   📍 Sincronizados: {result['synced']}")
        print(f"   ❌ Erros: {result['errors']}")

        if result['errors'] == 0:
            print("\n🎉 Sucesso! Todos os usuários foram criados!")
        else:
            print(f"\n⚠️  {result['errors']} erro(s)")

    except ValueError as e:
        print(f"❌ Erro: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Erro fatal: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
