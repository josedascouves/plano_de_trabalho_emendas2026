-- ============================================================================
-- CRIAR FUNÇÃO RPC PARA SINCRONIZAR USUÁRIOS ÓRFÃOS
-- ============================================================================
-- Esta função permite que a aplicação sincronize automaticamente usuários
-- que existem em auth.users mas não têm perfil em profiles/user_roles
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Cole este arquivo TODO
-- 4. Execute (Ctrl+Enter)
-- ============================================================================

BEGIN;

-- Desabilitar RLS para a função ter acesso total
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- FUNÇÃO: sincronizar_usuario_orfao
-- ============================================================================
-- Input: email do usuário
-- Output: JSON com status e resultado
-- Propósito: Sincronizar automaticamente usuário de auth.users para profiles

CREATE OR REPLACE FUNCTION public.sincronizar_usuario_orfao(
  p_email TEXT,
  p_cnes TEXT DEFAULT NULL,
  p_role TEXT DEFAULT 'user'
)
RETURNS JSON AS $$
DECLARE
  v_user_id UUID;
  v_full_name TEXT;
  v_result JSON;
BEGIN
  -- 1. Buscar o usuário em auth.users
  SELECT id, raw_user_meta_data->>'full_name'
  INTO v_user_id, v_full_name
  FROM auth.users
  WHERE email = p_email
  LIMIT 1;
  
  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'message', 'Usuário não encontrado em auth.users',
      'email', p_email
    );
  END IF;
  
  -- Se não temos full_name, usar o email como fallback
  IF v_full_name IS NULL THEN
    v_full_name := p_email;
  END IF;
  
  -- 2. Inserir ou atualizar em profiles
  INSERT INTO public.profiles (id, email, full_name, cnes, created_at)
  VALUES (v_user_id, p_email, v_full_name, COALESCE(p_cnes, ''), NOW())
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    cnes = COALESCE(EXCLUDED.cnes, public.profiles.cnes);
  
  -- 3. Inserir ou atualizar em user_roles
  INSERT INTO public.user_roles (user_id, role, disabled)
  VALUES (v_user_id, p_role, false)
  ON CONFLICT (user_id) DO UPDATE SET
    role = EXCLUDED.role,
    disabled = false;
  
  v_result := json_build_object(
    'success', true,
    'message', 'Usuário sincronizado com sucesso',
    'user_id', v_user_id,
    'email', p_email,
    'role', p_role
  );
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Re-habilitar RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- FUNÇÃO: sincronizar_todos_usuarios_orfaos
-- ============================================================================
-- Sincroniza TODOS os usuários órfãos de uma vez
-- Útil para limpeza em lote

CREATE OR REPLACE FUNCTION public.sincronizar_todos_usuarios_orfaos()
RETURNS TABLE(
  user_id UUID,
  email TEXT,
  full_name TEXT,
  status TEXT
) AS $$
BEGIN
  -- Desabilitar RLS temporariamente
  ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
  ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;
  
  -- Inserir profiles faltantes
  INSERT INTO public.profiles (id, email, full_name, cnes, created_at)
  SELECT 
    u.id,
    u.email,
    COALESCE(u.raw_user_meta_data->>'full_name', u.email),
    COALESCE(u.raw_user_meta_data->>'cnes', ''),
    u.created_at
  FROM auth.users u
  WHERE u.id NOT IN (SELECT id FROM public.profiles WHERE id IS NOT NULL)
  ON CONFLICT (id) DO NOTHING;
  
  -- Inserir user_roles faltantes
  INSERT INTO public.user_roles (user_id, role, disabled)
  SELECT 
    p.id,
    'user',
    false
  FROM public.profiles p
  WHERE p.id NOT IN (SELECT user_id FROM public.user_roles)
  ON CONFLICT (user_id) DO NOTHING;
  
  -- Re-habilitar RLS
  ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
  ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
  
  -- Retornar resultado
  RETURN QUERY
  SELECT 
    p.id,
    p.email,
    p.full_name,
    'Sincronizado'::TEXT
  FROM public.profiles p
  LEFT JOIN public.user_roles ur ON p.id = ur.user_id
  WHERE ur.user_id IS NOT NULL
  ORDER BY p.email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- TESTE: Você pode testar a função com:
-- SELECT public.sincronizar_usuario_orfao('email@exemplo.com', '0052124', 'intermediate');
-- ============================================================================

COMMIT;

SELECT '✅ Funções RPC criadas com sucesso!' as status;
