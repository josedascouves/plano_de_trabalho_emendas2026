-- ============================================================================
-- SINCRONIZAR USUÁRIOS ÓRFÃOS E CRIAR NOVOS USUÁRIOS
-- ============================================================================
-- Este script:
-- 1. Sincroniza automaticamente usuários órfãos em auth.users com profiles
-- 2. Cria os 6 novos usuários com todos os dados necessários
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Cole este arquivo TODO
-- 4. Execute (Ctrl+Enter)
-- 5. Aguarde "Query executed successfully"
-- ============================================================================

-- PASSO 0: Desabilitar RLS temporariamente para evitar bloqueios
BEGIN;

ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PARTE 1: SINCRONIZAR USUÁRIOS ÓRFÃOS EXISTENTES
-- ============================================================================
-- Se algum usuário foi criado em auth.users mas não tem profile

INSERT INTO public.profiles (id, email, full_name, cnes, created_at)
SELECT 
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'full_name', u.email),
  COALESCE(u.raw_user_meta_data->>'cnes', ''),
  u.created_at
FROM auth.users u
WHERE u.id NOT IN (SELECT id FROM public.profiles WHERE id IS NOT NULL)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  cnes = EXCLUDED.cnes;

SELECT '✅ PASSO 1: Profiles sincronizados' as status;

-- Sincronizar user_roles para os órfãos em profiles
INSERT INTO public.user_roles (user_id, role, disabled)
SELECT 
  p.id,
  'user',
  false
FROM public.profiles p
WHERE p.id NOT IN (SELECT user_id FROM public.user_roles)
ON CONFLICT (user_id) DO UPDATE SET
  disabled = false;

SELECT '✅ PASSO 2: User_roles sincronizados' as status;

-- ============================================================================
-- PARTE 2: SINCRONIZAR ROLES ESPECÍFICOS Por Email
-- ============================================================================
-- Se temos usuários intermediários que precisam ter role = 'intermediate'

UPDATE public.user_roles
SET role = 'intermediate'
WHERE user_id IN (
  SELECT p.id FROM public.profiles p
  WHERE p.email IN (
    'mvvasconcelos@saude.sp.gov.br',
    'janete.sgueglia@saude.sp.gov.br',
    'lhribeiro@saude.sp.gov.br',
    'gtcosta@saude.sp.gov.br',
    'casouza@saude.sp.gov.br',
    'rcloscher@saude.sp.gov.br'
  )
)
AND role != 'intermediate';

SELECT '✅ PASSO 3: Roles de intermediários configurados' as status;

-- ============================================================================
-- PARTE 3: GARANTIR QUE OS CNES ESTEJAM CORRETOS
-- ============================================================================
-- Atualizar CNES para os 6 usuários

UPDATE public.profiles
SET cnes = '0052124'
WHERE email IN (
  'mvvasconcelos@saude.sp.gov.br',
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br',
  'rcloscher@saude.sp.gov.br'
);

SELECT '✅ PASSO 4: CNES atualizados para 0052124' as status;

-- ============================================================================
-- PARTE 4: GARANTIR QUE NINGUÉM ESTÁ DESATIVADO
-- ============================================================================

UPDATE public.user_roles
SET disabled = false
WHERE user_id IN (
  SELECT p.id FROM public.profiles p
  WHERE p.email IN (
    'mvvasconcelos@saude.sp.gov.br',
    'janete.sgueglia@saude.sp.gov.br',
    'lhribeiro@saude.sp.gov.br',
    'gtcosta@saude.sp.gov.br',
    'casouza@saude.sp.gov.br',
    'rcloscher@saude.sp.gov.br'
  )
);

SELECT '✅ PASSO 5: Usuários ativados' as status;

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
  (a.confirmed_at IS NOT NULL) as email_confirmado
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
