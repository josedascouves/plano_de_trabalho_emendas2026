-- ============================================================================
-- CRIAR USUÁRIOS PADRÃO - PLANO DE TRABALHO SES/SP 2026
-- ============================================================================
-- Este script cria todos os usuários responsáveis pelo plano de trabalho
-- no Supabase auth.users com seus respectivos emails, CNES e senhas
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Cole este arquivo TODO
-- 4. Execute (Ctrl+Enter)
-- ============================================================================

-- Garantir que a extensão pgcrypto está habilitada
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- CRIAR FUNÇÃO COM PERMISSÕES ELEVADAS PARA INSERIR USUÁRIOS
-- ============================================================================
-- Esta função contorna a restrição "must be owner of table users"
-- e evita duplicatas verificando se o email já existe
CREATE OR REPLACE FUNCTION create_app_user(
  user_email TEXT,
  user_encrypted_password TEXT,
  user_full_name TEXT,
  user_cnes TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  new_user_id UUID;
BEGIN
  -- Verificar se o usuário já existe
  SELECT id INTO new_user_id FROM auth.users WHERE email = user_email LIMIT 1;
  
  -- Se o usuário não existe, criar
  IF new_user_id IS NULL THEN
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
      user_email,
      user_encrypted_password,
      NOW(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object('full_name', user_full_name, 'cnes', user_cnes),
      false,
      NOW(), NOW()
    )
    RETURNING id INTO new_user_id;
  END IF;
  
  RETURN new_user_id;
END;
$$;

-- ============================================================================
-- CRIAR USUÁRIOS EM auth.users (VIA FUNÇÃO)
-- ============================================================================

-- 1. MARIA LUCIA BRAGA
SELECT create_app_user(
  'ibraga@unimautraimiira.unicamp.br',
  crypt('6523536', gen_salt('bf')),
  'MARIA LUCIA BRAGA',
  '6523536'
);

-- 2. LUIZ CARLOS VIANA BARBOSA
SELECT create_app_user(
  'luiz.barbosa@amemogi.spdm.org.br',
  crypt('7021801', gen_salt('bf')),
  'LUIZ CARLOS VIANA BARBOSA',
  '7021801'
);

-- 3. FABIO CAMARGO DA SILVA
SELECT create_app_user(
  'hospitalderluiz@yahoo.com.br',
  crypt('2745356', gen_salt('bf')),
  'FABIO CAMARGO DA SILVA',
  '2745356'
);

-- 4. EVELYN FERNANDA PEREIRA DOS SANTOS
SELECT create_app_user(
  'convenios2@cipriaioayla.com.br',
  crypt('2078813', gen_salt('bf')),
  'EVELYN FERNANDA PEREIRA DOS SANTOS',
  '2078813'
);

-- 5. AMAURI PERES VENTOJA
SELECT create_app_user(
  'relacaespublicas@casadedavid.org.br',
  crypt('2688522', gen_salt('bf')),
  'AMAURI PERES VENTOJA',
  '2688522'
);

-- 6. PATRICIA SILVA SANTOS
SELECT create_app_user(
  'patricia.santos@colsan.org.br',
  crypt('2088932', gen_salt('bf')),
  'PATRICIA SILVA SANTOS',
  '2088932'
);

-- 7. EVELYN FERNANDA PEREIRA DOS SANTOS (segundo registro)
SELECT create_app_user(
  'convenios2.b@cipriaioayla.com.br',
  crypt('2089327', gen_salt('bf')),
  'EVELYN FERNANDA PEREIRA DOS SANTOS',
  '2089327'
);

-- 8. RUBENS SINSE TANABE
SELECT create_app_user(
  'hospitalbsaojose@gmsil.com',
  crypt('2080281', gen_salt('bf')),
  'RUBENS SINSE TANABE',
  '2080281'
);

-- 9. MEIRE VIEIRA DE CARVALHO TARLA
SELECT create_app_user(
  'tarla@hcrp.usp.br',
  crypt('2082187', gen_salt('bf')),
  'MEIRE VIEIRA DE CARVALHO TARLA',
  '2082187'
);

-- 10. IRENE DE SOUSA FARIAS
SELECT create_app_user(
  'irenef@frm.br',
  crypt('2078015', gen_salt('bf')),
  'IRENE DE SOUSA FARIAS',
  '2078015'
);

-- 11. PAULO DAVID DOMINGUES DE OLIVEIRA
SELECT create_app_user(
  'paulo.o@hc.fm.usp.br',
  crypt('2078015', gen_salt('bf')),
  'PAULO DAVID DOMINGUES DE OLIVEIRA',
  '2078015'
);

-- 12. PATRICIA ARAUJO LANTMAN DE SOUZA
SELECT create_app_user(
  'dir.executiva.heb@famesp.org.br',
  crypt('2790602', gen_salt('bf')),
  'PATRICIA ARAUJO LANTMAN DE SOUZA',
  '2790602'
);

-- 13. ANA PAULA BORGES
SELECT create_app_user(
  'expediente@hgt.org.br',
  crypt('2082225', gen_salt('bf')),
  'ANA PAULA BORGES',
  '2082225'
);

-- 14. FERNANDA APARECIDA SILVA OLIVEIRA
SELECT create_app_user(
  'sec.itaim@oss.santamarcalina.org.br',
  crypt('2077620', gen_salt('bf')),
  'FERNANDA APARECIDA SILVA OLIVEIRA',
  '2077620'
);

-- 15. SILVANIA SOUZA SILVA
SELECT create_app_user(
  'silvania.ssilva@hgvp.org.br',
  crypt('2091755', gen_salt('bf')),
  'SILVANIA SOUZA SILVA',
  '2091755'
);

-- 16. SIDINEI OLIVEIRA SOARES
SELECT create_app_user(
  'administracao.hefr@ceiam.org.br',
  crypt('6878687', gen_salt('bf')),
  'SIDINEI OLIVEIRA SOARES',
  '6878687'
);

-- 17. IVANETE ALBINO
SELECT create_app_user(
  'ivaneti.albino@hospitalfreigalvao.com.br',
  crypt('2081644', gen_salt('bf')),
  'IVANETE ALBINO',
  '2081644'
);

-- 18. ROBSON RAIMUNDO DA COSTA
SELECT create_app_user(
  'robson@saocamilo-hlmb.org.br',
  crypt('3753433', gen_salt('bf')),
  'ROBSON RAIMUNDO DA COSTA',
  '3753433'
);

-- 19. FRANCIANE DE ARAUJO CASTANHAR ALVES
SELECT create_app_user(
  'pcontas@santacasadearacatuba.com.br',
  crypt('2078775', gen_salt('bf')),
  'FRANCIANE DE ARAUJO CASTANHAR ALVES',
  '2078775'
);

-- 20. RONEY LORENZETTI E SILVA
SELECT create_app_user(
  'siemservicosadm@gmail.com',
  crypt('2080095', gen_salt('bf')),
  'RONEY LORENZETTI E SILVA',
  '2080095'
);

-- ============================================================================
-- CONFIRMAÇÃO
-- ============================================================================
-- Script concluído! Verifique se todos os usuários foram criados:
-- SELECT COUNT(*) FROM auth.users;
-- ============================================================================
