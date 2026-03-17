-- === RPC SIMPLES E CONFIÁVEL PARA CRIAR USUÁRIOS ===
-- Remova ANY old functions first
DROP FUNCTION IF EXISTS public.criar_usuario_individual(TEXT, TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.criar_usuario_individual(JSON) CASCADE;

-- Create the simple function
CREATE OR REPLACE FUNCTION public.criar_usuario_individual(
  p_email TEXT,
  p_senha TEXT,
  p_nome TEXT,
  p_cnes TEXT
)
RETURNS json AS $$
DECLARE
  v_user_id UUID;
  v_result_json json;
BEGIN
  
  -- Criar usuário com signup simples
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    email,
    encrypted_password,
    email_confirmed_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    created_at,
    updated_at,
    phone,
    phone_confirmed_at,
    confirmation_token,
    recovery_token,
    email_change,
    email_change_token_new
  )
  VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    p_email,
    crypt(p_senha, gen_salt('bf')),
    NOW(),
    NULL,
    json_build_object('provider','email','providers',array['email']),
    json_build_object('full_name', p_nome, 'cnes', p_cnes),
    false,
    NOW(),
    NOW(),
    NULL,
    NULL,
    '',
    '',
    '',
    ''
  ) RETURNING id INTO v_user_id;
  
  -- Criar profile
  INSERT INTO public.profiles (id, full_name, email, cnes, created_at, updated_at)
  VALUES (v_user_id, p_nome, p_email, p_cnes, NOW(), NOW())
  ON CONFLICT (id) DO UPDATE
  SET full_name = p_nome, email = p_email, cnes = p_cnes, updated_at = NOW();
  
  -- Criar user_role
  INSERT INTO public.user_roles (user_id, role, created_at)
  VALUES (v_user_id, 'user', NOW())
  ON CONFLICT (user_id) DO NOTHING;
  
  v_result_json := json_build_object(
    'success', true,
    'user_id', v_user_id,
    'email', p_email
  );
  
  RETURN v_result_json;
  
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, auth;

GRANT EXECUTE ON FUNCTION public.criar_usuario_individual(TEXT, TEXT, TEXT, TEXT) TO authenticated, anon;

SELECT '✅ RPC SEM PROBLEMAS CRIADA!' as msg;
