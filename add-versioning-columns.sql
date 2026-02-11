-- Script SQL para adicionar suporte a versionamento de edições
-- Execute este script no console Supabase para rastrear edições de planos

-- Adicionar coluna de contagem de edições
ALTER TABLE planos_trabalho 
ADD COLUMN IF NOT EXISTS edit_count INTEGER DEFAULT 0;

-- Adicionar coluna de data última edição
ALTER TABLE planos_trabalho 
ADD COLUMN IF NOT EXISTS last_edited_at TIMESTAMP WITH TIME ZONE;

-- Adicionar coluna de usuário última edição
ALTER TABLE planos_trabalho 
ADD COLUMN IF NOT EXISTS last_edited_by UUID;

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_planos_work_edit_count ON planos_trabalho(edit_count DESC);
CREATE INDEX IF NOT EXISTS idx_planos_work_last_edited_at ON planos_trabalho(last_edited_at DESC);

-- Comentários esquemáticos
COMMENT ON COLUMN planos_trabalho.edit_count IS 'Número total de vezes que o plano foi editado após criação';
COMMENT ON COLUMN planos_trabalho.last_edited_at IS 'Data e hora da última edição do plano';
COMMENT ON COLUMN planos_trabalho.last_edited_by IS 'ID do usuário que fez a última edição';
