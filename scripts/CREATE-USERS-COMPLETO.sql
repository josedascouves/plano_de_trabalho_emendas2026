-- ==============================================================================
-- SCRIPT COMPLETO: Criar 26 Usuários Diretamente no Supabase
-- ==============================================================================
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Clique em "New Query"
-- 4. Cole TODO este arquivo
-- 5. Execute (Ctrl+Enter ou clique em Run)
-- 6. Aguarde a mensagem de sucesso
--
-- ==============================================================================

-- ==================== PARTE 1: PREPARAR =====================

-- Remover trigger anterior (se existir)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- ==================== PARTE 2: CRIAR USUÁRIOS =====================

-- Nota: A tabela auth.users é gerenciada pelo Supabase Auth
-- Não podemos inserir diretamente via SQL INSERT
-- Este script sincroniza os usuários que já existem em auth.users

-- Para criar usuários, use a API REST do Supabase ou execute via Dashboard
-- Mas aqui está o SQL que PREPARARÁ tudo para os usuários

-- Limpar profiles antigos com dados problemáticos (se houver)
DELETE FROM public.profiles 
WHERE email IN (
  'escritoriodeprojetos@hospitaldeamor.com.br / ebenezer.marques@hospitaldeamor.com.br',
  'administracao1@scma.org.br / administraacao@scma.org.br / contratos@scma.org.br'
);

-- ==================== PARTE 3: CRIAR/SINCRONIZAR PROFILES =====================

-- Garantir que a tabela profiles existe
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE,
  email text NOT NULL,
  full_name text,
  cnes text,
  role text DEFAULT 'user',
  disabled boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  PRIMARY KEY (id),
  UNIQUE(email)
);

-- Adicionar coluna 'role' se não existir
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role text DEFAULT 'user';

-- Adicionar coluna 'disabled' se não existir
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS disabled boolean DEFAULT false;

-- Sincronizar profiles existentes com auth.users
INSERT INTO public.profiles (id, email, full_name, cnes, role)
SELECT 
  u.id,
  u.email,
  COALESCE(u.user_metadata ->> 'full_name', u.email),
  u.user_metadata ->> 'cnes',
  COALESCE(p.role, 'user')
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE (p.id IS NULL OR p.email IS NULL OR p.full_name IS NULL)
ON CONFLICT (id) DO UPDATE
SET 
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  cnes = EXCLUDED.cnes,
  updated_at = timezone('utc'::text, now());

-- ==================== PARTE 4: RECRIAR TRIGGER =====================

-- Criar função do trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  BEGIN
    INSERT INTO public.profiles (id, email, full_name, cnes, role)
    VALUES (
      new.id,
      new.email,
      COALESCE(new.user_metadata ->> 'full_name', new.email),
      new.user_metadata ->> 'cnes',
      'user'
    )
    ON CONFLICT (id) DO UPDATE
    SET 
      email = new.email,
      full_name = COALESCE(new.user_metadata ->> 'full_name', new.email),
      cnes = new.user_metadata ->> 'cnes',
      updated_at = timezone('utc'::text, now());
  EXCEPTION WHEN OTHERS THEN
    -- Ignora erros no trigger
    RETURN new;
  END;
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Habilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Criar políticas de RLS
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.profiles;

CREATE POLICY "Admins can view all profiles" ON public.profiles
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "Admins can update all profiles" ON public.profiles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- ==================== PARTE 5: VERIFICAÇÃO =====================

-- Contar usuários
SELECT 
  COUNT(DISTINCT u.id) as total_auth_users,
  COUNT(DISTINCT p.id) as total_profiles
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id;

-- Listar todos os usuários criados
SELECT 
  u.id,
  u.email,
  u.user_metadata ->> 'full_name' as full_name,
  u.user_metadata ->> 'cnes' as cnes,
  u.created_at,
  p.role,
  p.disabled
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
ORDER BY u.created_at DESC;

-- ==================== PRÓXIMO PASSO =====================
-- Para criar os usuários, use o script Python:
-- python scripts/import_users_simple.py usuarios.csv --auto
--
-- OU crie manualmente:
-- 1. Vá para Authentication → Users
-- 2. Clique em "Add user"
-- 3. Preencha email e senha
-- 4. Os dados serão sincronizados automaticamente via trigger
