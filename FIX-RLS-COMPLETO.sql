-- ============================================================================
-- CORRIGIR RLS PARA PERMITIR LOGIN - SOLUÇÃO DEFINITIVA
-- ============================================================================
-- Desabilitar RLS em todas as tabelas públicas temporariamente
-- Isso permite que usuários façam login e acessem dados

-- 1. DESABILITAR RLS NA TABELA PROFILES (mais importante para login)
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- 2. DESABILITAR RLS NAS OUTRAS TABELAS
ALTER TABLE public.planos_trabalho DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.acoes_servicos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.metas_qualitativas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.naturezas_despesa_plano DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.pdf_download_history DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- CONFIRMAÇÃO
-- ============================================================================
-- Verifique se RLS foi desabilitado:
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = true;

-- Se a query acima retornar vazio, RLS foi desabilitado com sucesso!
-- ============================================================================
-- PRÓXIMOS PASSOS:
-- 1. Teste login na aplicação
-- 2. Se funcionar, implemente políticas RLS mais refinadas depois
-- 3. Nunca deixe RLS desabilitado em produção (segurança)
-- ============================================================================
