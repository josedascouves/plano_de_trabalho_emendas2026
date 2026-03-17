-- ============================================================================
-- LIMPEZA NUCLEAR FINAL: REMOVER DUPLICATAS DO NOVO PLANO
-- ============================================================================
-- Cole o ID do seu plano abaixo:

-- PASSO 1: Limpar Naturezas de Despesa Duplicadas
DELETE FROM public.naturezas_despesa_plano
WHERE plano_id = '2dc3ffe6-8e2d-46a6-92bb-a6775dbcf2bb'
  AND id NOT IN (
    SELECT MIN(id)
    FROM public.naturezas_despesa_plano
    WHERE plano_id = '2dc3ffe6-8e2d-46a6-92bb-a6775dbcf2bb'
    GROUP BY codigo
  );

-- PASSO 2: Limpar Metas Qualitativas Duplicadas
DELETE FROM public.metas_qualitativas
WHERE plano_id = '2dc3ffe6-8e2d-46a6-92bb-a6775dbcf2bb'
  AND id NOT IN (
    SELECT MIN(id)
    FROM public.metas_qualitativas
    WHERE plano_id = '2dc3ffe6-8e2d-46a6-92bb-a6775dbcf2bb'
    GROUP BY meta_descricao, indicador
  );

-- PASSO 3: Limpar Ações/Serviços Duplicadas
DELETE FROM public.acoes_servicos
WHERE plano_id = '2dc3ffe6-8e2d-46a6-92bb-a6775dbcf2bb'
  AND id NOT IN (
    SELECT MIN(id)
    FROM public.acoes_servicos
    WHERE plano_id = '2dc3ffe6-8e2d-46a6-92bb-a6775dbcf2bb'
    GROUP BY categoria, item
  );

-- VERIFICAÇÃO FINAL
SELECT 'naturezas_despesa_plano' as tabela, COUNT(*) as total
FROM public.naturezas_despesa_plano
WHERE plano_id = '2dc3ffe6-8e2d-46a6-92bb-a6775dbcf2bb'
UNION ALL
SELECT 'metas_qualitativas', COUNT(*)
FROM public.metas_qualitativas
WHERE plano_id = '2dc3ffe6-8e2d-46a6-92bb-a6775dbcf2bb'
UNION ALL
SELECT 'acoes_servicos', COUNT(*)
FROM public.acoes_servicos
WHERE plano_id = '2dc3ffe6-8e2d-46a6-92bb-a6775dbcf2bb';
