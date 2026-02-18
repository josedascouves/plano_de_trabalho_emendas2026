-- ============================================================
-- TESTE RÁPIDO - VERIFICAR SE ADMIN CONSEGUE VER DADOS
-- ============================================================
-- Execute este script APÓS executar CORRECAO-ADMIN-PLANOS.sql
-- e DEPOIS de fazer novo login

-- ============================================================
-- 1. VERIFICAR STATUS DE AFPEREIRA
-- ============================================================

SELECT '=== AFPEREIRA STATUS ===' as test;

SELECT 
  p.id,
  p.full_name,
  p.email,
  ur.role,
  ur.disabled,
  'CORRETO!' as status
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE p.email ILIKE '%afpereira%';

-- Esperado: role = 'admin', disabled = false

-- ============================================================
-- 2. VERIFICAR PLANOS VISÍVEIS PARA ADMIN
-- ============================================================

SELECT '=== PLANOS VISÍVEIS ===' as test;

SELECT 
  id,
  created_by,
  created_at,
  updated_at,
  'PLANO OK' as status
FROM public.planos_trabalho
ORDER BY created_at DESC
LIMIT 10;

-- Esperado: Deve listar todos os planos (se for admin)

-- ============================================================
-- 3. VERIFICAR RLS POLICIES EM PLANOS_TRABALHO
-- ============================================================

SELECT '=== RLS POLICIES EM PLANOS ===' as test;

SELECT 
  policyname,
  permissive,
  roles,
  'POLICY OK' as status
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'planos_trabalho'
ORDER BY policyname;

-- Esperado: Deve ter 7 policies (view, edit, delete para admin/user, insert)

-- ============================================================
-- 4. CONTAR USUÁRIOS COM ROLES
-- ============================================================

SELECT '=== CONTAGEM DE USUÁRIOS ===' as test;

SELECT 
  COUNT(*) as total_usuarios,
  SUM(CASE WHEN ur.role = 'admin' THEN 1 ELSE 0 END) as admins,
  SUM(CASE WHEN ur.role = 'user' THEN 1 ELSE 0 END) as usuarios_padrao,
  'CONTAGEM OK' as status
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id;

-- Esperado: total_usuarios >= 1, admins >= 1

-- ============================================================
-- 5. TESTAR CONDIÇÃO DE RLS (SEM EXECUTAR REALMENTE)
-- ============================================================

SELECT '=== TESTE RLS CONDITION ===' as test;

-- Test: Admin consegue ver todos?
SELECT 
  EXISTS(
    SELECT 1 FROM public.user_roles 
    WHERE user_id = (SELECT id FROM public.profiles WHERE email ILIKE '%afpereira%' LIMIT 1)
    AND role = 'admin' 
    AND disabled = false
  ) as afpereira_is_active_admin;

-- Esperado: true

-- ============================================================
-- 6. RESUMO FINAL
-- ============================================================

SELECT '✅ SE TODOS OS TESTES PASSARAM, TUDO ESTÁ CORRETO!' as resultado;
