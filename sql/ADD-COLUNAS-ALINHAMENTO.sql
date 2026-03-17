-- ============================================================
-- ADICIONAR COLUNAS FALTANTES EM PLANOS_TRABALHO
-- Script para completar a tabela com campos de Alinhamento Estratégico
-- e metadados de edição
-- ============================================================

-- ============================================================
-- 1. ADICIONAR COLUNAS DE ALINHAMENTO ESTRATÉGICO
-- ============================================================

-- Adicionar coluna para Diretriz
ALTER TABLE public.planos_trabalho
ADD COLUMN IF NOT EXISTS diretriz_id TEXT;

-- Adicionar coluna para Objetivo
ALTER TABLE public.planos_trabalho
ADD COLUMN IF NOT EXISTS objetivo_id TEXT;

-- Adicionar coluna para Metas (array de IDs)
ALTER TABLE public.planos_trabalho
ADD COLUMN IF NOT EXISTS metas_ids TEXT[] DEFAULT ARRAY[]::TEXT[];

-- ============================================================
-- 2. ADICIONAR COLUNAS DE RASTREAMENTO DE EDIÇÃO
-- ============================================================

-- Adicionar coluna para contar edições
ALTER TABLE public.planos_trabalho
ADD COLUMN IF NOT EXISTS edit_count INTEGER DEFAULT 0;

-- Adicionar coluna para última data de edição
ALTER TABLE public.planos_trabalho
ADD COLUMN IF NOT EXISTS last_edited_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- ============================================================
-- 3. ADICIONAR ÍNDICES PARA PERFORMANCE
-- ============================================================

-- Índice em diretriz_id para queries rápidas
CREATE INDEX IF NOT EXISTS idx_planos_diretriz_id ON public.planos_trabalho(diretriz_id);

-- Índice em objetivo_id para queries rápidas
CREATE INDEX IF NOT EXISTS idx_planos_objetivo_id ON public.planos_trabalho(objetivo_id);

-- Índice em created_by para listar planos por usuário (já deve existir)
CREATE INDEX IF NOT EXISTS idx_planos_created_by ON public.planos_trabalho(created_by);

-- ============================================================
-- 4. VERIFICAR RESULTADO
-- ============================================================

-- Ver as colunas que foram adicionadas
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'planos_trabalho'
ORDER BY ordinal_position;

-- ============================================================
-- 5. VERIFICAR DADOS EXISTENTES
-- ============================================================

-- Ver planos cadastrados e verificar se têm dados nessas colunas
SELECT 
  id,
  numero_emenda,
  beneficiario_nome,
  diretriz_id,
  objetivo_id,
  metas_ids,
  edit_count,
  last_edited_at,
  created_at,
  updated_at
FROM public.planos_trabalho
ORDER BY created_at DESC
LIMIT 10;

-- ============================================================
-- Se todos os planos têm diretriz_id vazio, precisa recarregar com dados!
-- ============================================================
