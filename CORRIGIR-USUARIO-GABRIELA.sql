-- ============================================================================
-- CORRECÇÃO FORÇADA: RECUPERAR USUÁRIO NÃO-VISÍVEL
-- ============================================================================
-- EXECUTAR ISSO NO SUPABASE SQL EDITOR para garantir que o usuário:
-- 1. Existe em profiles
-- 2. Existe em user_roles
-- 3. Não está desativado
-- 4. Aparece na lista de usuários
-- ============================================================================

-- PASSO 1: Pegar o user_id do auth.users (COPIAR O ID)
-- Ajuste o email conforme necessário
WITH user_data AS (
  SELECT id, email, raw_user_meta_data->>'full_name' as full_name, created_at
  FROM auth.users
  WHERE email = 'gabriela.dias@hc.fm.usp.br'
)

-- PASSO 2: Garantir entry em profiles
INSERT INTO profiles (id, email, full_name, cnes, created_at)
SELECT 
  ud.id,
  ud.email,
  COALESCE(ud.full_name, 'Gabriela Dias Propheta Caneiro'),
  '2071568',
  ud.created_at
FROM user_data ud
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = COALESCE(EXCLUDED.full_name, profiles.full_name),
  cnes = COALESCE(EXCLUDED.cnes, profiles.cnes);

-- PASSO 3: Garantir entry em user_roles (como user padrão)
INSERT INTO user_roles (user_id, role, disabled)
SELECT 
  p.id,
  'user',
  false
FROM profiles p
WHERE p.email = 'gabriela.dias@hc.fm.usp.br'
ON CONFLICT (user_id) DO UPDATE SET
  disabled = false;

-- PASSO 4: Confirmar que o usuário está OK
SELECT 
  '✅ STATUS FINAL' as resultado,
  p.id,
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled,
  a.confirmed_at
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
LEFT JOIN auth.users a ON p.id = a.id
WHERE p.email = 'gabriela.dias@hc.fm.usp.br';

-- ============================================================================
-- ALTERNATIVA: SE ACIMA NÃO FUNCIONAR, EXECUTAR ISSO PARA DELETAR TUDO
-- (Você precisará deletar manualmente do Supabase Dashboard: Auth → Users)
-- ============================================================================

-- Deletar de user_roles
DELETE FROM user_roles 
WHERE user_id IN (
  SELECT id FROM profiles 
  WHERE email = 'gabriela.dias@hc.fm.usp.br'
);

-- Deletar de profiles  
DELETE FROM profiles 
WHERE email = 'gabriela.dias@hc.fm.usp.br';

-- DEPOIS: Deletar manualmente do Supabase Dashboard:
-- 1. Vá para: Supabase Dashboard → Authentication → Users
-- 2. Procure por: gabriela.dias@hc.fm.usp.br
-- 3. Clique nos 3 pontinhos (⋮) e selecione "Delete user"
-- 4. Depois no app, crie o usuário novamente com as credenciais:
--    Email: gabriela.dias@hc.fm.usp.br
--    Senha: 2071568
--    Nome: Gabriela Dias Propheta Caneiro
--    CNES: 2071568
--    Perfil: Usuário Padrão

-- ============================================================================
-- VERIFICAR TODOS OS USUÁRIOS PARA GARANTIR INTEGRIDADE
-- ============================================================================

-- Mostrar usuários visíveis (devem aparecer na lista)
SELECT 
  'USUÁRIOS VISÍVEIS (aparecem na lista)' as categoria,
  p.full_name,
  p.email,
  p.cnes,
  ur.role,
  p.created_at
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
WHERE (ur.disabled IS NULL OR ur.disabled = false)
ORDER BY ur.role DESC, p.full_name;

-- Mostrar usuários desativados (NÃO aparecem na lista)
SELECT 
  'USUÁRIOS DESATIVADOS (não aparecem na lista)' as categoria,
  p.full_name,
  p.email,
  p.cnes,
  ur.role,
  p.created_at
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
WHERE ur.disabled = true
ORDER BY p.full_name;

-- Mostrar usuários órfãos (em profiles mas sem role)
SELECT 
  'USUÁRIOS ÓRFÃOS (faltam roles)' as categoria,
  p.full_name,
  p.email,
  p.cnes,
  p.created_at
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
WHERE ur.user_id IS NULL
ORDER BY p.full_name;
