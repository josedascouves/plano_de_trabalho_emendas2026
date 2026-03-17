-- ============================================================
-- DESCOBRIR ESTRUTURA REAL DA TABELA PLANOS_TRABALHO
-- ============================================================

SELECT '================== ESTRUTURA DE PLANOS_TRABALHO ==================' as info;

-- Ver todas as colunas que realmente existem
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'planos_trabalho'
ORDER BY ordinal_position;

SELECT '================ CONTAR PLANOS ================' as info;

SELECT COUNT(*) as total_planos FROM public.planos_trabalho;

SELECT '================ PLANOS (ÚLTIMOS 5) ================' as info;

SELECT * FROM public.planos_trabalho ORDER BY created_at DESC LIMIT 5;
