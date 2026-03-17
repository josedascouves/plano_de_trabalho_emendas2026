-- Adicionar campo responsavel_assinatura à tabela planos_trabalho
ALTER TABLE planos_trabalho 
ADD COLUMN responsavel_assinatura TEXT DEFAULT NULL;

-- Comentar a coluna para documentação
COMMENT ON COLUMN planos_trabalho.responsavel_assinatura IS 'Nome completo da pessoa responsável pela assinatura do plano';
