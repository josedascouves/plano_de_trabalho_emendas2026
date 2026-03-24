-- ========================================================
-- MIGRATION: Adicionar campos de validação admin
-- ========================================================
-- Execute NO SUPABASE SQL EDITOR (não é via código)
-- 
-- COMO EXECUTAR:
-- 1. Abra Supabase Dashboard > SQL Editor
-- 2. Cole este arquivo completo
-- 3. Clique "Run" (ou Cmd+Enter)
-- 4. Pronto! Os campos serão criados automaticamente
--
-- O QUE ISSO FAZ:
-- - Adiciona coluna 'validado' (BOOLEAN) - indica se admin validou o plano
-- - Adiciona coluna 'validado_por' (UUID) - quem validou (referência ao admin)
-- - Adiciona coluna 'validado_em' (TIMESTAMPTZ) - quando foi validado
-- - Cria índice para melhorar performance de filtros
--
-- APÓS EXECUTAR:
-- - Reload a página do navegador
-- - Admin verá botão "Validar" em cada plano
-- - Usuários não conseguirão editar planos validados
-- ========================================================

-- 1. Adicionar colunas de validação na tabela planos_trabalho
ALTER TABLE public.planos_trabalho 
ADD COLUMN IF NOT EXISTS validado BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS validado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS validado_em TIMESTAMPTZ;

-- 2. Criar índice para consultas por status de validação (opcional, melhora performance)
CREATE INDEX IF NOT EXISTS idx_planos_trabalho_validado ON public.planos_trabalho(validado);

-- 3. Atualizar registros existentes para garantir que validado = false por padrão
UPDATE public.planos_trabalho SET validado = FALSE WHERE validado IS NULL;

-- 4. Criar função RPC para toggle de validação (bypassa schema cache do PostgREST)
CREATE OR REPLACE FUNCTION toggle_validacao_plano(
  p_plano_id UUID,
  p_user_id UUID,
  p_validar BOOLEAN
) RETURNS VOID AS $$
BEGIN
  UPDATE public.planos_trabalho 
  SET 
    validado = p_validar,
    validado_por = CASE WHEN p_validar THEN p_user_id ELSE NULL END,
    validado_em = CASE WHEN p_validar THEN NOW() ELSE NULL END
  WHERE id = p_plano_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Recarregar schema cache do PostgREST (ESSENCIAL para .update() funcionar)
NOTIFY pgrst, 'reload schema';
