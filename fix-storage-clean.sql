-- ========================================
-- REMOVER POLÍTICAS ANTIGAS
-- ========================================

DROP POLICY IF EXISTS "Give users authenticated access to folder 1kr6q65_0" ON storage.objects;
DROP POLICY IF EXISTS "Give users authenticated access to folder 1kr6q65_1" ON storage.objects;
DROP POLICY IF EXISTS "Give users authenticated access to folder 1kr6q65_2" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to upload" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read" ON storage.objects;

-- ========================================
-- CRIAR POLÍTICAS NOVAS E SIMPLES
-- ========================================

-- Policy 1: Permitir INSERT (upload) para usuários autenticados
CREATE POLICY "authenticated users can upload"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = (SELECT id FROM storage.buckets WHERE name = 'planos-trabalho-pdfs')
);

-- Policy 2: Permitir SELECT (leitura/download) para todos
CREATE POLICY "public can read"
ON storage.objects
FOR SELECT
USING (
  bucket_id = (SELECT id FROM storage.buckets WHERE name = 'planos-trabalho-pdfs')
);

-- ========================================
-- PRONTO!
-- ========================================
-- Agora o upload deve funcionar para usuários autenticados
