-- Adicionar nome e email de quem criou/salvou o plano
ALTER TABLE planos_trabalho ADD COLUMN IF NOT EXISTS created_by_name TEXT;
ALTER TABLE planos_trabalho ADD COLUMN IF NOT EXISTS created_by_email TEXT;

-- Preencher retroativamente com dados da tabela profiles (para planos já existentes)
UPDATE planos_trabalho pt
SET 
  created_by_name = p.full_name,
  created_by_email = COALESCE(p.email, u.email)
FROM profiles p
JOIN auth.users u ON u.id = p.id
WHERE pt.created_by = p.id
  AND pt.created_by_name IS NULL;
