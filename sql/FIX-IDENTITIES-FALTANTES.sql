-- ============================================================================
-- FIX IDENTITIES - Criar auth.identities para os 11 usuarios que estao sem
-- ============================================================================
-- O erro "Database error querying schema" acontece porque o Supabase GoTrue
-- PRECISA do registro em auth.identities para autenticar via email/password.
-- Este script cria as identities faltantes.
--
-- Execute no SQL Editor do Supabase:
-- https://supabase.com/dashboard/project/tlpmspfnswaxwqzmwski/sql/new
-- ============================================================================

-- Primeiro, remover identities duplicadas/corrompidas que possam existir
DELETE FROM auth.identities 
WHERE user_id IN (
  SELECT id FROM auth.users WHERE email IN (
    'expediente@hgt.org.br',
    'pcontas@santacasadearacatuba.com.br',
    'ivaneti.albino@hospitalfreigalvao.com.br',
    'luiz.barbosa@amemogi.spdm.org.br',
    'tarla@hcrp.usp.br',
    'dir.executiva.heb@famesp.org.br',
    'patricia.santos@colsan.org.br',
    'paulo.o@hc.fm.usp.br',
    'robson@saocamilo-hlmb.org.br',
    'hospitalbsaojose@gmsil.com',
    'silvania.ssilva@hgvp.org.br'
  )
);

-- Agora criar as identities corretas para TODOS os 11 usuarios faltantes
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN 
    SELECT id, email 
    FROM auth.users 
    WHERE email IN (
      'expediente@hgt.org.br',
      'pcontas@santacasadearacatuba.com.br',
      'ivaneti.albino@hospitalfreigalvao.com.br',
      'luiz.barbosa@amemogi.spdm.org.br',
      'tarla@hcrp.usp.br',
      'dir.executiva.heb@famesp.org.br',
      'patricia.santos@colsan.org.br',
      'paulo.o@hc.fm.usp.br',
      'robson@saocamilo-hlmb.org.br',
      'hospitalbsaojose@gmsil.com',
      'silvania.ssilva@hgvp.org.br'
    )
  LOOP
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at
    ) VALUES (
      gen_random_uuid(),
      r.id,
      jsonb_build_object(
        'sub', r.id::text,
        'email', r.email,
        'email_verified', true,
        'phone_verified', false
      ),
      'email',
      r.id::text,
      NOW(), NOW(), NOW()
    );
    
    RAISE NOTICE 'Identity criada para: %', r.email;
  END LOOP;
END $$;

-- Tambem garantir que email_confirmed_at esta preenchido para todos
UPDATE auth.users 
SET email_confirmed_at = COALESCE(email_confirmed_at, NOW())
WHERE email IN (
  'expediente@hgt.org.br',
  'pcontas@santacasadearacatuba.com.br',
  'ivaneti.albino@hospitalfreigalvao.com.br',
  'luiz.barbosa@amemogi.spdm.org.br',
  'tarla@hcrp.usp.br',
  'dir.executiva.heb@famesp.org.br',
  'patricia.santos@colsan.org.br',
  'paulo.o@hc.fm.usp.br',
  'robson@saocamilo-hlmb.org.br',
  'hospitalbsaojose@gmsil.com',
  'silvania.ssilva@hgvp.org.br'
);

-- Garantir que confirmation_token e recovery_token estao limpos (evita erros)
UPDATE auth.users 
SET 
  confirmation_token = COALESCE(confirmation_token, ''),
  recovery_token = COALESCE(recovery_token, ''),
  email_change_token_new = COALESCE(email_change_token_new, ''),
  email_change = COALESCE(email_change, '')
WHERE email IN (
  'expediente@hgt.org.br',
  'pcontas@santacasadearacatuba.com.br',
  'ivaneti.albino@hospitalfreigalvao.com.br',
  'luiz.barbosa@amemogi.spdm.org.br',
  'tarla@hcrp.usp.br',
  'dir.executiva.heb@famesp.org.br',
  'patricia.santos@colsan.org.br',
  'paulo.o@hc.fm.usp.br',
  'robson@saocamilo-hlmb.org.br',
  'hospitalbsaojose@gmsil.com',
  'silvania.ssilva@hgvp.org.br'
);

-- ============================================================================
-- VERIFICACAO: Todos devem mostrar "SIM" em TEM IDENTITY agora
-- ============================================================================
SELECT 
  u.email as "EMAIL (LOGIN)",
  p.full_name as "NOME",
  p.cnes as "CNES (SENHA)",
  CASE WHEN i.id IS NOT NULL THEN '✅ SIM' ELSE '❌ NAO' END as "TEM IDENTITY",
  CASE WHEN p.id IS NOT NULL THEN '✅ SIM' ELSE '❌ NAO' END as "TEM PROFILE",
  CASE WHEN ur.user_id IS NOT NULL THEN '✅ SIM' ELSE '❌ NAO' END as "TEM USER_ROLE"
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
LEFT JOIN public.user_roles ur ON u.id = ur.user_id
LEFT JOIN auth.identities i ON u.id = i.user_id
WHERE u.email IN (
  'lbraga@amelimeira.unicamp.br',
  'luiz.barbosa@amemogi.spdm.org.br',
  'hospitalandreluiz@yahoo.com.br',
  'convenios2@ciprianoayla.com.br',
  'relacoespublicas@casadedavid.org.br',
  'patricia.santos@colsan.org.br',
  'convenios2.cnes2089327@ciprianoayla.com.br',
  'hospitalbsaojose@gmsil.com',
  'tarla@hcrp.usp.br',
  'irenef@ffm.br',
  'paulo.o@hc.fm.usp.br',
  'dir.executiva.heb@famesp.org.br',
  'expediente@hgt.org.br',
  'sec.itaim@oss.santamarcelina.org',
  'silvania.ssilva@hgvp.org.br',
  'administracao.hefr@cejam.org.br',
  'ivaneti.albino@hospitalfreigalvao.com.br',
  'robson@saocamilo-hlmb.org.br',
  'pcontas@santacasadearacatuba.com.br',
  'siempservicosadm@gmail.com'
)
ORDER BY p.full_name;
