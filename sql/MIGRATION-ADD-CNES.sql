-- ================================================
-- MIGRAÇÃO: Adicionar coluna CNES aos planos
-- ================================================
-- Execute este script no Supabase SQL Editor se a coluna ainda não existe
-- URL: https://supabase.com/dashboard/project/tlpmspfnswaxwqzmwski/sql/new

-- 1. Adicionar coluna CNES se não existir
ALTER TABLE public.planos_trabalho 
ADD COLUMN IF NOT EXISTS cnes TEXT;

-- 2. Adicionar coluna updated_at se não existir (para rastrear atualizações)
ALTER TABLE public.planos_trabalho 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 3. Verificar se as colunas foram criadas
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'planos_trabalho' 
ORDER BY ordinal_position;

-- Resultado esperado deve incluir:
-- cnes | text
-- updated_at | timestamp with time zone
