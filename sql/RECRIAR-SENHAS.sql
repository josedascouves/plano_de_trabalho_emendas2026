-- ============================================================================
-- RECRIAR SENHAS - Se necessário
-- ============================================================================
-- Este script RECRIA as senhas dos 20 usuários com o CNES como senha
-- Usa o mesmo método que funcionou na criação original

BEGIN TRANSACTION;

-- Garantir que pgcrypto está habilitada
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Recriar as senhas de TODOS os 20 usuários
-- MARIA LUCIA BRAGA (CNES: 6523536)
UPDATE auth.users 
SET encrypted_password = crypt('6523536', gen_salt('bf'))
WHERE email = 'ibraga@unimautraimiira.unicamp.br';

-- LUIZ CARLOS VIANA BARBOSA (CNES: 7021801)
UPDATE auth.users 
SET encrypted_password = crypt('7021801', gen_salt('bf'))
WHERE email = 'luiz.barbosa@amemogi.spdm.org.br';

-- FABIO CAMARGO DA SILVA (CNES: 2745356)
UPDATE auth.users 
SET encrypted_password = crypt('2745356', gen_salt('bf'))
WHERE email = 'hospitalderluiz@yahoo.com.br';

-- EVELYN FERNANDA PEREIRA DOS SANTOS (CNES: 2078813)
UPDATE auth.users 
SET encrypted_password = crypt('2078813', gen_salt('bf'))
WHERE email = 'convenios2@cipriaioayla.com.br';

-- AMAURI PERES VENTOJA (CNES: 2688522)
UPDATE auth.users 
SET encrypted_password = crypt('2688522', gen_salt('bf'))
WHERE email = 'relacaespublicas@casadedavid.org.br';

-- PATRICIA SILVA SANTOS (CNES: 2088932)
UPDATE auth.users 
SET encrypted_password = crypt('2088932', gen_salt('bf'))
WHERE email = 'patricia.santos@colsan.org.br';

-- EVELYN FERNANDA PEREIRA DOS SANTOS (CNES: 2089327)
UPDATE auth.users 
SET encrypted_password = crypt('2089327', gen_salt('bf'))
WHERE email = 'convenios2.b@cipriaioayla.com.br';

-- RUBENS SINSE TANABE (CNES: 2080281)
UPDATE auth.users 
SET encrypted_password = crypt('2080281', gen_salt('bf'))
WHERE email = 'hospitalbsaojose@gmsil.com';

-- MEIRE VIEIRA DE CARVALHO TARLA (CNES: 2082187)
UPDATE auth.users 
SET encrypted_password = crypt('2082187', gen_salt('bf'))
WHERE email = 'tarla@hcrp.usp.br';

-- IRENE DE SOUSA FARIAS (CNES: 2078015)
UPDATE auth.users 
SET encrypted_password = crypt('2078015', gen_salt('bf'))
WHERE email = 'irenef@frm.br';

-- PAULO DAVID DOMINGUES DE OLIVEIRA (CNES: 2078015)
UPDATE auth.users 
SET encrypted_password = crypt('2078015', gen_salt('bf'))
WHERE email = 'paulo.o@hc.fm.usp.br';

-- PATRICIA ARAUJO LANTMAN DE SOUZA (CNES: 2790602)
UPDATE auth.users 
SET encrypted_password = crypt('2790602', gen_salt('bf'))
WHERE email = 'dir.executiva.heb@famesp.org.br';

-- ANA PAULA BORGES (CNES: 2082225)
UPDATE auth.users 
SET encrypted_password = crypt('2082225', gen_salt('bf'))
WHERE email = 'expediente@hgt.org.br';

-- FERNANDA APARECIDA SILVA OLIVEIRA (CNES: 2077620)
UPDATE auth.users 
SET encrypted_password = crypt('2077620', gen_salt('bf'))
WHERE email = 'sec.itaim@oss.santamarcalina.org';

-- SILVANIA SOUZA SILVA (CNES: 2091755)
UPDATE auth.users 
SET encrypted_password = crypt('2091755', gen_salt('bf'))
WHERE email = 'silvania.ssilva@hgvp.org.br';

-- SIDINEI OLIVEIRA SOARES (CNES: 6878687)
UPDATE auth.users 
SET encrypted_password = crypt('6878687', gen_salt('bf'))
WHERE email = 'administracao.hefr@ceiam.org.br';

-- IVANETE ALBINO (CNES: 2081644)
UPDATE auth.users 
SET encrypted_password = crypt('2081644', gen_salt('bf'))
WHERE email = 'ivaneti.albino@hospitalfreigalvao.com.br';

-- ROBSON RAIMUNDO DA COSTA (CNES: 3753433)
UPDATE auth.users 
SET encrypted_password = crypt('3753433', gen_salt('bf'))
WHERE email = 'robson@saocamilo-hlmb.org.br';

-- FRANCIANE DE ARAUJO CASTANHAR ALVES (CNES: 2078775)
UPDATE auth.users 
SET encrypted_password = crypt('2078775', gen_salt('bf'))
WHERE email = 'pcontas@santacasadearacatuba.com.br';

-- RONEY LORENZETTI E SILVA (CNES: 2080095)
UPDATE auth.users 
SET encrypted_password = crypt('2080095', gen_salt('bf'))
WHERE email = 'siemservicosadm@gmail.com';

COMMIT TRANSACTION;

SELECT '✅✅✅ TODAS AS SENHAS RECRIADAS ✅✅✅' as status;

-- Verificar se funcionou
SELECT 
  email,
  raw_user_meta_data->>'full_name' as full_name,
  raw_user_meta_data->>'cnes' as cnes,
  CASE 
    WHEN encrypted_password LIKE '$2%' THEN '✅ BCRYPT OK'
    ELSE '❌ HASH INVÁLIDO'
  END as hash_status
FROM auth.users
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
ORDER BY email;
