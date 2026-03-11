-- RPC Function para atualizar o email do usuário no auth.users + auth.identities + profiles
-- Execute esta função uma única vez no Supabase SQL Editor
-- IMPORTANTE: Atualiza TODAS as tabelas necessárias para que o login funcione com o novo email

CREATE OR REPLACE FUNCTION update_user_email(p_user_id UUID, p_new_email TEXT)
RETURNS JSON AS $$
DECLARE
  result JSON;
  v_email TEXT;
BEGIN
  v_email := LOWER(TRIM(p_new_email));
  
  -- Verificar se o email já está em uso por outro usuário
  IF EXISTS (SELECT 1 FROM auth.users WHERE email = v_email AND id != p_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Este email já está em uso por outro usuário'
    );
  END IF;

  -- 1️⃣ Atualizar email na tabela auth.users
  UPDATE auth.users
  SET email = v_email,
      raw_user_meta_data = raw_user_meta_data || jsonb_build_object('email', v_email),
      updated_at = NOW(),
      email_confirmed_at = CASE 
        WHEN email_confirmed_at IS NOT NULL THEN NOW() 
        ELSE email_confirmed_at 
      END
  WHERE id = p_user_id;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado em auth.users'
    );
  END IF;

  -- 2️⃣ Atualizar email na tabela auth.identities (ESSENCIAL para login funcionar!)
  UPDATE auth.identities
  SET identity_data = identity_data || jsonb_build_object('email', v_email),
      updated_at = NOW()
  WHERE auth.identities.user_id = p_user_id
    AND provider = 'email';

  -- 3️⃣ Atualizar email na tabela profiles
  UPDATE public.profiles
  SET email = v_email,
      updated_at = NOW()
  WHERE id = p_user_id;

  result := json_build_object(
    'success', true,
    'message', 'Email atualizado com sucesso em auth.users, auth.identities e profiles'
  );
  
  RETURN result;
EXCEPTION WHEN OTHERS THEN
  result := json_build_object(
    'success', false,
    'error', SQLERRM
  );
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

GRANT EXECUTE ON FUNCTION public.update_user_email(UUID, TEXT) TO authenticated;

-- Teste da função:
-- SELECT update_user_email('uuid-do-usuario', 'novo-email@example.com');
-- Os parametros são: p_user_id e p_new_email
-- Mas ao chamar via supabase.rpc, use: { user_id: '...', new_email: '...' }
