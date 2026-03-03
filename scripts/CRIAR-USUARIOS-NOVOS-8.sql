-- ==============================================================================
-- SCRIPT: Sincronizar 8 Novos Usuários no Supabase
-- ==============================================================================
--
-- INSTRUÇÕES:
-- 1. Crie os usuários PRIMEIRO no Dashboard ou via Python script
-- 2. Depois execute este SQL no SQL Editor do Supabase
--
-- USUÁRIOS A CRIAR:
-- 1. GABRIEL LAMBERT BORGES / gabriel.borges@fajsaude.com.br / 2088495
-- 2. EVELYN FERNANDA DOS SANTOS / convenios2@ciprianoayla.com.br / 2089335
-- 3. ORIVAL ANDRIES JUNIOR / diretoriaoss@funcamp.unicamp.br / 2083981
-- 4. FERDINANDO BORRELLI JUNIOR / ferdinando.borrelli@oss.santamarcelina.org / 2078562
-- 5. MARIA DE LOURDES LACERDA FRANCO / lourdes.franco@hgp.spdm.org.br / 2079828
-- 6. KELLER RAFAELA CANUTO CASTRO / keller.castro@santacasajales.com.br / 2079895
-- 7. FERNANDA EUGENIO FERREIRA / dec@caism.unicamp.br / 2079798
-- 8. GABRIELA MORANDI DE ARAUJO / convenios@caism.unicamp.br / 2079798
--
-- ==============================================================================

-- ===================== PASSO 1: SINCRONIZAR PROFILES =====================

-- Insere/atualiza os perfis na tabela public.profiles
-- Esta tabela já deve ter sido criada pelo script CREATE-USERS-COMPLETO.sql

INSERT INTO public.profiles (id, email, full_name, cnes, role, created_at, updated_at)
SELECT 
  u.id,
  u.email,
  u.raw_user_meta_data ->> 'full_name' AS full_name,
  u.raw_user_meta_data ->> 'cnes' AS cnes,
  'user' as role,
  now(),
  now()
FROM auth.users u
WHERE u.email IN (
  'gabriel.borges@fajsaude.com.br',
  'convenios2@ciprianoayla.com.br',
  'diretoriaoss@funcamp.unicamp.br',
  'ferdinando.borrelli@oss.santamarcelina.org',
  'lourdes.franco@hgp.spdm.org.br',
  'keller.castro@santacasajales.com.br',
  'dec@caism.unicamp.br',
  'convenios@caism.unicamp.br'
)
AND NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.id = u.id
)
ON CONFLICT (id) DO UPDATE
SET 
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  cnes = EXCLUDED.cnes,
  updated_at = now();

-- ===================== PASSO 2: VERIFICAR SINCRONIZAÇÃO =====================

-- Verificar se todos os usuários foram sincronizados
SELECT 
  p.email,
  p.full_name,
  p.cnes,
  p.role,
  p.created_at
FROM public.profiles p
WHERE p.email IN (
  'gabriel.borges@fajsaude.com.br',
  'convenios2@ciprianoayla.com.br',
  'diretoriaoss@funcamp.unicamp.br',
  'ferdinando.borrelli@oss.santamarcelina.org',
  'lourdes.franco@hgp.spdm.org.br',
  'keller.castro@santacasajales.com.br',
  'dec@caism.unicamp.br',
  'convenios@caism.unicamp.br'
)
ORDER BY p.created_at DESC;

-- ===================== PASSO 3: CONTAR TOTAL =====================

SELECT COUNT(*) as total_usuarios_sincronizados
FROM public.profiles;

