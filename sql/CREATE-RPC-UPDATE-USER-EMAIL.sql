-- RPC Function para atualizar o email do usuário no auth.users + auth.identities + profiles
-- Execute esta função uma única vez no Supabase SQL Editor
-- IMPORTANTE: Atualiza TODAS as tabelas necessárias para que o login funcione com o novo email

-- Dropar função antiga (necessário para renomear parâmetros)
DROP FUNCTION IF EXISTS public.update_user_email(UUID, TEXT);

CREATE OR REPLACE FUNCTION update_user_email(user_id UUID, new_email TEXT)
RETURNS JSON AS $$
DECLARE
  result JSON;
  v_email TEXT;
BEGIN
  v_email := LOWER(TRIM(new_email));
  
  -- Verificar se o email já está em uso por outro usuário
  IF EXISTS (SELECT 1 FROM auth.users u WHERE u.email = v_email AND u.id != user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Este email já está em uso por outro usuário'
    );
  END IF;

  -- 1️⃣ Atualizar email na tabela auth.users
  UPDATE auth.users u
  SET email = v_email,
      raw_user_meta_data = u.raw_user_meta_data || jsonb_build_object('email', v_email),
      updated_at = NOW(),
      email_confirmed_at = CASE 
        WHEN u.email_confirmed_at IS NOT NULL THEN NOW() 
        ELSE u.email_confirmed_at 
      END
  WHERE u.id = update_user_email.user_id;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado em auth.users'
    );
  END IF;

  -- 2️⃣ Atualizar email na tabela auth.identities (ESSENCIAL para login funcionar!)
  UPDATE auth.identities i
  SET identity_data = i.identity_data || jsonb_build_object('email', v_email),
      updated_at = NOW()
  WHERE i.user_id = update_user_email.user_id
    AND i.provider = 'email';

  -- 3️⃣ Atualizar email na tabela profiles
  UPDATE public.profiles p
  SET email = v_email,
      updated_at = NOW()
  WHERE p.id = update_user_email.user_id;

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

-- Forçar reload do schema cache do PostgREST
NOTIFY pgrst, 'reload schema';

-- Teste da função:
-- SELECT update_user_email('uuid-do-usuario', 'novo-email@example.com');
