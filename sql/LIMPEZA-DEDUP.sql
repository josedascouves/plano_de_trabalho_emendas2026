-- ============================================================================
-- LIMPEZA DE DUPLICATAS: Manter APENAS o registro mais recente de cada tipo
-- ============================================================================
-- Este script remove duplicatas mantendo apenas o registro mais recente
-- (baseado em created_at) para cada plano

-- PASSO 1: Para CADA PLANO, deletar ações duplicadas (manter só a última)
DELETE FROM public.acoes_servicos
WHERE id NOT IN (
  SELECT DISTINCT ON (plano_id) id
  FROM public.acoes_servicos
  ORDER BY plano_id, created_at DESC
);

-- PASSO 2: Para CADA PLANO, deletar metas_qualitativas duplicadas (manter só a última)
DELETE FROM public.metas_qualitativas
WHERE id NOT IN (
  SELECT DISTINCT ON (plano_id) id
  FROM public.metas_qualitativas
  ORDER BY plano_id, created_at DESC
);

-- PASSO 3: Para CADA PLANO, deletar naturezas_despesa_plano duplicadas (manter só a última)
DELETE FROM public.naturezas_despesa_plano
WHERE id NOT IN (
  SELECT DISTINCT ON (plano_id) id
  FROM public.naturezas_despesa_plano
  ORDER BY plano_id, created_at DESC
);

-- ============================================================================
-- PASSO 4: Verificar resultado
-- ============================================================================
SELECT 
  p.id,
  p.numero_emenda,
  COUNT(DISTINCT n.id) as naturezas_count,
  COUNT(DISTINCT m.id) as metas_count,
  COUNT(DISTINCT a.id) as acoes_count
FROM public.planos_trabalho p
LEFT JOIN public.naturezas_despesa_plano n ON p.id = n.plano_id
LEFT JOIN public.metas_qualitativas m ON p.id = m.plano_id
LEFT JOIN public.acoes_servicos a ON p.id = a.plano_id
GROUP BY p.id, p.numero_emenda
ORDER BY p.updated_at DESC;
