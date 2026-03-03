#!/usr/bin/env python3
"""
Script para criar 8 novos usuários no Supabase
Uso: python scripts/criar-usuarios-novos-8.py
ou com service key: python scripts/criar-usuarios-novos-8.py --key "sua_chave_aqui"
"""

import os
import sys
import json
import time

try:
    import requests
except ImportError:
    print("❌ Erro: requests não está instalado")
    print("   Execute: pip install requests")
    sys.exit(1)


class SupabaseUserCreator:
    def __init__(self):
        """Inicializa com as credenciais do Supabase"""
        self.supabase_url = "https://tlpmspfnswaxwqzmwski.supabase.co"
        
        # Tenta obter a chave do ambiente
        self.service_key = os.environ.get('SUPABASE_SERVICE_ROLE_KEY')
        
        # Se não tiver nos args, tenta do ambiente
        if not self.service_key and len(sys.argv) > 1 and sys.argv[1] == '--key':
            self.service_key = sys.argv[2]
        
        if not self.service_key:
            print("❌ ERRO: Chave do Supabase não encontrada!")
            print("\n📍 Para adicionar a chave, escolha UMA opção:")
            print("\n   OPÇÃO 1: Via variável de ambiente (Windows PowerShell):")
            print('   $env:SUPABASE_SERVICE_ROLE_KEY = "sua_chave_aqui"')
            print("   python scripts/criar-usuarios-novos-8.py")
            print("\n   OPÇÃO 2: Passar direto no comando:")
            print('   python scripts/criar-usuarios-novos-8.py --key "sua_chave_aqui"')
            print("\n🔑 Copie a chave em: https://app.supabase.com → Project Settings → API → Service Role")
            sys.exit(1)
        
        self.headers = {
            'Content-Type': 'application/json',
            'apikey': self.service_key,
            'Authorization': f'Bearer {self.service_key}',
        }
        
        self.users = [
            {
                'full_name': 'GABRIEL LAMBERT BORGES',
                'email': 'gabriel.borges@fajsaude.com.br',
                'cnes': '2088495',
                'password': '2088495'
            },
            {
                'full_name': 'EVELYN FERNANDA DOS SANTOS',
                'email': 'convenios2@ciprianoayla.com.br',
                'cnes': '2089335',
                'password': '2089335'
            },
            {
                'full_name': 'ORIVAL ANDRIES JUNIOR',
                'email': 'diretoriaoss@funcamp.unicamp.br',
                'cnes': '2083981',
                'password': '2083981'
            },
            {
                'full_name': 'FERDINANDO BORRELLI JUNIOR',
                'email': 'ferdinando.borrelli@oss.santamarcelina.org',
                'cnes': '2078562',
                'password': '2078562'
            },
            {
                'full_name': 'MARIA DE LOURDES LACERDA FRANCO',
                'email': 'lourdes.franco@hgp.spdm.org.br',
                'cnes': '2079828',
                'password': '2079828'
            },
            {
                'full_name': 'KELLER RAFAELA CANUTO CASTRO',
                'email': 'keller.castro@santacasajales.com.br',
                'cnes': '2079895',
                'password': '2079895'
            },
            {
                'full_name': 'FERNANDA EUGENIO FERREIRA',
                'email': 'dec@caism.unicamp.br',
                'cnes': '2079798',
                'password': '2079798'
            },
            {
                'full_name': 'GABRIELA MORANDI DE ARAUJO',
                'email': 'convenios@caism.unicamp.br',
                'cnes': '2079798',
                'password': '2079798'
            }
        ]
    
    def create_user(self, user_data):
        """Cria um usuário no Supabase"""
        url = f"{self.supabase_url}/auth/v1/admin/users"
        
        body = {
            'email': user_data['email'],
            'password': user_data['password'],
            'email_confirm': True,
            'user_metadata': {
                'full_name': user_data['full_name'],
                'cnes': user_data['cnes']
            }
        }
        
        try:
            response = requests.post(url, json=body, headers=self.headers, timeout=30)
            
            if response.status_code in [200, 201]:
                result = response.json()
                return {
                    'success': True,
                    'email': user_data['email'],
                    'user_id': result.get('id'),
                    'message': 'Usuário criado com sucesso'
                }
            else:
                error_data = response.json() if response.headers.get('content-type') == 'application/json' else response.text
                
                # Verifica se é erro de usuário já existe
                if response.status_code == 422 and isinstance(error_data, dict):
                    if 'email' in str(error_data).lower() or 'already' in str(error_data).lower():
                        return {
                            'success': False,
                            'email': user_data['email'],
                            'error': 'Usuário já existe'
                        }
                
                return {
                    'success': False,
                    'email': user_data['email'],
                    'error': f"Erro {response.status_code}: {error_data}"
                }
        
        except requests.Timeout:
            return {
                'success': False,
                'email': user_data['email'],
                'error': 'Timeout ao conectar com Supabase'
            }
        except Exception as e:
            return {
                'success': False,
                'email': user_data['email'],
                'error': str(e)
            }
    
    def run(self):
        """Executa a criação de todos os usuários"""
        print("\n" + "="*80)
        print("🚀 CRIANDO 8 NOVOS USUÁRIOS NO SUPABASE")
        print("="*80 + "\n")
        
        results = []
        
        for i, user in enumerate(self.users, 1):
            print(f"[{i}/8] Criando: {user['full_name']} ({user['email']})...", end=" ")
            result = self.create_user(user)
            results.append(result)
            
            if result['success']:
                print("✅ OK")
            else:
                print(f"❌ ERRO: {result['error']}")
            
            # Pequeno delay entre requisições
            time.sleep(0.5)
        
        # Resumo
        print("\n" + "="*80)
        print("📊 RESUMO DA OPERAÇÃO")
        print("="*80 + "\n")
        
        success_count = sum(1 for r in results if r['success'])
        error_count = sum(1 for r in results if not r['success'])
        
        print(f"✅ Sucesso: {success_count}/{len(self.users)}")
        print(f"❌ Erros: {error_count}/{len(self.users)}")
        
        if error_count > 0:
            print("\n⚠️  Usuários com erro:")
            for result in results:
                if not result['success']:
                    print(f"   • {result['email']}: {result['error']}")
        
        print("\n" + "="*80)
        print("📝 PRÓXIMOS PASSOS:")
        print("="*80)
        print("""
1. Verifique se todos os usuários foram criados:
   Dashboard → Authentication → Users

2. Se teve erro "Usuário já existe":
   O usuário foi criado em outra oportunidade, não precisa fazer nada.

3. Para sincronizar os dados (full_name, cnes) na tabela profiles:
   Execute o arquivo: CRIAR-USUARIOS-NOVOS-8.sql
   
4. Pronto! Os usuários podem fazer login na plataforma.
""")


if __name__ == '__main__':
    creator = SupabaseUserCreator()
    creator.run()
