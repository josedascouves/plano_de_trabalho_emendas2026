-- ========================================
-- CORRIGIR POLÍTICAS RLS DO STORAGE
-- ========================================

-- Remover políticas antigas do bucket planos-trabalho-pdfs
DELETE FROM storage.objects 
WHERE bucket_id = (SELECT id FROM storage.buckets WHERE name = 'planos-trabalho-pdfs')
AND auth.role() != 'authenticated';

-- Remover políticas antigas existentes
DROP POLICY IF EXISTS "Upload PDFs para usuários autenticados" ON storage.objects;
DROP POLICY IF EXISTS "Leitura PDFs pública" ON storage.objects;
DROP POLICY IF EXISTS "DELETE PDFs do dono" ON storage.objects;

-- ========================================
-- CRIAR NOVAS POLÍTICAS DE STORAGE
-- ========================================

-- Permitir UPLOAD (INSERT) para usuários autenticados no bucket planos-trabalho-pdfs
CREATE POLICY "Upload PDFs para autenticados"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = (SELECT id FROM storage.buckets WHERE name = 'planos-trabalho-pdfs') AND
  auth.role() = 'authenticated'
);

-- Permitir LEITURA (SELECT) pública do bucket planos-trabalho-pdfs
CREATE POLICY "Leitura PDFs pública"
ON storage.objects
FOR SELECT
USING (
  bucket_id = (SELECT id FROM storage.buckets WHERE name = 'planos-trabalho-pdfs')
);

-- Permitir DELEÇÃO (DELETE) apenas do dono
CREATE POLICY "DELETE PDFs do dono"
ON storage.objects
FOR DELETE
USING (
  bucket_id = (SELECT id FROM storage.buckets WHERE name = 'planos-trabalho-pdfs') AND
  owner = auth.uid()
);

-- ========================================
-- PRONTO!
-- ========================================
-- Agora usuários autenticados podem fazer upload no bucket
