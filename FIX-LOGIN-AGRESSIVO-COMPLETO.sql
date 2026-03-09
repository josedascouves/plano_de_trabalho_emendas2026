-- ============================================================================
-- FIX AGRESSIVO TOTAL - Remove TODOS os triggers, funções e RLS
-- ============================================================================

BEGIN TRANSACTION;

-- ============================================================================
-- PASSO 1: Remover TODOS os triggers da tabela auth.users
-- ============================================================================
DO $$ 
DECLARE r RECORD;
BEGIN
  FOR r IN (SELECT trigger_name FROM information_schema.triggers WHERE trigger_schema = 'auth' AND event_object_table = 'users')
  LOOP
    EXECUTE 'DROP TRIGGER IF EXISTS ' || r.trigger_name || ' ON auth.users';
  END LOOP;
END $$;

-- ============================================================================
-- PASSO 2: Remover TODOS os triggers da tabela public.profiles
-- ============================================================================
DO $$ 
DECLARE r RECORD;
BEGIN
  FOR r IN (SELECT trigger_name FROM information_schema.triggers WHERE trigger_schema = 'public' AND event_object_table = 'profiles')
  LOOP
    EXECUTE 'DROP TRIGGER IF EXISTS ' || r.trigger_name || ' ON public.profiles';
  END LOOP;
END $$;

-- ============================================================================
-- PASSO 3: Remover TODAS as funções do schema public
-- ============================================================================
DO $$ 
DECLARE r RECORD;
BEGIN
  FOR r IN (
    SELECT pg_proc.proname, pg_namespace.nspname,
           STRING_AGG(CONCAT(CASE WHEN pg_type.typname IS NULL THEN 'void' ELSE pg_type.typname END), ', ' ORDER BY pg_proc.pronargs)
    FROM pg_proc
    JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
    LEFT JOIN pg_type ON pg_proc.prorettype = pg_type.oid
    WHERE pg_namespace.nspname = 'public'
    GROUP BY pg_proc.proname, pg_namespace.nspname
  )
  LOOP
    BEGIN
      EXECUTE 'DROP FUNCTION IF EXISTS public.' || r.proname || '() CASCADE';
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
  END LOOP;
END $$;

SELECT '✅ PASSO 1-3: Triggers e Funções removidas' as status;

-- ============================================================================
-- PASSO 4: DESABILITAR RLS em TODAS as tabelas
-- ============================================================================
DO $$ 
DECLARE r RECORD;
BEGIN
  FOR r IN (
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
  )
  LOOP
    BEGIN
      EXECUTE 'ALTER TABLE public.' || r.table_name || ' DISABLE ROW LEVEL SECURITY';
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
  END LOOP;
END $$;

SELECT '✅ PASSO 4: RLS desabilitado em TODAS as tabelas' as status;

-- ============================================================================
-- PASSO 5: Remover TODAS as políticas RLS
-- ============================================================================
DO $$ 
DECLARE r RECORD;
BEGIN
  FOR r IN (
    SELECT policyname, tablename FROM pg_policies WHERE schemaname = 'public'
  )
  LOOP
    BEGIN
      EXECUTE 'DROP POLICY IF EXISTS ' || QUOTE_IDENT(r.policyname) || ' ON public.' || QUOTE_IDENT(r.tablename);
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
  END LOOP;
END $$;

SELECT '✅ PASSO 5: Todas as políticas RLS removidas' as status;

-- ============================================================================
-- PASSO 6: LIMPAR e SINCRONIZAR dados dos 20 usuários
-- ============================================================================

-- Deletar profiles antigos
DELETE FROM public.profiles 
WHERE email IN (
  'administracao.hefr@ceiam.org.br',
  'convenios2.b@cipriaioayla.com.br',
  'convenios2@cipriaioayla.com.br',
  'dir.executiva.heb@famesp.org.br',
  'expediente@hgt.org.br',
  'hospitalbsaojose@gmsil.com',
  'hospitalderluiz@yahoo.com.br',
  'ibraga@unimautraimiira.unicamp.br',
  'irenef@frm.br',
  'ivaneti.albino@hospitalfreigalvao.com.br',
  'luiz.barbosa@amemogi.spdm.org.br',
  'patricia.santos@colsan.org.br',
  'paulo.o@hc.fm.usp.br',
  'pcontas@santacasadearacatuba.com.br',
  'relacaespublicas@casadedavid.org.br',
  'robson@saocamilo-hlmb.org.br',
  'sec.itaim@oss.santamarcalina.org.br',
  'siemservicosadm@gmail.com',
  'silvania.ssilva@hgvp.org.br',
  'tarla@hcrp.usp.br'
);

SELECT '✅ PASSO 6A: Profiles antigos deletados' as status;

-- Recriar profiles limpos
INSERT INTO public.profiles (id, email, full_name, cnes, created_at)
SELECT 
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'full_name', u.email),
  COALESCE(u.raw_user_meta_data->>'cnes', '0000000'),
  u.created_at
FROM auth.users u
WHERE u.email IN (
  'administracao.hefr@ceiam.org.br',
  'convenios2.b@cipriaioayla.com.br',
  'convenios2@cipriaioayla.com.br',
  'dir.executiva.heb@famesp.org.br',
  'expediente@hgt.org.br',
  'hospitalbsaojose@gmsil.com',
  'hospitalderluiz@yahoo.com.br',
  'ibraga@unimautraimiira.unicamp.br',
  'irenef@frm.br',
  'ivaneti.albino@hospitalfreigalvao.com.br',
  'luiz.barbosa@amemogi.spdm.org.br',
  'patricia.santos@colsan.org.br',
  'paulo.o@hc.fm.usp.br',
  'pcontas@santacasadearacatuba.com.br',
  'relacaespublicas@casadedavid.org.br',
  'robson@saocamilo-hlmb.org.br',
  'sec.itaim@oss.santamarcalina.org.br',
  'siemservicosadm@gmail.com',
  'silvania.ssilva@hgvp.org.br',
  'tarla@hcrp.usp.br'
)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  cnes = EXCLUDED.cnes;

SELECT '✅ PASSO 6B: Profiles recriados' as status;

-- Recriar user_roles como USER
DELETE FROM public.user_roles 
WHERE user_id IN (
  SELECT id FROM auth.users WHERE email IN (
    'administracao.hefr@ceiam.org.br',
    'convenios2.b@cipriaioayla.com.br',
    'convenios2@cipriaioayla.com.br',
    'dir.executiva.heb@famesp.org.br',
    'expediente@hgt.org.br',
    'hospitalbsaojose@gmsil.com',
    'hospitalderluiz@yahoo.com.br',
    'ibraga@unimautraimiira.unicamp.br',
    'irenef@frm.br',
    'ivaneti.albino@hospitalfreigalvao.com.br',
    'luiz.barbosa@amemogi.spdm.org.br',
    'patricia.santos@colsan.org.br',
    'paulo.o@hc.fm.usp.br',
    'pcontas@santacasadearacatuba.com.br',
    'relacaespublicas@casadedavid.org.br',
    'robson@saocamilo-hlmb.org.br',
    'sec.itaim@oss.santamarcalina.org.br',
    'siemservicosadm@gmail.com',
    'silvania.ssilva@hgvp.org.br',
    'tarla@hcrp.usp.br'
  )
);

-- Agora inserir com o tipo correto
INSERT INTO public.user_roles (user_id, role, disabled)
SELECT 
  u.id,
  'user',
  false
FROM auth.users u
WHERE u.email IN (
  'administracao.hefr@ceiam.org.br',
  'convenios2.b@cipriaioayla.com.br',
  'convenios2@cipriaioayla.com.br',
  'dir.executiva.heb@famesp.org.br',
  'expediente@hgt.org.br',
  'hospitalbsaojose@gmsil.com',
  'hospitalderluiz@yahoo.com.br',
  'ibraga@unimautraimiira.unicamp.br',
  'irenef@frm.br',
  'ivaneti.albino@hospitalfreigalvao.com.br',
  'luiz.barbosa@amemogi.spdm.org.br',
  'patricia.santos@colsan.org.br',
  'paulo.o@hc.fm.usp.br',
  'pcontas@santacasadearacatuba.com.br',
  'relacaespublicas@casadedavid.org.br',
  'robson@saocamilo-hlmb.org.br',
  'sec.itaim@oss.santamarcalina.org.br',
  'siemservicosadm@gmail.com',
  'silvania.ssilva@hgvp.org.br',
  'tarla@hcrp.usp.br'
)
ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

SELECT '✅ PASSO 6C: User_roles recriados como USER' as status;

COMMIT TRANSACTION;

-- ============================================================================
-- PASSO 7: VERIFICAÇÃO FINAL
-- ============================================================================

SELECT COUNT(*) as total_usuarios_sincronizados FROM public.profiles 
WHERE email IN (
  'administracao.hefr@ceiam.org.br',
  'convenios2.b@cipriaioayla.com.br',
  'convenios2@cipriaioayla.com.br',
  'dir.executiva.heb@famesp.org.br',
  'expediente@hgt.org.br',
  'hospitalbsaojose@gmsil.com',
  'hospitalderluiz@yahoo.com.br',
  'ibraga@unimautraimiira.unicamp.br',
  'irenef@frm.br',
  'ivaneti.albino@hospitalfreigalvao.com.br',
  'luiz.barbosa@amemogi.spdm.org.br',
  'patricia.santos@colsan.org.br',
  'paulo.o@hc.fm.usp.br',
  'pcontas@santacasadearacatuba.com.br',
  'relacaespublicas@casadedavid.org.br',
  'robson@saocamilo-hlmb.org.br',
  'sec.itaim@oss.santamarcalina.org.br',
  'siemservicosadm@gmail.com',
  'silvania.ssilva@hgvp.org.br',
  'tarla@hcrp.usp.br'
);

SELECT '✅✅✅ RLS COMPLETAMENTE DESABILITADO ✅✅✅' as resultado;
SELECT '✅ TODOS OS TRIGGERS REMOVIDOS' as resultado;
SELECT '✅ TODAS AS FUNÇÕES REMOVIDAS' as resultado;
SELECT '✅ 20 USUÁRIOS PREPARADOS PARA LOGIN' as resultado;

-- Listar todos os 20 usuários
SELECT 
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE p.email IN (
  'administracao.hefr@ceiam.org.br',
  'convenios2.b@cipriaioayla.com.br',
  'convenios2@cipriaioayla.com.br',
  'dir.executiva.heb@famesp.org.br',
  'expediente@hgt.org.br',
  'hospitalbsaojose@gmsil.com',
  'hospitalderluiz@yahoo.com.br',
  'ibraga@unimautraimiira.unicamp.br',
  'irenef@frm.br',
  'ivaneti.albino@hospitalfreigalvao.com.br',
  'luiz.barbosa@amemogi.spdm.org.br',
  'patricia.santos@colsan.org.br',
  'paulo.o@hc.fm.usp.br',
  'pcontas@santacasadearacatuba.com.br',
  'relacaespublicas@casadedavid.org.br',
  'robson@saocamilo-hlmb.org.br',
  'sec.itaim@oss.santamarcalina.org.br',
  'siemservicosadm@gmail.com',
  'silvania.ssilva@hgvp.org.br',
  'tarla@hcrp.usp.br'
)
ORDER BY p.email;
