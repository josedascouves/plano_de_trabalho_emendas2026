-- =========================================
-- SCRIPT COMPLETO DE RESOLUÇÃO RLS
-- =========================================
-- Este script REMOVE TODAS as políticas antigas
-- e reconstrói as políticas corretamente

-- PASSO 1: REMOVER TODAS AS POLÍTICAS ANTIGAS
-- ==========================================

-- Remover todas as políticas da tabela acoes_servicos
DROP POLICY IF EXISTS "Acesso metas quant via dono/admin" ON public.acoes_servicos;
DROP POLICY IF EXISTS "INSERT acoes_servicos para autenticados" ON public.acoes_servicos;
DROP POLICY IF EXISTS "SELECT acoes_servicos para dono/admin" ON public.acoes_servicos;
DROP POLICY IF EXISTS "UPDATE acoes_servicos para dono/admin" ON public.acoes_servicos;
DROP POLICY IF EXISTS "DELETE acoes_servicos para dono/admin" ON public.acoes_servicos;

-- Remover todas as políticas da tabela metas_qualitativas
DROP POLICY IF EXISTS "Acesso metas qual via dono/admin" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "INSERT metas_qualitativas para autenticados" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "SELECT metas_qualitativas para dono/admin" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "UPDATE metas_qualitativas para dono/admin" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "DELETE metas_qualitativas para dono/admin" ON public.metas_qualitativas;

-- Remover todas as políticas da tabela naturezas_despesa_plano
DROP POLICY IF EXISTS "Acesso naturezas via dono/admin" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "INSERT naturezas_despesa_plano para autenticados" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "SELECT naturezas_despesa_plano para dono/admin" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "UPDATE naturezas_despesa_plano para dono/admin" ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "DELETE naturezas_despesa_plano para dono/admin" ON public.naturezas_despesa_plano;

-- Remover todas as políticas da tabela planos_trabalho
DROP POLICY IF EXISTS "Usuários veem próprios planos ou admins todos" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Usuários inserem próprios planos" ON public.planos_trabalho;
DROP POLICY IF EXISTS "INSERT planos para dono" ON public.planos_trabalho;
DROP POLICY IF EXISTS "SELECT planos para dono/admin" ON public.planos_trabalho;
DROP POLICY IF EXISTS "UPDATE planos para dono/admin" ON public.planos_trabalho;
DROP POLICY IF EXISTS "DELETE planos para dono/admin" ON public.planos_trabalho;

-- Remover políticas de profiles
DROP POLICY IF EXISTS "Profiles visíveis por usuários autenticados" ON public.profiles;
DROP POLICY IF EXISTS "Usuários editam próprio perfil" ON public.profiles;

-- PASSO 2: DESABILITAR E REABILITAR RLS
-- ======================================
ALTER TABLE public.planos_trabalho DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.acoes_servicos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.metas_qualitativas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.naturezas_despesa_plano DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

ALTER TABLE public.planos_trabalho ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.acoes_servicos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.metas_qualitativas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.naturezas_despesa_plano ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- PASSO 3: CRIAR NOVAS POLÍTICAS SIMPLES E FUNCIONAIS
-- ====================================================

-- ===== PROFILES =====
CREATE POLICY "Profiles leitura pública" ON public.profiles FOR SELECT
USING (true);

CREATE POLICY "Profiles edição próprio" ON public.profiles FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- ===== PLANOS DE TRABALHO =====
CREATE POLICY "Planos INSERT para autenticados" ON public.planos_trabalho FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Planos SELECT dono/admin" ON public.planos_trabalho FOR SELECT
USING (
  created_by = auth.uid() OR 
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
);

CREATE POLICY "Planos UPDATE dono/admin" ON public.planos_trabalho FOR UPDATE
USING (
  created_by = auth.uid() OR 
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
)
WITH CHECK (
  created_by = auth.uid() OR 
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
);

CREATE POLICY "Planos DELETE dono/admin" ON public.planos_trabalho FOR DELETE
USING (
  created_by = auth.uid() OR 
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
);

-- ===== AÇÕES E SERVIÇOS =====
CREATE POLICY "Acoes INSERT para autenticados" ON public.acoes_servicos FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Acoes SELECT dono/admin" ON public.acoes_servicos FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho pt
    WHERE pt.id = acoes_servicos.plano_id AND (
      pt.created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

CREATE POLICY "Acoes UPDATE dono/admin" ON public.acoes_servicos FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho pt
    WHERE pt.id = acoes_servicos.plano_id AND (
      pt.created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho pt
    WHERE pt.id = acoes_servicos.plano_id AND (
      pt.created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

CREATE POLICY "Acoes DELETE dono/admin" ON public.acoes_servicos FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho pt
    WHERE pt.id = acoes_servicos.plano_id AND (
      pt.created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

-- ===== METAS QUALITATIVAS =====
CREATE POLICY "Qualitativas INSERT para autenticados" ON public.metas_qualitativas FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Qualitativas SELECT dono/admin" ON public.metas_qualitativas FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho pt
    WHERE pt.id = metas_qualitativas.plano_id AND (
      pt.created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

CREATE POLICY "Qualitativas UPDATE dono/admin" ON public.metas_qualitativas FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho pt
    WHERE pt.id = metas_qualitativas.plano_id AND (
      pt.created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho pt
    WHERE pt.id = metas_qualitativas.plano_id AND (
      pt.created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

CREATE POLICY "Qualitativas DELETE dono/admin" ON public.metas_qualitativas FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho pt
    WHERE pt.id = metas_qualitativas.plano_id AND (
      pt.created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

-- ===== NATUREZAS DE DESPESA =====
CREATE POLICY "Naturezas INSERT para autenticados" ON public.naturezas_despesa_plano FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Naturezas SELECT dono/admin" ON public.naturezas_despesa_plano FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho pt
    WHERE pt.id = naturezas_despesa_plano.plano_id AND (
      pt.created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

CREATE POLICY "Naturezas UPDATE dono/admin" ON public.naturezas_despesa_plano FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho pt
    WHERE pt.id = naturezas_despesa_plano.plano_id AND (
      pt.created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho pt
    WHERE pt.id = naturezas_despesa_plano.plano_id AND (
      pt.created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

CREATE POLICY "Naturezas DELETE dono/admin" ON public.naturezas_despesa_plano FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho pt
    WHERE pt.id = naturezas_despesa_plano.plano_id AND (
      pt.created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

-- ==========================================
-- FIM - TODAS AS POLÍTICAS FORAM RECRIADAS
-- ==========================================
-- Agora tente fazer login e salvar um plano
