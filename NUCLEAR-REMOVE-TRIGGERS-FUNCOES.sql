-- ============================================================================
-- NUCLEAR - Remover TODOS os triggers e funções de TODAS as tabelas
-- ============================================================================

-- Lista e REMOVE todos os triggers automaticamente
BEGIN;

DO $$
DECLARE
  v_trigger_record RECORD;
BEGIN
  -- Remover TODOS os triggers de TODAS as tabelas e schemas
  FOR v_trigger_record IN (
    SELECT trigger_schema, trigger_name, event_object_table
    FROM information_schema.triggers
    WHERE trigger_schema NOT IN ('pg_catalog', 'information_schema')
  )
  LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS %I ON %I.%I CASCADE',
      v_trigger_record.trigger_name,
      v_trigger_record.trigger_schema,
      v_trigger_record.event_object_table
    );
    RAISE NOTICE 'Removido trigger: %.%', v_trigger_record.trigger_schema, v_trigger_record.trigger_name;
  END LOOP;
  RAISE NOTICE '✅ Todos os triggers foram removidos!';
END $$;

-- Remove TODAS as funções (SEM CASCADE para evitar erros)
DO $$
DECLARE
  v_func RECORD;
BEGIN
  FOR v_func IN (
    SELECT p.proname, n.nspname, pg_get_function_identity_arguments(p.oid) as args
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
    ORDER BY n.nspname, p.proname
  )
  LOOP
    BEGIN
      EXECUTE format('DROP FUNCTION IF EXISTS %I.%I(%s) CASCADE', 
        v_func.nspname, v_func.proname, v_func.args);
      RAISE NOTICE 'Removida função: %.%', v_func.nspname, v_func.proname;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Erro ao remover função %.%: %', v_func.nspname, v_func.proname, SQLERRM;
    END;
  END LOOP;
  RAISE NOTICE '✅ Funções removidas!';
END $$;

COMMIT;

-- Verificar quais triggers e funções ficaram
SELECT '📊 TRIGGERS RESTANTES:' as info;
SELECT trigger_schema, trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY trigger_schema, trigger_name;

SELECT '📊 FUNÇÕES RESTANTES:' as info;
SELECT n.nspname as schema_name, p.proname as function_name, pg_get_function_identity_arguments(p.oid) as arguments
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY n.nspname, p.proname;

SELECT '✅ LIMPEZA NUCLEAR CONCLUÍDA' as status;
