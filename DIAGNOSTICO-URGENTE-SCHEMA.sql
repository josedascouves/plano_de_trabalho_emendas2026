-- ============================================================================
-- DIAGNÓSTICO URGENTE: Encontrar TODAS as fontes de erro "Database error querying schema"
-- ============================================================================
-- Execute este script EXATAMENTE COMO ESTÁ para ver qual é o problema real
-- Cada query vai mostrar se profiles/user_roles estão acessíveis

BEGIN;

-- ==========================================================================
-- TESTE 1: Verificar estrutura real das tabelas
-- ==========================================================================
SELECT 
  'TEST 1: Colunas em profiles' as test,
  string_agg(column_name, ', ') as colunas
FROM information_schema.columns 
WHERE table_name = 'profiles' AND table_schema = 'public';

SELECT 
  'TEST 1: Colunas em user_roles' as test,
  string_agg(column_name, ', ') as colunas
FROM information_schema.columns 
WHERE table_name = 'user_roles' AND table_schema = 'public';

-- ==========================================================================
-- TESTE 2: Tentar SELECT simples (como faz o App.tsx)
-- ==========================================================================
SELECT '✅ TEST 2A: SELECT de profiles' as test;
SELECT COUNT(*) FROM public.profiles;

SELECT '✅ TEST 2B: SELECT de user_roles' as test;
SELECT COUNT(*) FROM public.user_roles;

-- ==========================================================================
-- TESTE 3: Verificar RLS - está habilitado?
-- ==========================================================================
SELECT 
  'TEST 3: RLS Status' as test,
  tablename,
  rowsecurity as "RLS Enabled?"
FROM pg_tables 
WHERE tablename IN ('profiles', 'user_roles') 
  AND schemaname = 'public';

-- ==========================================================================
-- TESTE 4: Listar TODAS as políticas RLS
-- ==========================================================================
SELECT 
  'TEST 4: RLS Policies' as test,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('profiles', 'user_roles');

-- ==========================================================================
-- TESTE 5: Verificar TRIGGERS que podem causar erro
-- ==========================================================================
SELECT 
  'TEST 5: Triggers' as test,
  trigger_name,
  event_manipulation,
  event_object_table
FROM information_schema.triggers 
WHERE event_object_schema = 'public' 
  AND event_object_table IN ('profiles', 'user_roles');

-- ==========================================================================
-- TESTE 6: Verificar FUNCTIONS que podem estar causando erro
-- ==========================================================================
SELECT 
  'TEST 6: Functions' as test,
  routine_name,
  routine_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN (
    'handle_new_user',
    'update_profiles_timestamp', 
    'handle_updated_at',
    'sincronizar_usuario_orfao',
    'sincronizar_todos_usuarios_orfaos'
  );

-- ==========================================================================
-- TESTE 7: Tentar as queries EXATAS que o App.tsx faz
-- ==========================================================================
SELECT '✅ TEST 7A: Query do checkSession - profiles' as test;
SELECT id, full_name, email, cnes FROM public.profiles LIMIT 1;

SELECT '✅ TEST 7B: Query do checkSession - user_roles' as test;
SELECT user_id, role FROM public.user_roles LIMIT 1;

-- ==========================================================================
-- TESTE 8: Dados dos 4 usuários problemáticos
-- ==========================================================================
SELECT '📊 TEST 8: Status dos 4 usuários problemáticos' as test;
SELECT 
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled,
  'Profile Existe?' as profile_status,
  'Role Existe?' as role_status
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE p.email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
)
ORDER BY p.email;

-- ==========================================================================
-- TESTE 9: Verificar função sincronizar_usuario_orfao (se existe)
-- ==========================================================================
SELECT '📝 TEST 9: Definição da função sincronizar_usuario_orfao' as test;
SELECT 
  p.proname as function_name,
  p.prosrc as function_body
FROM pg_proc p
WHERE p.proname = 'sincronizar_usuario_orfao'
  AND p.pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

COMMIT;

-- ==========================================================================
-- RESUMO FINAL
-- ==========================================================================
SELECT '═════════════════════════════════════════════════════════' as linha;
SELECT '✅ SE TODOS OS TESTES PASSARAM, O BANCO ESTÁ OK!' as resultado;
SELECT '❌ SE ALGUM TESTE FALHOU, VERIFIQUE O ERRO ACIMA' as resultado;
SELECT '═════════════════════════════════════════════════════════' as linha;
