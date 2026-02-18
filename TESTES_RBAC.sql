-- ============================================================
-- TESTES PARA SISTEMA RBAC
-- Execute os testes abaixo para validar o sistema
-- ============================================================

-- PREPARAÇÃO: Variáveis de teste
-- Substitua os UUIDs por reais do seu banco

-- ============================================================
-- TESTE 1: Verificar Tabelas Criadas
-- ============================================================

-- Listar tabelas criadas
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Verificar estrutura da tabela profiles
\d profiles

-- Verificar estrutura da tabela audit_logs
\d audit_logs

-- ============================================================
-- TESTE 2: Verificar Políticas RLS
-- ============================================================

-- Listar todas as políticas RLS
SELECT schemaname, tablename, policyname, permissive, qual FROM pg_policies
ORDER BY tablename, policyname;

-- Verificar se RLS está habilitado
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE tablename IN ('profiles', 'audit_logs');

-- Esperado: rowsecurity = true para ambas

-- ============================================================
-- TESTE 3: Verificar Funções Criadas
-- ============================================================

-- Listar funções customizadas
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name LIKE '%admin%' OR routine_name LIKE '%password%'
ORDER BY routine_name;

-- Esperado: 7+ funções
-- - promote_user_to_admin
-- - demote_admin_to_user
-- - reset_user_password
-- - change_user_password_admin
-- - change_own_password
-- - toggle_user_status
-- - delete_user_admin

-- ============================================================
-- TESTE 4: Verificar Dados de Teste
-- ============================================================

-- Contar usuários
SELECT COUNT(*) as total_usuarios FROM profiles;

-- Listar admins
SELECT id, role, full_name, email, disabled FROM profiles
WHERE role = 'admin';

-- Listar usuários padrão
SELECT id, role, full_name, email, disabled FROM profiles
WHERE role = 'user';

-- Contar logs de auditoria
SELECT COUNT(*) as total_logs FROM audit_logs;

-- ============================================================
-- TESTE 5: Testar Função - Promover para Admin
-- ============================================================

-- SETUP: Criar usuário de teste (se não existir)
-- SKIP se já tiver usuários de teste

-- Obter UUID de um usuário padrão
SELECT id FROM profiles WHERE role = 'user' LIMIT 1;

-- Copie o UUID e execute:
-- SELECT promote_user_to_admin('cole-aqui-o-uuid');

-- Verificar resultado
-- SELECT action, affected_user_id, created_at FROM audit_logs
-- WHERE action = 'PROMOTE_TO_ADMIN'
-- ORDER BY created_at DESC LIMIT 1;

-- Esperado:
-- - Ação: PROMOTE_TO_ADMIN
-- - Log criado
-- - Usuário agora tem role = 'admin'

-- ============================================================
-- TESTE 6: Testar Função - Rebaixar Admin
-- ============================================================

-- Obter UUID de um admin que não seja o único
SELECT id, full_name FROM profiles
WHERE role = 'admin'
AND id != (SELECT id FROM profiles WHERE role = 'admin' LIMIT 1)
LIMIT 1;

-- Copie o UUID e execute:
-- SELECT demote_admin_to_user('cole-aqui-o-uuid');

-- Verificar resultado
-- SELECT action, affected_user_id, created_at FROM audit_logs
-- WHERE action = 'DEMOTE_TO_USER'
-- ORDER BY created_at DESC LIMIT 1;

-- Esperado:
-- - Ação: DEMOTE_TO_USER
-- - Log criado
-- - Usuário agora tem role = 'user'

-- ============================================================
-- TESTE 7: Testar Proteção - Não Pode Rebaixar Único Admin
-- ============================================================

-- Obter UUID do único admin (se houver)
SELECT id, full_name FROM profiles
WHERE role = 'admin'
AND disabled = false
AND (SELECT COUNT(*) FROM profiles WHERE role = 'admin' AND disabled = false) = 1;

-- Tentar rebaixar (deve gerar erro)
-- SELECT demote_admin_to_user('cole-aqui-o-uuid');

-- Esperado: ERRO
-- "Cannot demote the last admin"
-- OU
-- "Cannot disable the last admin"

-- ============================================================
-- TESTE 8: Testar Função - Reset de Senha
-- ============================================================

-- Obter UUID de um usuário
SELECT id, full_name, email FROM profiles
WHERE id != auth.uid() LIMIT 1;

-- Copie o UUID e execute:
-- SELECT reset_user_password('cole-aqui-o-uuid');

-- Resultado deve ser:
-- {"success": true, "temp_password": "abc123def456", ...}

-- Verificar log
-- SELECT action, details FROM audit_logs
-- WHERE action = 'RESET_PASSWORD'
-- ORDER BY created_at DESC LIMIT 1;

-- Esperado:
-- - Ação: RESET_PASSWORD
-- - Senha temporária gerada
-- - Log criado

-- ============================================================
-- TESTE 9: Testar Função - Ativar/Desativar Usuário
-- ============================================================

-- Obter UUID de um usuário ativo
SELECT id, full_name, disabled FROM profiles
WHERE disabled = false AND id != auth.uid() LIMIT 1;

-- Desativar (execute como admin):
-- SELECT toggle_user_status('cole-aqui-o-uuid', true);

-- Verificar se foi desativado
-- SELECT id, disabled FROM profiles WHERE id = 'cole-aqui-o-uuid';

-- Esperado: disabled = true

-- Verificar log
-- SELECT action FROM audit_logs WHERE action = 'DISABLE_USER'
-- ORDER BY created_at DESC LIMIT 1;

-- Reativar (execute):
-- SELECT toggle_user_status('cole-aqui-o-uuid', false);

-- Verificar se foi reativado
-- SELECT id, disabled FROM profiles WHERE id = 'cole-aqui-o-uuid';

-- Esperado: disabled = false

-- ============================================================
-- TESTE 10: Testar RLS - Usuário Common Não Consegue Ver Outros
-- ============================================================

-- COMO USUARIO COMMON, execute:
-- SELECT * FROM profiles;

-- Esperado: Somente seu próprio perfil

-- COMO ADMIN, execute:
-- SELECT * FROM profiles;

-- Esperado: Todos os perfis

-- ============================================================
-- TESTE 11: Testar RLS - Audit Logs Filtrado
-- ============================================================

-- COMO ADMIN:
-- SELECT COUNT(*) FROM audit_logs;

-- Esperado: Todos os logs (ou mais)

-- COMO USER:
-- SELECT COUNT(*) FROM audit_logs;

-- Esperado: Somente logs onde performed_by_id = seu UUID

-- ============================================================
-- TESTE 12: Testar Proteção - Cannot Delete Unique Admin
-- ============================================================

-- Contar admins ativos
SELECT COUNT(*) FROM profiles
WHERE role = 'admin' AND disabled = false;

-- Se count = 1, tentar deletar esse admin (como admin):
-- SELECT delete_user_admin('seu-uuid');

-- Esperado: ERRO
-- "Cannot delete the last admin"

-- ============================================================
-- TESTE 13: Verificar Audit Trail Completo
-- ============================================================

-- Listar todas as ações
SELECT 
  action,
  COUNT(*) as quantidade,
  MAX(created_at) as ultima_acao
FROM audit_logs
GROUP BY action
ORDER BY quantidade DESC;

-- Esperado: Todas as ações que foram testadas aparecerão

-- ============================================================
-- TESTE 14: Verificar Estatísticas
-- ============================================================

-- Ver estatísticas
SELECT * FROM user_statistics;

-- Esperado resultado similar a:
-- active_admins | active_users | total_active_users | total_users | disabled_users
-- 1             | 2            | 3                  | 4           | 1

-- ============================================================
-- TESTE 15: Testar Performance - Índices
-- ============================================================

-- Verificar índices criados
SELECT indexname, tablename
FROM pg_indexes
WHERE tablename IN ('profiles', 'audit_logs')
ORDER BY tablename, indexname;

-- Esperado: Vários índices em audit_logs

-- ============================================================
-- TESTE 16: Executar Query de Relatório
-- ============================================================

-- Relatório de alterações de perfil
SELECT 
  affected_user_id,
  action,
  details,
  created_at
FROM audit_logs
WHERE action IN ('PROMOTE_TO_ADMIN', 'DEMOTE_TO_USER')
ORDER BY created_at DESC;

-- Relatório de alterações de senha
SELECT
  affected_user_id,
  action,
  performed_by_id,
  created_at
FROM audit_logs
WHERE action LIKE '%PASSWORD%'
ORDER BY created_at DESC;

-- Relatório de usuários
SELECT
  id,
  full_name,
  email,
  role,
  disabled,
  created_at
FROM profiles
ORDER BY created_at DESC;

-- ============================================================
-- LIMPEZA DE TESTE (OPCIONAL)
-- ============================================================

-- ATENÇÃO: Isso deletará dados de teste!

-- Deletar logs de teste (últimas 24 horas)
-- DELETE FROM audit_logs
-- WHERE created_at > NOW() - INTERVAL '24 hours';

-- Deletar usuários de teste
-- DELETE FROM profiles
-- WHERE email LIKE '%test%' OR email LIKE '%teste%';

-- ============================================================
-- RESUMO DE TESTES
-- ============================================================

-- Execute todos os SELECT acima para ter um resumo:

-- Tabelas criadas
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('profiles', 'audit_logs');

-- RLS habilitado
SELECT tablename, rowsecurity FROM pg_tables
WHERE tablename IN ('profiles', 'audit_logs');

-- Funções criadas
SELECT COUNT(*) FROM information_schema.routines
WHERE routine_schema = 'public'
AND (routine_name LIKE '%admin%' OR routine_name LIKE '%password%' OR routine_name LIKE '%toggle%');

-- Dados
SELECT 
  (SELECT COUNT(*) FROM profiles) as usuarios,
  (SELECT COUNT(*) FROM profiles WHERE role = 'admin') as admins,
  (SELECT COUNT(*) FROM audit_logs) as logs,
  (SELECT COUNT(*) FROM profiles WHERE disabled = true) as desativados;

-- ============================================================
-- FIM DOS TESTES
-- ============================================================
-- Se todos os testes passarem, o sistema RBAC está 100% funcional!
-- ============================================================

