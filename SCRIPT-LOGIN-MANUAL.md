# Solução para Erro de Login - Database Error Querying Schema

## ⚠️ Problema Identificado
O erro "Database error querying schema" ao fazer login indica que pode haver:
1. Extensão pgcrypto não habilitada no Supabase
2. Usuário não criado corretamente
3. Configuração de RLS (Row Level Security) incorreta

---

## ✅ Solução 1: Recriar Usuário via Painel Supabase (RECOMENDADO)

### Passo 1: Acesse o Supabase
1. Vá para https://app.supabase.com
2. Selecione seu projeto
3. Clique em **Authentication** (Autenticação)
4. Clique em **Users** (Usuários)

### Passo 2: Crie Manualmente
1. Clique em **Create a New User** (Criar novo usuário)
2. Preencha:
   - **Email**: convenios2@cipriaioayla.com.br
   - **Password**: Crie uma senha segura (ex: SenhaSegura123!)
   - **Auto Confirm User**: ✅ MARQUE ESTA OPÇÃO
3. Clique em **Create User** (Criar usuário)

### Passo 3: Crie Perfil (Se Necessário)
Se sua aplicação usa tabela `profiles`, execute este SQL:

```sql
INSERT INTO profiles (id, email, full_name, cnes, created_at, updated_at)
SELECT id, email, 
  'EVELYN FERNANDA PEREIRA DOS SANTOS',
  '2078813',
  NOW(), 
  NOW()
FROM auth.users
WHERE email = 'convenios2@cipriaioayla.com.br'
ON CONFLICT (id) DO UPDATE SET updated_at = NOW();
```

---

## ✅ Solução 2: Script SQL Simplificado (Se tiver permissão)

Copie e execute isso no **SQL Editor** do Supabase:

```sql
-- Garantir extensão
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Criar usuário (escolha UM método abaixo)

-- OPÇÃO A: Com crypt() (mais seguro)
INSERT INTO auth.users (
  instance_id, id, aud, role, email, 
  encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, 
  is_super_admin, created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'convenios2@cipriaioayla.com.br',
  crypt('SenhaSegura123!', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "EVELYN FERNANDA PEREIRA DOS SANTOS", "cnes": "2078813"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;
```

---

## ✅ Solução 3: Verificar e Corrigir RLS

Execute este diagnóstico:

```sql
-- Ver políticas de RLS
SELECT * FROM pg_policies WHERE tablename = 'users';

-- Se houver problema, desabilite temporariamente
ALTER TABLE auth.users DISABLE ROW LEVEL SECURITY;

-- Depois de criar usuários, reabilite
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;
```

---

## 🔍 Checklist de Validação

- [ ] Email cadastrado: `convenios2@cipriaioayla.com.br`
- [ ] Senha definida e confirmada
- [ ] "Auto Confirm User" foi marcado ao criar
- [ ] Tabela `profiles` tem o registro correspondente (se aplicável)
- [ ] RLS está habilitado corretamente
- [ ] Extensão pgcrypto ativa (execute: `SELECT * FROM pg_extension WHERE extname = 'pgcrypto';`)

---

## 📞 Se Persistir o Erro

1. **Verifique os logs do Supabase**: Vá em Settings > Logs
2. **Teste sem RLS**: Desabilite RLS temporariamente para isolar o problema
3. **Recrie o usuário**: Delete (se possível) e recrie manualmente
4. **Contate suporte Supabase**: https://support.supabase.com

---

## 🔑 Credenciais de Teste

- **Email**: convenios2@cipriaioayla.com.br
- **Senha**: Use a senha que criou/recebeu
- **CNES**: 2078813
