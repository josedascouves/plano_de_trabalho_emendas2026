-- =============================================================
-- EXECUTAR NO SQL EDITOR DO SUPABASE
-- Corrige o schema cache para a coluna justificativa_alterada_em
-- =============================================================

-- 1. Garantir que a coluna existe
ALTER TABLE planos_trabalho 
ADD COLUMN IF NOT EXISTS justificativa_alterada_em TIMESTAMPTZ;

-- 2. Forçar recarga do schema cache do PostgREST
NOTIFY pgrst, 'reload schema';

-- Pronto! Após executar, o campo justificativa_alterada_em 
-- será reconhecido pela API do Supabase imediatamente.
