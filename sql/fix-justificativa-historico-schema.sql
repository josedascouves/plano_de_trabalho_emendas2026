-- =============================================================
-- MIGRAÇÃO: Corrigir tabela justificativa_historico
-- Renomeia colunas antigas e adiciona novas
-- Execute no Supabase SQL Editor
-- =============================================================

-- Verificar se a tabela tem o schema antigo (tem justificativa_nova)
-- e migrar para o novo

-- Passo 1: Adicionar novas colunas (se não existirem)
ALTER TABLE justificativa_historico 
  ADD COLUMN IF NOT EXISTS justificativa_texto TEXT,
  ADD COLUMN IF NOT EXISTS resumo_alteracao TEXT,
  ADD COLUMN IF NOT EXISTS caracteres_antes INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS caracteres_depois INTEGER DEFAULT 0;

-- Passo 2: Copiar dados das colunas antigas para as novas (se existirem dados)
DO $$
BEGIN
  -- Se a coluna antiga justificativa_nova existe, copiar dados
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'justificativa_historico' 
    AND column_name = 'justificativa_nova'
  ) THEN
    UPDATE justificativa_historico 
    SET justificativa_texto = COALESCE(justificativa_texto, justificativa_nova)
    WHERE justificativa_texto IS NULL AND justificativa_nova IS NOT NULL;
  END IF;
END $$;

-- Passo 3: Remover colunas antigas (se existirem)
ALTER TABLE justificativa_historico 
  DROP COLUMN IF EXISTS justificativa_anterior,
  DROP COLUMN IF EXISTS justificativa_nova;

-- Passo 4: Tornar justificativa_texto NOT NULL (com default vazio temporário)
UPDATE justificativa_historico SET justificativa_texto = '' WHERE justificativa_texto IS NULL;

-- Passo 5: Backfill - Criar registro inicial para planos que já foram editados
-- mas não têm histórico registrado
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
  AND NOT EXISTS (
    SELECT 1 FROM justificativa_historico jh 
    WHERE jh.plano_id = pt.id
  );

-- Verificação
SELECT 
  'Migração concluída!' AS status,
  (SELECT COUNT(*) FROM justificativa_historico) AS total_registros;
