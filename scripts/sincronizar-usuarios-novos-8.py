#!/usr/bin/env python3
"""
Script para sincronizar os 8 usuários na tabela profiles
Usa a API REST do Supabase para executar SQL
"""

import os
import sys
import json

try:
    import requests
except ImportError:
    print("❌ Erro: requests não está instalado")
    sys.exit(1)


class SupaabaseProfileSync:
    def __init__(self):
        self.supabase_url = "https://tlpmspfnswaxwqzmwski.supabase.co"
        
        self.service_key = os.environ.get('SUPABASE_SERVICE_ROLE_KEY')
        if not self.service_key and len(sys.argv) > 1 and sys.argv[1] == '--key':
            self.service_key = sys.argv[2]
        
        if not self.service_key:
            print("❌ Chave não encontrada. Uso:")
            print('   python sincronizar-usuarios-novos-8.py --key "sua_chave"')
            sys.exit(1)
        
        self.headers = {
            'Content-Type': 'application/json',
            'apikey': self.service_key,
            'Authorization': f'Bearer {self.service_key}',
        }
        
        self.emails = [
            ('gabriel.borges@fajsaude.com.br', 'GABRIEL LAMBERT BORGES', '2088495'),
            ('convenios2@ciprianoayla.com.br', 'EVELYN FERNANDA DOS SANTOS', '2089335'),
            ('diretoriaoss@funcamp.unicamp.br', 'ORIVAL ANDRIES JUNIOR', '2083981'),
            ('ferdinando.borrelli@oss.santamarcelina.org', 'FERDINANDO BORRELLI JUNIOR', '2078562'),
            ('lourdes.franco@hgp.spdm.org.br', 'MARIA DE LOURDES LACERDA FRANCO', '2079828'),
            ('keller.castro@santacasajales.com.br', 'KELLER RAFAELA CANUTO CASTRO', '2079895'),
            ('dec@caism.unicamp.br', 'FERNANDA EUGENIO FERREIRA', '2079798'),
            ('convenios@caism.unicamp.br', 'GABRIELA MORANDI DE ARAUJO', '2079798'),
        ]
    
    def sync(self):
        """Sincroniza os profiles"""
        print("\n" + "="*80)
        print("🔄 SINCRONIZANDO 8 USUÁRIOS NA TABELA PROFILES")
        print("="*80 + "\n")
        
        # SQL para sincronizar
        sql = """
        INSERT INTO public.profiles (id, email, full_name, cnes, role, created_at, updated_at)
        SELECT 
          u.id,
          u.email,
          u.raw_user_meta_data ->> 'full_name' AS full_name,
          u.raw_user_meta_data ->> 'cnes' AS cnes,
          'user' as role,
          now(),
          now()
        FROM auth.users u
        WHERE u.email IN (
          'gabriel.borges@fajsaude.com.br',
          'convenios2@ciprianoayla.com.br',
          'diretoriaoss@funcamp.unicamp.br',
          'ferdinando.borrelli@oss.santamarcelina.org',
          'lourdes.franco@hgp.spdm.org.br',
          'keller.castro@santacasajales.com.br',
          'dec@caism.unicamp.br',
          'convenios@caism.unicamp.br'
        )
        AND NOT EXISTS (
          SELECT 1 FROM public.profiles p WHERE p.id = u.id
        )
        ON CONFLICT (id) DO UPDATE
        SET 
          email = EXCLUDED.email,
          full_name = EXCLUDED.full_name,
          cnes = EXCLUDED.cnes,
          updated_at = now();
        """
        
        url = f"{self.supabase_url}/rest/v1/rpc/execute_sql"
        
        body = {
            'query': sql
        }
        
        try:
            response = requests.post(url, json=body, headers=self.headers, timeout=30)
            
            if response.status_code in [200, 201]:
                print("✅ Sincronização completada com sucesso!")
                print("\n📋 Os dados foram sincronizados na tabela profiles:")
                for email, name, cnes in self.emails:
                    print(f"   • {email}")
                    print(f"     Nome: {name}")
                    print(f"     CNES: {cnes}")
                    print()
                return True
            else:
                # Tentar via raw SQL
                print("⚠️  Método 1 falhou, tentando método alternativo...")
                return self.sync_alternative()
        
        except Exception as e:
            print(f"⚠️  Erro: {e}")
            print("\n💡 Solução alternativa:")
            print("   Execute manualmente no Dashboard do Supabase:")
            print("   1. Vá para: SQL Editor")
            print("   2. Clique: New Query")
            print("   3. Abra: CRIAR-USUARIOS-NOVOS-8.sql")
            print("   4. Cole o conteúdo e clique: Run")
            return False
    
    def sync_alternative(self):
        """Método alternativo usando POST direto na tabela"""
        print("✅ Usando método alternativo de sincronização...")
        
        success = 0
        for email, name, cnes in self.emails:
            try:
                # Buscar o usuário primeiro
                auth_url = f"{self.supabase_url}/auth/v1/admin/users"
                resp = requests.get(auth_url, headers=self.headers, timeout=30)
                
                if resp.status_code == 200:
                    users = resp.json().get('users', [])
                    user = next((u for u in users if u['email'] == email), None)
                    
                    if user:
                        # Inserir/atualizar profile
                        profile_url = f"{self.supabase_url}/rest/v1/profiles"
                        profile_data = {
                            'id': user['id'],
                            'email': email,
                            'full_name': name,
                            'cnes': cnes,
                            'role': 'user'
                        }
                        
                        resp = requests.post(
                            profile_url,
                            json=profile_data,
                            headers=self.headers,
                            timeout=30,
                            params={'on_conflict': 'id'}
                        )
                        
                        if resp.status_code in [200, 201]:
                            print(f"   ✅ {email}")
                            success += 1
                        else:
                            print(f"   ⚠️  {email} - resposta {resp.status_code}")
            except Exception as e:
                print(f"   ❌ {email} - {str(e)}")
        
        print(f"\n✅ Sincronizados: {success}/8")
        return success > 0


if __name__ == '__main__':
    sync = SupaabaseProfileSync()
    success = sync.sync()
    
    if not success:
        print("\n" + "="*80)
        print("📖 INSTRUÇÕES MANUAIS")
        print("="*80)
        print("""
1. Acesse: https://app.supabase.com
2. Selecione seu projeto
3. Vá para: SQL Editor
4. Clique: New Query
5. Abra arquivo: CRIAR-USUARIOS-NOVOS-8.sql
6. Cole TUDO e clique: Run
        """)
