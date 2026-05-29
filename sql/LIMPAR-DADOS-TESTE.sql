-- ============================================================
-- LIMPAR DADOS DE TESTE
-- Remove os planos e emendas criados para testes.
-- Execute no Supabase → SQL Editor.
-- ============================================================

-- 1. Ver quais emendas serão removidas (execute só isso primeiro para conferir)
SELECT id, cnes, entidade, numero_emenda, parlamentar, valor, status, plano_id
FROM public.emendas_disponibilizadas
WHERE cnes = '123456'
ORDER BY created_at DESC;

-- 2. Ver quais planos estão vinculados a essas emendas
SELECT pt.id, pt.oferta_emenda_id, ed.entidade, ed.numero_emenda, ed.status
FROM public.planos_trabalho pt
INNER JOIN public.emendas_disponibilizadas ed ON ed.id = pt.oferta_emenda_id
WHERE ed.cnes = '123456';

-- ============================================================
-- ATENÇÃO: Só execute os DELETEs abaixo após confirmar
--          que as linhas acima são apenas dados de teste!
-- ============================================================

-- 3. Remover os planos vinculados às emendas de teste
DELETE FROM public.planos_trabalho
WHERE oferta_emenda_id IN (
  SELECT id FROM public.emendas_disponibilizadas WHERE cnes = '123456'
);

-- 4. Remover as emendas de teste
DELETE FROM public.emendas_disponibilizadas
WHERE cnes = '123456';
