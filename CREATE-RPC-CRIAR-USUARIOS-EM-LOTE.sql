-- RPC Function para criar múltiplos usuários a partir de um JSON
-- Execute esta função uma única vez no Supabase SQL Editor

CREATE OR REPLACE FUNCTION public.criar_usuarios_em_lote(p_usuarios JSONB)
RETURNS JSONB AS $$
DECLARE
  v_usuario JSONB;
  v_user_id UUID;
  v_total INT := 0;
  v_criados INT := 0;
  v_erros INT := 0;
  v_erro_msgs TEXT[] := ARRAY[]::TEXT[];
  v_resultado TEXT;
BEGIN
  -- Iterar sobre cada usuário no array JSON
  FOR v_usuario IN SELECT jsonb_array_elements(p_usuarios) LOOP
    v_total := v_total + 1;
    
    BEGIN
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
        updated_at,
        last_sign_in_at,
        confirmation_token,
        recovery_token,
        email_change,
        email_change_token_new,
        recovery_sent_at
      )
      VALUES (
        gen_random_uuid(),
        '00000000-0000-0000-0000-000000000000',
        v_usuario ->> 'email',
        crypt(v_usuario ->> 'senha', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        jsonb_build_object('full_name', v_usuario ->> 'nome', 'email', v_usuario ->> 'email'),
        NOW(),
        NOW(),
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
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
        v_usuario ->> 'nome',
        v_usuario ->> 'email',
        v_usuario ->> 'cnes',
        NOW(),
        NOW()
      );

      -- 3️⃣ Criar role de usuário em user_roles
      INSERT INTO public.user_roles (
        user_id,
        role,
        created_at
      )
      VALUES (
        v_user_id,
        'user',
        NOW()
      );

      v_criados := v_criados + 1;
      v_resultado := 'Sucesso';
      
    EXCEPTION WHEN OTHERS THEN
      v_erros := v_erros + 1;
      v_erro_msgs := array_append(
        v_erro_msgs,
        v_total || '. ' || COALESCE(v_usuario ->> 'email', 'Email inválido') || ': ' || SQLERRM
      );
    END;
  END LOOP;

  RETURN jsonb_build_object(
    'success', v_erros = 0,
    'total', v_total,
    'criados', v_criados,
    'erros', v_erros,
    'mensagens_erro', v_erro_msgs
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object(
    'success', FALSE,
    'error', 'Erro fatal ao processar: ' || SQLERRM,
    'total', v_total
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

-- Grant permissões necessárias
GRANT EXECUTE ON FUNCTION public.criar_usuarios_em_lote(p_usuarios JSONB) TO anon, authenticated;

SELECT 'RPC Function criar_usuarios_em_lote criada com sucesso!' as resultado;
