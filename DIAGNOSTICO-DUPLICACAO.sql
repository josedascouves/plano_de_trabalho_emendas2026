-- ============================================================================
-- DIAGNÓSTICO: Verificar Duplicação de Dados
-- ============================================================================

-- PASSO 1: Listar TODOS os planos com seus valores atuais
SELECT 
  id,
  numero_emenda,
  valor_total,
  created_at,
  updated_at,
  edit_count
FROM public.planos_trabalho
ORDER BY updated_at DESC
LIMIT 5;

-- ============================================================================
-- Para o ÚLTIMO plano (o que você acabou de editar), execute separadamente:
-- ============================================================================

-- Copie o ID do plano acima e cole aqui:
-- Exemplo: '123e4567-e89b-12d3-a456-426614174000'

-- SUBSTITUA 'SEU_PLANO_ID_AQUI' pelo ID real:

-- PASSO 2: Verificar QUANTAS naturezas-despesa tem ESSE plano
SELECT 
  id,
  plano_id,
  codigo,
  valor,
  created_at
FROM public.naturezas_despesa_plano
WHERE plano_id = 'SEU_PLANO_ID_AQUI'
ORDER BY created_at;

-- PASSO 3: Verificar QUANTAS metas-qualitativas tem ESSE plano
SELECT 
  id,
  plano_id,
  meta_descricao,
  indicador,
  created_at
FROM public.metas_qualitativas
WHERE plano_id = 'SEU_PLANO_ID_AQUI'
ORDER BY created_at;

-- PASSO 4: Verificar QUANTAS ações-serviços tem ESSE plano
SELECT 
  id,
  plano_id,
  categoria,
  item,
  valor,
  created_at
FROM public.acoes_servicos
WHERE plano_id = 'SEU_PLANO_ID_AQUI'
ORDER BY created_at;

-- ============================================================================
-- Se encontrar duplicatas, execute isto para limpar:
-- ============================================================================

-- LIMPEZA DE NATUREZAS DUPLICADAS
DELETE FROM public.naturezas_despesa_plano
WHERE plano_id = 'SEU_PLANO_ID_AQUI'
  AND id NOT IN (
    SELECT MIN(id)
    FROM public.naturezas_despesa_plano
    WHERE plano_id = 'SEU_PLANO_ID_AQUI'
    GROUP BY codigo
  );

-- LIMPEZA DE METAS QUALITATIVAS DUPLICADAS
DELETE FROM public.metas_qualitativas
WHERE plano_id = 'SEU_PLANO_ID_AQUI'
  AND id NOT IN (
    SELECT MIN(id)
    FROM public.metas_qualitativas
    WHERE plano_id = 'SEU_PLANO_ID_AQUI'
    GROUP BY meta_descricao, indicador
  );

-- LIMPEZA DE AÇÕES/SERVIÇOS DUPLICADAS
DELETE FROM public.acoes_servicos
WHERE plano_id = 'SEU_PLANO_ID_AQUI'
  AND id NOT IN (
    SELECT MIN(id)
    FROM public.acoes_servicos
    WHERE plano_id = 'SEU_PLANO_ID_AQUI'
    GROUP BY categoria, item
  );
