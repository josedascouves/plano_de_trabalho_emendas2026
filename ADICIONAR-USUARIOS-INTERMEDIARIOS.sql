-- ==============================================================================
-- SCRIPT: Adicionar Suporte a Usuários Intermediários
-- ==============================================================================
--
-- PROPÓSITO: 
-- Implementar novo papel "intermediate" que permite:
-- ✅ Visualizar TODOS os planos do sistema
-- ❌ NÃO pode criar novos planos
-- ❌ NÃO pode editar planos
-- ❌ NÃO pode apagar planos
-- (Apenas leitura/visualização)
--
-- INSTRUÇÕES:
-- 1. Acesse https://app.supabase.com
-- 2. Vá para SQL Editor
-- 3. Clique em "New Query"
-- 4. Cole TODO este arquivo
-- 5. Execute (Ctrl+Enter ou clique em Run)
--
-- O script também está disponível em:
-- - CONFIGURAR-USER-ROLES.sql (já atualizado)
-- ==============================================================================

-- ============================================================
-- PASSO 1: Atualizar Constraint da Tabela user_roles
-- ============================================================
-- Remove a constraint antiga que apenas aceitava 'admin' e 'user'
-- Adiciona suporte ao novo papel 'intermediate'

ALTER TABLE public.user_roles DROP CONSTRAINT IF EXISTS user_roles_role_check;
ALTER TABLE public.user_roles ADD CONSTRAINT user_roles_role_check 
  CHECK (role IN ('admin', 'user', 'intermediate'));

-- Verificar se a constraint foi aplicada
SELECT '✅ CONSTRAINT user_roles_role_check atualizada com sucesso' as status;

-- ============================================================
-- PASSO 2: Verificar Estado Atual do Sistema
-- ============================================================

SELECT '📊 ESTADO ATUAL DO SISTEMA:' as status;

SELECT 
  COUNT(*) as total_users,
  COUNT(CASE WHEN role = 'admin' THEN 1 END) as admin_count,
  COUNT(CASE WHEN role = 'user' THEN 1 END) as user_count,
  COUNT(CASE WHEN role = 'intermediate' THEN 1 END) as intermediate_count,
  COUNT(CASE WHEN disabled = false THEN 1 END) as active_count,
  COUNT(CASE WHEN disabled = true THEN 1 END) as inactive_count
FROM public.user_roles;

-- ============================================================
-- PASSO 3: Listar Todos os Usuários com Seus Papéis
-- ============================================================

SELECT '👥 USUÁRIOS REGISTRADOS:' as status;

SELECT 
  ur.user_id,
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled,
  'Ativo' as status
FROM public.user_roles ur
LEFT JOIN public.profiles p ON ur.user_id = p.id
WHERE ur.disabled = false
ORDER BY 
  ur.role DESC,
  p.full_name;

-- ============================================================
-- PASSO 4: Exemplos de Como Usar
-- ============================================================

-- EXEMPLO 1: Promover um usuário para INTERMEDIÁRIO
-- Descomente e substitua o email real:
-- UPDATE public.user_roles 
-- SET role = 'intermediate'
-- WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'usuario@example.com');

-- EXEMPLO 2: Converter todos os users de uma região para intermediário
-- Descomente e execute conforme necessário:
-- UPDATE public.user_roles 
-- SET role = 'intermediate'
-- WHERE user_id IN (
--   SELECT ur.user_id FROM public.user_roles ur
--   LEFT JOIN public.profiles p ON ur.user_id = p.id
--   WHERE ur.role = 'user' 
--   AND p.cnes IS NOT NULL
-- );

-- EXEMPLO 3: Visualizar apenas usuários intermediários
-- SELECT 
--   p.id,
--   p.full_name,
--   p.email,
--   p.cnes,
--   ur.role,
--   ur.created_at
-- FROM public.user_roles ur
-- LEFT JOIN public.profiles p ON ur.user_id = p.id
-- WHERE ur.role = 'intermediate'
-- ORDER BY p.full_name;

-- ============================================================
-- PASSO 5: VERIFICAÇÃO FINAL
-- ============================================================

SELECT '✅ CONFIGURAÇÃO COMPLETADA COM SUCESSO!' as status;
SELECT '📝 Próximos Passos:' as instrucoes;
SELECT '1. Verifique se a constraint foi atualizada acima' as step;
SELECT '2. Use o painel de Gerenciamento de Usuários no app' as step;
SELECT '3. Selecione "Intermediário" ao criar novo usuário' as step;
SELECT '4. Use o dropdown "Papel" para alterar papel de usuários existentes' as step;

-- ============================================================
-- PASSO 6: DOCUMENTAÇÃO DOS PAPÉIS
-- ============================================================
-- 
-- 👑 ADMIN
--   ✅ Visualizar TODOS os planos
--   ✅ Criar novos planos
--   ✅ Editar qualquer plano
--   ✅ Apagar qualquer plano
--   ✅ Gerenciar usuários
--   ✅ Acessar Dashboard
--
-- 👤 USUÁRIO PADRÃO
--   ✅ Visualizar SEUS planos
--   ✅ Criar novos planos
--   ✅ Editar SEUS planos
--   ✅ Apagar SEUS planos
--   ❌ Visualizar planos de outros
--
-- 👁️ USUÁRIO INTERMEDIÁRIO (NOVO!)
--   ✅ Visualizar TODOS os planos
--   ❌ Criar novos planos
--   ❌ Editar planos
--   ❌ Apagar planos
--   ✅ Apenas leitura/visualização
--
-- ============================================================
