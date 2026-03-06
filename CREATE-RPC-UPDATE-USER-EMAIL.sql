-- RPC Function para atualizar o email do usuário no auth.users
-- Execute esta função uma única vez no Supabase SQL Editor

CREATE OR REPLACE FUNCTION update_user_email(user_id UUID, new_email TEXT)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  -- Atualizar email na tabela auth.users
  UPDATE auth.users
  SET email = new_email,
      raw_user_meta_data = raw_user_meta_data || jsonb_build_object('email', new_email),
      email_confirmed_at = CASE 
        WHEN email_confirmed_at IS NOT NULL THEN NOW() 
        ELSE email_confirmed_at 
      END
  WHERE id = user_id;

  result := json_build_object(
    'success', true,
    'message', 'Email atualizado com sucesso'
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

-- Teste da função:
-- SELECT update_user_email('uuid-do-usuario', 'novo-email@example.com');
