-- ============================================================================
-- FIX RLS: Permitir admin ver TODOS os dados relacionados aos planos
-- ============================================================================
-- Problema: Admin não consegue editar planos alheios porque RLS bloqueia
-- Solução: Admin consegue ver dados relacionados de qualquer plano

-- PASSO 1: Verificar usuários com role 'admin'
SELECT id, email, role FROM public.users WHERE role = 'admin' LIMIT 5;

-- PASSO 2: Verificar políticas RLS atuais nas tabelas
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  qual
FROM pg_policies
WHERE tablename IN ('acoes_servicos', 'metas_qualitativas', 'naturezas_despesa_plano')
ORDER BY tablename, policyname;

-- ============================================================================
-- PASSO 3: Remover políticas restritivas (opcional - apenas se necessário)
-- ============================================================================
-- Descomente apenas se quiser recriar as políticas

-- DROP POLICY IF EXISTS "Users can view own records" ON acoes_servicos;
-- DROP POLICY IF EXISTS "Users can view own records" ON metas_qualitativas;
-- DROP POLICY IF EXISTS "Users can view own records" ON naturezas_despesa_plano;

-- ============================================================================
-- PASSO 4: Criar novas políticas que permitem ADMIN ver TUDO
-- ============================================================================

-- Para ACOES_SERVICOS:
CREATE POLICY "Admin and creator can view all" ON acoes_servicos
FOR SELECT
USING (
  auth.uid() IN (SELECT id FROM public.users WHERE role = 'admin') OR
  created_by = auth.uid()
);

-- Para METAS_QUALITATIVAS:
CREATE POLICY "Admin and creator can view all" ON metas_qualitativas
FOR SELECT
USING (
  auth.uid() IN (SELECT id FROM public.users WHERE role = 'admin') OR
  created_by = auth.uid()
);

-- Para NATUREZAS_DESPESA_PLANO:
CREATE POLICY "Admin and creator can view all" ON naturezas_despesa_plano
FOR SELECT
USING (
  auth.uid() IN (SELECT id FROM public.users WHERE role = 'admin') OR
  created_by = auth.uid()
);

-- ============================================================================
-- PASSO 5: Verificar se funcionou
-- ============================================================================
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  qual
FROM pg_policies
WHERE tablename IN ('acoes_servicos', 'metas_qualitativas', 'naturezas_despesa_plano')
ORDER BY tablename, policyname;
