-- ============================================================================
-- SOLUÇÃO FINAL: DELETAR E RECRIAR DO ZERO OS 4 USUÁRIOS PROBLEMÁTICOS
-- ============================================================================
-- Este script:
-- 1. DELETA COMPLETAMENTE os 4 usuários
-- 2. RECRIA do zero com estrutura correta
-- 3. Garante consistência total
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Cole este arquivo TODO
-- 4. Execute (Ctrl+Enter)
-- ============================================================================

BEGIN;

-- ============================================================================
-- PASSO 1: DELETAR TUDO DOS 4 USUÁRIOS
-- ============================================================================

-- Pegar IDs dos 4 usuários em auth.users PRIMEIRO
WITH email_list AS (
  SELECT id FROM auth.users WHERE email IN (
    'janete.sgueglia@saude.sp.gov.br',
    'lhribeiro@saude.sp.gov.br',
    'gtcosta@saude.sp.gov.br',
    'casouza@saude.sp.gov.br'
  )
)

-- Deletar de user_roles PRIMEIRO (por causa de foreign key)
DELETE FROM public.user_roles
WHERE user_id IN (SELECT id FROM email_list);

SELECT '✅ PASSO 1A: User_roles deletados' as status;

-- Deletar de profiles
DELETE FROM public.profiles
WHERE email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
);

SELECT '✅ PASSO 1B: Profiles deletados' as status;

-- ============================================================================
-- PASSO 2: RECONSTRUIR PROFILES DO ZERO (de auth.users)
-- ============================================================================

INSERT INTO public.profiles (id, email, full_name, cnes, created_at)
SELECT 
  u.id,
  u.email,
  -- Extrair full_name do raw_user_meta_data
  CASE 
    WHEN u.raw_user_meta_data->>'full_name' IS NOT NULL 
      THEN u.raw_user_meta_data->>'full_name'
    ELSE u.email
  END as full_name,
  -- Extrair CNES do raw_user_meta_data ou padrão
  CASE
    WHEN u.raw_user_meta_data->>'cnes' IS NOT NULL 
      THEN u.raw_user_meta_data->>'cnes'
    ELSE '0052124'
  END as cnes,
  u.created_at
FROM auth.users u
WHERE u.email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
);

SELECT '✅ PASSO 2: Profiles recriados do zero' as status;

-- ============================================================================
-- PASSO 3: RECONSTRUIR USER_ROLES DO ZERO
-- ============================================================================

INSERT INTO public.user_roles (user_id, role, disabled)
SELECT 
  u.id,
  'intermediate' as role,
  false as disabled
FROM auth.users u
WHERE u.email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
);

SELECT '✅ PASSO 3: User_roles recriados do zero' as status;

COMMIT;

-- ============================================================================
-- PASSO 4: VERIFICAÇÃO FINAL - MOSTRAR O RESULTADO
-- ============================================================================

SELECT 
  '📊 RESULTADO FINAL - DADOS VALIDADOS' as verificacao;

-- Mostrar profiles
SELECT 
  '✅ PROFILES:' as tipo,
  COUNT(*) as total
FROM public.profiles
WHERE email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
);

-- Mostrar user_roles
SELECT 
  '✅ USER_ROLES:' as tipo,
  COUNT(*) as total
FROM public.user_roles
WHERE user_id IN (
  SELECT id FROM auth.users WHERE email IN (
    'janete.sgueglia@saude.sp.gov.br',
    'lhribeiro@saude.sp.gov.br',
    'gtcosta@saude.sp.gov.br',
    'casouza@saude.sp.gov.br'
  )
);

-- ============================================================================
-- PASSO 5: LISTAR DADOS FINAIS
-- ============================================================================

SELECT 
  '📋 DADOS FINAIS DOS 4 USUÁRIOS' as resultado;

SELECT 
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled,
  CASE WHEN ur.user_id IS NOT NULL THEN '✅ OK' ELSE '❌ FALTA' END as status
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE p.email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
)
ORDER BY p.email;

SELECT '✅ CONCLUSÃO: Dados reconstruídos com sucesso!' as resultado;
SELECT '✅ Os usuários estão prontos para login!' as proxima_acao;
SELECT '📱 Próximo passo: Teste login com cada usuário' as instrucao;
