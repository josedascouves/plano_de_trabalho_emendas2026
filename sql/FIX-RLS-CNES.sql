-- ============================================================
-- CORRIGIR RLS PARA PERMITIR LEITURA E ESCRITA DE CNES
-- O problema: RLS estava bloqueando a coluna CNES
-- ============================================================

-- OPÇÃO 1: DESABILITAR RLS COMPLETAMENTE EM PROFILES
-- (Use isto se não precisa de RLS em profiles)
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- OU OPÇÃO 2: CRIAR POLICIES QUE PERMITEM LER/ESCREVER CNES
-- (Use isto se quer manter RLS mas permitir CNES)

-- Listar todas as policies existentes em profiles
SELECT policyname, permissive, qual, roles 
FROM pg_policies 
WHERE tablename = 'profiles';

-- Permitir que cada usuário leia seu próprio perfil (incluindo CNES)
DROP POLICY IF EXISTS "users_read_own_profile" ON public.profiles;
CREATE POLICY "users_read_own_profile" ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Permitir que cada usuário atualize seu próprio perfil (incluindo CNES)
DROP POLICY IF EXISTS "users_update_own_profile" ON public.profiles;
CREATE POLICY "users_update_own_profile" ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id);

-- Admins conseguem ler e escrever em qualquer profile
-- (isso requer que você tenha uma forma de verificar admin, 
--  ou use um campo de metadados na tabela auth.users)
DROP POLICY IF EXISTS "admins_all_access_profiles" ON public.profiles;
CREATE POLICY "admins_all_access_profiles" ON public.profiles
  FOR ALL
  USING (auth.uid() IN (
    SELECT id FROM public.profiles 
    WHERE role = 'admin'
  ));

-- ============================================================
-- TESTE: Verificar se funciona agora
-- ============================================================

SELECT 
  id,
  full_name,
  email,
  cnes,
  role
FROM public.profiles
LIMIT 5;

-- ============================================================
-- Se ainda não funcionar, execute isto para ver o CNES do usuário logado:
-- ============================================================
-- Descomente a linha abaixo se precisar testar como um usuário específico
-- SELECT cnes FROM public.profiles WHERE id = 'SEU-UUID-AQUI';
