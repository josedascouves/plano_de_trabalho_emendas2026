-- ============================================================================
-- CORRIGIR TODOS OS USUÁRIOS ÓRFÃOS (faltam roles)
-- ============================================================================
-- Este script cria entradas em user_roles para todos os usuários que faltam
-- Resultado esperado: Todos os 5 usuários aparecem na lista e conseguem logar
-- ============================================================================

-- PASSO 1: Adicionar roles para TODOS os usuários órfãos
INSERT INTO user_roles (user_id, role, disabled)
SELECT 
  p.id,
  'user' as role,  -- Todos como usuários padrão
  false as disabled
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
WHERE ur.user_id IS NULL  -- Só os que NÃO têm role
ON CONFLICT (user_id) DO NOTHING;

-- PASSO 2: Verificar resultado - deve mostrar todos os 5 usuários visíveis
SELECT 
  p.full_name,
  p.email,
  p.cnes,
  ur.role,
  ur.disabled,
  '✅ CORRIGIDO' as status
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
WHERE ur.disabled = false
ORDER BY p.full_name;

-- PASSO 3: Confirmar que não há mais órfãos
SELECT 
  COUNT(*) as usuarios_orfaos_restantes,
  'Deve ser 0 se tudo correu bem' as esperado
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
WHERE ur.user_id IS NULL;

-- ============================================================================
-- RESULTADO ESPERADO:
-- - 5 usuários aparecendo em "CORRIGIDO"
-- - 0 em "usuarios_orfaos_restantes"
-- ============================================================================
