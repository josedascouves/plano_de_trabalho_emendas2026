-- ============================================================================
-- LIMPEZA NUCLEAR: DELETA TODOS OS DUPLICATAS EXPLICITAMENTE
-- ============================================================================

-- 1️⃣ DELETAR TODOS OS DUPLICATAS EM NATUREZAS_DESPESA_PLANO
-- Mantém apenas o id MAIS BAIXO de cada grupo

DELETE FROM public.naturezas_despesa_plano ndp1
WHERE id != (
  SELECT MIN(id)
  FROM public.naturezas_despesa_plano ndp2
  WHERE ndp2.plano_id = ndp1.plano_id 
    AND ndp2.codigo = ndp1.codigo
    AND ndp2.codigo IS NOT NULL
    AND ndp2.codigo != ''
);

-- 2️⃣ DELETAR TODOS OS DUPLICATAS EM ACOES_SERVICOS

DELETE FROM public.acoes_servicos ac1
WHERE id != (
  SELECT MIN(id)
  FROM public.acoes_servicos ac2
  WHERE ac2.plano_id = ac1.plano_id 
    AND ac2.categoria = ac1.categoria 
    AND ac2.item = ac1.item
);

-- 3️⃣ DELETAR TODOS OS DUPLICATAS EM METAS_QUALITATIVAS

DELETE FROM public.metas_qualitativas mq1
WHERE id != (
  SELECT MIN(id)
  FROM public.metas_qualitativas mq2
  WHERE mq2.plano_id = mq1.plano_id 
    AND mq2.meta_descricao = mq1.meta_descricao
    AND mq2.meta_descricao IS NOT NULL
    AND mq2.meta_descricao != ''
);

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

-- Verificar NATUREZAS_DESPESA_PLANO
SELECT plano_id, codigo, COUNT(*) as total
FROM public.naturezas_despesa_plano
WHERE codigo IS NOT NULL AND codigo != ''
GROUP BY plano_id, codigo
HAVING COUNT(*) > 1
ORDER BY total DESC;

-- Verificar ACOES_SERVICOS
SELECT plano_id, categoria, item, COUNT(*) as total
FROM public.acoes_servicos
GROUP BY plano_id, categoria, item
HAVING COUNT(*) > 1
ORDER BY total DESC;

-- Verificar METAS_QUALITATIVAS
SELECT plano_id, meta_descricao, COUNT(*) as total
FROM public.metas_qualitativas
WHERE meta_descricao IS NOT NULL AND meta_descricao != ''
GROUP BY plano_id, meta_descricao
HAVING COUNT(*) > 1
ORDER BY total DESC;

-- ✅ Se retornar 0 linhas em TODAS, problema resolvido!
