-- ============================================================================
-- CORRECÇÃO FORÇADA: RECUPERAR USUÁRIO NÃO-VISÍVEL
-- ============================================================================
-- EXECUTAR ISSO NO SUPABASE SQL EDITOR para garantir que o usuário:
-- 1. Existe em profiles
-- 2. Existe em user_roles
-- 3. Não está desativado
-- 4. Aparece na lista de usuários
-- ============================================================================
-- PROBLEMA ENCONTRADO: RLS policies bloqueavam a inserção
-- SOLUÇÃO: Desabilitar RLS temporariamente
-- ============================================================================

-- PASSO 0: Iniciar transação com RLS desabilitado (tudo dentro de uma transação)
BEGIN;

ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;

-- PASSO 1: Inserir em profiles (DIRETO, uuid de Gabriela apenas)
INSERT INTO profiles (id, email, full_name, cnes, created_at)
VALUES (
  '53dd9dd2-9090-4456-860f-d40678eefa3d',
  'gabriela.dias@hc.fm.usp.br',
  'Gabriela Dias Propheta Caneiro',
  '2071568',
  '2026-03-03 14:38:54.26345+00'
)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  cnes = EXCLUDED.cnes;

-- PASSO 2: Garantir entry em user_roles (uuid de Gabriela apenas)
INSERT INTO user_roles (user_id, role, disabled)
VALUES (
  '53dd9dd2-9090-4456-860f-d40678eefa3d',
  'user',
  false
)
ON CONFLICT (user_id) DO UPDATE SET
  role = EXCLUDED.role,
  disabled = false;

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

COMMIT;

-- PASSO 4: Confirmar que o usuário está OK
SELECT 
  '✅ USUÁRIO RECUPERADO COM SUCESSO' as resultado,
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
WHERE p.id = '53dd9dd2-9090-4456-860f-d40678eefa3d';


