-- ==============================================================================
-- SCRIPT: Desabilitar trigger, criar usuários via API, depois reabilitar
-- ==============================================================================
-- Execute isso no SQL Editor do Supabase ANTES de tentar importar

-- 1. Desabilitar trigger (se existir)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2. Dropa função anterior se existir
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 3. Este script irá sincronizar os usuários criados após serem criados via API
-- Por enquanto, deixe o banco sem o trigger automático

-- Confirme que não há mais trigger:
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';

-- ==============================================================================
-- PRÓXIMO PASSO: Execute o script Python para criar usuários
-- python scripts/import_users_simple.py usuarios.csv --auto
-- ==============================================================================

-- Depois que os usuários forem criados, execute isto para sincronizar profiles:
INSERT INTO public.profiles (id, email, full_name, cnes, role)
SELECT 
  u.id,
  u.email,
  u.user_metadata ->> 'full_name' as full_name,
  u.user_metadata ->> 'cnes' as cnes,
  'user' as role
FROM auth.users u
WHERE u.email NOT IN (SELECT email FROM public.profiles WHERE email IS NOT NULL)
  AND u.user_metadata ->> 'full_name' IS NOT NULL
ON CONFLICT (id) DO NOTHING;

-- ==============================================================================
-- RECRIAR TRIGGER (após usuários serem criados)
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  BEGIN
    INSERT INTO public.profiles (id, email, full_name, cnes, role)
    VALUES (
      new.id,
      new.email,
      new.user_metadata ->> 'full_name',
      new.user_metadata ->> 'cnes',
      'user'
    )
    ON CONFLICT (id) DO UPDATE
    SET 
      email = new.email,
      full_name = new.user_metadata ->> 'full_name',
      cnes = new.user_metadata ->> 'cnes',
      updated_at = timezone('utc'::text, now());
  EXCEPTION WHEN OTHERS THEN
    -- Ignora erros (por exemplo, se o nome tive mais de 255 caracteres)
    NULL;
  END;
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ==============================================================================
-- VERIFICAR RESULTADO
-- ==============================================================================

SELECT COUNT(*) as total_users_created FROM auth.users;
SELECT COUNT(*) as total_profiles_created FROM public.profiles;

-- Ver últimos usuários criados
SELECT 
  u.email,
  u.user_metadata ->> 'full_name' as full_name,
  u.user_metadata ->> 'cnes' as cnes,
  u.created_at,
  p.role,
  p.disabled
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
ORDER BY u.created_at DESC
LIMIT 30;
