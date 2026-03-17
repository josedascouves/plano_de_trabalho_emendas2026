-- ============================================================================
-- LIMPEZA NUCLEAR: Remover TODOS os dados órfãos/duplicados
-- ============================================================================

-- PASSO 1: Listar planos com seus dados para verificar situação
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
ORDER BY p.updated_at DESC
LIMIT 10;

-- ============================================================================
-- PASSO 2: Para CADA plano que tem duplicatas, executar sua limpeza
-- ============================================================================

-- OPÇÃO A: Deletar manualmente usando ID específico
-- Copie este padrão para cada plano problemático:
/*
DELETE FROM naturezas_despesa_plano WHERE plano_id = 'SEU_PLANO_ID_AQUI';
DELETE FROM metas_qualitativas WHERE plano_id = 'SEU_PLANO_ID_AQUI';
DELETE FROM acoes_servicos WHERE plano_id = 'SEU_PLANO_ID_AQUI';
*/

-- OPÇÃO B: Delete em cascata com truncate (NUCLEAR - remove TUDO)
-- ⚠️ CUIDADO! Isso remove TODOS os planos!
/*
TRUNCATE TABLE naturezas_despesa_plano CASCADE;
TRUNCATE TABLE metas_qualitativas CASCADE;
TRUNCATE TABLE acoes_servicos CASCADE;
TRUNCATE TABLE planos_trabalho CASCADE;
*/

-- ============================================================================
-- PASSO 3: Verificar após limpeza
-- ============================================================================

SELECT 'naturezas_despesa_plano' as tabela, COUNT(*) as total FROM public.naturezas_despesa_plano
UNION ALL
SELECT 'metas_qualitativas', COUNT(*) FROM public.metas_qualitativas
UNION ALL
SELECT 'acoes_servicos', COUNT(*) FROM public.acoes_servicos
UNION ALL
SELECT 'planos_trabalho', COUNT(*) FROM public.planos_trabalho;
