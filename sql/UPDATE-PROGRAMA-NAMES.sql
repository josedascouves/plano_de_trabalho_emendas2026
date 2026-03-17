-- ============================================================
-- ATUALIZAR NOMES DOS PROGRAMAS ORÇAMENTÁRIOS NA BASE DE DADOS
-- ============================================================

-- Script para renomear os programas existentes na tabela planos_trabalho
-- para os novos nomes conforme solicitado

-- ============================================================
-- 1. ATUALIZAR PROGRAMA: CUSTEIO MAC
-- ============================================================
UPDATE public.planos_trabalho
SET programa = 'EMENDA INDIVIDUAL - CUSTEIO MAC - 2E90'
WHERE programa = 'CUSTEIO MAC – 2E90'
   OR programa = 'CUSTEIO MAC - 2E90';

-- Resultado esperado: X linhas atualizadas
-- SELECT count(*) FROM public.planos_trabalho WHERE programa = 'EMENDA INDIVIDUAL - CUSTEIO MAC - 2E90';

-- ============================================================
-- 2. ATUALIZAR PROGRAMA: PMAE COMPONENTE CIRURGIA
-- ============================================================
UPDATE public.planos_trabalho
SET programa = 'EMENDA INDIVIDUAL - PMAE COMPONENTE CIRURGIA - (PNRF/MUTIRÃO)'
WHERE programa = 'PMAE COMPONENTE CIRURGIA - (PNRF/MUTIRÃO)';

-- Resultado esperado: X linhas atualizadas
-- SELECT count(*) FROM public.planos_trabalho WHERE programa = 'EMENDA INDIVIDUAL - PMAE COMPONENTE CIRURGIA - (PNRF/MUTIRÃO)';

-- ============================================================
-- 3. ATUALIZAR PROGRAMA: CUSTEIO DA MÉDIA E ALTA COMPLEXIDADE
-- ============================================================
UPDATE public.planos_trabalho
SET programa = 'PORTARIA 10.169 - PARCELA SUPLEMENTAR - CUSTEIO DA MÉDIA E ALTA COMPLEXIDADE'
WHERE programa = 'CUSTEIO DA MÉDIA E ALTA COMPLEXIDADE - PORTARIA 10.169 - PARCELA SUPLEMENTAR';

-- Resultado esperado: X linhas atualizadas
-- SELECT count(*) FROM public.planos_trabalho WHERE programa = 'PORTARIA 10.169 - PARCELA SUPLEMENTAR - CUSTEIO DA MÉDIA E ALTA COMPLEXIDADE';

-- ============================================================
-- 4. ATUALIZAR PROGRAMA: PROGRAMA AGORA TEM ESPECIALISTA
-- ============================================================
UPDATE public.planos_trabalho
SET programa = 'PORTARIA 10.169 - PARCELA SUPLEMENTAR - PROGRAMA AGORA TEM ESPECIALISTA'
WHERE programa = 'PROGRAMA AGORA TEM ESPECIALISTA - PORTARIA 10.169 - PARCELA SUPLEMENTAR'
   OR programa = 'PROGRAMA AGORA TEM ESPECIALISTA';

-- Resultado esperado: X linhas atualizadas
-- SELECT count(*) FROM public.planos_trabalho WHERE programa = 'PORTARIA 10.169 - PARCELA SUPLEMENTAR - PROGRAMA AGORA TEM ESPECIALISTA';

-- ============================================================
-- 5. VERIFICAÇÃO FINAL - LISTAR TODOS OS PROGRAMAS DISTINTOS
-- ============================================================

-- Execute esta query para verificar todos os programas existentes após as atualizações:
SELECT DISTINCT programa, COUNT(*) as quantidade
FROM public.planos_trabalho
GROUP BY programa
ORDER BY programa;

-- ============================================================
-- Resumo das alterações:
-- ============================================================
-- ✓ CUSTEIO MAC – 2E90 
--   → EMENDA INDIVIDUAL - CUSTEIO MAC - 2E90
--
-- ✓ PMAE COMPONENTE CIRURGIA - (PNRF/MUTIRÃO) 
--   → EMENDA INDIVIDUAL - PMAE COMPONENTE CIRURGIA - (PNRF/MUTIRÃO)
--
-- ✓ CUSTEIO DA MÉDIA E ALTA COMPLEXIDADE - PORTARIA 10.169 - PARCELA SUPLEMENTAR 
--   → PORTARIA 10.169 - PARCELA SUPLEMENTAR - CUSTEIO DA MÉDIA E ALTA COMPLEXIDADE
--
-- ✓ PROGRAMA AGORA TEM ESPECIALISTA - PORTARIA 10.169 - PARCELA SUPLEMENTAR 
--   → PORTARIA 10.169 - PARCELA SUPLEMENTAR - PROGRAMA AGORA TEM ESPECIALISTA
--
-- ✓ Opção "Selecione um Programa" removida do dropdown
-- ============================================================
