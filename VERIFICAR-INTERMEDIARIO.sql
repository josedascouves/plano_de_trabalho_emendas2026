-- ==============================================================================
-- VERIFICAÇÃO: Usuários Intermediários
-- ==============================================================================
--
-- PROBLEMA: Intermediário está aparecendo como usuário "padrão"
-- CAUSAS POSSÍVEIS:
-- 1. Role não foi criada corretamente no banco
-- 2. Role está com valor diferente de 'intermediate'
-- 3. Cache/sessão não foi limpa
--
-- ==============================================================================

-- 1️⃣ VER TODOS OS USUÁRIOS E SUAS ROLES
SELECT 
  p.id,
  p.email,
  p.full_name,
  ur.role,
  ur.disabled,
  p.created_at
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
ORDER BY p.full_name;

-- 2️⃣ VERIFICAR RESTRIÇÃO DE CHECK CONSTRAINT
SELECT 
  constraint_name,
  check_clause
FROM information_schema.check_constraints
WHERE constraint_name LIKE '%role%';

-- 3️⃣ VERIFICAR SE EXISTE CONSTRAINT ACEITA 'intermediate'
SELECT 
  'Valores aceitos em user_roles.role: user, admin, intermediate' as info;

-- 4️⃣ SE ENCONTROU INTERMEDIÁRIO COM ROLE ERRADO, CORRIGIR:
-- (Descomente se necessário)

-- Opção A: Se role está NULL ou vazio
-- UPDATE public.user_roles 
-- SET role = 'intermediate'
-- WHERE user_id = 'ID_DO_INTERMEDIARIO_AQUI' 
-- AND role IS NULL;

-- Opção B: Se role está 'user' e precisa ser 'intermediate'
-- UPDATE public.user_roles 
-- SET role = 'intermediate'
-- WHERE user_id = 'ID_DO_INTERMEDIARIO_AQUI' 
-- AND role = 'user';

-- 5️⃣ CONFIRMAÇÃO
SELECT '
╔════════════════════════════════════════════════════════════╗
║  VERIFICAÇÃO CONCLUÍDA                                     ║
║                                                            ║
║  Se viu intermediário no resultado:                       ║
║    ✅ Role está correto no banco                         ║
║    → Faça Ctrl+F5 para limpar cache                      ║
║    → Logout e login novamente                            ║
║                                                            ║
║  Se não viu ou role está errado:                          ║
║    → Execute a Opção A ou B acima (descomente)           ║
║    → Depois faça Ctrl+F5 na app                          ║
║                                                            ║
║  Se problema persistir:                                   ║
║    → Execute: RECUPERAR-USUARIOS-CORRIGIDO.sql           ║
║
╚════════════════════════════════════════════════════════════╝
' as info;

-- ==============================================================================
