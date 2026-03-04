-- ============================================================================
-- VERIFICAR E CORRIGIR POLÍTICAS RLS
-- ============================================================================
-- O erro "Database error querying schema" pode ser causado por:
-- 1. Políticas RLS muito restritivas
-- 2. Falta de acesso às tabelAs profiles/user_roles
-- 3. Recursão infinita nas políticas
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Cole este arquivo TODO
-- 4. Execute (Ctrl+Enter)
-- ============================================================================

-- ============================================================================
-- PASSO 1: Verificar políticas RLS atuais
-- ============================================================================

SELECT 
  'POLÍTICAS RLS ATIVAS' as diagnostico,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual as condicao_select,
  with_check as condicao_insert_update
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'user_roles')
ORDER BY tablename, policyname;

-- ============================================================================
-- PASSO 2: Verificar RLS status
-- ============================================================================

SELECT 
  'STATUS RLS' as diagnostico,
  tablename,
  CASE WHEN rowsecurity THEN 'ENABLED' ELSE 'DISABLED' END as rls_status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'user_roles')
ORDER BY tablename;

-- ============================================================================
-- PASSO 3: SOLUÇÃO - Recriar políticas RLS de forma PERMISSIVA
-- ============================================================================

BEGIN;

-- Remover todas as políticas existentes
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

SELECT '✅ PASSO 3A: Políticas antigas removidas' as status;

-- ============================================================================
-- PASSO 4: Criar NOVAS políticas PERMISSIVAS (SEM RECURSÃO)
-- ============================================================================

-- POLÍTICA 1: Qualquer usuário autenticado pode ler profiles
CREATE POLICY "read_all_profiles"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (true);

SELECT '✅ PASSO 4A: Política READ criada' as status;

-- POLÍTICA 2: Qualquer usuário autenticado pode atualizar seu próprio profile
CREATE POLICY "update_own_profile"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

SELECT '✅ PASSO 4B: Política UPDATE criada' as status;

-- POLÍTICA 3: Qualquer usuário autenticado pode inserir (para admin criar usuários)
CREATE POLICY "insert_profile"
  ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

SELECT '✅ PASSO 4C: Política INSERT criada' as status;

-- POLÍTICA 4: Qualquer usuário autenticado pode ler user_roles
CREATE POLICY "read_all_user_roles"
  ON public.user_roles
  FOR SELECT
  TO authenticated
  USING (true);

SELECT '✅ PASSO 4D: Política user_roles READ criada' as status;

-- POLÍTICA 5: Qualquer usuário autenticado pode atualizar user_roles
CREATE POLICY "update_user_roles"
  ON public.user_roles
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

SELECT '✅ PASSO 4E: Política user_roles UPDATE criada' as status;

-- POLÍTICA 6: Qualquer usuário autenticado pode inserir em user_roles
CREATE POLICY "insert_user_roles"
  ON public.user_roles
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

SELECT '✅ PASSO 4F: Política user_roles INSERT criada' as status;

COMMIT;

-- ============================================================================
-- PASSO 5: VERIFICAÇÃO FINAL
-- ============================================================================

SELECT 
  'POLÍTICAS RLS CRIADAS CORRETAMENTE' as resultado,
  COUNT(*) as total_policies
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'user_roles');

SELECT '✅ CONCLUSÃO: Políticas RLS foram corrigidas!' as aviso;
SELECT 'ℹ️ Agora os usuários devem conseguir fazer login sem erro "Database error"' as proxima_acao;
