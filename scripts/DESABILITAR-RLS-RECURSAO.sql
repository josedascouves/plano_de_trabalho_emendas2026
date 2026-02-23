-- ==============================================================================
-- SCRIPT: Desabilitar RLS Recursiva e Restaurar Acesso
-- ==============================================================================

-- 1. DESABILITAR RLS EM TODAS AS TABELAS (resolver recursão)
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER TODAS AS POLÍTICAS PROBLEMÁTICAS
DROP POLICY IF EXISTS "Allow all read access" ON public.profiles;
DROP POLICY IF EXISTS "Allow all update for admins" ON public.profiles;
DROP POLICY IF EXISTS "Users can read own role" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can read all roles" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can update roles" ON public.user_roles;

-- 3. GARANTIR QUE TODOS OS ADMINS ESTÃO CONFIGURADOS CORRETAMENTE
UPDATE public.user_roles 
SET role = 'admin', disabled = false
WHERE user_id IN (
  SELECT id FROM auth.users 
  WHERE email IN (
    'afpereira@saude.sp.gov.br',
    'gcf-emendasfederais@saude.sp.gov.br',
    'tcnbarbosa@saude.sp.gov.br',
    'mrsilva@saude.sp.gov.br'
  )
);

-- 4. SINCRONIZAR profiles COM user_roles
UPDATE public.profiles p
SET 
  role = ur.role,
  disabled = ur.disabled,
  updated_at = timezone('utc'::text, now())
FROM public.user_roles ur
WHERE p.id = ur.user_id;

-- 5. VERIFICAÇÃO
SELECT '✅ RLS DESABILIZADA - SISTEMA DESBLOQUEADO!' as status;

SELECT 
  email,
  full_name,
  role,
  disabled
FROM public.profiles 
WHERE email IN (
  'afpereira@saude.sp.gov.br',
  'gcf-emendasfederais@saude.sp.gov.br',
  'tcnbarbosa@saude.sp.gov.br',
  'mrsilva@saude.sp.gov.br'
);

-- 6. CONTAR USUÁRIOS
SELECT 
  COUNT(*) as total_users,
  COUNT(CASE WHEN role = 'admin' THEN 1 END) as admin_count,
  COUNT(CASE WHEN role = 'user' THEN 1 END) as user_count
FROM public.user_roles;
