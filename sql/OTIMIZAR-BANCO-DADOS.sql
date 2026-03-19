-- =============================================================
-- OTIMIZAÇÃO COMPLETA DO BANCO DE DADOS
-- Execute este script no Supabase SQL Editor
-- Banco atual: 28.91 MB / 500 MB (Free Plan)
-- =============================================================

-- ============================================================
-- ETAPA 1: DIAGNÓSTICO - Ver quanto espaço cada tabela usa
-- ============================================================
SELECT 
  schemaname,
  relname AS tabela,
  pg_size_pretty(pg_total_relation_size(schemaname || '.' || relname)) AS tamanho_total,
  pg_size_pretty(pg_relation_size(schemaname || '.' || relname)) AS tamanho_dados,
  pg_size_pretty(pg_total_relation_size(schemaname || '.' || relname) - pg_relation_size(schemaname || '.' || relname)) AS tamanho_indices,
  n_live_tup AS linhas_ativas,
  n_dead_tup AS linhas_mortas
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname || '.' || relname) DESC;

-- ============================================================
-- ETAPA 2: CONTAR DUPLICATAS (antes de limpar)
-- ============================================================

-- Duplicatas em acoes_servicos
SELECT 'acoes_servicos' AS tabela, COUNT(*) AS duplicatas FROM (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY plano_id, categoria, item ORDER BY created_at DESC NULLS LAST, id DESC) as rn
    FROM public.acoes_servicos
  ) sub WHERE rn > 1
) dups;

-- Duplicatas em metas_qualitativas
SELECT 'metas_qualitativas' AS tabela, COUNT(*) AS duplicatas FROM (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY plano_id, meta_descricao ORDER BY created_at DESC NULLS LAST, id DESC) as rn
    FROM public.metas_qualitativas
    WHERE meta_descricao IS NOT NULL AND meta_descricao != ''
  ) sub WHERE rn > 1
) dups;

-- Duplicatas em naturezas_despesa_plano
SELECT 'naturezas_despesa_plano' AS tabela, COUNT(*) AS duplicatas FROM (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY plano_id, codigo ORDER BY created_at DESC NULLS LAST, id DESC) as rn
    FROM public.naturezas_despesa_plano
    WHERE codigo IS NOT NULL AND codigo != ''
  ) sub WHERE rn > 1
) dups;

-- ============================================================
-- ETAPA 3: LIMPAR DUPLICATAS (manter o mais recente de cada)
-- ============================================================

-- 3a. Limpar acoes_servicos duplicadas
DELETE FROM public.acoes_servicos
WHERE id IN (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY plano_id, categoria, item ORDER BY created_at DESC NULLS LAST, id DESC) as rn
    FROM public.acoes_servicos
  ) sub WHERE rn > 1
);

-- 3b. Limpar metas_qualitativas duplicadas
DELETE FROM public.metas_qualitativas
WHERE id IN (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY plano_id, meta_descricao ORDER BY created_at DESC NULLS LAST, id DESC) as rn
    FROM public.metas_qualitativas
    WHERE meta_descricao IS NOT NULL AND meta_descricao != ''
  ) sub WHERE rn > 1
);

-- 3c. Limpar naturezas_despesa_plano duplicadas  
DELETE FROM public.naturezas_despesa_plano
WHERE id IN (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY plano_id, codigo ORDER BY created_at DESC NULLS LAST, id DESC) as rn
    FROM public.naturezas_despesa_plano
    WHERE codigo IS NOT NULL AND codigo != ''
  ) sub WHERE rn > 1
);

-- ============================================================
-- ETAPA 4: CRIAR FUNÇÃO RPC PARA DELETE+INSERT ATÔMICO
-- (Resolve o problema de RLS que impede DELETE do frontend)
-- ============================================================

CREATE OR REPLACE FUNCTION public.replace_plano_children(
  p_plano_id UUID,
  p_acoes JSONB DEFAULT '[]'::JSONB,
  p_metas_qual JSONB DEFAULT '[]'::JSONB,
  p_naturezas JSONB DEFAULT '[]'::JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSONB;
  acoes_count INT := 0;
  metas_count INT := 0;
  nat_count INT := 0;
BEGIN
  -- Verificar que o plano existe
  IF NOT EXISTS (SELECT 1 FROM planos_trabalho WHERE id = p_plano_id) THEN
    RAISE EXCEPTION 'Plano não encontrado: %', p_plano_id;
  END IF;

  -- DELETE antigos (SECURITY DEFINER bypassa RLS)
  DELETE FROM public.acoes_servicos WHERE plano_id = p_plano_id;
  DELETE FROM public.metas_qualitativas WHERE plano_id = p_plano_id;
  DELETE FROM public.naturezas_despesa_plano WHERE plano_id = p_plano_id;

  -- INSERT novos - Ações/Serviços
  IF jsonb_array_length(p_acoes) > 0 THEN
    INSERT INTO public.acoes_servicos (plano_id, categoria, item, meta, valor, created_by)
    SELECT 
      p_plano_id,
      (elem->>'categoria')::TEXT,
      (elem->>'item')::TEXT,
      (elem->>'meta')::TEXT,
      (elem->>'valor')::NUMERIC,
      (elem->>'created_by')::UUID
    FROM jsonb_array_elements(p_acoes) AS elem;
    GET DIAGNOSTICS acoes_count = ROW_COUNT;
  END IF;

  -- INSERT novos - Metas Qualitativas
  IF jsonb_array_length(p_metas_qual) > 0 THEN
    INSERT INTO public.metas_qualitativas (plano_id, meta_descricao, indicador, created_by)
    SELECT 
      p_plano_id,
      (elem->>'meta_descricao')::TEXT,
      (elem->>'indicador')::TEXT,
      (elem->>'created_by')::UUID
    FROM jsonb_array_elements(p_metas_qual) AS elem;
    GET DIAGNOSTICS metas_count = ROW_COUNT;
  END IF;

  -- INSERT novos - Naturezas de Despesa
  IF jsonb_array_length(p_naturezas) > 0 THEN
    INSERT INTO public.naturezas_despesa_plano (plano_id, codigo, valor, created_by)
    SELECT 
      p_plano_id,
      (elem->>'codigo')::TEXT,
      (elem->>'valor')::NUMERIC,
      (elem->>'created_by')::UUID
    FROM jsonb_array_elements(p_naturezas) AS elem;
    GET DIAGNOSTICS nat_count = ROW_COUNT;
  END IF;

  result := jsonb_build_object(
    'success', true,
    'acoes_inseridas', acoes_count,
    'metas_inseridas', metas_count,
    'naturezas_inseridas', nat_count
  );

  RETURN result;
END;
$$;

-- Permissão para usuários autenticados chamarem a função
GRANT EXECUTE ON FUNCTION public.replace_plano_children TO authenticated;

-- ============================================================
-- ETAPA 5: RECUPERAR ESPAÇO
-- ============================================================
-- NOTA: VACUUM não pode rodar no SQL Editor do Supabase (roda em transaction).
-- O Supabase executa VACUUM automaticamente (autovacuum).
-- O espaço das linhas deletadas será recuperado automaticamente
-- em alguns minutos pelo autovacuum do PostgreSQL.

-- ============================================================
-- ETAPA 6: VERIFICAÇÃO FINAL
-- ============================================================
SELECT 
  schemaname,
  relname AS tabela,
  pg_size_pretty(pg_total_relation_size(schemaname || '.' || relname)) AS tamanho_total,
  n_live_tup AS linhas_ativas,
  n_dead_tup AS linhas_mortas
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname || '.' || relname) DESC;

SELECT 'Otimização concluída! Execute novamente o diagnóstico após alguns minutos para ver o espaço recuperado.' AS status;
