-- ============================================================================
-- VERIFICAR E CORRIGIR SENHAS - Auth Users
-- ============================================================================

-- 1. Verificar o formato das senhas armazenadas
SELECT 
  email,
  encrypted_password,
  LENGTH(encrypted_password) as senha_length,
  SUBSTRING(encrypted_password, 1, 50) as senha_preview,
  CASE 
    WHEN encrypted_password LIKE '$2%' THEN '✅ BCRYPT'
    WHEN encrypted_password LIKE '$1%' THEN '⚠️ MD5'
    WHEN encrypted_password LIKE '$5%' THEN '⚠️ SHA256'
    WHEN encrypted_password LIKE '$6%' THEN '⚠️ SHA512'
    ELSE '❌ UNKNOWN: ' || SUBSTRING(encrypted_password, 1, 10)
  END as hash_type
FROM auth.users
WHERE email IN (
  'administracao.hefr@ceiam.org.br',
  'convenios2.b@cipriaioayla.com.br',
  'convenios2@cipriaioayla.com.br',
  'dir.executiva.heb@famesp.org.br',
  'expediente@hgt.org.br',
  'hospitalbsaojose@gmsil.com',
  'hospitalderluiz@yahoo.com.br',
  'ibraga@unimautraimiira.unicamp.br',
  'irenef@frm.br',
  'ivaneti.albino@hospitalfreigalvao.com.br',
  'luiz.barbosa@amemogi.spdm.org.br',
  'patricia.santos@colsan.org.br',
  'paulo.o@hc.fm.usp.br',
  'pcontas@santacasadearacatuba.com.br',
  'relacaespublicas@casadedavid.org.br',
  'robson@saocamilo-hlmb.org.br',
  'sec.itaim@oss.santamarcalina.org',
  'siemservicosadm@gmail.com',
  'silvania.ssilva@hgvp.org.br',
  'tarla@hcrp.usp.br'
)
ORDER BY email;

-- 2. Testar se a senha está funcionando (verificar hash)
-- Para cada usuário, testamos se o CNES como senha gera o hash correto
SELECT 
  email,
  raw_user_meta_data->>'cnes' as cnes_password,
  -- Testar se o hash corresponde ao CNES
  CASE 
    WHEN encrypted_password = crypt(raw_user_meta_data->>'cnes', encrypted_password) 
      THEN '✅ SENHA VÁLIDA'
    ELSE '❌ SENHA INVÁLIDA'
  END as password_status
FROM auth.users
WHERE email IN (
  'administracao.hefr@ceiam.org.br',
  'convenios2.b@cipriaioayla.com.br',
  'convenios2@cipriaioayla.com.br',
  'dir.executiva.heb@famesp.org.br',
  'expediente@hgt.org.br',
  'hospitalbsaojose@gmsil.com',
  'hospitalderluiz@yahoo.com.br',
  'ibraga@unimautraimiira.unicamp.br',
  'irenef@frm.br',
  'ivaneti.albino@hospitalfreigalvao.com.br',
  'luiz.barbosa@amemogi.spdm.org.br',
  'patricia.santos@colsan.org.br',
  'paulo.o@hc.fm.usp.br',
  'pcontas@santacasadearacatuba.com.br',
  'relacaespublicas@casadedavid.org.br',
  'robson@saocamilo-hlmb.org.br',
  'sec.itaim@oss.santamarcalina.org',
  'siemservicosadm@gmail.com',
  'silvania.ssilva@hgvp.org.br',
  'tarla@hcrp.usp.br'
);
