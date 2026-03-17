-- ============================================================
-- Script para RESETAR SENHA do usuário sessp.css2@gmail.com
-- ============================================================

-- PASSO 1: Verificar status do usuário
SELECT 
  id,
  email,
  email_confirmed_at,
  created_at,
  last_sign_in_at
FROM auth.users 
WHERE email = 'sessp.css2@gmail.com';

-- PASSO 2: Verificar se está desativado no profiles
SELECT 
  id,
  role,
  disabled
FROM profiles
WHERE id IN (
  SELECT id FROM auth.users WHERE email = 'sessp.css2@gmail.com'
);

-- PASSO 3: RESETAR A SENHA (escolha uma nova senha abaixo)
UPDATE auth.users
SET 
  encrypted_password = crypt('NovaSenh123!', gen_salt('bf')),
  updated_at = now()
WHERE email = 'sessp.css2@gmail.com';

-- PASSO 4: Se estiver desativado, ativar
UPDATE profiles
SET disabled = false
WHERE id IN (
  SELECT id FROM auth.users WHERE email = 'sessp.css2@gmail.com'
);

-- PASSO 5: Confirmar a mudança
SELECT 
  u.email,
  u.email_confirmed_at,
  p.disabled,
  u.updated_at
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.id
WHERE u.email = 'sessp.css2@gmail.com';
