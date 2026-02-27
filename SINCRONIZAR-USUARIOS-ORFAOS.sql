-- ==============================================================================
-- SINCRONIZAR TODOS OS USUÁRIOS ÓRFÃOS
-- ==============================================================================
--
-- PROBLEMA: Usuários existem em auth.users mas não têm entry em profiles
-- SOLUÇÃO: Criar automaticamente profiles e user_roles para todos
--
-- ==============================================================================

-- 1️⃣ SINCRONIZAR: Criar profiles faltantes
INSERT INTO public.profiles (id, email, full_name, role, disabled, created_at)
SELECT 
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'full_name', u.email),
  'user',
  false,
  u.created_at
FROM auth.users u
WHERE u.id NOT IN (SELECT id FROM public.profiles)
ON CONFLICT (id) DO NOTHING;

SELECT '✅ Passo 1: Profiles sincronizados' as resultado;

-- 2️⃣ SINCRONIZAR: Criar user_roles faltantes
INSERT INTO public.user_roles (user_id, role, disabled)
SELECT 
  u.id,
  'user',
  false
FROM auth.users u
WHERE u.id NOT IN (SELECT user_id FROM public.user_roles)
ON CONFLICT (user_id) DO NOTHING;

SELECT '✅ Passo 2: User roles sincronizados' as resultado;

-- 3️⃣ ATUALIZAR roles baseado em profiles (se houver discrepâncias)
UPDATE public.user_roles ur
SET role = p.role
FROM public.profiles p
WHERE ur.user_id = p.id
AND ur.role != p.role;

SELECT '✅ Passo 3: Roles atualizados para corresponder com profiles' as resultado;

-- 4️⃣ DIAGNÓSTICO: Mostrar resultado final
SELECT '
=== RESULTADO DA SINCRONIZAÇÃO ===' as diagnostico;

SELECT 
  COUNT(*) as total_usuarios,
  COUNT(CASE WHEN p.id IS NOT NULL THEN 1 END) as com_profile,
  COUNT(CASE WHEN p.id IS NULL THEN 1 END) as sem_profile,
  COUNT(CASE WHEN ur.user_id IS NOT NULL THEN 1 END) as com_role,
  COUNT(CASE WHEN ur.user_id IS NULL THEN 1 END) as sem_role
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
LEFT JOIN public.user_roles ur ON u.id = ur.user_id;

-- 5️⃣ LISTAR: Todos os usuários agora sincronizados
SELECT '
=== USUÁRIOS SINCRONIZADOS ===' as info;

SELECT 
  p.id,
  p.email,
  p.full_name,
  ur.role,
  ur.disabled,
  p.created_at
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
ORDER BY p.full_name;

-- 6️⃣ RESUMO FINAL
SELECT '
╔═══════════════════════════════════════════════════════════╗
║  ✅ SINCRONIZAÇÃO CONCLUÍDA!                              ║
║                                                           ║
║  Todos os usuários órfãos foram recuperados              ║
║  e sincronizados entre auth.users, profiles e user_roles ║
║                                                           ║
║  Próximos passos:                                        ║
║  1. Verifique a lista acima                             ║
║  2. Atualize roles conforme necessário                  ║
║  3. Ctrl+F5 na app                                      ║
║  4. Logout/Login dos usuários                           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
' as resultado;

-- ==============================================================================
