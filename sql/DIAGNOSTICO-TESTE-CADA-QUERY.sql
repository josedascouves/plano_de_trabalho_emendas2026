-- ============================================================================
-- DIAGNÓSTICO DETALHADO: Encontrar exatamente qual query está com erro
-- ============================================================================
-- Execute CADA query uma por uma para encontrar qual está falhando
-- Copie e cole UMA query por vez no SQL Editor
-- ============================================================================

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 1: Verificar se auth.users tem os 4 usuários
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 1: auth.users - 4 usuários' as teste,
  COUNT(*) as encontrados
FROM auth.users
WHERE email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
);

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 2: Verificar se profiles tem os 4 usuários
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 2: profiles - 4 usuários' as teste,
  COUNT(*) as encontrados
FROM public.profiles
WHERE email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
);

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 3: Verificar se user_roles tem os 4 usuários
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 3: user_roles - 4 usuários' as teste,
  COUNT(*) as encontrados
FROM public.user_roles
WHERE user_id IN (
  SELECT id FROM auth.users WHERE email IN (
    'janete.sgueglia@saude.sp.gov.br',
    'lhribeiro@saude.sp.gov.br',
    'gtcosta@saude.sp.gov.br',
    'casouza@saude.sp.gov.br'
  )
);

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 4: Query EXATA que App.tsx faz no checkSession (linha 313-316)
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 4: Query exata do checkSession' as teste,
  id, full_name, email, cnes
FROM public.profiles
LIMIT 1;

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 5: Query para user_roles (linha 324-325)
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 5: Query exata para user_roles' as teste,
  role
FROM public.user_roles
LIMIT 1;

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 6: Query EXATA que App.tsx faz no handleLogin (linha 680-684)
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 6: Query do handleLogin - profiles' as teste,
  id, full_name, email, cnes
FROM public.profiles
WHERE id = 'f47ac10b-58cc-4372-a567-0e02b2c3d479' -- Substitir por ID real
LIMIT 1;

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 7: Query do handleLogin - user_roles (linha 696-701)
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 7: Query do handleLogin - user_roles' as teste,
  role, disabled
FROM public.user_roles
WHERE user_id = 'f47ac10b-58cc-4372-a567-0e02b2c3d479' -- Substitir por ID real
LIMIT 1;

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 8: Listar TODAS as colunas de profiles (para ver quais existem)
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 8: Estrutura de profiles' as teste;

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles' AND table_schema = 'public'
ORDER BY ordinal_position;

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 9: Listar TODAS as colunas de user_roles
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 9: Estrutura de user_roles' as teste;

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'user_roles' AND table_schema = 'public'
ORDER BY ordinal_position;

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 10: Verificar RLS - está habilitado?
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 10: RLS Status' as teste,
  tablename,
  rowsecurity as "RLS Enabled?"
FROM pg_tables 
WHERE tablename IN ('profiles', 'user_roles') 
  AND schemaname = 'public';

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 11: Verificar quantas políticas RLS estão ativas
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 11: Políticas RLS Ativas' as teste,
  COUNT(*) as total_politicas
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('profiles', 'user_roles');

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 12: Listar TODAS as políticas RLS ativas
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 12: Lista de Políticas RLS' as teste,
  tablename,
  policyname,
  permissive,
  qual
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('profiles', 'user_roles')
ORDER BY tablename, policyname;

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 13: Dados completos dos 4 usuários (incluindo tudo)
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 13: Dados Completos' as teste;

SELECT 
  p.id,
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled,
  CASE WHEN ur.user_id IS NOT NULL THEN '✅ OK' ELSE '❌ FALTA' END as status
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE p.email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
)
ORDER BY p.email;

-- ═════════════════════════════════════════════════════════════════════════=
-- TESTE 14: Simular query de login para cada usuário
-- ═════════════════════════════════════════════════════════════════════════=

SELECT 
  '🔍 TESTE 14: Simulação de Login' as teste,
  p.email,
  p.id,
  p.full_name,
  ur.role,
  ur.disabled,
  CASE WHEN ur.disabled = true THEN '❌ DESATIVADO' ELSE '✅ ATIVO' END as login_status
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE p.email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
)
ORDER BY p.email;
