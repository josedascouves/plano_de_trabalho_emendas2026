-- ============================================================================
-- DIAGNÓSTICO - Verificar status de RLS e usuários
-- ============================================================================

-- 1. Verificar quais tabelas ainda têm RLS habilitado
SELECT 
  table_name,
  CASE WHEN relrowsecurity THEN '❌ RLS ATIVADO' ELSE '✅ RLS DESABILITADO' END as rls_status
FROM information_schema.tables t
JOIN pg_class c ON c.relname = t.table_name
JOIN pg_namespace n ON n.oid = c.relnamespace AND n.nspname = t.table_schema
WHERE t.table_schema = 'public' AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name;

-- 2. Verificar quantas políticas RLS ainda existem
SELECT COUNT(*) as total_politicas_rls FROM pg_policies WHERE schemaname = 'public';

-- 3. Listar TODAS as políticas RLS ativas
SELECT schemaname, tablename, policyname FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, policyname;

-- 4. Verificar status dos 20 usuários
SELECT 
  'PROFILES' as tabela,
  COUNT(*) as total
FROM public.profiles 
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
  'sec.itaim@oss.santamarcalina.org',
  'siemservicosadm@gmail.com',
  'silvania.ssilva@hgvp.org.br',
  'tarla@hcrp.usp.br'
)

UNION ALL

SELECT 
  'USER_ROLES' as tabela,
  COUNT(*) as total
FROM public.user_roles ur
WHERE ur.user_id IN (
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
    'sec.itaim@oss.santamarcalina.org',
    'siemservicosadm@gmail.com',
    'silvania.ssilva@hgvp.org.br',
    'tarla@hcrp.usp.br'
  )
);

-- 5. Detalhe de cada usuário
SELECT 
  u.email,
  u.email_confirmed_at,
  p.email as profile_exists,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
LEFT JOIN public.user_roles ur ON u.id = ur.user_id
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
  'sec.itaim@oss.santamarcalina.org',
  'siemservicosadm@gmail.com',
  'silvania.ssilva@hgvp.org.br',
  'tarla@hcrp.usp.br'
)
ORDER BY u.email;
