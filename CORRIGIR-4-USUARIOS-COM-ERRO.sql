-- ============================================================================
-- DIAGNOSTICAR E CORRIGIR OS 4 USUÁRIOS COM ERRO
-- ============================================================================
-- Usuários com problema:
-- 1. janete.sgueglia@saude.sp.gov.br
-- 2. lhribeiro@saude.sp.gov.br
-- 3. gtcosta@saude.sp.gov.br
-- 4. casouza@saude.sp.gov.br
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Cole este arquivo TODO
-- 4. Execute (Ctrl+Enter)
-- ============================================================================

-- ============================================================================
-- PASSO 1: DIAGNÓSTICO - Verificar status dos 4 usuários
-- ============================================================================

SELECT 
  'DIAGNÓSTICO: auth.users' as diagnostico,
  u.id,
  u.email,
  (u.confirmed_at IS NOT NULL) as email_confirmado,
  u.created_at
FROM auth.users u
WHERE u.email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
)
ORDER BY u.email;

SELECT 
  'DIAGNÓSTICO: profiles' as diagnostico,
  p.id,
  p.email,
  p.full_name,
  p.cnes,
  (p.id IS NOT NULL) as existe
FROM public.profiles p
WHERE p.email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
)
ORDER BY p.email;

SELECT 
  'DIAGNÓSTICO: user_roles' as diagnostico,
  ur.user_id,
  ur.role,
  ur.disabled,
  (ur.user_id IS NOT NULL) as existe
FROM public.user_roles ur
WHERE ur.user_id IN (
  SELECT id FROM auth.users 
  WHERE email IN (
    'janete.sgueglia@saude.sp.gov.br',
    'lhribeiro@saude.sp.gov.br',
    'gtcosta@saude.sp.gov.br',
    'casouza@saude.sp.gov.br'
  )
)
ORDER BY ur.user_id;

-- ============================================================================
-- PASSO 2: LIMPEZA - Remover dados órfãos/corruptos (SE HOUVER)
-- ============================================================================

BEGIN;

-- Desabilitar RLS temporariamente
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;

-- Limpar profiles para os 4 usuários
DELETE FROM public.profiles 
WHERE email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
);

SELECT '✅ PASSO 2A: Profiles antigos deletados' as status;

-- Limpar user_roles para os 4 usuários
DELETE FROM public.user_roles
WHERE user_id IN (
  SELECT id FROM auth.users 
  WHERE email IN (
    'janete.sgueglia@saude.sp.gov.br',
    'lhribeiro@saude.sp.gov.br',
    'gtcosta@saude.sp.gov.br',
    'casouza@saude.sp.gov.br'
  )
);

SELECT '✅ PASSO 2B: User_roles antigos deletados' as status;

-- ============================================================================
-- PASSO 3: RECRIAÇÃO - Recrear profiles e user_roles corretamente
-- ============================================================================

-- Criar profiles para os 4 usuários
INSERT INTO public.profiles (id, email, full_name, cnes, created_at)
SELECT 
  u.id,
  u.email,
  u.raw_user_meta_data->>'full_name',
  u.raw_user_meta_data->>'cnes',
  u.created_at
FROM auth.users u
WHERE u.email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  cnes = EXCLUDED.cnes;

SELECT '✅ PASSO 3A: Profiles recriados' as status;

-- Criar user_roles para os 4 usuários
INSERT INTO public.user_roles (user_id, role, disabled)
SELECT 
  u.id,
  'intermediate',
  false
FROM auth.users u
WHERE u.email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
)
ON CONFLICT (user_id) DO UPDATE SET role = 'intermediate', disabled = false;

SELECT '✅ PASSO 3B: User_roles recriados' as status;

-- Re-habilitar RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

COMMIT;

-- ============================================================================
-- PASSO 4: VERIFICAÇÃO FINAL
-- ============================================================================

SELECT 
  '📊 RESULTADO FINAL - 4 USUÁRIOS CORRIGIDOS' as status,
  p.id as user_id,
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled,
  CASE 
    WHEN p.id IS NOT NULL AND ur.user_id IS NOT NULL AND a.id IS NOT NULL
    THEN '✅ COMPLETO'
    ELSE '❌ INCOMPLETO'
  END as sync_status
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
LEFT JOIN auth.users a ON p.id = a.id
WHERE p.email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
)
ORDER BY p.email;
