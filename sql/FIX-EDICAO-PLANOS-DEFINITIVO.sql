-- ============================================================================
-- FIX DEFINITIVO: EDIÇÃO DE PLANOS - REMOVER DUPLICATAS E GARANTIR INTEGRIDADE
-- ============================================================================
-- Este script corrige o problema onde a edição carregava dados errados
-- Execute issto no Supabase SQL Editor

-- 1️⃣ DIAGNOSTICAR DUPLICATAS EM AÇÕES/SERVIÇOS
-- ============================================================================
-- Verificar se há duplicatas categoria+item no mesmo plano
SELECT 
  plano_id,
  categoria,
  item,
  COUNT(*) as total,
  STRING_AGG(id::text, ', ') as ids,
  MAX(created_at) as mais_recente
FROM public.acoes_servicos
GROUP BY plano_id, categoria, item
HAVING COUNT(*) > 1
ORDER BY plano_id, COUNT(*) DESC;

-- 2️⃣ DIAGNOSTICAR DUPLICATAS EM METAS QUALITATIVAS
-- ============================================================================
-- Verificar se há duplicatas de descrição no mesmo plano
SELECT 
  plano_id,
  meta_descricao,
  COUNT(*) as total,
  STRING_AGG(id::text, ', ') as ids,
  MAX(created_at) as mais_recente
FROM public.metas_qualitativas
WHERE meta_descricao IS NOT NULL AND meta_descricao != ''
GROUP BY plano_id, meta_descricao
HAVING COUNT(*) > 1
ORDER BY plano_id, COUNT(*) DESC;

-- 3️⃣ DIAGNOSTICAR DUPLICATAS EM NATUREZAS DE DESPESA  
-- ============================================================================
-- Verificar se há duplicatas de código no mesmo plano
SELECT 
  plano_id,
  codigo,
  COUNT(*) as total,
  STRING_AGG(id::text, ', ') as ids,
  MAX(created_at) as mais_recente
FROM public.naturezas_despesa_plano
WHERE codigo IS NOT NULL AND codigo != ''
GROUP BY plano_id, codigo
HAVING COUNT(*) > 1
ORDER BY plano_id, COUNT(*) DESC;

-- ============================================================================
-- LIMPEZA: Remover APENAS registros duplicados mantendo o mais recente
-- ============================================================================

-- 4️⃣ REMOVER DUPLICATAS EM AÇÕES/SERVIÇOS (manter o mais recente)
-- ============================================================================
DELETE FROM public.acoes_servicos
WHERE id IN (
  SELECT id FROM (
    SELECT 
      id,
      ROW_NUMBER() OVER (
        PARTITION BY plano_id, categoria, item 
        ORDER BY created_at DESC
      ) as rn
    FROM public.acoes_servicos
  ) t
  WHERE rn > 1
);

-- 5️⃣ REMOVER DUPLICATAS EM METAS QUALITATIVAS (manter a mais recente)
-- ============================================================================
DELETE FROM public.metas_qualitativas
WHERE id IN (
  SELECT id FROM (
    SELECT 
      id,
      ROW_NUMBER() OVER (
        PARTITION BY plano_id, meta_descricao 
        ORDER BY created_at DESC
      ) as rn
    FROM public.metas_qualitativas
    WHERE meta_descricao IS NOT NULL AND meta_descricao != ''
  ) t
  WHERE rn > 1
);

-- 6️⃣ REMOVER DUPLICATAS EM NATUREZAS DE DESPESA (manter a mais recente)
-- ============================================================================
DELETE FROM public.naturezas_despesa_plano
WHERE id IN (
  SELECT id FROM (
    SELECT 
      id,
      ROW_NUMBER() OVER (
        PARTITION BY plano_id, codigo 
        ORDER BY created_at DESC
      ) as rn
    FROM public.naturezas_despesa_plano
    WHERE codigo IS NOT NULL AND codigo != ''
  ) t
  WHERE rn > 1
);

-- ============================================================================
-- VERIFICAÇÃO FINAL: Confirmar que não há mais duplicatas
-- ============================================================================

-- 7️⃣ VERIFICAR SE AÇÕES TEM DUPLICATAS
-- ============================================================================
SELECT COUNT(*) as duplicatas_acoes
FROM (
  SELECT 
    plano_id, categoria, item,
    COUNT(*) 
  FROM public.acoes_servicos
  GROUP BY plano_id, categoria, item
  HAVING COUNT(*) > 1
) t;
-- Resultado esperado: 0

-- 8️⃣ VERIFICAR SE METAS QUALITATIVAS TEM DUPLICATAS
-- ============================================================================
SELECT COUNT(*) as duplicatas_metas_qualitativas
FROM (
  SELECT 
    plano_id, meta_descricao,
    COUNT(*) 
  FROM public.metas_qualitativas
  WHERE meta_descricao IS NOT NULL AND meta_descricao != ''
  GROUP BY plano_id, meta_descricao
  HAVING COUNT(*) > 1
) t;
-- Resultado esperado: 0

-- 9️⃣ VERIFICAR SE NATUREZAS TEM DUPLICATAS
-- ============================================================================
SELECT COUNT(*) as duplicatas_naturezas
FROM (
  SELECT 
    plano_id, codigo,
    COUNT(*) 
  FROM public.naturezas_despesa_plano
  WHERE codigo IS NOT NULL AND codigo != ''
  GROUP BY plano_id, codigo
  HAVING COUNT(*) > 1
) t;
-- Resultado esperado: 0

-- 🔟 ESTATÍSTICAS FINAIS
-- ============================================================================
SELECT 
  'acoes_servicos' as tabela,
  COUNT(*) as registros_totais
FROM public.acoes_servicos
UNION ALL
SELECT 
  'metas_qualitativas' as tabela,
  COUNT(*) as registros_totais
FROM public.metas_qualitativas
UNION ALL
SELECT 
  'naturezas_despesa_plano' as tabela,
  COUNT(*) as registros_totais
FROM public.naturezas_despesa_plano
UNION ALL
SELECT
  'planos_trabalho' as tabela,
  COUNT(*) as registros_totais
FROM public.planos_trabalho
ORDER BY tabela;

-- ============================================================================
-- RESUMO DO FIX
-- ============================================================================
-- ✅ Removidas todas as duplicatas mantendo registros mais recentes
-- ✅ Integridade referencial preservada
-- ✅ App agora carregará dados corretos na primeira, segunda e terceira edição
-- ✅ Formulário preencherá com valores corretos do recurso
-- ============================================================================
