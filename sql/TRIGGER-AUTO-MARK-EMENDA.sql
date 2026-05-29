-- ============================================================
-- TRIGGER: auto_mark_emenda_utilizada
-- Dispara AFTER INSERT na tabela planos_trabalho.
-- Se o plano tem oferta_emenda_id, marca automaticamente a emenda
-- como 'utilizada' — sem depender de RLS ou do cliente.
-- ============================================================

-- 1. Função do trigger
CREATE OR REPLACE FUNCTION public.auto_mark_emenda_utilizada()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Para INSERT: se o plano já vem com oferta_emenda_id
  IF TG_OP = 'INSERT' AND NEW.oferta_emenda_id IS NOT NULL THEN
    UPDATE public.emendas_disponibilizadas
    SET
      status       = 'utilizada',
      plano_id     = NEW.id,
      utilizada_em = COALESCE(utilizada_em, NOW()),
      updated_at   = NOW()
    WHERE id = NEW.oferta_emenda_id
      AND status = 'disponibilizada';

  -- Para UPDATE: somente quando oferta_emenda_id mudou de NULL para um valor
  ELSIF TG_OP = 'UPDATE'
    AND NEW.oferta_emenda_id IS NOT NULL
    AND (OLD.oferta_emenda_id IS NULL OR OLD.oferta_emenda_id IS DISTINCT FROM NEW.oferta_emenda_id)
  THEN
    UPDATE public.emendas_disponibilizadas
    SET
      status       = 'utilizada',
      plano_id     = NEW.id,
      utilizada_em = COALESCE(utilizada_em, NOW()),
      updated_at   = NOW()
    WHERE id = NEW.oferta_emenda_id
      AND status = 'disponibilizada';
  END IF;

  RETURN NEW;
END;
$$;

-- 2. Remover trigger antigo se existir
DROP TRIGGER IF EXISTS trigger_auto_mark_emenda_utilizada ON public.planos_trabalho;

-- 3. Criar trigger
CREATE TRIGGER trigger_auto_mark_emenda_utilizada
  AFTER INSERT OR UPDATE OF oferta_emenda_id
  ON public.planos_trabalho
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_mark_emenda_utilizada();
