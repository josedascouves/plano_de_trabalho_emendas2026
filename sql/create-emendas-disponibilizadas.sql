-- =====================================================
-- EMENDAS DISPONIBILIZADAS (admin -> beneficiario)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.emendas_disponibilizadas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cnes VARCHAR(10) NOT NULL,
  entidade TEXT NOT NULL,
  cnpj VARCHAR(18) NOT NULL,
  parlamentar TEXT NOT NULL,
  tipo_parlamentar TEXT NULL CHECK (tipo_parlamentar IN ('deputado', 'senador')),
  numero_emenda TEXT NULL,
  valor NUMERIC(15,2) NOT NULL CHECK (valor > 0),
  programa TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'disponibilizada' CHECK (status IN ('disponibilizada', 'utilizada', 'cancelada')),
  disponibilizada_por UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  plano_id UUID NULL REFERENCES public.planos_trabalho(id) ON DELETE SET NULL,
  utilizada_em TIMESTAMPTZ NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_emendas_disponibilizadas_cnes ON public.emendas_disponibilizadas(cnes);
CREATE INDEX IF NOT EXISTS idx_emendas_disponibilizadas_status ON public.emendas_disponibilizadas(status);
CREATE INDEX IF NOT EXISTS idx_emendas_disponibilizadas_created_at ON public.emendas_disponibilizadas(created_at DESC);

-- Adicionar coluna numero_emenda se ainda não existir (para bases já criadas)
ALTER TABLE public.emendas_disponibilizadas
  ADD COLUMN IF NOT EXISTS numero_emenda TEXT NULL;

-- Vínculo opcional no plano para rastrear origem da disponibilização
ALTER TABLE public.planos_trabalho
  ADD COLUMN IF NOT EXISTS oferta_emenda_id UUID NULL REFERENCES public.emendas_disponibilizadas(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_planos_trabalho_oferta_emenda_id ON public.planos_trabalho(oferta_emenda_id);

-- Trigger de updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at_emendas_disponibilizadas()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_set_updated_at_emendas_disponibilizadas ON public.emendas_disponibilizadas;
CREATE TRIGGER trg_set_updated_at_emendas_disponibilizadas
BEFORE UPDATE ON public.emendas_disponibilizadas
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at_emendas_disponibilizadas();

-- =====================================================
-- RLS
-- =====================================================
ALTER TABLE public.emendas_disponibilizadas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin_select_emendas_disponibilizadas" ON public.emendas_disponibilizadas;
CREATE POLICY "admin_select_emendas_disponibilizadas"
ON public.emendas_disponibilizadas
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.user_roles ur
    WHERE ur.user_id = auth.uid()
      AND ur.role IN ('admin', 'intermediate')
      AND COALESCE(ur.disabled, false) = false
  )
);

DROP POLICY IF EXISTS "admin_insert_emendas_disponibilizadas" ON public.emendas_disponibilizadas;
CREATE POLICY "admin_insert_emendas_disponibilizadas"
ON public.emendas_disponibilizadas
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.user_roles ur
    WHERE ur.user_id = auth.uid()
      AND ur.role = 'admin'
      AND COALESCE(ur.disabled, false) = false
  )
);

DROP POLICY IF EXISTS "admin_update_emendas_disponibilizadas" ON public.emendas_disponibilizadas;
CREATE POLICY "admin_update_emendas_disponibilizadas"
ON public.emendas_disponibilizadas
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.user_roles ur
    WHERE ur.user_id = auth.uid()
      AND ur.role = 'admin'
      AND COALESCE(ur.disabled, false) = false
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.user_roles ur
    WHERE ur.user_id = auth.uid()
      AND ur.role = 'admin'
      AND COALESCE(ur.disabled, false) = false
  )
);

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
      AND cnes = ANY(string_to_array(replace(COALESCE(p.cnes, ''), ' ', ''), ','))
  )
);

-- Permitir delete somente admin
DROP POLICY IF EXISTS "admin_delete_emendas_disponibilizadas" ON public.emendas_disponibilizadas;
CREATE POLICY "admin_delete_emendas_disponibilizadas"
ON public.emendas_disponibilizadas
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.user_roles ur
    WHERE ur.user_id = auth.uid()
      AND ur.role = 'admin'
      AND COALESCE(ur.disabled, false) = false
  )
);
