-- ============================================================================
-- RECRIAR 4 USUÁRIOS COM SENHAS CORRETAS (SEM CRYPT)
-- ============================================================================
-- Execute este script NO SUPABASE SQL EDITOR
-- ============================================================================

-- PASSO 1: Deletar os 4 usuários de auth.users (cascata)
DELETE FROM auth.users
WHERE email IN (
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br'
);

-- PASSO 2: Agora vá em Supabase Dashboard > Auth > Users > Invite > Add user manualmente

-- OU execute manualmente os INSERTs se tiver permissão de inserção direta:
-- (Mas Supabase não permite INSERTs diretos em auth.users, é preciso usar a dashboard ou API)

-- Para referência, aqui estão os dados:
-- Email: janete.sgueglia@saude.sp.gov.br - CNES: 0052124
-- Email: lhribeiro@saude.sp.gov.br - CNES: 0052124
-- Email: gtcosta@saude.sp.gov.br - CNES: 0052124
-- Email: casouza@saude.sp.gov.br - CNES: 0052124

-- SENHA TEMPORÁRIA: 0052124 (o número do CNES)
