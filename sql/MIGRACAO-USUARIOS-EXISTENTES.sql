-- ============================================================
-- SETUP COM MIGRAÇÃO DE USUÁRIOS EXISTENTES
-- Script que popula profiles e user_roles com os usuários já criados
-- ============================================================

-- ============================================================
-- PARTE 1: EXECUTAR LIMPEZA E SETUP COMPLETO
-- ============================================================
-- (Copie TODO o conteúdo de LIMPEZA-E-SETUP-COMPLETO.sql ANTES deste comando)
-- Ou execute o script anterior uma vez

-- ============================================================
-- PARTE 2: MIGRAR USUÁRIOS EXISTENTES
-- ============================================================

-- ============================================================
-- Passo 1: Criar profiles para todos os usuários
-- ============================================================

-- Este script usa os UUIDs exatos do Supabase
-- Se algum UUID estiver incompleto, ele vai dar erro
-- Nesse caso, copie os UUIDs exatos da tabela Supabase > Auth > Users

INSERT INTO public.profiles (id, full_name, email, created_at, updated_at)
SELECT 
  id,
  COALESCE(raw_user_meta_data->>'full_name', SPLIT_PART(email, '@', 1)) as full_name,
  email,
  now(),
  now()
FROM auth.users
ON CONFLICT (id) DO UPDATE SET updated_at = now();

-- Confirmação
SELECT COUNT(*) as profiles_criados FROM public.profiles;

-- ============================================================
-- Passo 2: Criar user_roles para todos os usuários
-- ============================================================

-- Todos começam como USER
INSERT INTO public.user_roles (user_id, role, disabled)
SELECT id, 'user', false
FROM auth.users
ON CONFLICT (user_id) DO UPDATE SET disabled = false;

-- Confirmação
SELECT COUNT(*) as user_roles_criados FROM public.user_roles;

-- ============================================================
-- Passo 3: Definir afpereira como ADMIN
-- ============================================================

UPDATE public.user_roles 
SET role = 'admin' 
WHERE user_id IN (
  SELECT id FROM auth.users WHERE email ILIKE '%afpereira@saude.sp.gov.br%'
);

-- Confirmação
SELECT COUNT(*) as total_admins FROM public.user_roles WHERE role = 'admin';

-- ============================================================
-- Passo 3: Verificação Final
-- ============================================================

-- Ver todos os usuários com seus roles
SELECT 
  p.id,
  p.full_name,
  p.email,
  ur.role,
  ur.disabled,
  p.created_at
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
ORDER BY ur.role DESC, p.full_name;

-- Contar admins
SELECT COUNT(*) as total_admins FROM public.user_roles WHERE role = 'admin';

-- Contar usários
SELECT COUNT(*) as total_users FROM public.user_roles WHERE role = 'user';

-- ============================================================
-- FIM - Migração Completa
-- ============================================================
