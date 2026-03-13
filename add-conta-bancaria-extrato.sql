-- Migration: Adicionar campos de conta bancária e extrato ao plano de trabalho
-- Execute no Supabase SQL Editor

-- 1. Adicionar colunas na tabela planos_trabalho
ALTER TABLE public.planos_trabalho 
ADD COLUMN IF NOT EXISTS conta_bancaria TEXT,
ADD COLUMN IF NOT EXISTS extrato_url TEXT,
ADD COLUMN IF NOT EXISTS extrato_filename TEXT;

-- 2. Criar bucket de storage para extratos bancários
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'extratos-bancarios',
  'extratos-bancarios',
  false,
  1048576, -- 1MB limit
  ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- 3. Políticas de Storage - Upload (INSERT)
DROP POLICY IF EXISTS "Authenticated users can upload extratos" ON storage.objects;
CREATE POLICY "Authenticated users can upload extratos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'extratos-bancarios');

-- 4. Políticas de Storage - Leitura (SELECT)
DROP POLICY IF EXISTS "Authenticated users can view extratos" ON storage.objects;
CREATE POLICY "Authenticated users can view extratos"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'extratos-bancarios');

-- 5. Políticas de Storage - Atualização (UPDATE)
DROP POLICY IF EXISTS "Authenticated users can update extratos" ON storage.objects;
CREATE POLICY "Authenticated users can update extratos"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'extratos-bancarios');

-- 6. Políticas de Storage - Deleção (DELETE)
DROP POLICY IF EXISTS "Authenticated users can delete extratos" ON storage.objects;
CREATE POLICY "Authenticated users can delete extratos"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'extratos-bancarios');

-- Forçar reload do schema cache do PostgREST
NOTIFY pgrst, 'reload schema';
