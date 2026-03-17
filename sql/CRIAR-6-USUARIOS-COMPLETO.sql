-- ============================================================================
-- CRIAR 6 NOVOS USUÁRIOS NO SUPABASE AUTH
-- ============================================================================
-- Este script cria 6 usuários direto em auth.users com senhas aleatórias
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Cole este arquivo TODO
-- 4. Execute (Ctrl+Enter)
-- ============================================================================

BEGIN;

-- Desabilitar RLS temporariamente
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- CRIAR 6 USUÁRIOS EM auth.users
-- ============================================================================
-- Nota: Você pode usar senhas aleatórias geradas ou padrões

-- 1. MÁRCIA VITORINO DE VASCONCELOS
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
SELECT
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'mvvasconcelos@saude.sp.gov.br',
  crypt('SenhaTemporaria123!', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "MÁRCIA VITORINO DE VASCONCELOS", "cnes": "0052124"}',
  false,
  NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'mvvasconcelos@saude.sp.gov.br');

-- 2. JANETE LOURENÇO SGUEGLIA
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
SELECT
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'janete.sgueglia@saude.sp.gov.br',
  crypt('SenhaTemporaria123!', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "JANETE LOURENÇO SGUEGLIA", "cnes": "0052124"}',
  false,
  NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'janete.sgueglia@saude.sp.gov.br');

-- 3. Lúcia Henrique Ribeiro
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
SELECT
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'lhribeiro@saude.sp.gov.br',
  crypt('SenhaTemporaria123!', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "Lúcia Henrique Ribeiro", "cnes": "0052124"}',
  false,
  NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'lhribeiro@saude.sp.gov.br');

-- 4. Geisel Guimarães Torres Costa
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
SELECT
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'gtcosta@saude.sp.gov.br',
  crypt('SenhaTemporaria123!', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "Geisel Guimarães Torres Costa", "cnes": "0052124"}',
  false,
  NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'gtcosta@saude.sp.gov.br');

-- 5. Cristiane Aparecida Barreto de Souza
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
SELECT
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'casouza@saude.sp.gov.br',
  crypt('SenhaTemporaria123!', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "Cristiane Aparecida Barreto de Souza", "cnes": "0052124"}',
  false,
  NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'casouza@saude.sp.gov.br');

-- 6. ROBERTO CLÁUDIO LOSCHER
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
SELECT
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'rcloscher@saude.sp.gov.br',
  crypt('SenhaTemporaria123!', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "ROBERTO CLÁUDIO LOSCHER", "cnes": "0052124"}',
  false,
  NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'rcloscher@saude.sp.gov.br');

SELECT '✅ PASSO 1: Os 6 usuários foram criados em auth.users' as status;

-- ============================================================================
-- SINCRONIZAR PROFILES E USER_ROLES AUTOMATICAMENTE
-- ============================================================================

-- Criar profiles para ainda não foram sincronizados
INSERT INTO public.profiles (id, email, full_name, cnes, created_at)
SELECT 
  u.id,
  u.email,
  u.raw_user_meta_data->>'full_name',
  u.raw_user_meta_data->>'cnes',
  u.created_at
FROM auth.users u
WHERE u.email IN (
  'mvvasconcelos@saude.sp.gov.br',
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br',
  'rcloscher@saude.sp.gov.br'
)
ON CONFLICT (id) DO NOTHING;

SELECT '✅ PASSO 2: Profiles criados' as status;

-- Criar user_roles com role = 'intermediate' para todos
INSERT INTO public.user_roles (user_id, role, disabled)
SELECT 
  u.id,
  'intermediate',
  false
FROM auth.users u
WHERE u.email IN (
  'mvvasconcelos@saude.sp.gov.br',
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br',
  'rcloscher@saude.sp.gov.br'
)
ON CONFLICT (user_id) DO UPDATE SET role = 'intermediate', disabled = false;

SELECT '✅ PASSO 3: User_roles criados com role = intermediate' as status;

-- Re-habilitar RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

COMMIT;

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

SELECT 
  '📊 RESULTADO FINAL' as status,
  p.id as user_id,
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled,
  (a.email_confirmed_at IS NOT NULL) as email_confirmado
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
LEFT JOIN auth.users a ON p.id = a.id
WHERE p.email IN (
  'mvvasconcelos@saude.sp.gov.br',
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br',
  'rcloscher@saude.sp.gov.br'
)
ORDER BY p.email;
