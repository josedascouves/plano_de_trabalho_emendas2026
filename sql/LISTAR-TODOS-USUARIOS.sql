-- ==============================================================================
-- LISTAR TODOS OS USUÁRIOS - Sem Filtros
-- ==============================================================================

SELECT '=== TODOS OS USUÁRIOS ===' as info;

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

-- ==============================================================================
-- DEPOIS DE VER A LISTA ACIMA, EXECUTE O COMANDO ABAIXO
-- Substitua 'ID_DO_INTERMEDIARIO' pelo ID exato que apareceu na lista
-- ==============================================================================

-- Exemplo:
-- UPDATE public.user_roles 
-- SET role = 'intermediate'
-- WHERE user_id = 'd16f9b12-1234-5678-abcd-ef1234567890';

-- UPDATE public.profiles
-- SET role = 'intermediate'
-- WHERE id = 'd16f9b12-1234-5678-abcd-ef1234567890';

SELECT '
╔═══════════════════════════════════════════════════════════╗
║  INSTRUÇÕES:                                              ║
║                                                           ║
║  1. Encontre na lista acima qual é o intermediário       ║
║  2. Copie o ID dele                                      ║
║  3. Copie o comando UPDATE acima                         ║
║  4. Substitua "ID_DO_INTERMEDIARIO" pelo ID copiado      ║
║  5. Execute                                              ║
║  6. Ctrl+F5 na app + Logout + Login                     ║
║                                                           ║
║  Agora Dashboard deve aparecer!                          ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
' as instrucoes;

-- ==============================================================================
