-- ============================================================
-- RPC: mark_emenda_utilizada
-- Marca uma emenda como 'utilizada' ao salvar o plano de trabalho.
-- Usa SECURITY DEFINER para contornar RLS e garantir a atualização.
-- Verifica se o chamador (auth.uid) tem CNES compatível com a emenda.
-- ============================================================

CREATE OR REPLACE FUNCTION public.mark_emenda_utilizada(
  p_emenda_id UUID,
  p_plano_id  UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_emenda_cnes    TEXT;
  v_user_cnes_raw  TEXT;
  v_rows_updated   INT;
BEGIN
  -- 1. Buscar CNES da emenda (precisa estar com status 'disponibilizada')
  SELECT cnes INTO v_emenda_cnes
  FROM public.emendas_disponibilizadas
  WHERE id = p_emenda_id
    AND status = 'disponibilizada';

  IF NOT FOUND THEN
    RAISE NOTICE 'mark_emenda_utilizada: emenda % não encontrada ou já utilizada', p_emenda_id;
    RETURN FALSE;
  END IF;

  -- 2. Buscar CNES do usuário autenticado
  SELECT cnes INTO v_user_cnes_raw
  FROM public.profiles
  WHERE id = auth.uid();

  -- 3. Verificar se o CNES da emenda pertence ao usuário
  IF NOT (v_emenda_cnes = ANY(
    string_to_array(
      replace(COALESCE(v_user_cnes_raw, ''), ' ', ''),
      ','
    )
  )) THEN
    -- CNES não confere — admin bypassa esta verificação
    IF NOT EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid()
        AND role IN ('admin', 'intermediario')
    ) THEN
      RAISE NOTICE 'mark_emenda_utilizada: CNES % não pertence ao usuário %', v_emenda_cnes, auth.uid();
      RETURN FALSE;
    END IF;
  END IF;

  -- 4. Atualizar a emenda
  UPDATE public.emendas_disponibilizadas
  SET
    status       = 'utilizada',
    plano_id     = p_plano_id,
    utilizada_em = NOW(),
    updated_at   = NOW()
  WHERE id = p_emenda_id;

  GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

  RAISE NOTICE 'mark_emenda_utilizada: % linhas atualizadas para emenda %', v_rows_updated, p_emenda_id;

  RETURN v_rows_updated > 0;
END;
$$;

-- Permissão de execução para usuários autenticados
GRANT EXECUTE ON FUNCTION public.mark_emenda_utilizada(UUID, UUID) TO authenticated;
