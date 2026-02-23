-- ==============================================================================
-- SCRIPT: Corrigir Políticas de RLS e Restaurar Admin
-- ==============================================================================

-- 1. VERIFICAR SE O ADMIN EXISTE
SELECT 
  id,
  email
FROM auth.users 
WHERE email = 'afpereira@saude.sp.gov.br';

-- 2. VERIFICAR SE O PERFIL EXISTE
SELECT 
  id,
  email,
  full_name,
  role
FROM public.profiles 
WHERE email = 'afpereira@saude.sp.gov.br';

-- 3. VERIFICAR SE user_roles EXISTE
SELECT 
  user_id,
  role,
  disabled
FROM public.user_roles 
WHERE user_id = (
  SELECT id FROM auth.users WHERE email = 'afpereira@saude.sp.gov.br'
);

-- 4. REMOVER POLÍTICAS DE RLS PROBLEMÁTICAS
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can read all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Public can read profiles" ON public.profiles;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.profiles;
DROP POLICY IF EXISTS "Enable update for users based on id" ON public.profiles;

-- 5. CRIAR NOVAS POLÍTICAS DE RLS (PERMISSIVAS)
CREATE POLICY "Allow all read access" ON public.profiles
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow all update for admins" ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  )
  WITH CHECK (true);

-- 6. RESTAURAR ADMIN
UPDATE public.user_roles 
SET role = 'admin', disabled = false
WHERE user_id = (
  SELECT id FROM auth.users WHERE email = 'afpereira@saude.sp.gov.br'
);

-- 7. SINCRONIZAR profiles
UPDATE public.profiles p
SET 
  role = ur.role,
  disabled = ur.disabled,
  updated_at = timezone('utc'::text, now())
FROM public.user_roles ur
WHERE p.id = ur.user_id;

-- 8. VERIFICAÇÃO FINAL
SELECT '✅ ADMIN RESTAURADO!' as status;

SELECT 
  email,
  full_name,
  role,
  disabled
FROM public.profiles 
WHERE email = 'afpereira@saude.sp.gov.br';

-- 9. VER TODAS AS POLÍTICAS ATIVAS
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE tablename IN ('profiles', 'user_roles')
ORDER BY tablename, policyname;
