-- ============================================================================
-- CRIAR USUÁRIOS PADRÃO - PLANO DE TRABALHO SES/SP 2026
-- VERSION 2: CORRIGIDA COM IDENTITIES
-- ============================================================================
-- Este script cria usuários em auth.users E auth.identities
-- para que apareçam corretamente nos providers
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Cole este arquivo TODO
-- 4. Execute (Ctrl+Enter)
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- Função auxiliar para criar usuário com provider
-- ============================================================================
DO $$
DECLARE
  v_user_id uuid;
  v_email text;
BEGIN
  -- 1. MARIA LUCIA BRAGA
  v_email := 'ibraga@unimautraimiira.unicamp.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('6523536', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "MARIA LUCIA BRAGA", "cnes": "6523536"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 2. LUIZ CARLOS VIANA BARBOSA
  v_email := 'luiz.barbosa@amemogi.spdm.org.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('7021801', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "LUIZ CARLOS VIANA BARBOSA", "cnes": "7021801"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 3. FABIO CAMARGO DA SILVA
  v_email := 'hospitalderluiz@yahoo.com.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2745356', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "FABIO CAMARGO DA SILVA", "cnes": "2745356"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 4. EVELYN FERNANDA PEREIRA DOS SANTOS
  v_email := 'convenios2@cipriaioayla.com.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2078813', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "EVELYN FERNANDA PEREIRA DOS SANTOS", "cnes": "2078813"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 5. AMAURI PERES VENTOJA
  v_email := 'relacaespublicas@casadedavid.org.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2688522', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "AMAURI PERES VENTOJA", "cnes": "2688522"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 6. PATRICIA SILVA SANTOS
  v_email := 'patricia.santos@colsan.org.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2088932', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "PATRICIA SILVA SANTOS", "cnes": "2088932"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 7. EVELYN FERNANDA PEREIRA DOS SANTOS (segundo)
  v_email := 'convenios2.b@cipriaioayla.com.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2089327', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "EVELYN FERNANDA PEREIRA DOS SANTOS", "cnes": "2089327"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 8. RUBENS SINSE TANABE
  v_email := 'hospitalbsaojose@gmsil.com';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2080281', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "RUBENS SINSE TANABE", "cnes": "2080281"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 9. MEIRE VIEIRA DE CARVALHO TARLA
  v_email := 'tarla@hcrp.usp.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2082187', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "MEIRE VIEIRA DE CARVALHO TARLA", "cnes": "2082187"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 10. IRENE DE SOUSA FARIAS
  v_email := 'irenef@frm.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2078015', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "IRENE DE SOUSA FARIAS", "cnes": "2078015"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 11. PAULO DAVID DOMINGUES DE OLIVEIRA
  v_email := 'paulo.o@hc.fm.usp.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2078015', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "PAULO DAVID DOMINGUES DE OLIVEIRA", "cnes": "2078015"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 12. PATRICIA ARAUJO LANTMAN DE SOUZA
  v_email := 'dir.executiva.heb@famesp.org.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2790602', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "PATRICIA ARAUJO LANTMAN DE SOUZA", "cnes": "2790602"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 13. ANA PAULA BORGES
  v_email := 'expediente@hgt.org.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2082225', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "ANA PAULA BORGES", "cnes": "2082225"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 14. FERNANDA APARECIDA SILVA OLIVEIRA
  v_email := 'sec.itaim@oss.santamarcalina.org.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2077620', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "FERNANDA APARECIDA SILVA OLIVEIRA", "cnes": "2077620"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 15. SILVANIA SOUZA SILVA
  v_email := 'silvania.ssilva@hgvp.org.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2091755', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "SILVANIA SOUZA SILVA", "cnes": "2091755"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 16. SIDINEI OLIVEIRA SOARES
  v_email := 'administracao.hefr@ceiam.org.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('6878687', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "SIDINEI OLIVEIRA SOARES", "cnes": "6878687"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 17. IVANETE ALBINO
  v_email := 'ivaneti.albino@hospitalfreigalvao.com.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2081644', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "IVANETE ALBINO", "cnes": "2081644"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 18. ROBSON RAIMUNDO DA COSTA
  v_email := 'robson@saocamilo-hlmb.org.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('3753433', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "ROBSON RAIMUNDO DA COSTA", "cnes": "3753433"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 19. FRANCIANE DE ARAUJO CASTANHAR ALVES
  v_email := 'pcontas@santacasadearacatuba.com.br';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2078775', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "FRANCIANE DE ARAUJO CASTANHAR ALVES", "cnes": "2078775"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- 20. RONEY LORENZETTI E SILVA
  v_email := 'siemservicosadm@gmail.com';
  v_user_id := (SELECT id FROM auth.users WHERE email = v_email LIMIT 1);
  
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      crypt('2080095', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name": "RONEY LORENZETTI E SILVA", "cnes": "2080095"}',
      false,
      NOW(), NOW()
    )
    RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

END $$;

-- ============================================================================
-- VALIDAÇÃO
-- ============================================================================
-- Verifique quantos usuários foram criados:
-- SELECT COUNT(*) FROM auth.users;
-- SELECT COUNT(*) FROM auth.identities;
-- ============================================================================
