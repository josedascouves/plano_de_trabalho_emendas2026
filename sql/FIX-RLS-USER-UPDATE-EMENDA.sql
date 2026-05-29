-- =====================================================
-- FIX: Corrige políticas RLS da tabela emendas_disponibilizadas
--
-- PROBLEMA 1: a política de SELECT do usuário comparava
--   p.cnes = ANY(string_to_array(p.cnes,...))  -- tautologia!
-- em vez de comparar o CNES da EMENDA com o CNES do usuário.
-- Resultado: qualquer usuário ativo via TODOS as emendas.
--
-- PROBLEMA 2: política de UPDATE para usuário ('user') estava
-- ausente, impedindo a marcação automática como 'utilizada'.
--
-- SOLUÇÃO: usar emendas_disponibilizadas.cnes explicitamente
-- dentro dos subqueries para evitar ambiguidade de coluna.
-- =====================================================

-- 1) Recriar política de SELECT do usuário com referência correta
DROP POLICY IF EXISTS "user_select_own_cnes_emendas_disponibilizadas" ON public.emendas_disponibilizadas;
CREATE POLICY "user_select_own_cnes_emendas_disponibilizadas"
ON public.emendas_disponibilizadas
FOR SELECT
TO authenticated
USING (
  status = 'disponibilizada'
  AND EXISTS (
    SELECT 1
    FROM public.profiles p
    JOIN public.user_roles ur ON ur.user_id = p.id
    WHERE p.id = auth.uid()
      AND ur.role = 'user'
      AND COALESCE(ur.disabled, false) = false
      -- Referência explícita ao CNES da EMENDA (coluna da tabela outer)
      AND emendas_disponibilizadas.cnes = ANY(
            string_to_array(replace(COALESCE(p.cnes, ''), ' ', ''), ',')
          )
  )
);

-- 2) Recriar (ou criar) política de UPDATE para usuário
DROP POLICY IF EXISTS "user_update_own_cnes_emendas_disponibilizadas" ON public.emendas_disponibilizadas;
CREATE POLICY "user_update_own_cnes_emendas_disponibilizadas"
ON public.emendas_disponibilizadas
FOR UPDATE
TO authenticated
USING (
  -- Só pode atualizar emenda do próprio CNES
  EXISTS (
    SELECT 1
    FROM public.profiles p
    JOIN public.user_roles ur ON ur.user_id = p.id
    WHERE p.id = auth.uid()
      AND ur.role = 'user'
      AND COALESCE(ur.disabled, false) = false
      AND emendas_disponibilizadas.cnes = ANY(
            string_to_array(replace(COALESCE(p.cnes, ''), ' ', ''), ',')
          )
  )
)
WITH CHECK (
  -- Usuários só podem alterar status para 'utilizada'
  status = 'utilizada'
  AND EXISTS (
    SELECT 1
    FROM public.profiles p
    JOIN public.user_roles ur ON ur.user_id = p.id
    WHERE p.id = auth.uid()
      AND ur.role = 'user'
      AND COALESCE(ur.disabled, false) = false
      AND emendas_disponibilizadas.cnes = ANY(
            string_to_array(replace(COALESCE(p.cnes, ''), ' ', ''), ',')
          )
  )
);

-- Verificar políticas ativas após criação
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'emendas_disponibilizadas'
ORDER BY policyname;
