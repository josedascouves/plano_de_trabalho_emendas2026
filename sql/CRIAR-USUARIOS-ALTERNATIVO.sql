-- ============================================================================
-- SCRIPT ALTERNATIVO: CRIAR USUÁRIOS - VERSÃO SIMPLIFICADA
-- ============================================================================
-- Use este script se o anterior gerar erros
-- Cole cada inserção uma por uma se necessário
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- CRIAR USUÁRIOS - ABORDAGEM DIRETA (SEM SELECT)
-- ============================================================================

-- 1. MARIA LUCIA BRAGA
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'ibraga@unimautraimiira.unicamp.br',
  crypt('6523536', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "MARIA LUCIA BRAGA", "cnes": "6523536"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 2. LUIZ CARLOS VIANA BARBOSA
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'luiz.barbosa@amemogi.spdm.org.br',
  crypt('7021801', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "LUIZ CARLOS VIANA BARBOSA", "cnes": "7021801"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 3. FABIO CAMARGO DA SILVA
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'hospitalderluiz@yahoo.com.br',
  crypt('2745356', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "FABIO CAMARGO DA SILVA", "cnes": "2745356"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 4. EVELYN FERNANDA PEREIRA DOS SANTOS
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'convenios2@cipriaioayla.com.br',
  crypt('2078813', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "EVELYN FERNANDA PEREIRA DOS SANTOS", "cnes": "2078813"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 5. AMAURI PERES VENTOJA
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'relacaespublicas@casadedavid.org.br',
  crypt('2688522', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "AMAURI PERES VENTOJA", "cnes": "2688522"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 6. PATRICIA SILVA SANTOS
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'patricia.santos@colsan.org.br',
  crypt('2088932', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "PATRICIA SILVA SANTOS", "cnes": "2088932"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 7. EVELYN FERNANDA PEREIRA DOS SANTOS (segundo)
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'convenios2.b@cipriaioayla.com.br',
  crypt('2089327', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "EVELYN FERNANDA PEREIRA DOS SANTOS", "cnes": "2089327"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 8. RUBENS SINSE TANABE
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'hospitalbsaojose@gmsil.com',
  crypt('2080281', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "RUBENS SINSE TANABE", "cnes": "2080281"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 9. MEIRE VIEIRA DE CARVALHO TARLA
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'tarla@hcrp.usp.br',
  crypt('2082187', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "MEIRE VIEIRA DE CARVALHO TARLA", "cnes": "2082187"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 10. IRENE DE SOUSA FARIAS
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'irenef@frm.br',
  crypt('2078015', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "IRENE DE SOUSA FARIAS", "cnes": "2078015"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 11. PAULO DAVID DOMINGUES DE OLIVEIRA
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'paulo.o@hc.fm.usp.br',
  crypt('2078015', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "PAULO DAVID DOMINGUES DE OLIVEIRA", "cnes": "2078015"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 12. PATRICIA ARAUJO LANTMAN DE SOUZA
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'dir.executiva.heb@famesp.org.br',
  crypt('2790602', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "PATRICIA ARAUJO LANTMAN DE SOUZA", "cnes": "2790602"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 13. ANA PAULA BORGES
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'expediente@hgt.org.br',
  crypt('2082225', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "ANA PAULA BORGES", "cnes": "2082225"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 14. FERNANDA APARECIDA SILVA OLIVEIRA
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'sec.itaim@oss.santamarcalina.org.br',
  crypt('2077620', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "FERNANDA APARECIDA SILVA OLIVEIRA", "cnes": "2077620"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 15. SILVANIA SOUZA SILVA
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'silvania.ssilva@hgvp.org.br',
  crypt('2091755', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "SILVANIA SOUZA SILVA", "cnes": "2091755"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 16. SIDINEI OLIVEIRA SOARES
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'administracao.hefr@ceiam.org.br',
  crypt('6878687', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "SIDINEI OLIVEIRA SOARES", "cnes": "6878687"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 17. IVANETE ALBINO
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'ivaneti.albino@hospitalfreigalvao.com.br',
  crypt('2081644', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "IVANETE ALBINO", "cnes": "2081644"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 18. ROBSON RAIMUNDO DA COSTA
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'robson@saocamilo-hlmb.org.br',
  crypt('3753433', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "ROBSON RAIMUNDO DA COSTA", "cnes": "3753433"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 19. FRANCIANE DE ARAUJO CASTANHAR ALVES
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'pcontas@santacasadearacatuba.com.br',
  crypt('2078775', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "FRANCIANE DE ARAUJO CASTANHAR ALVES", "cnes": "2078775"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- 20. RONEY LORENZETTI E SILVA
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_super_admin,
  created_at, updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'siemservicosadm@gmail.com',
  crypt('2080095', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name": "RONEY LORENZETTI E SILVA", "cnes": "2080095"}',
  false,
  NOW(), NOW()
)
ON CONFLICT (email) DO NOTHING;

-- ============================================================================
-- VALIDAÇÃO
-- ============================================================================
-- Verifique quantos usuários foram criados:
-- SELECT COUNT(*) FROM auth.users;
-- ============================================================================
