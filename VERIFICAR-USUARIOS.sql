-- ============================================================================
-- VERIFICACAO - Execute APENAS este script para ver os usuarios criados
-- ============================================================================

-- 1. Listar TODOS os 20 usuarios com status completo
SELECT 
  u.email as "EMAIL (LOGIN)",
  p.full_name as "NOME",
  p.cnes as "CNES (SENHA)",
  ur.role as "ROLE",
  CASE WHEN i.id IS NOT NULL THEN 'SIM' ELSE 'NAO' END as "TEM IDENTITY",
  CASE WHEN p.id IS NOT NULL THEN 'SIM' ELSE 'NAO' END as "TEM PROFILE",
  CASE WHEN ur.user_id IS NOT NULL THEN 'SIM' ELSE 'NAO' END as "TEM USER_ROLE"
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
LEFT JOIN public.user_roles ur ON u.id = ur.user_id
LEFT JOIN auth.identities i ON u.id = i.user_id
WHERE u.email IN (
  'lbraga@amelimeira.unicamp.br',
  'luiz.barbosa@amemogi.spdm.org.br',
  'hospitalandreluiz@yahoo.com.br',
  'convenios2@ciprianoayla.com.br',
  'relacoespublicas@casadedavid.org.br',
  'patricia.santos@colsan.org.br',
  'convenios2.cnes2089327@ciprianoayla.com.br',
  'hospitalbsaojose@gmsil.com',
  'tarla@hcrp.usp.br',
  'irenef@ffm.br',
  'paulo.o@hc.fm.usp.br',
  'dir.executiva.heb@famesp.org.br',
  'expediente@hgt.org.br',
  'sec.itaim@oss.santamarcelina.org',
  'silvania.ssilva@hgvp.org.br',
  'administracao.hefr@cejam.org.br',
  'ivaneti.albino@hospitalfreigalvao.com.br',
  'robson@saocamilo-hlmb.org.br',
  'pcontas@santacasadearacatuba.com.br',
  'siempservicosadm@gmail.com'
)
ORDER BY p.full_name;
