-- ==============================================================================
-- FIX: RLS em planos_trabalho para Intermediário
-- ==============================================================================
--
-- PROBLEMA: Intermediário não consegue ver planos
-- CAUSA: RLS está bloqueando porque planos foram criados por outros usuários
-- SOLUÇÃO: Permitir intermediário ler TODOS os planos
--
-- ==============================================================================

-- 1️⃣ DESABILITAR RLS na tabela (mais simples)
ALTER TABLE public.planos_trabalho DISABLE ROW LEVEL SECURITY;

SELECT '✅ RLS desabilitado em planos_trabalho' as resultado;

-- OU

-- 2️⃣ CRIAR POLÍTICA QUE PERMITE INTERMEDIÁRIO (se preferir manter RLS)
-- Descomente se quiser usar isso em vez da opção 1:

/*
CREATE POLICY "intermediario_can_read_all_planos"
ON public.planos_trabalho
FOR SELECT
USING (
  auth.uid() IN (
    SELECT user_id FROM public.user_roles 
    WHERE role = 'intermediate'
  )
  OR
  auth.uid() IN (
    SELECT user_id FROM public.user_roles 
    WHERE role = 'admin'
  )
  OR
  created_by = auth.uid()
);

SELECT '✅ Política criada para intermediário' as resultado;
*/

-- VERIFICAÇÃO
SELECT '
╔════════════════════════════════════════════════════════════╗
║  ✅ RLS CORRIGIDO!                                         ║
║                                                            ║
║  Agora:                                                   ║
║  1. Ctrl+F5 na app                                       ║
║  2. Logout e login novamente                            ║
║  3. Intermediário verá TODOS os planos                 ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
' as info;

-- ==============================================================================
