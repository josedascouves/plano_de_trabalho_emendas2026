-- ============================================================
-- ADICIONAR CNES AOS USUÁRIOS EXISTENTES
-- Execute este script para adicionar CNES aos usuários que não têm
-- ============================================================

-- ============================================================
-- Atualizar usuários com CNES padrão para teste
-- ============================================================

-- Para usuários específicos, atribua CNES diferentes
UPDATE public.profiles 
SET cnes = '12345001'
WHERE email = 'afpereira@saude.sp.gov.br' AND (cnes IS NULL OR cnes = '');

UPDATE public.profiles 
SET cnes = '12345002'
WHERE email = 'sessp.css2@gmail.com' AND (cnes IS NULL OR cnes = '');

UPDATE public.profiles 
SET cnes = '12345003'
WHERE email ILIKE '%@saude.sp.gov.br%' AND email != 'afpereira@saude.sp.gov.br' AND (cnes IS NULL OR cnes = '');

-- Para qualquer outro usuário que não tenha CNES, atribua um genérico
UPDATE public.profiles 
SET cnes = '99999999'
WHERE cnes IS NULL OR cnes = '';

-- ============================================================
-- VERIFICAR RESULTADO
-- ============================================================

SELECT 
  id,
  full_name,
  email,
  cnes,
  created_at
FROM public.profiles
ORDER BY created_at DESC
LIMIT 10;

-- ============================================================
-- Esperado: Todos os usuários devem ter CNES preenchido
-- ============================================================
