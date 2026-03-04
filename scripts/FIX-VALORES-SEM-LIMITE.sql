-- ==============================================================================
-- SCRIPT: REMOVER LIMITE DE VALORES EM TODOS OS CAMPOS MONETÁRIOS
-- ==============================================================================
-- Data: 2026-03-04
-- Objetivo: Aumentar precisão de NUMERIC para aceitar valores ilimitados
-- ==============================================================================

-- 1️⃣ ATUALIZAR planos_trabalho - VALOR TOTAL DA EMENDA
ALTER TABLE public.planos_trabalho
ALTER COLUMN valor_total TYPE NUMERIC(20, 2);

-- 2️⃣ ATUALIZAR acoes_servicos - VALOR DAS METAS QUANTITATIVAS
ALTER TABLE public.acoes_servicos
ALTER COLUMN valor TYPE NUMERIC(20, 2);

-- 3️⃣ ATUALIZAR naturezas_despesa_plano - VALOR DA EXECUÇÃO FINANCEIRA
ALTER TABLE public.naturezas_despesa_plano
ALTER COLUMN valor TYPE NUMERIC(20, 2);

-- ==============================================================================
-- ✅ VERIFICAÇÃO: Confirmar os tipos de dados
-- ==============================================================================

SELECT 
  table_name,
  column_name,
  data_type,
  CASE 
    WHEN numeric_precision IS NOT NULL 
    THEN 'NUMERIC(' || numeric_precision || ',' || numeric_scale || ')'
    ELSE data_type
  END as tipo_completo
FROM information_schema.columns
WHERE (
  (table_name = 'planos_trabalho' AND column_name = 'valor_total')
  OR (table_name = 'acoes_servicos' AND column_name = 'valor')
  OR (table_name = 'naturezas_despesa_plano' AND column_name = 'valor')
)
ORDER BY table_name, column_name;

-- ==============================================================================
-- 📊 TESTE: Verificar se consegue armazenar valores grandes
-- ==============================================================================
-- Exemplo: verificar capacidade máxima (99.999.999.999.999,99)
-- Descomente para testar:

/*
SELECT 
  99999999999999.99 as valor_maximo_suportado,
  'NUMERIC(20,2) = até 99.999.999.999.999,99' as capacidade;
*/

-- ==============================================================================
-- 🔍 VERIFICAÇÃO ADICIONAL: Gaps, constraints e limitações
-- ==============================================================================

-- Verificar se há alguma constraint que pode limitar os valores
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name IN ('planos_trabalho', 'acoes_servicos', 'naturezas_despesa_plano')
AND constraint_type = 'CHECK';

-- ==============================================================================
-- ⚠️ IMPORTANTE: Após executar este script
-- ==============================================================================
-- 1. Aguarde a conclusão sem erros
-- 2. Recarregue a aplicação no navegador
-- 3. Teste inserindo valores maiores que 99 bilhões
-- 4. Verifique o console para mensagens de erro (F12)
