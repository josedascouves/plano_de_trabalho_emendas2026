-- =============================================================
-- HISTÓRICO DE ALTERAÇÕES NA JUSTIFICATIVA
-- Execute este script no Supabase SQL Editor
-- Se a tabela já existir, ela será RECRIADA com schema correto
-- =============================================================

-- 1. DROPAR tabela existente (se houver) para garantir schema correto
DROP TABLE IF EXISTS justificativa_historico CASCADE;

-- 2. Criar tabela com schema correto
CREATE TABLE justificativa_historico (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  plano_id UUID NOT NULL REFERENCES planos_trabalho(id) ON DELETE CASCADE,
  justificativa_texto TEXT NOT NULL DEFAULT '',
  resumo_alteracao TEXT,
  caracteres_antes INTEGER DEFAULT 0,
  caracteres_depois INTEGER DEFAULT 0,
  alterado_por UUID REFERENCES auth.users(id),
  alterado_por_nome TEXT,
  alterado_por_email TEXT,
  alterado_em TIMESTAMPTZ DEFAULT NOW(),
  edit_number INTEGER DEFAULT 1
);

-- 3. Índices para performance
CREATE INDEX idx_justificativa_historico_plano_id 
  ON justificativa_historico(plano_id);

CREATE INDEX idx_justificativa_historico_alterado_em 
  ON justificativa_historico(alterado_em DESC);

-- 4. RLS (Row Level Security)
ALTER TABLE justificativa_historico ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins podem ver todo historico justificativa"
  ON justificativa_historico FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.role IN ('admin', 'intermediate')
    )
  );

CREATE POLICY "Usuarios veem historico dos proprios planos"
  ON justificativa_historico FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM planos_trabalho 
      WHERE planos_trabalho.id = justificativa_historico.plano_id 
      AND planos_trabalho.created_by = auth.uid()
    )
  );

CREATE POLICY "Autenticados podem inserir historico justificativa"
  ON justificativa_historico FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- 5. Backfill: registros retroativos para planos já editados
INSERT INTO justificativa_historico (
  plano_id, justificativa_texto, resumo_alteracao, 
  caracteres_antes, caracteres_depois,
  alterado_por, alterado_por_nome, alterado_por_email, 
  alterado_em, edit_number
)
SELECT 
  pt.id,
  pt.justificativa,
  'Registro retroativo (edição anterior ao sistema de histórico)',
  0,
  LENGTH(pt.justificativa),
  pt.created_by,
  pt.created_by_name,
  pt.created_by_email,
  COALESCE(pt.last_edited_at, pt.updated_at, pt.created_at),
  COALESCE(pt.edit_count, 1)
FROM planos_trabalho pt
WHERE pt.justificativa IS NOT NULL 
  AND pt.justificativa != ''
  AND pt.edit_count > 0;

-- 6. Verificação
SELECT 
  'Tabela recriada com sucesso!' AS status,
  (SELECT COUNT(*) FROM justificativa_historico) AS registros_backfill;
