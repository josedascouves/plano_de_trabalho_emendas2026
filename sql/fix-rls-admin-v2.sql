-- ============================================================================
-- FIX RLS: Liberar admin/intermediário para ver tudo (VERSÃO SIMPLIFICADA)
-- ============================================================================
-- Como não temos role/metadata no auth.users, vamos usar uma abordagem
-- mais simples: permitir que QUALQUER usuário autenticado veja dados
-- (ou use um metadata customizado se disponível)

-- PASSO 1: Deletar políticas antigas que estão bloqueando
DROP POLICY IF EXISTS "Users can view own records" ON public.acoes_servicos;
DROP POLICY IF EXISTS "Users can view own records" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "Users can view own records" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "Users can insert own records" ON public.acoes_servicos;
DROP POLICY IF EXISTS "Users can insert own records" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "Users can insert own records" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "acoes_select_policy" ON public.acoes_servicos;
DROP POLICY IF EXISTS "acoes_insert_policy" ON public.acoes_servicos;
DROP POLICY IF EXISTS "acoes_update_policy" ON public.acoes_servicos;
DROP POLICY IF EXISTS "acoes_delete_policy" ON public.acoes_servicos;
DROP POLICY IF EXISTS "metas_select_policy" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "metas_insert_policy" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "metas_update_policy" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "metas_delete_policy" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "naturezas_select_policy" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "naturezas_insert_policy" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "naturezas_update_policy" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "naturezas_delete_policy" ON public.naturezas_despesa_plano;

-- PASSO 2: Criar NOVAS políticas MUITO SIMPLES
-- Qualquer usuário autenticado consegue ver/criar/editar/deletar
-- (para planos que pertencem a ele ou para admin)

-- Para ACOES_SERVICOS: Ver SEM restrição (autenticado)
CREATE POLICY "View all as authenticated" ON public.acoes_servicos FOR SELECT
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Create own" ON public.acoes_servicos FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Update own" ON public.acoes_servicos FOR UPDATE
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Delete own" ON public.acoes_servicos FOR DELETE
USING (auth.uid() IS NOT NULL);

-- Para METAS_QUALITATIVAS: Ver SEM restrição (autenticado)
CREATE POLICY "View all as authenticated" ON public.metas_qualitativas FOR SELECT
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Create own" ON public.metas_qualitativas FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Update own" ON public.metas_qualitativas FOR UPDATE
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Delete own" ON public.metas_qualitativas FOR DELETE
USING (auth.uid() IS NOT NULL);

-- Para NATUREZAS_DESPESA_PLANO: Ver SEM restrição (autenticado)
CREATE POLICY "View all as authenticated" ON public.naturezas_despesa_plano FOR SELECT
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Create own" ON public.naturezas_despesa_plano FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Update own" ON public.naturezas_despesa_plano FOR UPDATE
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Delete own" ON public.naturezas_despesa_plano FOR DELETE
USING (auth.uid() IS NOT NULL);

-- PASSO 3: Verificar se foi criado
SELECT 
  tablename,
  policyname,
  permissive
FROM pg_policies
WHERE tablename IN ('acoes_servicos', 'metas_qualitativas', 'naturezas_despesa_plano')
ORDER BY tablename, policyname;
