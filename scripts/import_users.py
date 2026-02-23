#!/usr/bin/env python3
"""
Script para importar usuários do CSV para o Supabase
Uso: python scripts/import_users.py usuarios.csv
"""

import os
import sys
import csv
import json
import time
import getpass
from pathlib import Path

try:
    import requests
except ImportError:
    print("❌ Erro: requests não está instalado")
    print("   Execute: pip install requests")
    sys.exit(1)


class SupabaseImporter:
    def __init__(self, service_key=None):
        """Inicializa o importador com as credenciais do Supabase"""
        self.supabase_url = "https://tlpmspfnswaxwqzmwski.supabase.co"
        self.service_key = service_key or os.environ.get('SUPABASE_SERVICE_ROLE_KEY')
        
        if not self.service_key:
            raise ValueError(
                "⚠️  SUPABASE_SERVICE_ROLE_KEY não definido\n"
                "Defina a variável de ambiente ou passe a chave como argumento"
            )
        
        self.headers = {
            'Content-Type': 'application/json',
            'apikey': self.service_key,
            'Authorization': f'Bearer {self.service_key}',
        }

    def create_user(self, email, password, metadata=None):
        """Cria um usuário na API de autenticação do Supabase"""
        url = f"{self.supabase_url}/auth/v1/admin/users"
        
        body = {
            'email': email,
            'password': password,
            'email_confirm': True,
            'user_metadata': metadata or {}
        }

        response = requests.post(url, json=body, headers=self.headers)
        
        if response.status_code not in [200, 201]:
            error_data = response.json() if response.headers.get('content-type') == 'application/json' else response.text
            raise Exception(f"Erro ao criar usuário {email}: {error_data}")
        
        return response.json()

    def parse_csv(self, filepath):
        """Lê e parseia o arquivo CSV"""
        users = []
        
        # Detectar encoding (suporta UTF-8 e Latin-1)
        encodings = ['utf-8', 'latin-1', 'iso-8859-1', 'cp1252']
        
        for encoding in encodings:
            try:
                with open(filepath, 'r', encoding=encoding) as f:
                    reader = csv.reader(f, delimiter=';')
                    header = next(reader, None)
                    
                    if not header:
                        raise ValueError("Arquivo CSV vazio")
                    
                    for i, row in enumerate(reader, start=2):
                        if not row or not row[0].strip():
                            continue
                        
                        if len(row) < 2:
                            print(f"⚠️  Linha {i}: Formato inválido, pulando...")
                            continue
                        
                        name = row[0].strip() if len(row) > 0 else f"Usuário {i}"
                        email = row[1].strip() if len(row) > 1 else ""
                        cnes = row[2].strip() if len(row) > 2 else ""
                        password = row[3].strip() if len(row) > 3 else cnes or "senha123"
                        
                        # Validar email
                        if not email or '@' not in email:
                            print(f"⚠️  Linha {i}: Email inválido '{email}', pulando...")
                            continue
                        
                        users.append({
                            'name': name,
                            'email': email.lower(),
                            'cnes': cnes or None,
                            'password': password
                        })
                
                return users
            
            except UnicodeDecodeError:
                continue
            except Exception as e:
                print(f"❌ Erro ao ler arquivo com encoding {encoding}: {e}")
                continue
        
        raise ValueError(f"Não foi possível ler o arquivo {filepath}")

    def import_users(self, users):
        """Importa uma lista de usuários"""
        success_count = 0
        error_count = 0
        errors = []

        print(f"\n🚀 Iniciando importação de {len(users)} usuários...\n")

        for i, user in enumerate(users, start=1):
            progress = f"[{i}/{len(users)}]"
            
            try:
                metadata = {
                    'full_name': user['name'],
                }
                if user['cnes']:
                    metadata['cnes'] = user['cnes']
                
                self.create_user(user['email'], user['password'], metadata)
                print(f"✅ {progress} {user['email']} criado com sucesso")
                success_count += 1
                
                # Delay para não sobrecarregar a API
                time.sleep(0.5)
            
            except Exception as error:
                print(f"❌ {progress} Erro ao criar {user['email']}: {str(error)}")
                error_count += 1
                errors.append({'email': user['email'], 'error': str(error)})

        return {
            'success': success_count,
            'errors': error_count,
            'details': errors
        }


def main():
    """Função principal"""
    if len(sys.argv) < 2:
        print("❌ Erro: Caminho do CSV não fornecido")
        print("Uso: python scripts/import_users.py usuarios.csv [--auto]")
        sys.exit(1)

    # Verificar flag --auto
    auto_confirm = '--auto' in sys.argv
    
    csv_path = Path(sys.argv[1])

    if not csv_path.exists():
        print(f"❌ Erro: Arquivo não encontrado: {csv_path}")
        sys.exit(1)

    try:
        # Criar importador
        service_key = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2].startswith('sb') else None
        importer = SupabaseImporter(service_key=service_key)

        # Parsear CSV
        print("📥 Lendo arquivo CSV...")
        users = importer.parse_csv(csv_path)

        if not users:
            print("❌ Nenhum usuário válido encontrado")
            sys.exit(1)

        print(f"✅ {len(users)} usuários encontrados\n")
        print("Usuários a serem criados:")
        for j, u in enumerate(users, start=1):
            cnes_str = f"CNES: {u['cnes']}" if u['cnes'] else "CNES: N/A"
            print(f"  {j}. {u['name']} ({u['email']}) - {cnes_str}")

        # Confirmar
        print("\n")
        if auto_confirm:
            print("ℹ️  Modo automático ativado (--auto)")
            response = 's'
        else:
            response = input("Deseja continuar com a importação? (s/n): ").strip().lower()
        
        if response != 's':
            print("❌ Importação cancelada")
            sys.exit(0)

        # Importar
        result = importer.import_users(users)

        # Resultado
        print(f"\n📊 Resultado Final:")
        print(f"   ✅ Criados: {result['success']}")
        print(f"   ❌ Erros: {result['errors']}")

        if result['errors'] > 0:
            print(f"\n⚠️  Detalhes dos erros:")
            for error in result['details']:
                print(f"   - {error['email']}: {error['error']}")

        if result['errors'] == 0:
            print("\n🎉 Importação concluída com sucesso!")
        else:
            print("\n⚠️  Importação concluída com alguns erros")

        sys.exit(0 if result['errors'] == 0 else 1)

    except ValueError as e:
        print(f"❌ Erro de configuração: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Erro fatal: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
