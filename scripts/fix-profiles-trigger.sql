-- ==============================================================================
-- Script para desabilitar trigger e recriar profiles
-- ==============================================================================

-- 1. Desabilitar trigger temporariamente (se existir)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2. Limpar perfis com dados inválidos
DELETE FROM public.profiles 
WHERE email IN (
  'escritoriodeprojetos@hospitaldeamor.com.br / ebenezer.marques@hospitaldeamor.com.br',
  'administracao1@scma.org.br / administraacao@scma.org.br / contratos@scma.org.br'
);

-- 3. Recriar trigger de forma mais robusta
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, cnes, role)
  VALUES (
    new.id,
    new.email,
    new.user_metadata ->> 'full_name',
    new.user_metadata ->> 'cnes',
    'user'
  )
  ON CONFLICT (id) DO NOTHING; -- Ignorar se já existe
  
  RETURN new;
EXCEPTION WHEN OTHERS THEN
  -- Ignorar erro no trigger
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Recriar trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Verificar quanto está atualmente na base
SELECT COUNT(*) as total_users FROM auth.users;
SELECT COUNT(*) as total_profiles FROM public.profiles;

-- 6. Listar usuários criados
SELECT 
  u.email,
  u.user_metadata ->> 'full_name' as full_name,
  u.user_metadata ->> 'cnes' as cnes,
  u.created_at,
  p.id,
  p.role
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
ORDER BY u.created_at DESC;
