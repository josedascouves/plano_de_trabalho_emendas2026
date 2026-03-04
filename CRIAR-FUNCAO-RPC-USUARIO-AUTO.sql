-- ============================================================================
-- CRIAR FUNÇÃO RPC PARA CRIAR USUÁRIOS AUTOMATICAMENTE
-- ============================================================================
-- Execute no Supabase SQL Editor
-- ============================================================================

CREATE OR REPLACE FUNCTION criar_usuario_automático(
  p_email TEXT,
  p_password TEXT,
  p_full_name TEXT,
  p_cnes TEXT,
  p_role TEXT DEFAULT 'user'
)
RETURNS json AS $$
DECLARE
  v_user_id uuid;
  v_result json;
BEGIN
  -- Criar usuário em auth.users usando admin API
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    confirmation_token,
    recovery_token,
    email_change_token_new,
    email_change_token_old,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    p_email,
    crypt(p_password, gen_salt('bf', 10)),
    NOW(),
    NOW(),
    NOW(),
    '',
    '',
    '',
    '',
    '{"provider":"email","providers":["email"]}',
    jsonb_build_object('full_name', p_full_name, 'cnes', p_cnes),
    false
  )
  RETURNING id INTO v_user_id;

  -- Criar profile
  INSERT INTO public.profiles (
    id,
    email,
    full_name,
    cnes
  ) VALUES (
    v_user_id,
    p_email,
    p_full_name,
    p_cnes
  );

  -- Criar user_role
  INSERT INTO public.user_roles (
    user_id,
    role,
    disabled
  ) VALUES (
    v_user_id,
    p_role,
    false
  );

  -- Retornar sucesso
  v_result := json_build_object(
    'success', true,
    'user_id', v_user_id,
    'email', p_email,
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
$$ LANGUAGE plpgsql SECURITY DEFINER;
