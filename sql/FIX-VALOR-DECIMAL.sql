-- ============================================================================
-- FIX: CONVERTER valor_total DE INTEGER PARA DECIMAL
-- ============================================================================
-- Problema: Valores menores que 1 (ex: 0,33) estão sendo salvos como 0
-- Causa: Coluna valor_total está como INTEGER em vez de DECIMAL
-- Solução: Converter para DECIMAL(10,2) para aceitar centavos
-- ============================================================================

-- PASSO 1: Verificar tipo atual da coluna
SELECT column_name, data_type, numeric_precision, numeric_scale
FROM information_schema.columns
WHERE table_name = 'planos_trabalho' AND column_name = 'valor_total';

-- PASSO 2: Alterar o tipo da coluna de INTEGER para NUMERIC(10,2)
ALTER TABLE public.planos_trabalho
ALTER COLUMN valor_total TYPE NUMERIC(10,2);

-- PASSO 3: Verificar se a alteração foi bem-sucedida
SELECT column_name, data_type, numeric_precision, numeric_scale
FROM information_schema.columns
WHERE table_name = 'planos_trabalho' AND column_name = 'valor_total';

-- PASSO 4: Verificar primeiros 10 planos e seus valores
SELECT id, numero_emenda, valor_total FROM public.planos_trabalho LIMIT 10;

-- ============================================================================
-- NOTAS:
-- ============================================================================
-- * NUMERIC(10,2) = até 10 dígitos totais, com 2 casas decimais
--   Máximo: 99.999.999,99
-- * Se esse limite for insuficiente, use NUMERIC(15,2) ou NUMERIC(18,2)
-- * Os dados existentes serão preservados na conversão
-- * A partir de agora, 0,33 será armazenado corretamente como 0.33
-- ============================================================================
