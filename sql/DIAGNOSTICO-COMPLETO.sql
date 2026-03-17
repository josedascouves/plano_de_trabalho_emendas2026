-- ============================================================
-- DIAGNÓSTICO COMPLETO - VERIFICAR STATUS DO SISTEMA RBAC
-- ============================================================

-- ====== 1. ESTRUTURA DO BANCO DE DADOS ======
-- Ver estrutura de RLS
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables 
WHERE schemaname = 'public' AND tablename IN ('profiles', 'user_roles', 'audit_logs', 'planos_trabalho');

-- Contar total de usuários
SELECT COUNT(*) as total_usuarios FROM public.profiles;

-- Contar total de admins
SELECT COUNT(*) as total_admins FROM public.user_roles WHERE role = 'admin';

-- ====== 2. VERIFICAR AFPEREIRA ======
-- Ver afpereira em profiles
SELECT 
  p.id,
  p.full_name,
  p.email,
  p.created_at
FROM public.profiles p
WHERE p.email ILIKE '%afpereira%';

-- Ver afpereira em user_roles
SELECT 
  ur.user_id,
  ur.role,
  ur.disabled
FROM public.user_roles ur
WHERE ur.user_id IN (
  SELECT p.id FROM public.profiles p WHERE p.email ILIKE '%afpereira%'
);

-- ====== 3. VER TODOS OS USUÁRIOS COM ROLES ======
SELECT 
  p.id,
  p.full_name,
  p.email,
  COALESCE(ur.role, 'FALTANDO') as role,
  COALESCE(ur.disabled::text, 'FALTANDO') as disabled,
  p.created_at
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
ORDER BY p.email;

-- ====== 4. PLANOS CRIADOS ======
SELECT 
  id,
  created_by,
  created_at,
  updated_at
FROM public.planos_trabalho
ORDER BY created_at DESC
LIMIT 10;

-- ====== 5. VERIFICAR RLS POLICIES ======
-- Ver todas as policies em planos_trabalho
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'planos_trabalho';

-- Ver todas as policies em profiles
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'profiles';

-- Ver todas as policies em user_roles
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'user_roles';
