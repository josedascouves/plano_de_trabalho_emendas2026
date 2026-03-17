-- RPC Function SIMPLIFICADA para criar um usuário individual
-- Esta versão usa JSON como parâmetro para evitar problemas de ordem
-- Execute esta função no Supabase SQL Editor

-- PASSO 1: DROP da função anterior se existir
DROP FUNCTION IF EXISTS public.criar_usuario_individual(TEXT, TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.criar_usuario_individual(JSON) CASCADE;

-- PASSO 2: Verificar se pgcrypto está habilitada
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- PASSO 3: Criar a RPC function com JSON
CREATE OR REPLACE FUNCTION public.criar_usuario_individual(p_usuario JSON)
RETURNS JSON AS $$
DECLARE
  v_email TEXT;
  v_senha TEXT;
  v_nome TEXT;
  v_cnes TEXT;
  v_user_id UUID;
  v_encrypted_password TEXT;
  v_result JSON;
BEGIN
  -- Extrair valores do JSON
  v_email := p_usuario ->> 'email';
  v_senha := p_usuario ->> 'senha';
  v_nome := p_usuario ->> 'nome';
  v_cnes := p_usuario ->> 'cnes';

  -- Validação
  IF v_email IS NULL OR v_email = '' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Email inválido'
    );
  END IF;

  IF v_senha IS NULL OR v_senha = '' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Senha inválida'
    );
  END IF;

  -- Verificar se usuário já existe
  IF EXISTS (SELECT 1 FROM auth.users WHERE email = v_email) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário com este email já existe'
    );
  END IF;

  -- Gerar hash da senha usando Bcrypt
  v_encrypted_password := crypt(v_senha, gen_salt('bf'));

  -- 1️⃣ Criar usuário em auth.users
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
  )
  VALUES (
    gen_random_uuid(),
    '00000000-0000-0000-0000-000000000000',
    v_email,
    v_encrypted_password,
    NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('full_name', v_nome, 'email', v_email),
    NOW(),
    NOW()
  )
  RETURNING id INTO v_user_id;

  -- 2️⃣ Criar perfil em profiles
  INSERT INTO public.profiles (
    id,
    full_name,
    email,
    cnes,
    created_at,
    updated_at
  )
  VALUES (
    v_user_id,
    v_nome,
    v_email,
    v_cnes,
    NOW(),
    NOW()
  );

  -- 3️⃣ Criar role de usuário em user_roles
  INSERT INTO public.user_roles (
    user_id,
    role,
    disabled,
    created_at
  )
  VALUES (
    v_user_id,
    'user',
    false,
    NOW()
  );

  v_result := json_build_object(
    'success', true,
    'user_id', v_user_id,
    'email', v_email,
    'message', 'Usuário criado com sucesso'
  );

  RETURN v_result;

EXCEPTION WHEN OTHERS THEN
  v_result := json_build_object(
    'success', false,
    'error', SQLERRM
  );
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

-- PASSO 4: Dar permissões
GRANT EXECUTE ON FUNCTION public.criar_usuario_individual(p_usuario JSON) TO anon, authenticated;

-- Teste
SELECT 'RPC Function criar_usuario_individual (versão JSON) criada com sucesso!' as resultado;
