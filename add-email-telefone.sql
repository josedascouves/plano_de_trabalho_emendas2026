-- ============================================================================
-- Adicionar colunas email e telefone à tabela planos_trabalho
-- ============================================================================

ALTER TABLE public.planos_trabalho 
ADD COLUMN IF NOT EXISTS beneficiario_email VARCHAR(255) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS beneficiario_telefone VARCHAR(20) DEFAULT NULL;

-- Verificar se foram adicionadas
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'planos_trabalho' 
ORDER BY ordinal_position;
