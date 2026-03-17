-- ============================================================================
-- LIMPEZA AGRESSIVA: REMOVE DUPLICATAS MANTENDO APENAS O ID MAIS BAIXO
-- ============================================================================
-- Use isto se o script anterior não funcionou

-- ⚠️ CUIDADO: Este script DELETA registros
-- Mantém apenas 1 de cada duplicata (o com menor ID)

-- ============================================================================
-- 1️⃣ LIMPAR NATUREZAS_DESPESA_PLANO - O PRINCIPAL CULPADO
-- ============================================================================

-- Identificar e deletar duplicatas
DELETE FROM public.naturezas_despesa_plano
WHERE id IN (
  SELECT id
  FROM (
    SELECT 
      id,
      ROW_NUMBER() OVER (PARTITION BY plano_id, codigo ORDER BY id) as rn
    FROM public.naturezas_despesa_plano
    WHERE codigo IS NOT NULL AND codigo != ''
  ) subquery
  WHERE rn > 1
);

-- ============================================================================
-- 2️⃣ LIMPAR ACOES_SERVICOS
-- ============================================================================

DELETE FROM public.acoes_servicos
WHERE id IN (
  SELECT id
  FROM (
    SELECT 
      id,
      ROW_NUMBER() OVER (PARTITION BY plano_id, categoria, item ORDER BY id) as rn
    FROM public.acoes_servicos
  ) subquery
  WHERE rn > 1
);

-- ============================================================================
-- 3️⃣ LIMPAR METAS_QUALITATIVAS
-- ============================================================================

DELETE FROM public.metas_qualitativas
WHERE id IN (
  SELECT id
  FROM (
    SELECT 
      id,
      ROW_NUMBER() OVER (PARTITION BY plano_id, meta_descricao ORDER BY id) as rn
    FROM public.metas_qualitativas
    WHERE meta_descricao IS NOT NULL AND meta_descricao != ''
  ) subquery
  WHERE rn > 1
);

-- ============================================================================
-- VERIFICAÇÃO: Confirmar limpeza
-- ============================================================================

-- Verificar NATUREZAS_DESPESA_PLANO
SELECT plano_id, codigo, COUNT(*) as total
FROM public.naturezas_despesa_plano
WHERE codigo IS NOT NULL AND codigo != ''
GROUP BY plano_id, codigo
HAVING COUNT(*) > 1;

-- Verificar ACOES_SERVICOS
SELECT plano_id, categoria, item, COUNT(*) as total
FROM public.acoes_servicos
GROUP BY plano_id, categoria, item
HAVING COUNT(*) > 1;

-- Verificar METAS_QUALITATIVAS
SELECT plano_id, meta_descricao, COUNT(*) as total
FROM public.metas_qualitativas
WHERE meta_descricao IS NOT NULL AND meta_descricao != ''
GROUP BY plano_id, meta_descricao
HAVING COUNT(*) > 1;

-- Se as 3 queries retornarem 0 linhas = ✅ LIMPEZA COMPLETA!
