-- ============================================================================
-- FIX AGRESSIVO - REMOVER RLS COMPLETAMENTE (Force Disable)
-- ============================================================================

-- PRIMEIRO: Execute este comando SEPARADAMENTE para remover TODAS as políticas
BEGIN;

-- Remove TODAS as políticas RLS de TODAS as tabelas
DO $$
DECLARE 
  r RECORD;
BEGIN
  FOR r IN (
    SELECT tablename, policyname 
    FROM pg_policies 
    WHERE schemaname = 'public'
  )
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', r.policyname, r.tablename);
    RAISE NOTICE 'Removida política: % de tabela %', r.policyname, r.tablename;
  END LOOP;
END $$;

SELECT '✅ PASSO 1: Todas as políticas RLS removidas' as status;

-- DESABILITAR RLS em TODAS as tabelas
DO $$
DECLARE 
  r RECORD;
BEGIN
  FOR r IN (
    SELECT tablename 
    FROM pg_tables 
    WHERE schemaname = 'public'
  )
  LOOP
    EXECUTE format('ALTER TABLE public.%I DISABLE ROW LEVEL SECURITY', r.tablename);
    RAISE NOTICE 'RLS desabilitado para tabela: %', r.tablename;
  END LOOP;
END $$;

SELECT '✅ PASSO 2: RLS desabilitado em TODAS as tabelas' as status;

-- REMOVER ENABLE RLS se houver (force disable)
DO $$
DECLARE 
  r RECORD;
BEGIN
  FOR r IN (
    SELECT tablename 
    FROM pg_tables 
    WHERE schemaname = 'public'
  )
  LOOP
    EXECUTE format('ALTER TABLE IF EXISTS public.%I NO FORCE ROW LEVEL SECURITY', r.tablename);
  END LOOP;
END $$;

COMMIT;

-- Aguardar um momento para as mudanças serem propagadas
SELECT '✅ PASSO 3: Propagando mudanças...' as status;
SELECT pg_sleep(2);

-- Verificar status
SELECT 
  table_name,
  CASE 
    WHEN relrowsecurity THEN '❌ RLS AINDA ATIVO' 
    ELSE '✅ RLS DESABILITADO' 
  END as status
FROM information_schema.tables t
JOIN pg_class c ON c.relname = t.table_name
JOIN pg_namespace n ON n.oid = c.relnamespace AND n.nspname = t.table_schema
WHERE t.table_schema = 'public' AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name;

SELECT 
  COUNT(*) as politicas_ativas
FROM pg_policies 
WHERE schemaname = 'public';
