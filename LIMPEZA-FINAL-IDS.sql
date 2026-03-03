-- ============================================================================
-- LIMPEZA FINAL: DELETAR DUPLICATAS POR ID EXPLICITAMENTE
-- ============================================================================

-- Primeiro, identifique EXATAMENTE quais IDs deletar
WITH duplicatas_identificadas AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (PARTITION BY plano_id, codigo ORDER BY id) as rn
  FROM public.naturezas_despesa_plano
  WHERE codigo IS NOT NULL AND codigo != ''
)
SELECT * FROM duplicatas_identificadas WHERE rn > 1;

-- Se a query acima retornar IDs, copie-os e execute o DELETE abaixo:
-- Exemplo: DELETE FROM public.naturezas_despesa_plano WHERE id IN (151, 152, ...);

-- ============================================================================
-- OU USE ESTE METODO MAIS FORCADO: RECONSTRUIR A TABELA
-- ============================================================================

-- Backup dos dados bons (sem duplicatas)
CREATE TEMP TABLE naturezas_backup AS
SELECT DISTINCT ON (plano_id, codigo) *
FROM public.naturezas_despesa_plano
WHERE codigo IS NOT NULL AND codigo != ''
ORDER BY plano_id, codigo, id;

-- Contar quantos registros ficarão
SELECT COUNT(*) as registros_que_ficarao FROM naturezas_backup;

-- Se o número estiver OK, deletar TODOS de naturezas_despesa_plano
-- DELETE FROM public.naturezas_despesa_plano;

-- Reinsert dos dados bons
-- INSERT INTO public.naturezas_despesa_plano SELECT * FROM naturezas_backup;

-- ============================================================================
-- VERIFICAÇÃO
-- ============================================================================
SELECT id, plano_id, codigo, COUNT(*) as total
FROM public.naturezas_despesa_plano
GROUP BY id, plano_id, codigo
ORDER BY plano_id, codigo;
