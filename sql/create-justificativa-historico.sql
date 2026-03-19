-- =============================================================
-- HISTÓRICO DE ALTERAÇÕES NA JUSTIFICATIVA
-- Registra cada alteração feita no campo justificativa
-- dos planos de trabalho, com data e autor da mudança.
-- Otimizado: NÃO armazena texto anterior (usa referência
-- ao registro anterior para economizar espaço)
-- =============================================================

-- 1. Criar tabela de histórico
CREATE TABLE IF NOT EXISTS justificativa_historico (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  plano_id UUID NOT NULL REFERENCES planos_trabalho(id) ON DELETE CASCADE,
  justificativa_texto TEXT NOT NULL,
  resumo_alteracao TEXT,
  caracteres_antes INTEGER DEFAULT 0,
  caracteres_depois INTEGER DEFAULT 0,
  alterado_por UUID REFERENCES auth.users(id),
  alterado_por_nome TEXT,
  alterado_por_email TEXT,
  alterado_em TIMESTAMPTZ DEFAULT NOW(),
  edit_number INTEGER DEFAULT 1
);

-- 2. Índices para performance
CREATE INDEX IF NOT EXISTS idx_justificativa_historico_plano_id 
  ON justificativa_historico(plano_id);

CREATE INDEX IF NOT EXISTS idx_justificativa_historico_alterado_em 
  ON justificativa_historico(alterado_em DESC);

-- 3. RLS (Row Level Security)
ALTER TABLE justificativa_historico ENABLE ROW LEVEL SECURITY;

-- Política: Admins e intermediários veem todo o histórico
DROP POLICY IF EXISTS "Admins podem ver todo historico justificativa" ON justificativa_historico;
CREATE POLICY "Admins podem ver todo historico justificativa"
  ON justificativa_historico FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.role IN ('admin', 'intermediate')
    )
  );

-- Política: Usuários comuns veem histórico dos próprios planos
DROP POLICY IF EXISTS "Usuarios veem historico dos proprios planos" ON justificativa_historico;
CREATE POLICY "Usuarios veem historico dos proprios planos"
  ON justificativa_historico FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM planos_trabalho 
      WHERE planos_trabalho.id = justificativa_historico.plano_id 
      AND planos_trabalho.created_by = auth.uid()
    )
  );

-- Política: Qualquer autenticado pode inserir histórico
DROP POLICY IF EXISTS "Autenticados podem inserir historico justificativa" ON justificativa_historico;
CREATE POLICY "Autenticados podem inserir historico justificativa"
  ON justificativa_historico FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- 4. Verificação
SELECT 'Tabela justificativa_historico criada com sucesso!' AS status;
