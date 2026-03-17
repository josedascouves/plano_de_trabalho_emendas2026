-- ============================================================================
-- DIAGNÓSTICO: Por que admin não consegue carregar dados relacionados
-- ============================================================================

-- PASSO 1: Verificar usuários no Supabase Auth
SELECT id, email FROM auth.users WHERE created_at IS NOT NULL LIMIT 5;

-- PASSO 2: Verificar planos criados por outros usuários
SELECT id, numero_emenda, parlamentar, created_by, valor_total 
FROM public.planos_trabalho 
LIMIT 5;

-- PASSO 3: Para CADA plano, verificar se tem dados relacionados
SELECT 
  p.id AS plano_id,
  p.numero_emenda,
  COUNT(DISTINCT a.id) AS acoes_count,
  COUNT(DISTINCT m.id) AS metas_count,
  COUNT(DISTINCT n.id) AS naturezas_count
FROM public.planos_trabalho p
LEFT JOIN public.acoes_servicos a ON p.id = a.plano_id
LEFT JOIN public.metas_qualitativas m ON p.id = m.plano_id
LEFT JOIN public.naturezas_despesa_plano n ON p.id = n.plano_id
GROUP BY p.id, p.numero_emenda
ORDER BY p.created_at DESC
LIMIT 10;

-- PASSO 4: Verificar políticas RLS
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual AS policy_expression,
  with_check
FROM pg_policies
WHERE tablename IN ('acoes_servicos', 'metas_qualitativas', 'naturezas_despesa_plano', 'planos_trabalho')
ORDER BY tablename, policyname;

-- PASSO 5: Verificar se RLS está HABILITADO nas tabelas
SELECT 
  table_schema,
  table_name,
  row_security_enabled
FROM information_schema.tables
WHERE table_name IN ('acoes_servicos', 'metas_qualitativas', 'naturezas_despesa_plano', 'planos_trabalho')
  AND table_schema = 'public';

-- PASSO 6: Contar registros nas tabelas
SELECT 'acoes_servicos' as tabela, COUNT(*) as total FROM public.acoes_servicos
UNION ALL
SELECT 'metas_qualitativas', COUNT(*) FROM public.metas_qualitativas
UNION ALL
SELECT 'naturezas_despesa_plano', COUNT(*) FROM public.naturezas_despesa_plano
UNION ALL
SELECT 'planos_trabalho', COUNT(*) FROM public.planos_trabalho;
