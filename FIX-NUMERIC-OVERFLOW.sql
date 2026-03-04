-- ============================================================================
-- CORREÇÃO: RESOLVER NUMERIC FIELD OVERFLOW
-- ============================================================================
-- Problema: Campos NUMERIC(10,2) não suportam valores > 99.999.999,99
-- Solução: Aumentar precisão para NUMERIC(15,2) que suporta até R$ 999.999.999.999,99
-- ============================================================================

-- 1️⃣ CORRIGIR COLUNA valor_total NA TABELA planos_trabalho
ALTER TABLE public.planos_trabalho
ALTER COLUMN valor_total TYPE NUMERIC(15, 2);

-- 2️⃣ CORRIGIR COLUNA valor NA TABELA acoes_servicos
ALTER TABLE public.acoes_servicos
ALTER COLUMN valor TYPE NUMERIC(15, 2);

-- 3️⃣ CORRIGIR COLUNA valor NA TABELA naturezas_despesa_plano
ALTER TABLE public.naturezas_despesa_plano
ALTER COLUMN valor TYPE NUMERIC(15, 2);

-- ============================================================================
-- ✅ VERIFICAÇÃO: Confirmar que as alterações funcionaram
-- ============================================================================

SELECT 'planos_trabalho' as tabela, column_name, data_type, numeric_precision, numeric_scale
FROM information_schema.columns
WHERE table_name = 'planos_trabalho' AND column_name = 'valor_total'

UNION ALL

SELECT 'acoes_servicos' as tabela, column_name, data_type, numeric_precision, numeric_scale
FROM information_schema.columns
WHERE table_name = 'acoes_servicos' AND column_name = 'valor'

UNION ALL

SELECT 'naturezas_despesa_plano' as tabela, column_name, data_type, numeric_precision, numeric_scale
FROM information_schema.columns
WHERE table_name = 'naturezas_despesa_plano' AND column_name = 'valor';

-- ============================================================================
-- 📊 TESTE: Verificar se consegue salvar valor de 129 bilhões
-- ============================================================================
-- Descomente e execute para testar:
-- INSERT INTO public.planos_trabalho (numero_emenda, valor_total, created_by)
-- VALUES ('TESTE-129B', 129000000.00, (SELECT id FROM auth.users LIMIT 1));
