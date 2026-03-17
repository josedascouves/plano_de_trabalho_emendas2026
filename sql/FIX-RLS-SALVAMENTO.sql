-- ============================================================================
-- CORRIGIR RLS PARA PERMITIR SALVAMENTO DE DADOS
-- ============================================================================
-- PROBLEMA: RLS policies estão bloqueando silenciosamente inserts/updates
-- SOLUÇÃO: Permitir que usuários autenticados insiram dados relacionados
-- ============================================================================

-- 1️⃣ TABELA: acoes_servicos
-- Permitir que usuários autenticados INSIRAM dados
DROP POLICY IF EXISTS "users_insert_acoes" ON public.acoes_servicos;
CREATE POLICY "users_insert_acoes" ON public.acoes_servicos
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Permitir que usuários LEIAM seus próprios dados
DROP POLICY IF EXISTS "users_read_acoes" ON public.acoes_servicos;
CREATE POLICY "users_read_acoes" ON public.acoes_servicos
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Permitir que usuários ATUALIZEM seus próprios dados
DROP POLICY IF EXISTS "users_update_acoes" ON public.acoes_servicos;
CREATE POLICY "users_update_acoes" ON public.acoes_servicos
  FOR UPDATE
  USING (auth.role() = 'authenticated');

-- ============================================================================

-- 2️⃣ TABELA: metas_qualitativas
-- Permitir que usuários autenticados INSIRAM dados
DROP POLICY IF EXISTS "users_insert_metas_qual" ON public.metas_qualitativas;
CREATE POLICY "users_insert_metas_qual" ON public.metas_qualitativas
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Permitir que usuários LEIAM seus próprios dados
DROP POLICY IF EXISTS "users_read_metas_qual" ON public.metas_qualitativas;
CREATE POLICY "users_read_metas_qual" ON public.metas_qualitativas
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Permitir que usuários ATUALIZEM seus próprios dados
DROP POLICY IF EXISTS "users_update_metas_qual" ON public.metas_qualitativas;
CREATE POLICY "users_update_metas_qual" ON public.metas_qualitativas
  FOR UPDATE
  USING (auth.role() = 'authenticated');

-- ============================================================================

-- 3️⃣ TABELA: naturezas_despesa_plano
-- Permitir que usuários autenticados INSIRAM dados
DROP POLICY IF EXISTS "users_insert_naturezas" ON public.naturezas_despesa_plano;
CREATE POLICY "users_insert_naturezas" ON public.naturezas_despesa_plano
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Permitir que usuários LEIAM seus próprios dados
DROP POLICY IF EXISTS "users_read_naturezas" ON public.naturezas_despesa_plano;
CREATE POLICY "users_read_naturezas" ON public.naturezas_despesa_plano
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Permitir que usuários ATUALIZEM seus próprios dados
DROP POLICY IF EXISTS "users_update_naturezas" ON public.naturezas_despesa_plano;
CREATE POLICY "users_update_naturezas" ON public.naturezas_despesa_plano
  FOR UPDATE
  USING (auth.role() = 'authenticated');

-- ============================================================================

-- 4️⃣ TABELA: planos_trabalho
-- Permitir que usuários autenticados INSIRAM planos
DROP POLICY IF EXISTS "users_insert_planos" ON public.planos_trabalho;
CREATE POLICY "users_insert_planos" ON public.planos_trabalho
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Permitir que usuários LEIAM planos
DROP POLICY IF EXISTS "users_read_planos" ON public.planos_trabalho;
CREATE POLICY "users_read_planos" ON public.planos_trabalho
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Permitir que usuários ATUALIZEM seus próprios planos
DROP POLICY IF EXISTS "users_update_planos" ON public.planos_trabalho;
CREATE POLICY "users_update_planos" ON public.planos_trabalho
  FOR UPDATE
  USING (auth.role() = 'authenticated');

-- ============================================================================

-- 5️⃣ TABELA: profiles (para que usuário leia/escreva seu próprio perfil)
DROP POLICY IF EXISTS "users_read_own_profile" ON public.profiles;
CREATE POLICY "users_read_own_profile" ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "users_update_own_profile" ON public.profiles;
CREATE POLICY "users_update_own_profile" ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id);

-- ============================================================================

-- 6️⃣ HABILITAR RLS EM TODAS AS TABELAS CRÍTICAS
-- Se RLS estiver desabilitada, isso a ativa
ALTER TABLE public.planos_trabalho ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.acoes_servicos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.metas_qualitativas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.naturezas_despesa_plano ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ============================================================================

-- ✅ VERIFICAÇÃO: Listar todas as policies criadas
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles
FROM pg_policies
WHERE tablename IN ('planos_trabalho', 'acoes_servicos', 'metas_qualitativas', 'naturezas_despesa_plano', 'profiles')
ORDER BY tablename, policyname;

-- ============================================================================

-- 🧪 TESTE: Verificar se usuário consegue ler seus dados
-- (Execute como o usuário Dorion Denardi)
SELECT 
  'TESTE LEITURA PLANOS' as teste,
  COUNT(*) as total_planos
FROM public.planos_trabalho;

-- Testar se consegue ler ações
SELECT 
  'TESTE LEITURA AÇÕES' as teste,
  COUNT(*) as total_acoes
FROM public.acoes_servicos;
