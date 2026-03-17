-- ============================================================
-- FIX RLS - Corrigir recursão infinita nas políticas
-- ============================================================
-- SOLUÇÃO: Usar políticas simples que NÃO causam recursão

-- ============================================================
-- DESABILITAR RLS TEMPORARIAMENTE PARA CORRIGIR
-- ============================================================
ALTER TABLE public.planos_trabalho DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.acoes_servicos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.metas_qualitativas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.naturezas_despesa_plano DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- Remover todas as políticas antigas
DROP POLICY IF EXISTS "Users can view their own plans" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Users can insert their own plans" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Users can update their own plans" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Admin can view all plans" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Users can view own plans" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Users can insert plans" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Users can update own plans" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Users can delete own plans" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Users can view plan actions" ON public.acoes_servicos;
DROP POLICY IF EXISTS "Users can insert plan actions" ON public.acoes_servicos;
DROP POLICY IF EXISTS "Users can view plan metas" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "Users can insert plan metas" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "Users can view plan expenses" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "Users can insert plan expenses" ON public.naturezas_despesa_plano;

-- ============================================================
-- APLICAR NOVAS POLÍTICAS SIMPLES (SEM RECURSÃO)
-- ============================================================

-- 1. TABELA: planos_trabalho
ALTER TABLE public.planos_trabalho ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Insert owns plan"
ON public.planos_trabalho FOR INSERT
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "View own plans"
ON public.planos_trabalho FOR SELECT
USING (auth.uid() = created_by);

CREATE POLICY "Update own plans"
ON public.planos_trabalho FOR UPDATE
USING (auth.uid() = created_by)
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Delete own plans"
ON public.planos_trabalho FOR DELETE
USING (auth.uid() = created_by);

-- 2. TABELA: acoes_servicos
ALTER TABLE public.acoes_servicos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Insert plan actions"
ON public.acoes_servicos FOR INSERT
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "View plan actions"
ON public.acoes_servicos FOR SELECT
USING (auth.uid() = created_by);

-- 3. TABELA: metas_qualitativas
ALTER TABLE public.metas_qualitativas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Insert metas"
ON public.metas_qualitativas FOR INSERT
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "View metas"
ON public.metas_qualitativas FOR SELECT
USING (auth.uid() = created_by);

-- 4. TABELA: naturezas_despesa_plano
ALTER TABLE public.naturezas_despesa_plano ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Insert expenses"
ON public.naturezas_despesa_plano FOR INSERT
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "View expenses"
ON public.naturezas_despesa_plano FOR SELECT
USING (auth.uid() = created_by);

-- ============================================================
-- VERIFICAÇÃO FINAL
-- ============================================================
SELECT 
  schemaname,
  tablename,
  policyname
FROM pg_policies 
WHERE schemaname = 'public' 
ORDER BY tablename, policyname;
