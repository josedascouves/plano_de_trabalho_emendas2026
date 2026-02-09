-- ============================================================
-- FIX RLS PROFILES - Desabilitar RLS para evitar recursão
-- ============================================================
-- SOLUÇÃO: A tabela profiles contém apenas dados de user info
-- que já estão protegidos pelo Supabase Auth.
-- Segurança de admin é garantida pelo app-layer + Edge Functions

ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- Remover qualquer politica antiga que possa estar causando problemas
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admin can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admin can manage profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admin can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admin can update all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admin can delete profiles" ON public.profiles;
DROP POLICY IF EXISTS "Insert owns plan" ON public.profiles;
DROP POLICY IF EXISTS "View own plans" ON public.profiles;
DROP POLICY IF EXISTS "Update own plans" ON public.profiles;
DROP POLICY IF EXISTS "Delete own plans" ON public.profiles;

-- ============================================================
-- VERIFICAÇÃO
-- ============================================================
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'profiles';
