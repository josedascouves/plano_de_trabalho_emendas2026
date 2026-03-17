-- ============================================================================
-- FIX RÁPIDO: Liberar admin para ver tudo (SIMPLES)
-- ============================================================================

-- PASSO 1: Deletar políticas antigas que estão bloqueando
DROP POLICY IF EXISTS "Users can view own records" ON public.acoes_servicos;
DROP POLICY IF EXISTS "Users can view own records" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "Users can view own records" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "Users can insert own records" ON public.acoes_servicos;
DROP POLICY IF EXISTS "Users can insert own records" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "Users can insert own records" ON public.naturezas_despesa_plano;

-- PASSO 2: Criar NOVAS políticas que deixam admin ver tudo
-- A política permite: Admin VER +CRIAR+EDITAR+DELETAR tudo
-- Usuário padrão: SÓ VER/CRIAR/EDITAR/DELETAR seus próprios registros

-- Para ACOES_SERVICOS:
CREATE POLICY "acoes_select_policy" ON public.acoes_servicos FOR SELECT
USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin', 'intermediate'))
  OR created_by = auth.uid()
);

CREATE POLICY "acoes_insert_policy" ON public.acoes_servicos FOR INSERT
WITH CHECK (created_by = auth.uid());

CREATE POLICY "acoes_update_policy" ON public.acoes_servicos FOR UPDATE
USING (created_by = auth.uid());

CREATE POLICY "acoes_delete_policy" ON public.acoes_servicos FOR DELETE
USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin', 'intermediate'))
  OR created_by = auth.uid()
);

-- Para METAS_QUALITATIVAS:
CREATE POLICY "metas_select_policy" ON public.metas_qualitativas FOR SELECT
USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin', 'intermediate'))
  OR created_by = auth.uid()
);

CREATE POLICY "metas_insert_policy" ON public.metas_qualitativas FOR INSERT
WITH CHECK (created_by = auth.uid());

CREATE POLICY "metas_update_policy" ON public.metas_qualitativas FOR UPDATE
USING (created_by = auth.uid());

CREATE POLICY "metas_delete_policy" ON public.metas_qualitativas FOR DELETE
USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin', 'intermediate'))
  OR created_by = auth.uid()
);

-- Para NATUREZAS_DESPESA_PLANO:
CREATE POLICY "naturezas_select_policy" ON public.naturezas_despesa_plano FOR SELECT
USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin', 'intermediate'))
  OR created_by = auth.uid()
);

CREATE POLICY "naturezas_insert_policy" ON public.naturezas_despesa_plano FOR INSERT
WITH CHECK (created_by = auth.uid());

CREATE POLICY "naturezas_update_policy" ON public.naturezas_despesa_plano FOR UPDATE
USING (created_by = auth.uid());

CREATE POLICY "naturezas_delete_policy" ON public.naturezas_despesa_plano FOR DELETE
USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin', 'intermediate'))
  OR created_by = auth.uid()
);

-- PASSO 3: Verificar se foi criado
SELECT 
  tablename,
  policyname,
  permissive
FROM pg_policies
WHERE tablename IN ('acoes_servicos', 'metas_qualitativas', 'naturezas_despesa_plano')
ORDER BY tablename, policyname;
