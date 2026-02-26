-- ==============================================================================
-- SCRIPT: Criar e Configurar Tabela user_roles para Todos os Usuários
-- ==============================================================================
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Clique em "New Query"
-- 4. Cole TODO este arquivo
-- 5. Execute (Ctrl+Enter ou clique em Run)
--
-- ==============================================================================

-- 1. CRIAR TABELA user_roles (se não existir)
CREATE TABLE IF NOT EXISTS public.user_roles (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role text DEFAULT 'user' CHECK (role IN ('admin', 'user', 'intermediate')),
  disabled boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

-- 2. HABILITAR RLS
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- 3. CRIAR POLÍTICAS DE RLS
DROP POLICY IF EXISTS "Users can read own role" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can read all roles" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can update roles" ON public.user_roles;

CREATE POLICY "Users can read own role" ON public.user_roles
  FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Admins can read all roles" ON public.user_roles
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles ur
      WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
    )
  );

CREATE POLICY "Admins can update roles" ON public.user_roles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles ur
      WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
    )
  );

-- 4. POPULAR user_roles COM TODOS OS USUÁRIOS DE auth.users
-- Todos como 'user' (não admin) por padrão
INSERT INTO public.user_roles (user_id, role, disabled)
SELECT 
  u.id,
  'user' as role,
  false as disabled
FROM auth.users u
WHERE u.id NOT IN (SELECT user_id FROM public.user_roles)
ON CONFLICT (user_id) DO NOTHING;

-- 5. SINCRONIZAR profiles COM user_roles
UPDATE public.profiles p
SET 
  role = ur.role,
  disabled = ur.disabled
FROM public.user_roles ur
WHERE p.id = ur.user_id;

-- 6. VERIFICAÇÃO
SELECT '✅ CONFIGURAÇÃO CONCLUÍDA!' as status;

-- Ver quantos usuários foram configurados
SELECT 
  COUNT(*) as total_users,
  COUNT(CASE WHEN role = 'admin' THEN 1 END) as admin_count,
  COUNT(CASE WHEN role = 'user' THEN 1 END) as user_count,
  COUNT(CASE WHEN role = 'intermediate' THEN 1 END) as intermediate_count,
  COUNT(CASE WHEN disabled = false THEN 1 END) as active_count
FROM public.user_roles;

-- Listar todos os usuários com seus roles
SELECT 
  ur.user_id,
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled,
  p.created_at
FROM public.user_roles ur
LEFT JOIN public.profiles p ON ur.user_id = p.id
ORDER BY p.email;
