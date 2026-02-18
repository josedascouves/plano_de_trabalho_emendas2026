-- ============================================================
-- FIX-RBAC-ERRO-500.sql
-- ⭐ ATENÇÃO: Veja SOLUCAO-RAPIDA-ERRO-500.md para instruções
-- 📌 RECOMENDADO: Use LIMPEZA-E-SETUP-COMPLETO.sql (mais fácil!)
-- ============================================================
--
-- Este arquivo é um GUIA com passos:
-- PASSO 1: Diagnóstico (verificar problemas)
-- PASSO 2: Limpeza (deletar objetos antigos)
-- PASSO 3-8: Validação e setup
--
-- ⚡ MAIS FÁCIL: Abra LIMPEZA-E-SETUP-COMPLETO.sql e execute tudo

-- ============================================================
-- PASSO 1: DIAGNÓSTICO
-- ============================================================

-- 1.1 Verificar se profiles existe
SELECT 'profiles' as table_name, EXISTS(
  SELECT 1 FROM information_schema.tables 
  WHERE table_schema = 'public' AND table_name = 'profiles'
) as exists;

-- 1.2 Verificar estrutura de profiles
-- \d public.profiles

-- 1.3 Verificar RLS status
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'profiles';

-- 1.4 Listar todas as políticas RLS em profiles
SELECT policyname, permissive, qual, with_check
FROM pg_policies 
WHERE tablename = 'profiles'
ORDER BY policyname;

-- 1.5 Contar linhas em profiles
SELECT COUNT(*) as total_profiles FROM public.profiles;

-- 1.6 Ver um exemplo de profile
SELECT id, role, full_name, email, disabled FROM public.profiles LIMIT 1;

-- ============================================================
-- PASSO 2: LIMPEZA COMPLETA (se tudo falhar)
-- ============================================================

-- ⚠️ AVISO: Este passo deletará TUDO! Só execute se nada mais funcionar!

-- Desabilitar RLS temporariamente
ALTER TABLE IF EXISTS public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.audit_logs DISABLE ROW LEVEL SECURITY;

-- Deletar todas as políticas
DROP POLICY IF EXISTS "admin_see_all_profiles" ON public.profiles;
DROP POLICY IF EXISTS "user_see_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_update_all_profiles" ON public.profiles;
DROP POLICY IF EXISTS "user_update_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_create_profiles" ON public.profiles;
DROP POLICY IF EXISTS "admin_delete_profiles" ON public.profiles;
DROP POLICY IF EXISTS "admin_view_all_audit_logs" ON public.audit_logs;
DROP POLICY IF EXISTS "user_view_own_audit_logs" ON public.audit_logs;
DROP POLICY IF EXISTS "system_insert_audit_logs" ON public.audit_logs;

-- Deletar views
DROP VIEW IF EXISTS public.user_statistics;

-- Deletar triggers
DROP TRIGGER IF EXISTS profiles_update_timestamp ON public.profiles;
DROP FUNCTION IF EXISTS public.update_profiles_timestamp();

-- Deletar funções
DROP FUNCTION IF EXISTS public.promote_user_to_admin(UUID);
DROP FUNCTION IF EXISTS public.demote_admin_to_user(UUID);
DROP FUNCTION IF EXISTS public.reset_user_password(UUID);
DROP FUNCTION IF EXISTS public.toggle_user_status(UUID, BOOLEAN);
DROP FUNCTION IF EXISTS public.change_own_password(VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS public.change_user_password_admin(UUID, VARCHAR);
DROP FUNCTION IF EXISTS public.delete_user_admin(UUID);

-- Deletar tabelas
DROP TABLE IF EXISTS public.audit_logs CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- ============================================================
-- PASSO 3: VERIFICAR DEPOIS DA LIMPEZA
-- ============================================================

-- Confirmar que tudo foi deletado
-- SELECT COUNT(*) FROM information_schema.tables 
-- WHERE table_schema = 'public' AND table_name IN ('profiles', 'audit_logs');

-- Esperado: 0 (zero)

-- ============================================================
-- PASSO 4: RE-EXECUTAR SETUP (AUTOMÁTICO)
-- ============================================================

-- ⭐ RECOMENDADO: Use o arquivo LIMPEZA-E-SETUP-COMPLETO.sql
-- Ele faz tudo automaticamente (limpeza + setup) em uma única execução
-- Muito mais fácil e seguro!

-- Se você preferir fazer manual:
-- Copie TODO o conteúdo de setup-rbac-completo.sql
-- E execute aqui (depois dos PASSOS 1-3)

-- ============================================================
-- PASSO 5: CRIAR ADMIN INICIAL
-- ============================================================

-- Agora você precisa criar o primeiro ADMIN fazendo:
-- 1. Vá ao Supabase: Authentication > Users
-- 2. Crie um novo usuário (ou use um existente)
-- 3. Copie o UUID do usuário
-- 4. Execute este comando aqui:

-- SUBSTITUA OS VALORES:
--
-- INSERT INTO public.profiles (id, role, full_name, email, created_at, updated_at)
-- VALUES (
--   '00000000-0000-0000-0000-000000000000',  <-- COLE O UUID AQUI
--   'admin',
--   'Seu Nome Completo',
--   'seu.email@domain.com',
--   now(),
--   now()
-- );
--
-- Depois execute (remova os -- das linhas acima primeiro)

-- ============================================================
-- PASSO 6: VALIDAR SETUP
-- ============================================================

-- Verificar que admin foi criado
SELECT id, role, full_name FROM public.profiles WHERE role = 'admin';

-- Esperado: Uma linha com role = 'admin'

-- ============================================================
-- PASSO 7: TESTE DE LEITURA (sem RLS)
-- ============================================================

-- Desabilitar RLS temporariamente para teste
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- Tentar ler
SELECT id, full_name, email, role FROM public.profiles;

-- Resultado esperado: Seu admin deve aparecer

-- Habilitar RLS de novo
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PASSO 8: TESTE DE RLS
-- ============================================================

-- Agora teste no navegador fazendo login
-- F12 > Console > Copie:
-- window.supabase.auth.getUser().then(u => console.log(u.data.user.id))

-- Compare o UUID do seu usuário com o de profiles
-- SELECT id FROM public.profiles WHERE id = 'COLE-AQUI-O-UUID';

-- Se retornar 1 linha, RLS está funcionando

-- ============================================================
-- FIM - Se tudo passou, o sistema está funcionando!
-- ============================================================
