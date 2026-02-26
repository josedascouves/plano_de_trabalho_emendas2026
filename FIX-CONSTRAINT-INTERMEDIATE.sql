-- ==============================================================================
-- FIX: Adicionar 'intermediate' à restrição check constraint
-- ==============================================================================
--
-- ERRO: new row for relation "user_roles" violates check constraint "user_roles_role_check"
-- CAUSA: A restrição só aceita 'user' e 'admin', não 'intermediate'
-- SOLUÇÃO: Alterar a restrição
--
-- ==============================================================================

-- 1️⃣ REMOVER a restrição antiga
ALTER TABLE public.user_roles 
DROP CONSTRAINT user_roles_role_check;

SELECT '✅ Restrição antiga removida' as resultado;

-- 2️⃣ ADICIONAR restrição nova que aceita intermediate
ALTER TABLE public.user_roles 
ADD CONSTRAINT user_roles_role_check 
CHECK (role IN ('user', 'admin', 'intermediate'));

SELECT '✅ Restrição atualizada para aceitar: user, admin, intermediate' as resultado;

-- 3️⃣ VERIFICAÇÃO
SELECT 
  tc.constraint_name,
  cc.check_clause as constraint_definition
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.check_constraints cc 
  ON tc.constraint_name = cc.constraint_name
WHERE tc.table_name = 'user_roles' AND tc.constraint_type = 'CHECK';

SELECT '
╔════════════════════════════════════════════════════╗
║  ✅ CONSTRAINT CORRIGIDA!                          ║
║                                                    ║
║  Agora você pode criar usuários intermediários     ║
║  sem erros de constraint!                          ║
╚════════════════════════════════════════════════════╝
' as mensagem;

-- ==============================================================================
