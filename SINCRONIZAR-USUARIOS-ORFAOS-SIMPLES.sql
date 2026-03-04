-- ============================================================================
-- SCRIPT DE SINCRONIZAÇÃO AUTOMÁTICA DE USUÁRIOS ÓRFÃOS (A QUALQUER HORA)
-- ============================================================================
-- Execute este script quando tiver usuários que:
-- - Existem em auth.users
-- - Mas NÃO têm profile em profiles
-- - Mas NÃO têm entry em user_roles
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Clique em "+ New Query"
-- 4. Cole TODO este arquivo
-- 5. Execute (Ctrl+Enter)
-- ============================================================================

BEGIN;

-- Desabilitar RLS temporariamente
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- SINCRONIZAR TODOS OS USUÁRIOS ÓRFÃOS (SIMPLES E SEGURO)
-- ============================================================================

-- PASSO 1: Inserir profiles faltantes (para usuários em auth.users que não têm profile)
INSERT INTO public.profiles (id, email, full_name, cnes, created_at)
SELECT 
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'full_name', u.email),
  COALESCE(u.raw_user_meta_data->>'cnes', ''),
  u.created_at
FROM auth.users u
WHERE u.id NOT IN (SELECT id FROM public.profiles WHERE id IS NOT NULL)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  cnes = EXCLUDED.cnes;

SELECT '✅ PASSO 1: Profiles sincronizados' as result;

-- PASSO 2: Inserir user_roles faltantes (para profiles que não têm role)
INSERT INTO public.user_roles (user_id, role, disabled)
SELECT 
  p.id,
  'user',
  false
FROM public.profiles p
WHERE p.id NOT IN (SELECT user_id FROM public.user_roles)
ON CONFLICT (user_id) DO UPDATE SET
  disabled = false;

SELECT '✅ PASSO 2: User_roles sincronizados' as result;

-- Re-habilitar RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

COMMIT;

-- ============================================================================
-- VERIFICAÇÃO: Mostrar usuários sincronizados
-- ============================================================================

SELECT 
  'RESULTADO DA SINCRONIZAÇÃO' as resultado,
  COUNT(*) as total_usuarios_sincronizados,
  COUNT(CASE WHEN ur.disabled = false THEN 1 END) as ativos,
  COUNT(CASE WHEN ur.disabled = true THEN 1 END) as desativos
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE ur.user_id IS NOT NULL;

-- Lista de usuários sincronizados
SELECT 
  '📊 USUÁRIOS SINCRONIZADOS' as resultado,
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE ur.user_id IS NOT NULL
ORDER BY p.email;
