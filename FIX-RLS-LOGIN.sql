-- ============================================================================
-- CORRIGIR ERRO "Database error querying schema" - RLS BLOQUEANDO LOGIN
-- ============================================================================
-- Este script desabilita RLS problemáticas que impedem login

-- 1. DIAGNOSTICAR TABELAS COM RLS HABILITADO
SELECT schemaname, tablename 
FROM pg_tables 
WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage')
AND tablename NOT LIKE 'pg_%';

-- ============================================================================
-- 2. DESABILITAR RLS TEMPORARIAMENTE (SE NECESSÁRIO)
-- ============================================================================
-- Encontre a tabela principal que está causando erro e execute:
-- ALTER TABLE public.sua_tabela_principal DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 3. VERIFICAR POLÍTICAS RLS EXISTENTES
-- ============================================================================
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  cmd
FROM pg_policies
WHERE schemaname = 'public';

-- ============================================================================
-- 4. SE HOUVER TABELA "planos" OU SIMILAR, CORRIGIR ASSIM:
-- ============================================================================

-- Exemplo para tabela 'planos':
-- ALTER TABLE public.planos DISABLE ROW LEVEL SECURITY;

-- Ou criar política permissiva:
-- ALTER TABLE public.planos ENABLE ROW LEVEL SECURITY;
-- 
-- CREATE POLICY "Usuários autenticados podem ver tudo" ON public.planos
--   FOR SELECT
--   USING (auth.uid() IS NOT NULL);
--
-- CREATE POLICY "Usuários autenticados podem editar seus dados" ON public.planos
--   FOR UPDATE
--   USING (auth.uid()::text = user_id OR auth.uid() IS NOT NULL)
--   WITH CHECK (auth.uid()::text = user_id OR auth.uid() IS NOT NULL);

-- ============================================================================
-- 5. SOLUÇÃO RÁPIDA: DESABILITAR RLS EM TODAS AS TABELAS PÚBLICAS
-- ============================================================================
-- CUIDADO: Usar apenas em desenvolvimento!

-- Para cada tabela, execute:
-- ALTER TABLE public.nome_da_tabela DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PRÓXIMOS PASSOS:
-- ============================================================================
-- 1. Procure qual tabela está causando erro (aplique os SELECTs acima)
-- 2. Se a tabela tem RLS, desabilite ou crie políticas corretas
-- 3. Teste login novamente
-- 4. Se ainda der erro, verifique logs em: Supabase > Logs > Edge Function
-- ============================================================================
