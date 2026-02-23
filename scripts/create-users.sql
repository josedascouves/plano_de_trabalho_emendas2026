-- ==============================================================================
-- Script SQL para importar usuários no Supabase
-- ==============================================================================
-- 
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com e selecione seu projeto
-- 2. Vá para SQL Editor
-- 3. Cole este script
-- 4. Execute o script
--
-- ⚠️ IMPORTANTE: Este script usa RPC auth.uid() que requer autenticação
--
-- ==============================================================================

-- Verificar se tabela de profiles existe e criar se necessário
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE,
  email text NOT NULL,
  full_name text,
  cnes text,
  role text DEFAULT 'user',
  disabled boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  PRIMARY KEY (id)
);

-- Habilitar RLS na tabela
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Políticas de RLS
-- Admin pode ver todos
CREATE POLICY "Admins can view all profiles" ON public.profiles
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- Usuários podem ver seu próprio perfil
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT
  USING (id = auth.uid());

-- Admins podem atualizar todos
CREATE POLICY "Admins can update all profiles" ON public.profiles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- ==============================================================================
-- DADOS DOS USUÁRIOS (Substitua pelos dados reais)
-- ==============================================================================

-- OPÇÃO 1: Inserir usuários via procedure SQL no Supabase
-- (Será necessário usar a API de Admin ou Dashboard)

-- OPÇÃO 2: Se os usuários já foram criados, inserir os dados de profile
-- (Execute após criar os usuários via Dashboard ou API)

-- Exemplo de inserção de profile (após criar usuário):
/*
INSERT INTO public.profiles (id, email, full_name, cnes, role)
SELECT 
  u.id,
  u.email,
  u.user_metadata ->> 'full_name' as full_name,
  u.user_metadata ->> 'cnes' as cnes,
  'user' as role
FROM auth.users u
WHERE u.email NOT IN (SELECT email FROM public.profiles)
  AND u.user_metadata ->> 'full_name' IS NOT NULL;
*/

-- ==============================================================================
-- VERIFICAR USUÁRIOS CRIADOS
-- ==============================================================================

-- Listar todos os usuários com seus dados
SELECT 
  u.id,
  u.email,
  u.user_metadata ->> 'full_name' as full_name,
  u.user_metadata ->> 'cnes' as cnes,
  u.last_sign_in_at,
  u.created_at,
  p.role,
  p.disabled
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
ORDER BY u.created_at DESC;

-- Contar total de usuários
SELECT 
  COUNT(DISTINCT u.id) as total_users,
  COUNT(CASE WHEN u.last_sign_in_at IS NOT NULL THEN 1 END) as active_users,
  COUNT(CASE WHEN p.disabled = true THEN 1 END) as disabled_users
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id;

-- Listar usuários por CNES
SELECT 
  u.user_metadata ->> 'cnes' as cnes,
  u.email,
  u.user_metadata ->> 'full_name' as full_name,
  p.role,
  u.created_at
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE u.user_metadata ->> 'cnes' IS NOT NULL
ORDER BY u.user_metadata ->> 'cnes';

-- ==============================================================================
-- OPERAÇÕES DE MANUTENÇÃO
-- ==============================================================================

-- Redefinir senha de um usuário (use o email do usuário)
-- Execute via: SELECT auth.reset_password('email@exemplo.com')

-- Desabilitar usuário
-- UPDATE public.profiles SET disabled = true WHERE email = 'email@exemplo.com';

-- Reabilitar usuário
-- UPDATE public.profiles SET disabled = false WHERE email = 'email@exemplo.com';

-- Promover usuário para admin
-- UPDATE public.profiles SET role = 'admin' WHERE email = 'email@exemplo.com';

-- Rebaixar de admin para user
-- UPDATE public.profiles SET role = 'user' WHERE email = 'email@exemplo.com';

-- Deletar usuário (cuidado! Isso é irreversível)
-- DELETE FROM auth.users WHERE email = 'email@exemplo.com';

-- ==============================================================================
-- TRIGGER PARA SINCRONIZAR PROFILES AUTOMATICAMENTE
-- ==============================================================================

-- Criar função para sincronizar
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, cnes, role)
  VALUES (
    new.id,
    new.email,
    new.user_metadata ->> 'full_name',
    new.user_metadata ->> 'cnes',
    'user'
  )
  ON CONFLICT (id) DO UPDATE
  SET 
    email = new.email,
    full_name = new.user_metadata ->> 'full_name',
    cnes = new.user_metadata ->> 'cnes',
    updated_at = timezone('utc'::text, now());
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
