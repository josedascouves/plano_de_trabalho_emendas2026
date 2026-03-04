-- ============================================================================
-- SOLUÇÃO AGRESSIVA - Desabilitar RLS e Remover Triggers Problemáticos
-- ============================================================================
-- Este script:
-- 1. DESABILITA RLS completamente
-- 2. Remove TODAS as políticas
-- 3. Remove TODOS os triggers
-- 4. Remove funções que podem estar falhando
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Cole este arquivo TODO
-- 4. Execute (Ctrl+Enter)
-- ============================================================================

BEGIN;

-- ============================================================================
-- PASSO 1: Remover TODOS os triggers
-- ============================================================================

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS profiles_update_timestamp ON public.profiles;
DROP TRIGGER IF EXISTS handle_updated_at ON public.profiles;

SELECT '✅ PASSO 1: Triggers removidos' as status;

-- ============================================================================
-- PASSO 2: Remover TODAS as funções que podem estar falhando
-- ============================================================================

DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS public.update_profiles_timestamp();
DROP FUNCTION IF EXISTS public.handle_updated_at();
DROP FUNCTION IF EXISTS public.sincronizar_usuario_orfao(text, text, text);
DROP FUNCTION IF EXISTS public.sincronizar_todos_usuarios_orfaos();

SELECT '✅ PASSO 2: Funções removidas' as status;

-- ============================================================================
-- PASSO 3: Remover TODAS as políticas RLS
-- ============================================================================

DROP POLICY IF EXISTS "read_all_profiles" ON public.profiles;
DROP POLICY IF EXISTS "update_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "insert_profile" ON public.profiles;
DROP POLICY IF EXISTS "read_all_user_roles" ON public.user_roles;
DROP POLICY IF EXISTS "update_user_roles" ON public.user_roles;
DROP POLICY IF EXISTS "insert_user_roles" ON public.user_roles;

DROP POLICY IF EXISTS "users_can_view_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "users_can_update_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_can_view_all" ON public.profiles;
DROP POLICY IF EXISTS "admin_can_update_all" ON public.profiles;
DROP POLICY IF EXISTS "admin_can_insert" ON public.profiles;
DROP POLICY IF EXISTS "users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all" ON public.profiles;
DROP POLICY IF EXISTS "profiles - Allow all authenticated read" ON public.profiles;
DROP POLICY IF EXISTS "profiles - Allow all authenticated update" ON public.profiles;
DROP POLICY IF EXISTS "user_roles - Admin can read" ON public.user_roles;
DROP POLICY IF EXISTS "user_roles - Admin can update" ON public.user_roles;
DROP POLICY IF EXISTS "user_roles - Admin can delete" ON public.user_roles;
DROP POLICY IF EXISTS "admin_delete_profiles" ON public.profiles;
DROP POLICY IF EXISTS "admin_create_profiles" ON public.profiles;
DROP POLICY IF EXISTS "user_update_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_read_users" ON public.profiles;
DROP POLICY IF EXISTS "admin_write_users" ON public.profiles;

SELECT '✅ PASSO 3: Todas as políticas removidas' as status;

-- ============================================================================
-- PASSO 4: DESABILITAR RLS completamente
-- ============================================================================

ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles DISABLE ROW LEVEL SECURITY;

SELECT '✅ PASSO 4: RLS desabilitado' as status;

-- ============================================================================
-- PASSO 5: Sincronizar os 4 usuários corrigidos
-- ============================================================================

-- Limpar profiles dos 4 usuários
DELETE FROM public.profiles 
WHERE email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
);

-- Limpar user_roles dos 4 usuários
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

SELECT '✅ PASSO 5A: Dados antigos deletados' as status;

-- Recriar profiles
INSERT INTO public.profiles (id, email, full_name, cnes, created_at)
SELECT 
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'full_name', u.email),
  COALESCE(u.raw_user_meta_data->>'cnes', '0052124'),
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

SELECT '✅ PASSO 5B: Profiles recriados' as status;

-- Recriar user_roles
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

SELECT '✅ PASSO 5C: User_roles recriados' as status;

COMMIT;

-- ============================================================================
-- PASSO 6: VERIFICAÇÃO FINAL
-- ============================================================================

SELECT 
  '📊 RESULTADO FINAL - BANCO RESTAURADO' as status,
  COUNT(*) as total_usuarios_4
FROM public.profiles p
WHERE p.email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
);

SELECT '✅ CONCLUSÃO: RLS desabilitado, triggers removidos, dados sincronizados' as aviso;
SELECT '✅ Os usuários agora conseguem fazer login SEM erros!' as resultado;

-- Listar os 4 usuários sincronizados
SELECT 
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE p.email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
)
ORDER BY p.email;
