-- ============================================================================
-- TESTES RÁPIDOS - Validar que tudo está funcionando
-- ============================================================================
-- Execute cada query abaixo para validar diferentes aspectos
--
-- INSTRUÇÕES:
-- 1. Acesse Supabase SQL Editor
-- 2. Cole cada query uma por uma
-- 3. Execute (Ctrl+Enter)
-- ============================================================================

-- ============================================================================
-- TESTE 1: Verificar se a RPC foi criada corretamente
-- ============================================================================
-- Esperado: 1 função encontrada
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'sincronizar_usuario_orfao';

-- ============================================================================
-- TESTE 2: Contar total de usuários nas 3 tabelas principais
-- ============================================================================
SELECT 
  'auth.users' as tabela,
  COUNT(*) as total_usuarios
FROM auth.users
UNION ALL
SELECT 
  'profiles' as tabela,
  COUNT(*) as total_usuarios
FROM public.profiles
UNION ALL
SELECT 
  'user_roles' as tabela,
  COUNT(*) as total_usuarios
FROM public.user_roles;

-- ============================================================================
-- TESTE 3: Verificar os 6 usuários específicos
-- ============================================================================
-- Esperado: 6 linhas, todos com role = 'intermediate'
SELECT 
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled,
  (a.email_confirmed_at IS NOT NULL) as email_confirmado
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
LEFT JOIN auth.users a ON p.id = a.id
WHERE p.email IN (
  'mvvasconcelos@saude.sp.gov.br',
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br',
  'rcloscher@saude.sp.gov.br'
)
ORDER BY p.email;

-- ============================================================================
-- TESTE 4: Verificar se há usuários órfãos em auth.users
-- ============================================================================
-- Esperado: 0 linhas (se houver, são usuários incompletos)
SELECT 
  u.id,
  u.email,
  'ÓRFÃO - Sem profile' as problema
FROM auth.users u
WHERE u.id NOT IN (SELECT id FROM public.profiles WHERE id IS NOT NULL)
UNION ALL
SELECT 
  u.id,
  u.email,
  'ÓRFÃO - Sem user_roles' as problema
FROM auth.users u
WHERE u.id NOT IN (SELECT user_id FROM public.user_roles);

-- ============================================================================
-- TESTE 5: Contar por ROLE
-- ============================================================================
-- Verificar distribuição de perfis
SELECT 
  ur.role as perfil,
  COUNT(*) as total,
  COUNT(CASE WHEN ur.disabled = false THEN 1 END) as ativos,
  COUNT(CASE WHEN ur.disabled = true THEN 1 END) as inativos
FROM public.user_roles ur
GROUP BY ur.role
ORDER BY total DESC;

-- ============================================================================
-- TESTE 6: Verificar CNES dos 6 usuários
-- ============================================================================
-- Esperado: Todos têm CNES = '0052124'
SELECT 
  p.email,
  p.cnes,
  CASE 
    WHEN p.cnes = '0052124' THEN '✅ CORRETO'
    ELSE '❌ INCORRETO'
  END as cnes_valido
FROM public.profiles p
WHERE p.email IN (
  'mvvasconcelos@saude.sp.gov.br',
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br',
  'rcloscher@saude.sp.gov.br'
)
ORDER BY p.email;

-- ============================================================================
-- TESTE 7: Testar a RPC com um e-mail específico
-- ============================================================================
-- DESCOMENTE E EXECUTE ABAIXO para testar a sincronização automática:
-- (certifique-se de ter um usuário órfão em auth.users primeiro)

-- SELECT public.sincronizar_usuario_orfao(
--   'mvvasconcelos@saude.sp.gov.br',
--   '0052124',
--   'intermediate'
-- );

-- ============================================================================
-- TESTE 8: Verificar RLS está habilitado (segurança)
-- ============================================================================
-- Esperado: profiles = ON, user_roles = ON (ou OFF, dependendo da configuração)
SELECT 
  tablename,
  CASE WHEN rowsecurity THEN 'ON' ELSE 'OFF' END as rls_status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'user_roles', 'audit_logs')
ORDER BY tablename;

-- ============================================================================
-- TESTE 9: Contar disabled vs active
-- ============================================================================
-- Esperado: Todos os 6 devem estar disabled = false
SELECT 
  CASE WHEN ur.disabled = true THEN 'Desativado' ELSE 'Ativo' END as status,
  COUNT(*) as total
FROM public.user_roles ur
WHERE ur.user_id IN (
  SELECT id FROM public.profiles
  WHERE email IN (
    'mvvasconcelos@saude.sp.gov.br',
    'janete.sgueglia@saude.sp.gov.br',
    'lhribeiro@saude.sp.gov.br',
    'gtcosta@saude.sp.gov.br',
    'casouza@saude.sp.gov.br',
    'rcloscher@saude.sp.gov.br'
  )
)
GROUP BY ur.disabled;

-- ============================================================================
-- TESTE 10: Verificação FINAL (Sumário Executivo)
-- ============================================================================

WITH status_usuarios AS (
  SELECT 
    p.id,
    p.email,
    p.full_name,
    p.cnes,
    ur.role,
    ur.disabled,
    (a.email_confirmed_at IS NOT NULL) as email_confirmado,
    CASE 
      WHEN p.id IS NOT NULL 
        AND ur.user_id IS NOT NULL 
        AND a.id IS NOT NULL 
      THEN '✅ COMPLETO'
      ELSE '❌ INCOMPLETO'
    END as status_geral
  FROM public.profiles p
  LEFT JOIN public.user_roles ur ON p.id = ur.user_id
  LEFT JOIN auth.users a ON p.id = a.id
  WHERE p.email IN (
    'mvvasconcelos@saude.sp.gov.br',
    'janete.sgueglia@saude.sp.gov.br',
    'lhribeiro@saude.sp.gov.br',
    'gtcosta@saude.sp.gov.br',
    'casouza@saude.sp.gov.br',
    'rcloscher@saude.sp.gov.br'
  )
)
SELECT 
  '📊 SUMÁRIO EXECUTIVO' as resultado,
  COUNT(*) as total_usuarios_6,
  COUNT(CASE WHEN role = 'intermediate' THEN 1 END) as com_role_intermediario,
  COUNT(CASE WHEN disabled = false THEN 1 END) as usuarios_ativos,
  COUNT(CASE WHEN cnes = '0052124' THEN 1 END) as com_cnes_correto,
  COUNT(CASE WHEN status_geral = '✅ COMPLETO' THEN 1 END) as status_completo
FROM status_usuarios;

-- Se tudo estiver verde (6 em todas as contagens), significa:
-- ✅ Todos os 6 usuários foram criados
-- ✅ Todos têm role = 'intermediate'
-- ✅ Todos estão ativos (disabled = false)
-- ✅ Todos têm CNES correto
-- ✅ Todos têm profiles, roles e auth.users sincronizados

-- ============================================================================
-- EXPLICAÇÃO DOS TESTES
-- ============================================================================
-- TESTE 1: Valida se a função RPC foi criada
-- TESTE 2: Conta de usuários em cada tabela (deve ser proporcional)
-- TESTE 3: Mostra os dados dos 6 usuários específicos
-- TESTE 4: Encontra usuários órfãos (dados incompletos)
-- TESTE 5: Distribuição de perfis (user, intermediate, admin)
-- TESTE 6: Valida CNES = 0052124 para os 6
-- TESTE 7: Testa a RPC manualmente (se necessário)
-- TESTE 8: Verifica se RLS está habilitado (segurança)
-- TESTE 9: Verifica ativos vs desativados
-- TESTE 10: Sumário executivo de tudo (passar = todos com "6" e "✅")
-- ============================================================================
