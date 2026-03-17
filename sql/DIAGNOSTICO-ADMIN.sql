-- ============================================================
-- DIAGNÓSTICO E CORREÇÃO - AFPEREIRA NÃO ESTÁ COMO ADMIN
-- ============================================================

-- ============================================================
-- PASSO 1: DIAGNÓSTICO
-- ============================================================

-- Verificar quantos usuários existem
SELECT COUNT(*) as total_usuarios FROM public.profiles;

-- Verificar quantos admins existem
SELECT COUNT(*) as total_admins FROM public.user_roles WHERE role = 'admin';

-- Ver afpereira em profiles
SELECT id, full_name, email FROM public.profiles 
WHERE email ILIKE '%afpereira%';

-- Ver afpereira em user_roles
SELECT user_id, role, disabled FROM public.user_roles 
WHERE user_id IN (
  SELECT id FROM public.profiles WHERE email ILIKE '%afpereira%'
);

-- Ver TODOS os usuários com roles
SELECT 
  p.id,
  p.full_name,
  p.email,
  COALESCE(ur.role, 'FALTANDO') as role,
  COALESCE(ur.disabled::text, 'FALTANDO') as disabled
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
ORDER BY p.email;

-- ============================================================
-- PASSO 2: CORREÇÃO - Garantir que afpereira é ADMIN
-- ============================================================

-- Atualizar afpereira para admin (se não for)
UPDATE public.user_roles 
SET role = 'admin', disabled = false
WHERE user_id IN (
  SELECT id FROM public.profiles WHERE email ILIKE '%afpereira%'
);

-- Confirmação
SELECT 'Afpereira agora é admin:' as status;
SELECT 
  p.full_name,
  p.email,
  ur.role,
  ur.disabled
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE p.email ILIKE '%afpereira%';

-- ============================================================
-- PASSO 3: VERIFICAÇÃO FINAL
-- ============================================================

-- Contar admins novamente (deve ser >= 1)
SELECT COUNT(*) as total_admins_after FROM public.user_roles WHERE role = 'admin';

-- Ver estrutura de user_roles (verificar se SEM RLS)
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables 
WHERE schemaname = 'public' AND tablename IN ('profiles', 'user_roles', 'audit_logs');

-- ============================================================
-- FIM - Se chegou até aqui, afpereira é admin!
-- ============================================================
