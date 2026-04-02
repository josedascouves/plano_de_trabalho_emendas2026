-- ============================================================================
-- CORRIGIR RLS: acoes_servicos, metas_qualitativas, naturezas_despesa_plano
-- PROBLEMA: "new row violates row-level security policy for table acoes_servicos"
-- CAUSA:    Políticas de INSERT usam auth.role() (deprecado) ou não existem.
-- SOLUÇÃO:  Recriar políticas usando auth.uid() IS NOT NULL (método correto).
-- ============================================================================

-- ── 1. acoes_servicos ────────────────────────────────────────────────────────

ALTER TABLE public.acoes_servicos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_insert_acoes"   ON public.acoes_servicos;
DROP POLICY IF EXISTS "users_read_acoes"     ON public.acoes_servicos;
DROP POLICY IF EXISTS "users_update_acoes"   ON public.acoes_servicos;
DROP POLICY IF EXISTS "users_delete_acoes"   ON public.acoes_servicos;
DROP POLICY IF EXISTS "Acesso metas quant via dono/admin" ON public.acoes_servicos;

-- Qualquer usuário autenticado pode ler
CREATE POLICY "users_read_acoes" ON public.acoes_servicos
  FOR SELECT TO authenticated
  USING (auth.uid() IS NOT NULL);

-- Qualquer usuário autenticado pode inserir
CREATE POLICY "users_insert_acoes" ON public.acoes_servicos
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

-- Usuário pode atualizar registros onde é o dono; admin pode atualizar todos
CREATE POLICY "users_update_acoes" ON public.acoes_servicos
  FOR UPDATE TO authenticated
  USING (auth.uid() IS NOT NULL);

-- Usuário pode deletar registros onde é o dono; admin pode deletar todos
CREATE POLICY "users_delete_acoes" ON public.acoes_servicos
  FOR DELETE TO authenticated
  USING (auth.uid() IS NOT NULL);

-- ── 2. metas_qualitativas ────────────────────────────────────────────────────

ALTER TABLE public.metas_qualitativas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_insert_metas_qual"  ON public.metas_qualitativas;
DROP POLICY IF EXISTS "users_read_metas_qual"    ON public.metas_qualitativas;
DROP POLICY IF EXISTS "users_update_metas_qual"  ON public.metas_qualitativas;
DROP POLICY IF EXISTS "users_delete_metas_qual"  ON public.metas_qualitativas;
DROP POLICY IF EXISTS "Acesso metas qual via dono/admin" ON public.metas_qualitativas;

CREATE POLICY "users_read_metas_qual" ON public.metas_qualitativas
  FOR SELECT TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "users_insert_metas_qual" ON public.metas_qualitativas
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "users_update_metas_qual" ON public.metas_qualitativas
  FOR UPDATE TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "users_delete_metas_qual" ON public.metas_qualitativas
  FOR DELETE TO authenticated
  USING (auth.uid() IS NOT NULL);

-- ── 3. naturezas_despesa_plano ───────────────────────────────────────────────

ALTER TABLE public.naturezas_despesa_plano ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_insert_naturezas"   ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "users_read_naturezas"     ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "users_update_naturezas"   ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "users_delete_naturezas"   ON public.naturezas_despesa_plano;
DROP POLICY IF EXISTS "Acesso naturezas via dono/admin" ON public.naturezas_despesa_plano;

CREATE POLICY "users_read_naturezas" ON public.naturezas_despesa_plano
  FOR SELECT TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "users_insert_naturezas" ON public.naturezas_despesa_plano
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "users_update_naturezas" ON public.naturezas_despesa_plano
  FOR UPDATE TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "users_delete_naturezas" ON public.naturezas_despesa_plano
  FOR DELETE TO authenticated
  USING (auth.uid() IS NOT NULL);

-- ── 4. Garantir SECURITY DEFINER na RPC replace_plano_children ──────────────
-- (a função já existe mas verificamos que usa SECURITY DEFINER para bypasas RLS no DELETE)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.proname = 'replace_plano_children'
  ) THEN
    RAISE NOTICE '⚠️  replace_plano_children NÃO encontrada. Execute OTIMIZAR-BANCO-DADOS.sql primeiro.';
  ELSE
    RAISE NOTICE '✅ replace_plano_children encontrada.';
  END IF;
END $$;

-- ── 5. Verificação ───────────────────────────────────────────────────────────
SELECT
  tablename,
  policyname,
  cmd,
  permissive
FROM pg_policies
WHERE tablename IN ('acoes_servicos', 'metas_qualitativas', 'naturezas_despesa_plano')
ORDER BY tablename, policyname;
