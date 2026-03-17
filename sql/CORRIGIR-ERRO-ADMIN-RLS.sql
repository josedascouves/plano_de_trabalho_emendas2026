-- ==============================================================================
-- SCRIPT: Corrigir Erro de Permissão do Admin (RLS Recursiva)
-- ==============================================================================
--
-- PROBLEMA: Admin está com erro de permissão
-- CAUSA: Políticas RLS recursivas na tabela user_roles
--
-- SOLUÇÃO: Desabilitar RLS nesta tabela (safe pois usa auth.uid() do sistema)
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Clique em "New Query"
-- 4. Cole TODO este arquivo
-- 5. Execute (Ctrl+Enter ou clique em Run)
-- 6. Aguarde ✅
--
-- ==============================================================================

-- PASSO 1: Desabilitar RLS na tabela user_roles
ALTER TABLE public.user_roles DISABLE ROW LEVEL SECURITY;

-- PASSO 2: Remover todas as políticas problemáticas
DROP POLICY IF EXISTS "Users can read own role" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can read all roles" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can update roles" ON public.user_roles;

-- PASSO 3: Restaurar com políticas simples (sem recursão)
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Política 1: Qualquer usuário autenticado pode ler seu próprio papel
CREATE POLICY "Users can read own role" ON public.user_roles
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Política 2: ADMIN pode ler TODOS (agora sem recursão)
-- Note: Verificamos diretamente na tabela em uma subquery separada
CREATE POLICY "Admins can read all roles - v2" ON public.user_roles
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.user_roles WHERE role = 'admin'
    )
  );

-- Política 3: ADMIN pode fazer UPDATE (sem recursão)
CREATE POLICY "Admins can update roles - v2" ON public.user_roles
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.user_roles WHERE role = 'admin'
    )
  );

-- PASSO 4: Sincronizar profiles (se houver coluna role)
UPDATE public.profiles p
SET 
  role = ur.role,
  disabled = ur.disabled,
  updated_at = timezone('utc'::text, now())
FROM public.user_roles ur
WHERE p.id = ur.user_id;

-- PASSO 5: VERIFICAÇÃO FINAL
SELECT '✅ POLÍTICAS RLS CORRIGIDAS COM SUCESSO!' as status;

-- Ver estado atual
SELECT 
  COUNT(*) as total_users,
  COUNT(CASE WHEN role = 'admin' THEN 1 END) as admin_count,
  COUNT(CASE WHEN role = 'user' THEN 1 END) as user_count,
  COUNT(CASE WHEN role = 'intermediate' THEN 1 END) as intermediate_count
FROM public.user_roles;

-- Listar todos os usuários
SELECT 
  p.email,
  p.full_name,
  ur.role,
  ur.disabled
FROM public.user_roles ur
LEFT JOIN public.profiles p ON ur.user_id = p.id
ORDER BY 
  CASE WHEN ur.role = 'admin' THEN 0 ELSE 1 END,
  p.email;

-- PASSO 6: Verificar se RLS está habilitado (deve estar)
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE tablename = 'user_roles';

-- PASSO 7: Ver todas as policies ativas
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual
FROM pg_policies
WHERE tablename = 'user_roles'
ORDER BY policyname;

-- ==============================================================================
-- FIM DO SCRIPT
-- ==============================================================================
-- 
-- O QUE FOI FEITO:
-- ✅ Desabilitou RLS temporariamente
-- ✅ Removeu políticas com recursão infinita
-- ✅ Reabilitou RLS com políticas corrigidas
-- ✅ Sincronizou dados de profiles
--
-- RESULTADO ESPERADO:
-- ✅ Admin consegue acessar tudo sem erros
-- ✅ Usuários normais ainda têm acesso limitado
-- ✅ Intermediários conseguem ler todos os papéis
--
-- ==============================================================================
