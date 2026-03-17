-- ============================================================================
-- ATUALIZAR FUNCAO RPC - CRIAR USUARIO COM IDENTITY (CORRIGIDO)
-- ============================================================================
-- PROBLEMA: A funcao antiga NAO criava auth.identities, causando
--           "Database error querying schema" no login.
-- SOLUCAO: Esta versao cria auth.users + auth.identities + profiles + user_roles
--
-- Execute no SQL Editor do Supabase:
-- https://supabase.com/dashboard/project/tlpmspfnswaxwqzmwski/sql/new
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Dropar funcao antiga
DROP FUNCTION IF EXISTS criar_usuario_automático(text, text, text, text, text);

-- Criar funcao corrigida
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
  -- Verificar se usuario ja existe
  SELECT id INTO v_user_id FROM auth.users WHERE email = LOWER(TRIM(p_email)) LIMIT 1;
  
  IF v_user_id IS NOT NULL THEN
    v_result := json_build_object(
      'success', false,
      'error', 'Já existe um usuário com este e-mail: ' || p_email
    );
    RETURN v_result;
  END IF;

  -- 1. Criar usuario em auth.users
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new, email_change,
    raw_app_meta_data, raw_user_meta_data, is_super_admin
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    LOWER(TRIM(p_email)),
    crypt(p_password, gen_salt('bf', 10)),
    NOW(), NOW(), NOW(),
    '', '', '', '',
    '{"provider":"email","providers":["email"]}',
    jsonb_build_object('full_name', p_full_name, 'cnes', p_cnes),
    false
  )
  RETURNING id INTO v_user_id;

  -- 2. CRIAR IDENTITY (ESSENCIAL para login funcionar!)
  INSERT INTO auth.identities (
    id, user_id, identity_data, provider, provider_id,
    last_sign_in_at, created_at, updated_at
  ) VALUES (
    gen_random_uuid(),
    v_user_id,
    jsonb_build_object(
      'sub', v_user_id::text,
      'email', LOWER(TRIM(p_email)),
      'email_verified', true,
      'phone_verified', false
    ),
    'email',
    v_user_id::text,
    NOW(), NOW(), NOW()
  );

  -- 3. Criar profile
  INSERT INTO public.profiles (id, email, full_name, cnes)
  VALUES (v_user_id, LOWER(TRIM(p_email)), p_full_name, p_cnes)
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    cnes = EXCLUDED.cnes;

  -- 4. Criar user_role
  INSERT INTO public.user_roles (user_id, role, disabled)
  VALUES (v_user_id, p_role, false)
  ON CONFLICT (user_id) DO UPDATE SET
    role = EXCLUDED.role,
    disabled = false;

  -- Retornar sucesso
  v_result := json_build_object(
    'success', true,
    'user_id', v_user_id,
    'email', LOWER(TRIM(p_email)),
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

-- ============================================================================
-- FUNCAO PARA CRIAR VARIOS USUARIOS DE UMA VEZ (BULK/CSV)
-- ============================================================================
-- Recebe um array JSON de usuarios e cria todos de uma vez
-- Retorna resultado detalhado por usuario
-- ============================================================================

CREATE OR REPLACE FUNCTION criar_usuarios_em_lote(
  p_usuarios JSON
)
RETURNS json AS $$
DECLARE
  v_user RECORD;
  v_user_id uuid;
  v_results json[] := '{}';
  v_total int := 0;
  v_sucesso int := 0;
  v_erro int := 0;
  v_email text;
  v_password text;
  v_full_name text;
  v_cnes text;
  v_role text;
BEGIN
  -- Iterar sobre cada usuario no array JSON
  FOR v_user IN SELECT * FROM json_array_elements(p_usuarios) AS elem
  LOOP
    v_total := v_total + 1;
    v_email := LOWER(TRIM(v_user.elem->>'email'));
    v_password := v_user.elem->>'senha';
    v_full_name := UPPER(TRIM(v_user.elem->>'nome'));
    v_cnes := TRIM(v_user.elem->>'cnes');
    v_role := COALESCE(NULLIF(TRIM(v_user.elem->>'role'), ''), 'user');
    
    -- Validacoes basicas
    IF v_email IS NULL OR v_email = '' THEN
      v_erro := v_erro + 1;
      v_results := array_append(v_results, json_build_object(
        'email', v_email, 'success', false, 'error', 'Email vazio'
      ));
      CONTINUE;
    END IF;
    
    IF v_password IS NULL OR v_password = '' THEN
      -- Se senha nao foi fornecida, usar CNES como senha
      v_password := v_cnes;
    END IF;
    
    IF v_password IS NULL OR length(v_password) < 6 THEN
      v_erro := v_erro + 1;
      v_results := array_append(v_results, json_build_object(
        'email', v_email, 'success', false, 'error', 'Senha muito curta (minimo 6 caracteres)'
      ));
      CONTINUE;
    END IF;

    BEGIN
      -- Verificar se ja existe
      SELECT id INTO v_user_id FROM auth.users WHERE email = v_email LIMIT 1;
      
      IF v_user_id IS NOT NULL THEN
        -- Usuario ja existe, apenas atualizar senha e dados
        UPDATE auth.users SET 
          encrypted_password = crypt(v_password, gen_salt('bf', 10)),
          updated_at = NOW()
        WHERE id = v_user_id;
        
        -- Garantir que tem identity
        IF NOT EXISTS (SELECT 1 FROM auth.identities WHERE user_id = v_user_id AND provider = 'email') THEN
          INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
          VALUES (gen_random_uuid(), v_user_id,
            jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true, 'phone_verified', false),
            'email', v_user_id::text, NOW(), NOW(), NOW());
        END IF;
        
        -- Atualizar profile
        INSERT INTO public.profiles (id, email, full_name, cnes)
        VALUES (v_user_id, v_email, v_full_name, v_cnes)
        ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
        
        -- Atualizar user_role
        INSERT INTO public.user_roles (user_id, role, disabled)
        VALUES (v_user_id, v_role, false)
        ON CONFLICT (user_id) DO UPDATE SET role = EXCLUDED.role, disabled = false;
        
        v_sucesso := v_sucesso + 1;
        v_results := array_append(v_results, json_build_object(
          'email', v_email, 'nome', v_full_name, 'success', true, 'message', 'Atualizado (ja existia)'
        ));
      ELSE
        -- Criar usuario novo completo
        INSERT INTO auth.users (
          instance_id, id, aud, role, email, encrypted_password,
          email_confirmed_at, created_at, updated_at,
          confirmation_token, recovery_token, email_change_token_new, email_change,
          raw_app_meta_data, raw_user_meta_data, is_super_admin
        ) VALUES (
          '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
          v_email, crypt(v_password, gen_salt('bf', 10)), NOW(), NOW(), NOW(),
          '', '', '', '',
          '{"provider":"email","providers":["email"]}',
          jsonb_build_object('full_name', v_full_name, 'cnes', v_cnes),
          false
        ) RETURNING id INTO v_user_id;
        
        -- Criar identity
        INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
        VALUES (gen_random_uuid(), v_user_id,
          jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true, 'phone_verified', false),
          'email', v_user_id::text, NOW(), NOW(), NOW());
        
        -- Criar profile
        INSERT INTO public.profiles (id, email, full_name, cnes)
        VALUES (v_user_id, v_email, v_full_name, v_cnes);
        
        -- Criar user_role
        INSERT INTO public.user_roles (user_id, role, disabled)
        VALUES (v_user_id, v_role, false);
        
        v_sucesso := v_sucesso + 1;
        v_results := array_append(v_results, json_build_object(
          'email', v_email, 'nome', v_full_name, 'success', true, 'message', 'Criado com sucesso'
        ));
      END IF;
    EXCEPTION WHEN OTHERS THEN
      v_erro := v_erro + 1;
      v_results := array_append(v_results, json_build_object(
        'email', v_email, 'nome', v_full_name, 'success', false, 'error', SQLERRM
      ));
    END;
  END LOOP;

  RETURN json_build_object(
    'success', true,
    'total', v_total,
    'criados', v_sucesso,
    'erros', v_erro,
    'detalhes', array_to_json(v_results)
  );

EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- TESTE: Verificar que as funcoes foram criadas
-- ============================================================================
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines 
WHERE routine_schema = 'public'
AND routine_name IN ('criar_usuario_automático', 'criar_usuarios_em_lote')
ORDER BY routine_name;
