-- ==========================================
-- CORREÇÃO DE POLÍTICAS RLS
-- ==========================================
-- Execute este script no Supabase SQL Editor para corrigir os erros de RLS

-- PASSO 1: Remover políticas antigas problemáticas
DROP POLICY IF EXISTS "Acesso metas quant via dono/admin" ON public.acoes_servicos;
DROP POLICY IF EXISTS "Acesso metas qual via dono/admin" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "Acesso naturezas via dono/admin" ON public.naturezas_despesa_plano;

-- PASSO 2: Criar novas políticas para Sub-tabelas com acesso direto para autenticados

-- ========== ACÕES E SERVIÇOS (Metas Quantitativas) ==========
CREATE POLICY "INSERT acoes_servicos para autenticados" ON public.acoes_servicos FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = acoes_servicos.plano_id AND created_by = auth.uid()
  )
);

CREATE POLICY "SELECT acoes_servicos para dono/admin" ON public.acoes_servicos FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = acoes_servicos.plano_id AND (
      created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

CREATE POLICY "UPDATE acoes_servicos para dono/admin" ON public.acoes_servicos FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = acoes_servicos.plano_id AND (
      created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = acoes_servicos.plano_id AND (
      created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

CREATE POLICY "DELETE acoes_servicos para dono/admin" ON public.acoes_servicos FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = acoes_servicos.plano_id AND (
      created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

-- ========== METAS QUALITATIVAS ==========
CREATE POLICY "INSERT metas_qualitativas para autenticados" ON public.metas_qualitativas FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = metas_qualitativas.plano_id AND created_by = auth.uid()
  )
);

CREATE POLICY "SELECT metas_qualitativas para dono/admin" ON public.metas_qualitativas FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = metas_qualitativas.plano_id AND (
      created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

CREATE POLICY "UPDATE metas_qualitativas para dono/admin" ON public.metas_qualitativas FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = metas_qualitativas.plano_id AND (
      created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = metas_qualitativas.plano_id AND (
      created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

CREATE POLICY "DELETE metas_qualitativas para dono/admin" ON public.metas_qualitativas FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = metas_qualitativas.plano_id AND (
      created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

-- ========== NATUREZAS DE DESPESA ==========
CREATE POLICY "INSERT naturezas_despesa_plano para autenticados" ON public.naturezas_despesa_plano FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = naturezas_despesa_plano.plano_id AND created_by = auth.uid()
  )
);

CREATE POLICY "SELECT naturezas_despesa_plano para dono/admin" ON public.naturezas_despesa_plano FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = naturezas_despesa_plano.plano_id AND (
      created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

CREATE POLICY "UPDATE naturezas_despesa_plano para dono/admin" ON public.naturezas_despesa_plano FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = naturezas_despesa_plano.plano_id AND (
      created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = naturezas_despesa_plano.plano_id AND (
      created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

CREATE POLICY "DELETE naturezas_despesa_plano para dono/admin" ON public.naturezas_despesa_plano FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.planos_trabalho 
    WHERE id = naturezas_despesa_plano.plano_id AND (
      created_by = auth.uid() OR 
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
  )
);

-- FIM DA CORREÇÃO RLS
-- As tabelas agora permitirão inserts de usuários autenticados em suas tabelas associadas
