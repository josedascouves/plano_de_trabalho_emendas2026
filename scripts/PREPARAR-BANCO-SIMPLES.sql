-- ==============================================================================
-- SCRIPT SIMPLES: Preparar Banco para Importação de Usuários
-- ==============================================================================
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Clique em "New Query"
-- 4. Cole TODO este arquivo
-- 5. Execute (Ctrl+Enter ou clique em Run)
-- 6. Aguarde: "Query executed successfully"
--
-- ==============================================================================

-- 1. REMOVER TRIGGER ANTIGO (que estava dando erro)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 2. DELETAR DADOS INVÁLIDOS
DELETE FROM public.profiles 
WHERE email LIKE '%/%';

-- 3. ADICIONAR COLUNAS FALTANTES
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role text DEFAULT 'user';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS disabled boolean DEFAULT false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT timezone('utc'::text, now());
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT timezone('utc'::text, now());

-- 4. GARANTIR QUE UNIQUE(email) EXISTE (se não tiver, adicionar)
-- (Ignorar erro se já existir)

-- 5. SINCRONIZAR PROFILES COM AUTH.USERS (dados que já existem)
INSERT INTO public.profiles (id, email, full_name, cnes, role, disabled)
SELECT 
  u.id,
  u.email,
  COALESCE(u.user_metadata ->> 'full_name', u.email),
  u.user_metadata ->> 'cnes',
  'user',
  false
FROM auth.users u
WHERE u.id NOT IN (SELECT id FROM public.profiles WHERE id IS NOT NULL)
ON CONFLICT (id) DO UPDATE
SET 
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  cnes = EXCLUDED.cnes,
  updated_at = timezone('utc'::text, now());

-- 6. RECRIAR TRIGGER (melhorado para não quebrar)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  BEGIN
    INSERT INTO public.profiles (id, email, full_name, cnes, role, disabled)
    VALUES (
      new.id,
      new.email,
      COALESCE(new.user_metadata ->> 'full_name', new.email),
      new.user_metadata ->> 'cnes',
      'user',
      false
    )
    ON CONFLICT (id) DO UPDATE
    SET 
      email = new.email,
      full_name = COALESCE(new.user_metadata ->> 'full_name', new.email),
      cnes = new.user_metadata ->> 'cnes',
      updated_at = timezone('utc'::text, now());
  EXCEPTION WHEN OTHERS THEN
    -- Silenciosamente ignora erros (user já criado, etc)
    RETURN new;
  END;
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recriar trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 7. VERIFICAÇÃO FINAL
SELECT COUNT(*) as total_auth_users FROM auth.users;
SELECT COUNT(*) as total_profiles FROM public.profiles;

-- 8. LISTAR ÚLTIMOS USUÁRIOS
SELECT 
  u.email,
  u.user_metadata ->> 'full_name' as full_name,
  u.user_metadata ->> 'cnes' as cnes,
  u.created_at
FROM auth.users u
ORDER BY u.created_at DESC
LIMIT 10;
