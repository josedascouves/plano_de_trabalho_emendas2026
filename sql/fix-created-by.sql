-- ========================================
-- ADICIONAR COLUNA created_by NAS SUBTABELAS
-- ========================================

-- 1. Adicionar coluna created_by em acoes_servicos
ALTER TABLE public.acoes_servicos
ADD COLUMN created_by UUID REFERENCES auth.users,
ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();

-- 2. Adicionar coluna created_by em metas_qualitativas
ALTER TABLE public.metas_qualitativas
ADD COLUMN created_by UUID REFERENCES auth.users,
ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();

-- 3. Adicionar coluna created_by em naturezas_despesa_plano
ALTER TABLE public.naturezas_despesa_plano
ADD COLUMN created_by UUID REFERENCES auth.users,
ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();

-- ========================================
-- REMOVER TODAS AS POLÍTICAS ANTIGAS
-- ========================================

-- Remover políticas de acoes_servicos
DROP POLICY IF EXISTS "Aceso metas quant via dono/admin" ON public.acoes_servicos;
DROP POLICY IF EXISTS "Acesso metas quant via dono/admin" ON public.acoes_servicos;
DROP POLICY IF EXISTS "Acoes INSERT para autenticados" ON public.acoes_servicos;
DROP POLICY IF EXISTS "Acoes SELECT dono/admin" ON public.acoes_servicos;
DROP POLICY IF EXISTS "Acoes UPDATE dono/admin" ON public.acoes_servicos;
DROP POLICY IF EXISTS "Acoes DELETE dono/admin" ON public.acoes_servicos;

-- Remover políticas de metas_qualitativas
DROP POLICY IF EXISTS "Acesso metas qual via dono/admin" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "Qualitativas INSERT para autenticados" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "Qualitativas SELECT dono/admin" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "Qualitativas UPDATE dono/admin" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "Qualitativas DELETE dono/admin" ON public.metas_qualitativas;

-- Remover políticas de naturezas_despesa_plano
DROP POLICY IF EXISTS "Acesso naturezas via dono/admin" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "Naturezas INSERT para autenticados" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "Naturezas SELECT dono/admin" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "Naturezas UPDATE dono/admin" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "Naturezas DELETE dono/admin" ON public.naturezas_despesa_plano;

-- Remover políticas de planos_trabalho
DROP POLICY IF EXISTS "Usuários veem próprios planos ou admins todos" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Usuários inserem próprios planos" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Planos INSERT para autenticados" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Planos SELECT dono/admin" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Planos UPDATE dono/admin" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Planos DELETE dono/admin" ON public.planos_trabalho;

-- ========================================
-- DESABILITAR E REABILITAR RLS
-- ========================================

ALTER TABLE public.planos_trabalho DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.acoes_servicos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.metas_qualitativas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.naturezas_despesa_plano DISABLE ROW LEVEL SECURITY;

ALTER TABLE public.planos_trabalho ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.acoes_servicos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.metas_qualitativas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.naturezas_despesa_plano ENABLE ROW LEVEL SECURITY;

-- ========================================
-- CRIAR POLÍTICAS SIMPLES E FUNCIONAIS
-- ========================================

-- PLANOS DE TRABALHO
CREATE POLICY "Planos SELECT" ON public.planos_trabalho FOR SELECT
USING (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

CREATE POLICY "Planos INSERT" ON public.planos_trabalho FOR INSERT
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Planos UPDATE" ON public.planos_trabalho FOR UPDATE
USING (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin')
WITH CHECK (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

CREATE POLICY "Planos DELETE" ON public.planos_trabalho FOR DELETE
USING (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

-- AÇÕES E SERVIÇOS (Metas Quantitativas)
CREATE POLICY "Acoes SELECT" ON public.acoes_servicos FOR SELECT
USING (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

CREATE POLICY "Acoes INSERT" ON public.acoes_servicos FOR INSERT
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Acoes UPDATE" ON public.acoes_servicos FOR UPDATE
USING (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin')
WITH CHECK (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

CREATE POLICY "Acoes DELETE" ON public.acoes_servicos FOR DELETE
USING (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

-- METAS QUALITATIVAS
CREATE POLICY "Qualitativas SELECT" ON public.metas_qualitativas FOR SELECT
USING (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

CREATE POLICY "Qualitativas INSERT" ON public.metas_qualitativas FOR INSERT
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Qualitativas UPDATE" ON public.metas_qualitativas FOR UPDATE
USING (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin')
WITH CHECK (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

CREATE POLICY "Qualitativas DELETE" ON public.metas_qualitativas FOR DELETE
USING (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

-- NATUREZAS DE DESPESA
CREATE POLICY "Naturezas SELECT" ON public.naturezas_despesa_plano FOR SELECT
USING (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

CREATE POLICY "Naturezas INSERT" ON public.naturezas_despesa_plano FOR INSERT
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Naturezas UPDATE" ON public.naturezas_despesa_plano FOR UPDATE
USING (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin')
WITH CHECK (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

CREATE POLICY "Naturezas DELETE" ON public.naturezas_despesa_plano FOR DELETE
USING (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

-- ========================================
-- PRONTO!
-- ========================================
-- Agora você pode fazer login e salvar planos com sucesso
