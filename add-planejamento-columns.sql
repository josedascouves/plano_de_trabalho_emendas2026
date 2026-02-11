-- Script SQL para adicionar suporte a planejamento estratégico no banco de dados
-- Execute este script no console Supabase

-- Adicionar colunas de planejamento estratégico à tabela planos_trabalho
ALTER TABLE planos_trabalho 
ADD COLUMN IF NOT EXISTS diretriz_id TEXT,
ADD COLUMN IF NOT EXISTS objetivo_id TEXT,
ADD COLUMN IF NOT EXISTS metas_ids TEXT[] DEFAULT '{}';

-- Comentários esquemáticos
COMMENT ON COLUMN planos_trabalho.diretriz_id IS 'ID da diretriz estratégica selecionada (ex: d1, d2, d3)';
COMMENT ON COLUMN planos_trabalho.objetivo_id IS 'ID do objetivo específico selecionado dentro da diretriz';
COMMENT ON COLUMN planos_trabalho.metas_ids IS 'Array de IDs das metas selecionadas (ex: [m1-1-1, m1-1-2])';
