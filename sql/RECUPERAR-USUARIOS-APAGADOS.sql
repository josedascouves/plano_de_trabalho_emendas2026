-- ==============================================================================
-- SCRIPT: Recuperar Usuários Apagados/Desativados
-- ==============================================================================
--
-- PROBLEMA: Usuário tenta criar novo mas recebe erro "já registrado"
-- Causa: Usuário existe em auth.users mas está desativado ou órfão
--
-- SOLUÇÃO: Ver e reativar usuários inativos
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Clique em "New Query"
-- 4. Cole TODO este arquivo
-- 5. Execute para identificar o problema
--
-- ==============================================================================

-- ============================================================
-- DIAGNÓSTICO: ENCONTRAR USUÁRIOS PROBLEMÁTICOS
-- ============================================================

SELECT '1️⃣ USUÁRIOS DESATIVADOS (disabled=true)' as diagnostico;
SELECT 
  p.id,
  p.email,
  p.full_name,
  ur.role,
  ur.disabled,
  p.created_at
FROM public.user_roles ur
LEFT JOIN public.profiles p ON ur.user_id = p.id
WHERE ur.disabled = true
ORDER BY p.email;

-- ============================================================

SELECT '2️⃣ USUÁRIOS ÓRFÃOS EM auth.users (sem entry em user_roles)' as diagnostico;
SELECT 
  u.id,
  u.email,
  'NÃO TEM entrada em user_roles' as status,
  u.created_at
FROM auth.users u
WHERE u.id NOT IN (SELECT user_id FROM public.user_roles)
ORDER BY u.email;

-- ============================================================

SELECT '3️⃣ USUÁRIOS ÓRFÃOS EM auth.users (sem profile)' as diagnostico;
SELECT 
  u.id,
  u.email,
  'NÃO TEM profile' as status,
  u.created_at
FROM auth.users u
WHERE u.id NOT IN (SELECT id FROM public.profiles)
ORDER BY u.email;

-- ============================================================
-- SOLUÇÃO 1: REATIVAR USUÁRIO DESATIVADO
-- ============================================================
-- Descomente e execute se encontrou usuário desativado:

-- UPDATE public.user_roles 
-- SET disabled = false, updated_at = timezone('utc'::text, now())
-- WHERE user_id = 'UUID_AQUI_DO_USUARIO';

-- SELECT '✅ Usuário reativado!' as resultado;

-- ============================================================
-- SOLUÇÃO 2: CRIAR ENTRY PARA USUÁRIO ÓRFÃO (em auth.users mas sem user_roles)
-- ============================================================
-- Descomente e execute se encontrou usuário órfão:

-- INSERT INTO public.user_roles (user_id, role, disabled)
-- VALUES ('UUID_AQUI_DO_USUARIO', 'user', false)
-- ON CONFLICT (user_id) DO UPDATE SET disabled = false;

-- SELECT '✅ Entry criada para usuário órfão!' as resultado;

-- ============================================================
-- SOLUÇÃO 3: CRIAR PROFILE COMPLETO PARA USUÁRIO ÓRFÃO
-- ============================================================
-- Descomente e execute se faltam dados de profile:

-- INSERT INTO public.profiles (id, email, full_name, role, disabled, created_at)
-- SELECT 
--   u.id,
--   u.email,
--   u.email,
--   'user',
--   false,
--   u.created_at
-- FROM auth.users u
-- WHERE u.id NOT IN (SELECT id FROM public.profiles)
-- ON CONFLICT (id) DO NOTHING;

-- SELECT '✅ Profiles criados!' as resultado;

-- ============================================================
-- SOLUÇÃO 4 (RECOMENDADA): LIMPAR E RECRIAR TUDO
-- ============================================================
-- Esta solução sincroniza TODOS os usuários corretamente

-- 1. Garantir que todos em auth.users têm entry em user_roles
INSERT INTO public.user_roles (user_id, role, disabled)
SELECT 
  u.id,
  'user' as role,
  false as disabled
FROM auth.users u
WHERE u.id NOT IN (SELECT user_id FROM public.user_roles)
ON CONFLICT (user_id) DO UPDATE SET disabled = false;

SELECT '✅ Passo 1: user_roles sincronizado' as resultado;

-- 2. Garantir que todos têm profiles
INSERT INTO public.profiles (id, email, full_name, role, created_at)
SELECT 
  u.id,
  u.email,
  u.email,
  'user',
  u.created_at
FROM auth.users u
WHERE u.id NOT IN (SELECT id FROM public.profiles)
ON CONFLICT (id) DO NOTHING;

SELECT '✅ Passo 2: profiles sincronizado' as resultado;

-- 3. Sincronizar profiles com user_roles
UPDATE public.profiles p
SET 
  role = ur.role,
  disabled = ur.disabled,
  updated_at = timezone('utc'::text, now())
FROM public.user_roles ur
WHERE p.id = ur.user_id;

SELECT '✅ Passo 3: dados sincronizados' as resultado;

-- ============================================================
-- VERIFICAÇÃO FINAL
-- ============================================================

SELECT '
╔═══════════════════════════════════════════════════════════╗
║      ✅ DIAGNÓSTICO E LIMPEZA CONCLUÍDOS!                ║
║                                                           ║
║ Verifique acima se encontrou usuários problemáticos      ║
║                                                           ║
║ Se encontrou desativados:                                ║
║   → Procure por "USUÁRIOS DESATIVADOS"                  ║
║   → Descomentar SOLUÇÃO 1 acima                         ║
║   → Substituir UUID_AQUI_DO_USUARIO                     ║
║   → Executar                                             ║
║                                                           ║
║ Se não encontrou nada:                                   ║
║   → Todos estão sincronizados!                          ║
║   → Tente criar usuário novamente                       ║
╚═══════════════════════════════════════════════════════════╝
' as mensagem;

-- Ver status atual
SELECT 
  '📊 STATUS FINAL:' as info,
  COUNT(*) as total_usuarios,
  COUNT(CASE WHEN ur.disabled = true THEN 1 END) as desativados,
  COUNT(CASE WHEN ur.disabled = false THEN 1 END) as ativos
FROM auth.users u
LEFT JOIN public.user_roles ur ON u.id = ur.user_id;

-- ==============================================================================
-- FIM DO SCRIPT
-- ==============================================================================
