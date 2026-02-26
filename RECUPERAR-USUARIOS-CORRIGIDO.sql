-- ==============================================================================
-- SCRIPT: Recuperar Usuários Apagados/Desativados (VERSÃO CORRIGIDA)
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
-- SOLUÇÃO 4 (RECOMENDADA): SINCRONIZAR AUTOMATICAMENTE
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
-- REATIVAR TODOS OS USUÁRIOS DESATIVADOS
-- ============================================================

UPDATE public.user_roles
SET disabled = false, updated_at = timezone('utc'::text, now())
WHERE disabled = true;

SELECT '✅ Passo 4: todos os usuários reativados' as resultado;

-- ============================================================
-- VERIFICAÇÃO FINAL
-- ============================================================

SELECT '
╔═══════════════════════════════════════════════════════════╗
║      ✅ SINCRONIZAÇÃO E LIMPEZA CONCLUÍDAS!              ║
║                                                           ║
║ Próximos passos:                                         ║
║ 1. Feche este editor                                     ║
║ 2. Volte para seu app                                    ║
║ 3. Pressione: Ctrl+F5 (recarregamento completo)         ║
║ 4. Logout e Login novamente                             ║
║ 5. Tente criar novo usuário                             ║
║                                                           ║
║ Todos os usuários estão sincronizados e ativos!         ║
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

-- Listar todos os usuários (ativos)
SELECT 
  '👥 USUÁRIOS ATIVOS:' as info;

SELECT 
  p.email,
  p.full_name,
  ur.role,
  ur.disabled
FROM public.user_roles ur
LEFT JOIN public.profiles p ON ur.user_id = p.id
WHERE ur.disabled = false
ORDER BY p.email;

-- ==============================================================================
-- FIM DO SCRIPT
-- ==============================================================================
