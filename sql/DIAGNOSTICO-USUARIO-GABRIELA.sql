-- ============================================================================
-- DIAGNÓSTICO E CORRECÇÃO DE USUÁRIO NÃO-VISÍVEL
-- ============================================================================
-- Problema: Usuário foi criado mas não aparece na lista (ou não consegue logar)
-- Solução: Verificar integridade do usuário em todas as tabelas
-- Email: gabriela.dias@hc.fm.usp.br
-- CNES: 2071568
-- ============================================================================

-- 1. VERIFICAR SE O USUÁRIO EXISTE EM CADA TABELA
SELECT 'auth.users' as tabela, COUNT(*) as total FROM auth.users WHERE email = 'gabriela.dias@hc.fm.usp.br'
UNION ALL
SELECT 'profiles' as tabela, COUNT(*) as total FROM profiles WHERE email = 'gabriela.dias@hc.fm.usp.br'
UNION ALL
SELECT 'user_roles' as tabela, COUNT(*) as total FROM user_roles ur 
  INNER JOIN profiles p ON ur.user_id = p.id WHERE p.email = 'gabriela.dias@hc.fm.usp.br';

-- 2. BUSCAR O USER_ID DO AUTH (se existir) ou doFICÍO (se não existir)
SELECT 'auth.users (detalhes)' as info,
       id as user_id,
       email,
       created_at,
       (confirmed_at IS NOT NULL) as email_confirmado
FROM auth.users 
WHERE email = 'gabriela.dias@hc.fm.usp.br';

-- 3. VERIFICAR PROFILES
SELECT 'profiles (detalhes)' as info,
       id as user_id,
       email,
       full_name,
       cnes,
       created_at
FROM profiles 
WHERE email = 'gabriela.dias@hc.fm.usp.br';

-- 4. VERIFICAR USER_ROLES
SELECT 'user_roles (detalhes)' as info,
       ur.user_id,
       ur.role,
       ur.disabled,
       p.email,
       p.full_name
FROM user_roles ur
LEFT JOIN profiles p ON ur.user_id = p.id
WHERE p.email = 'gabriela.dias@hc.fm.usp.br';

-- ============================================================================
-- SE O USUÁRIO EXISTE MAS ESTÁ INCOMPLETO, EXECUTAR ISSO:
-- ============================================================================

-- OPÇÃO A: Se existe em auth.users mas NÃO em profiles
-- Pega o ID do auth (copie o user_id da query acima)
INSERT INTO profiles (id, email, full_name, cnes, created_at)
SELECT id, email, raw_user_meta_data->>'full_name', '2071568', created_at
FROM auth.users
WHERE email = 'gabriela.dias@hc.fm.usp.br'
  AND id NOT IN (SELECT id FROM profiles WHERE email = 'gabriela.dias@hc.fm.usp.br')
ON CONFLICT (id) DO NOTHING;

-- OPÇÃO B: Se existe em profiles mas NÃO em user_roles
-- Buscar o ID de profiles e inserir em user_roles
INSERT INTO user_roles (user_id, role, disabled)
SELECT id, 'user', false
FROM profiles
WHERE email = 'gabriela.dias@hc.fm.usp.br'
  AND id NOT IN (SELECT user_id FROM user_roles WHERE user_id = profiles.id)
ON CONFLICT (user_id) DO NOTHING;

-- OPÇÃO C: Se existe em user_roles mas está desativado (disabled = true)
UPDATE user_roles
SET disabled = false
WHERE user_id IN (SELECT id FROM profiles WHERE email = 'gabriela.dias@hc.fm.usp.br');

-- ============================================================================
-- VERIFICAR RESULTADO FINAL
-- ============================================================================
SELECT 
  'RESULTADO FINAL' as status,
  p.id as user_id,
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled,
  a.created_at,
  (a.confirmed_at IS NOT NULL) as email_confirmado
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
LEFT JOIN auth.users a ON p.id = a.id
WHERE p.email = 'gabriela.dias@hc.fm.usp.br';

-- ============================================================================
-- VERIFICAR RLS - Confirmar que o usuário consegue ser visto
-- ============================================================================
-- Nota: A coluna 'disabled' deve ser false para aparecer na lista
-- Se aparecer alguma linha aqui é porque está tudo OK
SELECT 
  'RLS CHECK: Usuário visível?' as check_name,
  p.id,
  p.email,
  p.full_name,
  ur.role
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
WHERE p.email = 'gabriela.dias@hc.fm.usp.br'
  AND (ur.disabled IS NULL OR ur.disabled = false);
