-- ==============================================================================
-- SCRIPT: Verificar e Restaurar Permissões dos Admins
-- ==============================================================================

-- 1. VER TODOS OS USUÁRIOS E SEUS ROLES
SELECT 
  p.email,
  p.full_name,
  ur.role,
  ur.disabled
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
ORDER BY p.email;

-- 2. VER APENAS OS ADMINS
SELECT 
  p.email,
  p.full_name,
  ur.role,
  ur.disabled
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE ur.role = 'admin' OR p.role = 'admin'
ORDER BY p.email;

-- 3. SE UM ADMIN PERDEU PERMISSÃO, RESTAURE AQUI
-- Substitua 'seu-email-admin@exemplo.com' pelo email do seu admin
-- UPDATE public.user_roles 
-- SET role = 'admin', disabled = false
-- WHERE user_id = (
--   SELECT id FROM auth.users WHERE email = 'seu-email-admin@exemplo.com'
-- );

-- 4. SINCRONIZAR NOVAMENTE (se precisar)
UPDATE public.profiles p
SET 
  role = ur.role,
  disabled = ur.disabled
FROM public.user_roles ur
WHERE p.id = ur.user_id;

-- 5. VERIFICAÇÃO FINAL
SELECT '✅ VERIFICAÇÃO CONCLUÍDA!' as status;

SELECT 
  COUNT(CASE WHEN role = 'admin' THEN 1 END) as admin_count,
  COUNT(CASE WHEN role = 'user' THEN 1 END) as user_count,
  COUNT(CASE WHEN disabled = false THEN 1 END) as active_count
FROM public.user_roles;
