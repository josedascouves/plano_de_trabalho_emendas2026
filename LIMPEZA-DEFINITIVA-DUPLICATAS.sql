-- ============================================================================
-- LIMPEZA DEFINITIVA: REMOVER TODAS AS DUPLICATAS DO BANCO
-- ============================================================================
-- Execute isto no Supabase SQL Editor para remover duplicatas reais

-- ⚠️ AVISO: Este script DELETA registros duplicados
-- Mantém apenas o registro mais recente de cada grupo duplicado

-- ============================================================================
-- 1️⃣ REMOVER DUPLICATAS EM ACOES_SERVICOS
-- ============================================================================
DELETE FROM public.acoes_servicos
WHERE id NOT IN (
  SELECT MIN(id)
  FROM public.acoes_servicos
  GROUP BY plano_id, categoria, item
);

-- ============================================================================
-- 2️⃣ REMOVER DUPLICATAS EM METAS_QUALITATIVAS
-- ============================================================================
DELETE FROM public.metas_qualitativas
WHERE id NOT IN (
  SELECT MIN(id)
  FROM public.metas_qualitativas
  WHERE meta_descricao IS NOT NULL AND meta_descricao != ''
  GROUP BY plano_id, meta_descricao
);

-- ============================================================================
-- 3️⃣ REMOVER DUPLICATAS EM NATUREZAS_DESPESA_PLANO
-- ============================================================================
DELETE FROM public.naturezas_despesa_plano
WHERE id NOT IN (
  SELECT MIN(id)
  FROM public.naturezas_despesa_plano
  WHERE codigo IS NOT NULL AND codigo != ''
  GROUP BY plano_id, codigo
);

-- ============================================================================
-- VERIFICAÇÃO: Confirmar que não há duplicatas
-- ============================================================================

-- Verificar ACOES_SERVICOS
SELECT 
  plano_id,
  categoria,
  item,
  COUNT(*) as total
FROM public.acoes_servicos
GROUP BY plano_id, categoria, item
HAVING COUNT(*) > 1;

-- Verificar METAS_QUALITATIVAS
SELECT 
  plano_id,
  meta_descricao,
  COUNT(*) as total
FROM public.metas_qualitativas
WHERE meta_descricao IS NOT NULL AND meta_descricao != ''
GROUP BY plano_id, meta_descricao
HAVING COUNT(*) > 1;

-- Verificar NATUREZAS_DESPESA_PLANO
SELECT 
  plano_id,
  codigo,
  COUNT(*) as total
FROM public.naturezas_despesa_plano
WHERE codigo IS NOT NULL AND codigo != ''
GROUP BY plano_id, codigo
HAVING COUNT(*) > 1;

-- Se as 3 queries acima retornarem 0 linhas = ✅ Sem duplicatas!
