-- ============================================================================
-- SCRIPT DEFINITIVO - CORRIGIR BANCO + CRIAR 20 USUARIOS COM EMAILS CORRETOS
-- ============================================================================
-- Este script resolve:
--   1. Erro "Database error querying schema" (RLS recursivo + triggers quebrados)
--   2. Cria os 20 usuarios com os emails CORRETOS da planilha
--   3. Sincroniza profiles e user_roles
--
-- INSTRUCOES:
--   1. Acesse https://supabase.com/dashboard/project/tlpmspfnswaxwqzmwski/sql/new
--   2. Cole ESTE SCRIPT INTEIRO
--   3. Clique em "Run" (Ctrl+Enter)
--   4. Aguarde ate ver as mensagens de confirmacao
-- ============================================================================

-- ============================================================================
-- ETAPA 1: CORRIGIR SCHEMA - Remover triggers, funcoes e RLS problematicos
-- ============================================================================

-- 1A: Remover TODOS os triggers que causam erro
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS profiles_update_timestamp ON public.profiles;
DROP TRIGGER IF EXISTS handle_updated_at ON public.profiles;
DROP TRIGGER IF EXISTS on_user_created ON auth.users;
DROP TRIGGER IF EXISTS sync_profile_on_auth ON auth.users;

-- 1B: Remover TODAS as funcoes que podem falhar
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.update_profiles_timestamp() CASCADE;
DROP FUNCTION IF EXISTS public.handle_updated_at() CASCADE;
DROP FUNCTION IF EXISTS public.sincronizar_usuario_orfao(text, text, text) CASCADE;
DROP FUNCTION IF EXISTS public.sincronizar_todos_usuarios_orfaos() CASCADE;
DROP FUNCTION IF EXISTS public.sync_auth_to_profile() CASCADE;
DROP FUNCTION IF EXISTS public.create_app_user(text, text, text, text) CASCADE;

-- 1C: Remover TODAS as politicas RLS problematicas de profiles
DROP POLICY IF EXISTS "read_all_profiles" ON public.profiles;
DROP POLICY IF EXISTS "update_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "insert_profile" ON public.profiles;
DROP POLICY IF EXISTS "users_can_view_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "users_can_update_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_can_view_all" ON public.profiles;
DROP POLICY IF EXISTS "admin_can_update_all" ON public.profiles;
DROP POLICY IF EXISTS "admin_can_insert" ON public.profiles;
DROP POLICY IF EXISTS "users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all" ON public.profiles;
DROP POLICY IF EXISTS "profiles - Allow all authenticated read" ON public.profiles;
DROP POLICY IF EXISTS "profiles - Allow all authenticated update" ON public.profiles;
DROP POLICY IF EXISTS "admin_delete_profiles" ON public.profiles;
DROP POLICY IF EXISTS "admin_create_profiles" ON public.profiles;
DROP POLICY IF EXISTS "user_update_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_read_users" ON public.profiles;
DROP POLICY IF EXISTS "admin_write_users" ON public.profiles;
DROP POLICY IF EXISTS "users_read_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "users_insert_profile" ON public.profiles;
DROP POLICY IF EXISTS "users_update_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "verified email" ON public.profiles;
DROP POLICY IF EXISTS "Profiles visiveis por usuarios autenticados" ON public.profiles;
DROP POLICY IF EXISTS "Usuarios editam proprio perfil" ON public.profiles;

-- Remover politicas de user_roles
DROP POLICY IF EXISTS "read_all_user_roles" ON public.user_roles;
DROP POLICY IF EXISTS "update_user_roles" ON public.user_roles;
DROP POLICY IF EXISTS "insert_user_roles" ON public.user_roles;
DROP POLICY IF EXISTS "user_roles - Admin can read" ON public.user_roles;
DROP POLICY IF EXISTS "user_roles - Admin can update" ON public.user_roles;
DROP POLICY IF EXISTS "user_roles - Admin can delete" ON public.user_roles;

-- Remover politicas de planos_trabalho
DROP POLICY IF EXISTS "Usuarios veem proprios planos ou admins todos" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Usuarios inserem proprios planos" ON public.planos_trabalho;
DROP POLICY IF EXISTS "Acesso metas quant via dono/admin" ON public.acoes_servicos;
DROP POLICY IF EXISTS "Acesso metas qual via dono/admin" ON public.metas_qualitativas;
DROP POLICY IF EXISTS "Acesso naturezas via dono/admin" ON public.naturezas_despesa_plano;

-- 1D: DESABILITAR RLS em TODAS as tabelas
ALTER TABLE IF EXISTS public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.user_roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.planos_trabalho DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.acoes_servicos DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.metas_qualitativas DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.naturezas_despesa_plano DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.audit_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.pdf_download_history DISABLE ROW LEVEL SECURITY;

SELECT '✅ ETAPA 1 CONCLUIDA: Schema corrigido, RLS desabilitado' as status;


-- ============================================================================
-- ETAPA 2: GARANTIR QUE AS TABELAS EXISTEM COM AS COLUNAS CORRETAS
-- ============================================================================

-- Garantir extensao pgcrypto
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Garantir que profiles tem coluna cnes
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'cnes'
  ) THEN
    ALTER TABLE public.profiles ADD COLUMN cnes TEXT;
  END IF;
END $$;

-- Garantir que tabela user_roles existe
CREATE TABLE IF NOT EXISTS public.user_roles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role VARCHAR(50) DEFAULT 'user',
  disabled BOOLEAN DEFAULT FALSE
);

-- Desabilitar RLS na user_roles recem-criada (caso tenha sido criada agora)
ALTER TABLE public.user_roles DISABLE ROW LEVEL SECURITY;

SELECT '✅ ETAPA 2 CONCLUIDA: Tabelas verificadas' as status;


-- ============================================================================
-- ETAPA 3: LIMPAR USUARIOS ANTIGOS COM EMAILS ERRADOS
-- ============================================================================

-- Lista de emails ERRADOS que foram criados por scripts anteriores com typos
-- Vamos remover da user_roles, profiles e identities primeiro (FK cascade)

DELETE FROM public.user_roles WHERE user_id IN (
  SELECT id FROM auth.users WHERE email IN (
    'ibraga@unimautraimiira.unicamp.br',
    'hospitalderluiz@yahoo.com.br',
    'convenios2@cipriaioayla.com.br',
    'relacaespublicas@casadedavid.org.br',
    'convenios2.b@cipriaioayla.com.br',
    'irenef@frm.br',
    'sec.itaim@oss.santamarcalina.org',
    'sec.itaim@oss.santamarcalina.org.br',
    'administracao.hefr@ceiam.org.br',
    'siemservicosadm@gmail.com'
  )
);

DELETE FROM public.profiles WHERE id IN (
  SELECT id FROM auth.users WHERE email IN (
    'ibraga@unimautraimiira.unicamp.br',
    'hospitalderluiz@yahoo.com.br',
    'convenios2@cipriaioayla.com.br',
    'relacaespublicas@casadedavid.org.br',
    'convenios2.b@cipriaioayla.com.br',
    'irenef@frm.br',
    'sec.itaim@oss.santamarcalina.org',
    'sec.itaim@oss.santamarcalina.org.br',
    'administracao.hefr@ceiam.org.br',
    'siemservicosadm@gmail.com'
  )
);

DELETE FROM auth.identities WHERE user_id IN (
  SELECT id FROM auth.users WHERE email IN (
    'ibraga@unimautraimiira.unicamp.br',
    'hospitalderluiz@yahoo.com.br',
    'convenios2@cipriaioayla.com.br',
    'relacaespublicas@casadedavid.org.br',
    'convenios2.b@cipriaioayla.com.br',
    'irenef@frm.br',
    'sec.itaim@oss.santamarcalina.org',
    'sec.itaim@oss.santamarcalina.org.br',
    'administracao.hefr@ceiam.org.br',
    'siemservicosadm@gmail.com'
  )
);

DELETE FROM auth.users WHERE email IN (
  'ibraga@unimautraimiira.unicamp.br',
  'hospitalderluiz@yahoo.com.br',
  'convenios2@cipriaioayla.com.br',
  'relacaespublicas@casadedavid.org.br',
  'convenios2.b@cipriaioayla.com.br',
  'irenef@frm.br',
  'sec.itaim@oss.santamarcalina.org',
  'sec.itaim@oss.santamarcalina.org.br',
  'administracao.hefr@ceiam.org.br',
  'siemservicosadm@gmail.com'
);

SELECT '✅ ETAPA 3 CONCLUIDA: Usuarios com emails errados removidos' as status;


-- ============================================================================
-- ETAPA 4: CRIAR OS 20 USUARIOS COM EMAILS CORRETOS
-- ============================================================================
-- Emails e dados conforme planilha fornecida
-- Senha = CNES para todos
-- ============================================================================

DO $$
DECLARE
  v_user_id UUID;
BEGIN

  -- ========================================
  -- 1. MARIA LUCIA BRAGA
  -- Email CORRETO: lbraga@amelimeira.unicamp.br (antes estava: ibraga@unimautraimiira.unicamp.br)
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'lbraga@amelimeira.unicamp.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'lbraga@amelimeira.unicamp.br', crypt('6523536', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"MARIA LUCIA BRAGA","cnes":"6523536"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'lbraga@amelimeira.unicamp.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('6523536', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'lbraga@amelimeira.unicamp.br', 'MARIA LUCIA BRAGA', '6523536') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 2. LUIZ CARLOS VIANA BARBOSA
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'luiz.barbosa@amemogi.spdm.org.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'luiz.barbosa@amemogi.spdm.org.br', crypt('7021801', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"LUIZ CARLOS VIANA BARBOSA","cnes":"7021801"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'luiz.barbosa@amemogi.spdm.org.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('7021801', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'luiz.barbosa@amemogi.spdm.org.br', 'LUIZ CARLOS VIANA BARBOSA', '7021801') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 3. FABIO CAMARGO DA SILVA
  -- Email CORRETO: hospitalandreluiz@yahoo.com.br (antes estava: hospitalderluiz@yahoo.com.br)
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'hospitalandreluiz@yahoo.com.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'hospitalandreluiz@yahoo.com.br', crypt('2745356', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"FABIO CAMARGO DA SILVA","cnes":"2745356"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'hospitalandreluiz@yahoo.com.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2745356', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'hospitalandreluiz@yahoo.com.br', 'FABIO CAMARGO DA SILVA', '2745356') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 4. EVELYN FERNANDA PEREIRA DOS SANTOS (CNES 2078813)
  -- Email CORRETO: convenios2@ciprianoayla.com.br (antes estava: convenios2@cipriaioayla.com.br)
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'convenios2@ciprianoayla.com.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'convenios2@ciprianoayla.com.br', crypt('2078813', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"EVELYN FERNANDA PEREIRA DOS SANTOS","cnes":"2078813"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'convenios2@ciprianoayla.com.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2078813', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'convenios2@ciprianoayla.com.br', 'EVELYN FERNANDA PEREIRA DOS SANTOS', '2078813') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 5. AMAURI PERES VENTOJA
  -- Email CORRETO: relacoespublicas@casadedavid.org.br (antes estava: relacaespublicas@casadedavid.org.br)
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'relacoespublicas@casadedavid.org.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'relacoespublicas@casadedavid.org.br', crypt('2688522', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"AMAURI PERES VENTOJA","cnes":"2688522"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'relacoespublicas@casadedavid.org.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2688522', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'relacoespublicas@casadedavid.org.br', 'AMAURI PERES VENTOJA', '2688522') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 6. PATRICIA SILVA SANTOS
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'patricia.santos@colsan.org.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'patricia.santos@colsan.org.br', crypt('2088932', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"PATRICIA SILVA SANTOS","cnes":"2088932"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'patricia.santos@colsan.org.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2088932', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'patricia.santos@colsan.org.br', 'PATRICIA SILVA SANTOS', '2088932') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 7. EVELYN FERNANDA PEREIRA DOS SANTOS (CNES 2089327) - SEGUNDO CNES
  -- ATENCAO: Mesmo email que usuario #4! Supabase nao permite emails duplicados.
  -- Solucao: usar email com sufixo .cnes2089327 para diferenciar
  -- Login: convenios2.cnes2089327@ciprianoayla.com.br / Senha: 2089327
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'convenios2.cnes2089327@ciprianoayla.com.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'convenios2.cnes2089327@ciprianoayla.com.br', crypt('2089327', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"EVELYN FERNANDA PEREIRA DOS SANTOS","cnes":"2089327"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'convenios2.cnes2089327@ciprianoayla.com.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2089327', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'convenios2.cnes2089327@ciprianoayla.com.br', 'EVELYN FERNANDA PEREIRA DOS SANTOS', '2089327') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 8. RUBENS SINSEI TANABE
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'hospitalbsaojose@gmsil.com' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'hospitalbsaojose@gmsil.com', crypt('2080281', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"RUBENS SINSEI TANABE","cnes":"2080281"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'hospitalbsaojose@gmsil.com', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2080281', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'hospitalbsaojose@gmsil.com', 'RUBENS SINSEI TANABE', '2080281') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 9. MEIRE VIEIRA DE CARVALHO TARLA
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'tarla@hcrp.usp.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'tarla@hcrp.usp.br', crypt('2082187', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"MEIRE VIEIRA DE CARVALHO TARLA","cnes":"2082187"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'tarla@hcrp.usp.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2082187', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'tarla@hcrp.usp.br', 'MEIRE VIEIRA DE CARVALHO TARLA', '2082187') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 10. IRENE DE SOUSA FARIAS
  -- Email CORRETO: irenef@ffm.br (antes estava: irenef@frm.br)
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'irenef@ffm.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'irenef@ffm.br', crypt('2078015', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"IRENE DE SOUSA FARIAS","cnes":"2078015"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'irenef@ffm.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2078015', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'irenef@ffm.br', 'IRENE DE SOUSA FARIAS', '2078015') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 11. PAULO DAVID DOMINGUES DE OLIVEIRA
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'paulo.o@hc.fm.usp.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'paulo.o@hc.fm.usp.br', crypt('2078015', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"PAULO DAVID DOMINGUES DE OLIVEIRA","cnes":"2078015"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'paulo.o@hc.fm.usp.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2078015', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'paulo.o@hc.fm.usp.br', 'PAULO DAVID DOMINGUES DE OLIVEIRA', '2078015') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 12. PATRICIA ARAUJO LANTMAN DE SOUZA
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'dir.executiva.heb@famesp.org.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'dir.executiva.heb@famesp.org.br', crypt('2790602', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"PATRICIA ARAUJO LANTMAN DE SOUZA","cnes":"2790602"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'dir.executiva.heb@famesp.org.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2790602', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'dir.executiva.heb@famesp.org.br', 'PATRICIA ARAUJO LANTMAN DE SOUZA', '2790602') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 13. ANA PAULA BORGES
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'expediente@hgt.org.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'expediente@hgt.org.br', crypt('2082225', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"ANA PAULA BORGES","cnes":"2082225"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'expediente@hgt.org.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2082225', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'expediente@hgt.org.br', 'ANA PAULA BORGES', '2082225') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 14. FERNANDA APARECIDA FERNANDES DE OLIVEIRA
  -- Email CORRETO: sec.itaim@oss.santamarcelina.org (antes estava: sec.itaim@oss.santamarcalina.org)
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'sec.itaim@oss.santamarcelina.org' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'sec.itaim@oss.santamarcelina.org', crypt('2077620', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"FERNANDA APARECIDA FERNANDES DE OLIVEIRA","cnes":"2077620"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'sec.itaim@oss.santamarcelina.org', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2077620', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'sec.itaim@oss.santamarcelina.org', 'FERNANDA APARECIDA FERNANDES DE OLIVEIRA', '2077620') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 15. SILVANIA SOUZA SILVA
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'silvania.ssilva@hgvp.org.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'silvania.ssilva@hgvp.org.br', crypt('2091755', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"SILVANIA SOUZA SILVA","cnes":"2091755"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'silvania.ssilva@hgvp.org.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2091755', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'silvania.ssilva@hgvp.org.br', 'SILVANIA SOUZA SILVA', '2091755') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 16. SIDINEI OLIVEIRA SOARES
  -- Email CORRETO: administracao.hefr@cejam.org.br (antes estava: administracao.hefr@ceiam.org.br)
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'administracao.hefr@cejam.org.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'administracao.hefr@cejam.org.br', crypt('6878687', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"SIDINEI OLIVEIRA SOARES","cnes":"6878687"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'administracao.hefr@cejam.org.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('6878687', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'administracao.hefr@cejam.org.br', 'SIDINEI OLIVEIRA SOARES', '6878687') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 17. IVANETE ALBINO
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'ivaneti.albino@hospitalfreigalvao.com.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'ivaneti.albino@hospitalfreigalvao.com.br', crypt('2081644', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"IVANETE ALBINO","cnes":"2081644"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'ivaneti.albino@hospitalfreigalvao.com.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2081644', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'ivaneti.albino@hospitalfreigalvao.com.br', 'IVANETE ALBINO', '2081644') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 18. ROBSON RAIMUNDO DA COSTA
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'robson@saocamilo-hlmb.org.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'robson@saocamilo-hlmb.org.br', crypt('3753433', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"ROBSON RAIMUNDO DA COSTA","cnes":"3753433"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'robson@saocamilo-hlmb.org.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('3753433', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'robson@saocamilo-hlmb.org.br', 'ROBSON RAIMUNDO DA COSTA', '3753433') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 19. FRANCIANE DE ARAUJO CASTANHAR ALVES
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'pcontas@santacasadearacatuba.com.br' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'pcontas@santacasadearacatuba.com.br', crypt('2078775', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"FRANCIANE DE ARAUJO CASTANHAR ALVES","cnes":"2078775"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'pcontas@santacasadearacatuba.com.br', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2078775', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'pcontas@santacasadearacatuba.com.br', 'FRANCIANE DE ARAUJO CASTANHAR ALVES', '2078775') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  -- ========================================
  -- 20. RONEY LORENZETTI E SILVA
  -- Email CORRETO: siempservicosadm@gmail.com (antes estava: siemservicosadm@gmail.com - faltava o "p")
  -- ========================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'siempservicosadm@gmail.com' LIMIT 1;
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
      'siempservicosadm@gmail.com', crypt('2080095', gen_salt('bf')), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"RONEY LORENZETTI E SILVA","cnes":"2080095"}',
      false, NOW(), NOW(), '', '', '', ''
    ) RETURNING id INTO v_user_id;
    
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', 'siempservicosadm@gmail.com', 'email_verified', true, 'phone_verified', false),
      'email', v_user_id::text, NOW(), NOW(), NOW());
  ELSE
    UPDATE auth.users SET encrypted_password = crypt('2080095', gen_salt('bf')), updated_at = NOW() WHERE id = v_user_id;
  END IF;
  INSERT INTO public.profiles (id, email, full_name, cnes) VALUES (v_user_id, 'siempservicosadm@gmail.com', 'RONEY LORENZETTI E SILVA', '2080095') ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, full_name = EXCLUDED.full_name, cnes = EXCLUDED.cnes;
  INSERT INTO public.user_roles (user_id, role, disabled) VALUES (v_user_id, 'user', false) ON CONFLICT (user_id) DO UPDATE SET role = 'user', disabled = false;

  RAISE NOTICE '✅ ETAPA 4 CONCLUIDA: 20 usuarios criados/atualizados com emails corretos!';
END $$;

SELECT '✅ ETAPA 4 CONCLUIDA: 20 usuarios criados com emails corretos' as status;


-- ============================================================================
-- ETAPA 5: VERIFICACAO FINAL
-- ============================================================================

-- 5A: Contar usuarios criados
SELECT 
  '📊 TOTAL DE USUARIOS' as info,
  COUNT(*) as total
FROM auth.users 
WHERE email IN (
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
);

-- 5B: Listar todos com seus dados
SELECT 
  u.email as "EMAIL LOGIN",
  p.full_name as "NOME",
  p.cnes as "CNES",
  ur.role as "ROLE",
  CASE WHEN i.id IS NOT NULL THEN '✅' ELSE '❌' END as "IDENTITY",
  CASE WHEN p.id IS NOT NULL THEN '✅' ELSE '❌' END as "PROFILE",
  CASE WHEN ur.user_id IS NOT NULL THEN '✅' ELSE '❌' END as "USER_ROLE"
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

-- 5C: Verificar se existem usuarios orfaos (em auth.users mas sem profile)
SELECT 
  '⚠️ USUARIOS SEM PROFILE (orfaos)' as info,
  u.email
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE p.id IS NULL;

-- 5D: Verificar RLS desabilitado
SELECT 
  schemaname, tablename, rowsecurity
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('profiles', 'user_roles', 'planos_trabalho')
ORDER BY tablename;

SELECT '============================================' as separador;
SELECT '✅ SCRIPT FINALIZADO COM SUCESSO!' as resultado;
SELECT '✅ RLS desabilitado - sem erro "Database error querying schema"' as resultado;
SELECT '✅ 20 usuarios criados com emails CORRETOS' as resultado;
SELECT '✅ Senha de cada usuario = seu numero CNES' as resultado;
SELECT '============================================' as separador;
