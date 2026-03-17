-- ==============================================================================
-- DIAGNÓSTICO COMPLETO: Intermediário não vê Dashboard/Planos
-- ==============================================================================

-- 1️⃣ VERIFICAR TODOS OS USUÁRIOS E ROLES
SELECT 
  '=== USUÁRIOS E ROLES ===' as status;

SELECT 
  p.id,
  p.email,
  p.full_name,
  ur.role,
  ur.disabled,
  p.disabled as profile_disabled,
  p.created_at
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
ORDER BY p.full_name;

-- 2️⃣ VERIFICAR CONSTRAINT DE ROLES
SELECT '
=== CONSTRAINT ACEITA ===' as status;

SELECT check_clause FROM information_schema.check_constraints 
WHERE constraint_name = 'user_roles_role_check';

-- 3️⃣ VER TODOS OS PLANOS CRIADOS
SELECT '
=== PLANOS NO BANCO ===' as status;

SELECT 
  id,
  created_by,
  numero_emenda,
  valor_total,
  created_at
FROM public.planos_trabalho
ORDER BY created_at DESC
LIMIT 20;

-- 4️⃣ CORRELAÇÃO: USUÁRIOS vs PLANOS
SELECT '
=== CRUZAMENTO USUÁRIOS vs PLANOS ===' as status;

SELECT 
  p.full_name as usuario,
  ur.role,
  COUNT(pt.id) as total_planos
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
LEFT JOIN public.planos_trabalho pt ON p.id = pt.created_by
GROUP BY p.id, p.full_name, ur.role
ORDER BY p.full_name;

-- 5️⃣ CONFERIR SE TEM INTERMEDIÁRIO COM ROLE CORRETO
SELECT '
=== STATUS DO INTERMEDIÁRIO ===' as status;

SELECT 
  p.email,
  p.full_name,
  ur.role,
  ur.disabled,
  CASE 
    WHEN ur.role = 'intermediate' THEN '✅ CORRETO'
    WHEN ur.role = 'user' THEN '❌ ERRADO - é user, deveria ser intermediate'
    WHEN ur.role IS NULL THEN '❌ ERRADO - role é NULL'
    ELSE '❌ ERRADO - role é: ' || ur.role
  END as status
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE p.full_name ILIKE '%intermediario%' 
   OR p.email ILIKE '%intermediario%'
   OR ur.role = 'intermediate';

-- 6️⃣ SE ENCONTROU INTERMEDIÁRIO COM ROLE ERRADO, CORRIGIR
-- Procure pelo ID do usuário intermediário no resultado acima
-- Depois descomente e execute:

-- UPDATE public.user_roles 
-- SET role = 'intermediate'
-- WHERE user_id = 'PEGAR_ID_DO_RESULTADO_ACIMA';

-- UPDATE public.profiles
-- SET role = 'intermediate'
-- WHERE id = 'PEGAR_ID_DO_RESULTADO_ACIMA';

-- CONFIRMAÇÃO FINAL
SELECT '
╔═══════════════════════════════════════════════════════════╗
║  DIAGNÓSTICO CONCLUÍDO                                    ║
║                                                           ║
║  Verifique:                                              ║
║  1. Intermediário tem role = "intermediate"? ✅ ou ❌     ║
║  2. Intermediário está disabled = false? ✅ ou ❌         ║
║  3. Existem planos no banco? ✅ ou ❌                    ║
║  4. Algum plano foi criado pelo intermediário? ✅ ou ❌   ║
║                                                           ║
║  Se role está errado: Use UPDATE acima (descomente)      ║
║  Se role está certo:                                     ║
║    → Ctrl+F5 no navegador                               ║
║    → Logout e login novamente                           ║
║    → Agora Dashboard deve aparecer                      ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
' as info;

-- ==============================================================================
