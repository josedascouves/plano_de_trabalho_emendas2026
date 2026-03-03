#!/usr/bin/env python3
"""
Script para verificar o status de criação dos 8 novos usuários
Uso: python scripts/verificar-usuarios-novos-8.py --key "sua_chave_aqui"
"""

import os
import sys

try:
    import requests
except ImportError:
    print("❌ Erro: requests não está instalado")
    print("   Execute: pip install requests")
    sys.exit(1)


class SupabaseUserChecker:
    def __init__(self):
        """Inicializa o verificador"""
        self.supabase_url = "https://tlpmspfnswaxwqzmwski.supabase.co"
        
        # Obter a chave
        self.service_key = os.environ.get('SUPABASE_SERVICE_ROLE_KEY')
        
        if not self.service_key and len(sys.argv) > 1 and sys.argv[1] == '--key':
            self.service_key = sys.argv[2]
        
        if not self.service_key:
            print("❌ ERRO: Chave do Supabase não encontrada!")
            print("\nExecute assim:")
            print('   python scripts/verificar-usuarios-novos-8.py --key "sua_chave_aqui"')
            print("\nor:")
            print('   $env:SUPABASE_SERVICE_ROLE_KEY = "sua_chave_aqui"')
            print("   python scripts/verificar-usuarios-novos-8.py")
            sys.exit(1)
        
        self.headers = {
            'Content-Type': 'application/json',
            'apikey': self.service_key,
            'Authorization': f'Bearer {self.service_key}',
        }
        
        self.emails = [
            'gabriel.borges@fajsaude.com.br',
            'convenios2@ciprianoayla.com.br',
            'diretoriaoss@funcamp.unicamp.br',
            'ferdinando.borrelli@oss.santamarcelina.org',
            'lourdes.franco@hgp.spdm.org.br',
            'keller.castro@santacasajales.com.br',
            'dec@caism.unicamp.br',
            'convenios@caism.unicamp.br'
        ]
    
    def check_user(self, email):
        """Verifica se um usuário existe"""
        url = f"{self.supabase_url}/auth/v1/admin/users"
        
        try:
            response = requests.get(url, headers=self.headers, timeout=30)
            
            if response.status_code == 200:
                users = response.json().get('users', [])
                for user in users:
                    if user.get('email') == email:
                        return {
                            'found': True,
                            'email': email,
                            'user_id': user.get('id'),
                            'email_confirmed': user.get('email_confirmed_at') is not None,
                            'created_at': user.get('created_at'),
                            'full_name': user.get('user_metadata', {}).get('full_name', 'N/A'),
                            'cnes': user.get('user_metadata', {}).get('cnes', 'N/A')
                        }
                return {
                    'found': False,
                    'email': email,
                    'error': 'Usuário não encontrado'
                }
            else:
                return {
                    'found': False,
                    'email': email,
                    'error': f'Erro ao conectar: {response.status_code}'
                }
        
        except Exception as e:
            return {
                'found': False,
                'email': email,
                'error': str(e)
            }
    
    def run(self):
        """Executa a verificação"""
        print("\n" + "="*80)
        print("✓ VERIFICANDO 8 USUÁRIOS NO SUPABASE")
        print("="*80 + "\n")
        
        results = []
        
        for email in self.emails:
            result = self.check_user(email)
            results.append(result)
            
            if result['found']:
                print(f"✅ {email}")
                print(f"   ID: {result['user_id']}")
                print(f"   Nome: {result['full_name']}")
                print(f"   CNES: {result['cnes']}")
                print(f"   Email confirmado: {'Sim' if result['email_confirmed'] else 'Não'}")
            else:
                print(f"❌ {email}")
                print(f"   Status: {result['error']}")
            print()
        
        # Resumo
        print("="*80)
        print("📊 RESUMO")
        print("="*80 + "\n")
        
        found_count = sum(1 for r in results if r['found'])
        
        print(f"✅ Encontrados: {found_count}/8")
        print(f"❌ Não encontrados: {8-found_count}/8")
        
        if found_count == 8:
            print("\n🎉 Todos os usuários foram criados com sucesso!")
        elif found_count == 0:
            print("\n⚠️  Nenhum usuário foi criado ainda.")
            print("Execute primeiro: python scripts/criar-usuarios-novos-8.py")
        else:
            print(f"\n⚠️  {8-found_count} usuário(s) ainda precisa(m) ser criado(s).")
        
        print("\n" + "="*80)


if __name__ == '__main__':
    checker = SupabaseUserChecker()
    checker.run()
