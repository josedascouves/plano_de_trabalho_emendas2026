-- ==============================================================================
-- SCRIPT ULTRA-SIMPLES: Preparar Banco sem Acessar user_metadata
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

-- 1. REMOVER TRIGGER ANTIGO (que estava dando erro)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 2. VERIFICAR ESTRUTURA DA TABELA profiles
-- Se a tabela não existir, criar
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY,
  email text,
  full_name text,
  cnes text,
  role text DEFAULT 'user',
  disabled boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

-- 3. ADICIONAR COLUNAS SE FALTAREM
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role text DEFAULT 'user';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS disabled boolean DEFAULT false;

-- 4. LIMPAR DADOS INVÁLIDOS
DELETE FROM public.profiles 
WHERE email LIKE '%/%' OR email LIKE '% %';

-- 5. RECRIAR TRIGGER SEM ACESSAR user_metadata
-- Este trigger não faz nada por enquanto, apenas existe para não quebrar
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 6. HABILITAR RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 7. CRIAR POLÍTICAS DE RLS
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all" ON public.profiles;

CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "Admins can view all" ON public.profiles
  FOR SELECT
  USING (role = 'admin');

-- 8. VERIFICAÇÃO
SELECT 'BANCO PREPARADO COM SUCESSO!' as status;

-- Ver status
SELECT 
  COUNT(*) as total_profiles,
  COUNT(CASE WHEN role = 'admin' THEN 1 END) as admin_count,
  COUNT(CASE WHEN disabled = false THEN 1 END) as active_users
FROM public.profiles;
