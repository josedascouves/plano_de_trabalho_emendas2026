-- ============================================================
-- Script para criar usuário de teste no Supabase
-- Email: sessp.css2@gmail.com
-- Senha: Digite uma senha aqui (ex: SenhaSegura123!)
-- ============================================================

-- PASSO 1: Criar usuário na tabela auth.users
-- Substitua 'SenhaSegura123!' pela senha que desejar
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  invited_at,
  confirmation_token,
  confirmation_sent_at,
  recovery_token,
  recovery_sent_at,
  email_change_token_new,
  email_change,
  email_change_token_expires,
  phone,
  phone_confirmed_at,
  phone_change,
  phone_change_token,
  phone_change_sent_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  created_at,
  updated_at,
  last_sign_in_at,
  banned_until,
  reauthentication_token,
  reauthentication_sent_at,
  is_sso_user
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'sessp.css2@gmail.com',
  crypt('SenhaSegura123!', gen_salt('bf')),
  now(),
  NULL,
  '',
  NULL,
  '',
  NULL,
  '',
  '',
  NULL,
  '',
  NULL,
  '',
  '',
  NULL,
  '{"provider":"email","providers":["email"]}',
  '{}',
  false,
  now(),
  now(),
  NULL,
  NULL,
  '',
  NULL,
  false
)
ON CONFLICT (email) DO NOTHING;

-- PASSO 2: Obter o ID do usuário criado e criar perfil
-- Execute isto APÓS o PASSO 1
WITH user_id AS (
  SELECT id FROM auth.users 
  WHERE email = 'sessp.css2@gmail.com'
  LIMIT 1
)
INSERT INTO profiles (id, role, disabled, created_at)
SELECT id, 'user', false, now()
FROM user_id
ON CONFLICT (id) DO NOTHING;

-- PASSO 3: Verificar se foi criado com sucesso
SELECT 
  u.id,
  u.email,
  u.email_confirmed_at,
  p.role,
  p.disabled
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.id
WHERE u.email = 'sessp.css2@gmail.com';
