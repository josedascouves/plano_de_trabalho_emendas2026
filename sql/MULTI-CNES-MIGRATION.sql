-- ============================================
-- MIGRAÇÃO: Suporte a Múltiplos CNES por Usuário
-- ============================================
-- Altera a coluna profiles.cnes de VARCHAR(8) para TEXT
-- para permitir múltiplos CNES separados por vírgula
-- Exemplo: "2078813,2089335,2089327"
-- ============================================

-- 1. Alterar tipo da coluna CNES para TEXT
ALTER TABLE public.profiles 
ALTER COLUMN cnes TYPE TEXT;

-- 2. Verificar a alteração
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'profiles' AND column_name = 'cnes';

-- ============================================
-- CRIAR USUÁRIA: EVELYN FERNANDA PEREIRA DOS SANTOS
-- com 3 CNES: 2078813, 2089335, 2089327
-- ============================================

SELECT criar_usuario_automático(
  'convenios2@ciprianoayala.com.br',
  '2078813',
  'EVELYN FERNANDA PEREIRA DOS SANTOS',
  '2078813,2089335,2089327',
  'user'
);

-- ============================================
-- VERIFICAR
-- ============================================
SELECT id, full_name, email, cnes 
FROM public.profiles 
WHERE email = 'convenios2@ciprianoayala.com.br';
