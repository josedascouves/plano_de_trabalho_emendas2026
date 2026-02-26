-- ==============================================================================
-- FUNÇÃO RPC: Atualizar Senha de Usuário
-- ==============================================================================
--
-- ERRO: "This endpoint requires a valid Bearer token" ao editar senha
-- CAUSA: Client normal não tem acesso a supabase.auth.admin
-- SOLUÇÃO: Usar RPC function chamada do frontend
--
-- ==============================================================================

-- Criar função RPC para atualizar senha
-- ⚠️ Esta função requer que apenas admins possam atualizar senhas de outros
CREATE OR REPLACE FUNCTION public.update_user_password(
  user_id UUID,
  new_password TEXT
)
RETURNS JSON AS $$
DECLARE
  current_user_id UUID;
  target_user_role TEXT;
BEGIN
  -- Obter ID do usuário autenticado
  current_user_id := auth.uid();
  
  -- Verificar se existe usuário autenticado
  IF current_user_id IS NULL THEN
    RETURN json_build_object('error', 'Não autenticado');
  END IF;
  
  -- Verificar se é admin
  SELECT role INTO target_user_role
  FROM public.user_roles
  WHERE user_id = current_user_id
  LIMIT 1;
  
  IF target_user_role != 'admin' THEN
    RETURN json_build_object('error', 'Apenas administradores podem alterar senhas');
  END IF;
  
  -- Atualizar a senha via admin
  -- NOTA: Isso requer que a função seja executada com privilégios suficientes
  UPDATE auth.users
  SET 
    encrypted_password = crypt(new_password, gen_salt('bf')),
    updated_at = now()
  WHERE id = user_id;
  
  RETURN json_build_object(
    'success', true, 
    'message', 'Senha atualizada com sucesso'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Dar permissão para função ser chamada
GRANT EXECUTE ON FUNCTION public.update_user_password(UUID, TEXT) TO authenticated;

SELECT '✅ Função RPC criada: update_user_password' as resultado;

-- ==============================================================================
-- Verificação
-- ==============================================================================

SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public' 
  AND routine_name = 'update_user_password';

SELECT '
╔════════════════════════════════════════════════════╗
║  ✅ FUNÇÃO RPC CRIADA!                             ║
║                                                    ║
║  Agora pode editar senha de usuários              ║
║  sem erro de "Bearer token"!                      ║
╚════════════════════════════════════════════════════╝
' as mensagem;

-- ==============================================================================
