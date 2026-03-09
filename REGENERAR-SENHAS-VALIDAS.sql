-- ============================================================================
-- REGENERAR SENHAS - Com hash BCRYPT válido
-- ============================================================================

BEGIN TRANSACTION;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Regenerar cada senha individualmente com new salt a cada vez
-- Isso garante bcrypt válido

UPDATE auth.users 
SET encrypted_password = crypt('6523536', gen_salt('bf')), updated_at = now()
WHERE email = 'ibraga@unimautraimiira.unicamp.br';

UPDATE auth.users 
SET encrypted_password = crypt('7021801', gen_salt('bf')), updated_at = now()
WHERE email = 'luiz.barbosa@amemogi.spdm.org.br';

UPDATE auth.users 
SET encrypted_password = crypt('2745356', gen_salt('bf')), updated_at = now()
WHERE email = 'hospitalderluiz@yahoo.com.br';

UPDATE auth.users 
SET encrypted_password = crypt('2078813', gen_salt('bf')), updated_at = now()
WHERE email = 'convenios2@cipriaioayla.com.br';

UPDATE auth.users 
SET encrypted_password = crypt('2688522', gen_salt('bf')), updated_at = now()
WHERE email = 'relacaespublicas@casadedavid.org.br';

UPDATE auth.users 
SET encrypted_password = crypt('2088932', gen_salt('bf')), updated_at = now()
WHERE email = 'patricia.santos@colsan.org.br';

UPDATE auth.users 
SET encrypted_password = crypt('2089327', gen_salt('bf')), updated_at = now()
WHERE email = 'convenios2.b@cipriaioayla.com.br';

UPDATE auth.users 
SET encrypted_password = crypt('2080281', gen_salt('bf')), updated_at = now()
WHERE email = 'hospitalbsaojose@gmsil.com';

UPDATE auth.users 
SET encrypted_password = crypt('2082187', gen_salt('bf')), updated_at = now()
WHERE email = 'tarla@hcrp.usp.br';

UPDATE auth.users 
SET encrypted_password = crypt('2078015', gen_salt('bf')), updated_at = now()
WHERE email = 'irenef@frm.br';

UPDATE auth.users 
SET encrypted_password = crypt('2078015', gen_salt('bf')), updated_at = now()
WHERE email = 'paulo.o@hc.fm.usp.br';

UPDATE auth.users 
SET encrypted_password = crypt('2790602', gen_salt('bf')), updated_at = now()
WHERE email = 'dir.executiva.heb@famesp.org.br';

UPDATE auth.users 
SET encrypted_password = crypt('2082225', gen_salt('bf')), updated_at = now()
WHERE email = 'expediente@hgt.org.br';

UPDATE auth.users 
SET encrypted_password = crypt('2077620', gen_salt('bf')), updated_at = now()
WHERE email = 'sec.itaim@oss.santamarcalina.org';

UPDATE auth.users 
SET encrypted_password = crypt('2091755', gen_salt('bf')), updated_at = now()
WHERE email = 'silvania.ssilva@hgvp.org.br';

UPDATE auth.users 
SET encrypted_password = crypt('6878687', gen_salt('bf')), updated_at = now()
WHERE email = 'administracao.hefr@ceiam.org.br';

UPDATE auth.users 
SET encrypted_password = crypt('2081644', gen_salt('bf')), updated_at = now()
WHERE email = 'ivaneti.albino@hospitalfreigalvao.com.br';

UPDATE auth.users 
SET encrypted_password = crypt('3753433', gen_salt('bf')), updated_at = now()
WHERE email = 'robson@saocamilo-hlmb.org.br';

UPDATE auth.users 
SET encrypted_password = crypt('2078775', gen_salt('bf')), updated_at = now()
WHERE email = 'pcontas@santacasadearacatuba.com.br';

UPDATE auth.users 
SET encrypted_password = crypt('2080095', gen_salt('bf')), updated_at = now()
WHERE email = 'siemservicosadm@gmail.com';

COMMIT TRANSACTION;

SELECT '✅ TODAS AS SENHAS REGENERADAS COM BCRYPT VÁLIDO' as status;

-- Verificar
SELECT 
  email,
  CASE 
    WHEN encrypted_password LIKE '$2%' THEN '✅ VÁLIDA'
    ELSE '❌ INVÁLIDA'
  END as hash_status,
  SUBSTRING(encrypted_password, 1, 20) as hash_preview
FROM auth.users
WHERE email IN (
  'administracao.hefr@ceiam.org.br', 'convenios2.b@cipriaioayla.com.br',
  'convenios2@cipriaioayla.com.br', 'dir.executiva.heb@famesp.org.br',
  'expediente@hgt.org.br', 'hospitalbsaojose@gmsil.com',
  'hospitalderluiz@yahoo.com.br', 'ibraga@unimautraimiira.unicamp.br',
  'irenef@frm.br', 'ivaneti.albino@hospitalfreigalvao.com.br',
  'luiz.barbosa@amemogi.spdm.org.br', 'patricia.santos@colsan.org.br',
  'paulo.o@hc.fm.usp.br', 'pcontas@santacasadearacatuba.com.br',
  'relacaespublicas@casadedavid.org.br', 'robson@saocamilo-hlmb.org.br',
  'sec.itaim@oss.santamarcalina.org', 'siemservicosadm@gmail.com',
  'silvania.ssilva@hgvp.org.br', 'tarla@hcrp.usp.br'
)
ORDER BY email;
