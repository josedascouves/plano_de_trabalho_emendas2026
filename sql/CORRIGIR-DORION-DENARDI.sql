-- ============================================================================
-- CORRECÇÃO: USUÁRIO DORION DENARDI - ERRO AO RECREAR
-- ============================================================================
-- PROBLEMA:
-- - Usuário preenchendo formulários mas não salvando no banco
-- - Usuário foi deletado
-- - Ao tentar recriar, sistema diz que já existe
--
-- CAUSA: Registro órfão em auth.users (sem entradas em profiles/user_roles)
-- ============================================================================

-- PASSO 1: LIMPAR REGISTROS ÓRFÃOS
-- Apagar qualquer entrada em profiles e user_roles para este usuário
DELETE FROM user_roles 
WHERE user_id IN (
  SELECT id FROM profiles 
  WHERE email = 'escritoriodeprojetos@hospitaldeamor.com.br'
);

DELETE FROM profiles 
WHERE email = 'escritoriodeprojetos@hospitaldeamor.com.br';

-- ============================================================================
-- PASSO 2: VERIFICAR STATUS NO auth.users
-- ============================================================================
-- Execute esta query para ver se o usuário ainda existe em auth.users
SELECT 
  'STATUS AUTH.USERS' as info,
  id,
  email,
  raw_user_meta_data->>'full_name' as full_name,
  created_at,
  CASE WHEN deleted_at IS NOT NULL THEN 'DELETADO' ELSE 'ATIVO' END as status
FROM auth.users
WHERE email = 'escritoriodeprojetos@hospitaldeamor.com.br';

-- ============================================================================
-- PASSO 3: SE O USUÁRIO AINDA EXISTE EM auth.users
-- ============================================================================
-- Se a query acima retornar um registro, execute isto para recrear as entradas:

WITH user_data AS (
  SELECT id, email, raw_user_meta_data->>'full_name' as full_name, created_at
  FROM auth.users
  WHERE email = 'escritoriodeprojetos@hospitaldeamor.com.br'
)

-- Recriar entry em profiles
INSERT INTO profiles (id, email, full_name, cnes, created_at)
SELECT 
  ud.id,
  ud.email,
  COALESCE(ud.full_name, 'Dorion Denardi'),
  '2090236',
  ud.created_at
FROM user_data ud
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = COALESCE(EXCLUDED.full_name, profiles.full_name),
  cnes = COALESCE(EXCLUDED.cnes, profiles.cnes);

-- Recriar entry em user_roles (como user padrão)
INSERT INTO user_roles (user_id, role, disabled)
SELECT 
  p.id,
  'user',
  false
FROM profiles p
WHERE p.email = 'escritoriodeprojetos@hospitaldeamor.com.br'
ON CONFLICT (user_id) DO UPDATE SET
  disabled = false;

-- ============================================================================
-- PASSO 4: CONFIRMAR RESULTADO FINAL
-- ============================================================================
SELECT 
  '✅ SETUP COMPLETO' as resultado,
  p.id,
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled,
  COALESCE(a.confirmed_at, a.created_at) as created_at
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
LEFT JOIN auth.users a ON p.id = a.id
WHERE p.email = 'escritoriodeprojetos@hospitaldeamor.com.br';

-- ============================================================================
-- SE O USUÁRIO NÃO EXISTIR MAIS EM auth.users
-- ============================================================================
-- PASSO A: Deletar manualmente do Supabase Dashboard:
--   1. Vá para: Supabase Dashboard → Authentication → Users
--   2. Procure por: escritoriodeprojetos@hospitaldeamor.com.br
--   3. Se existir, clique nos 3 pontinhos (⋮) e selecione "Delete user"
--
-- PASSO B: No app, crie o usuário novamente com as credenciais:
--   Email:  escritoriodeprojetos@hospitaldeamor.com.br
--   Senha:  2090236 (ou a senha padrão do seu sistema)
--   Nome:   Dorion Denardi
--   CNES:   2090236
--   Perfil: Usuário Padrão

-- ============================================================================
-- DIAGNÓSTICO: USUÁRIOS ÓRFÃOS DO SISTEMA
-- ============================================================================
SELECT 
  'USUÁRIOS ÓRFÃOS (em auth.users mas não em profiles/roles)' as categoria,
  u.id,
  u.email,
  u.raw_user_meta_data->>'full_name' as full_name,
  u.created_at,
  CASE WHEN u.deleted_at IS NOT NULL THEN 'DELETADO' ELSE 'ATIVO' END as status
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.id
WHERE p.id IS NULL
ORDER BY u.created_at DESC;
