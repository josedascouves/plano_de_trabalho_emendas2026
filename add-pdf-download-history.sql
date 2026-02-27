-- ==============================================================================
-- TABELA DE HISTÓRICO DE DOWNLOADS/VISUALIZAÇÕES DE PDF
-- ==============================================================================
-- Esta tabela registra quando usuários clicam em "Visualizar e Baixar PDF"

-- 1️⃣ CRIAR TABELA DE HISTÓRICO
CREATE TABLE public.pdf_download_history (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  plano_id UUID NOT NULL REFERENCES public.planos_trabalho ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users ON DELETE CASCADE,
  downloaded_at TIMESTAMPTZ DEFAULT NOW(),
  action_type TEXT DEFAULT 'view_pdf', -- 'view_pdf' ou 'download_pdf'
  user_email TEXT,
  user_name TEXT,
  parlamentar TEXT,
  numero_emenda TEXT,
  valor_total NUMERIC(15, 2)
);

-- 2️⃣ CRIAR ÍNDICES PARA MELHOR PERFORMANCE
CREATE INDEX idx_pdf_history_plano ON public.pdf_download_history(plano_id);
CREATE INDEX idx_pdf_history_user ON public.pdf_download_history(user_id);
CREATE INDEX idx_pdf_history_date ON public.pdf_download_history(downloaded_at DESC);

-- 3️⃣ HABILITAR RLS
ALTER TABLE public.pdf_download_history ENABLE ROW LEVEL SECURITY;

-- 4️⃣ CRIAR POLÍTICA DE SEGURANÇA
-- Usuários podem ler apenas histórico de seus próprios downloads ou admins veem tudo
CREATE POLICY "Usuários veem seu próprio histórico, admins veem tudo"
ON public.pdf_download_history
FOR SELECT
USING (
  auth.uid() = user_id 
  OR 
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
);

-- Apenas o sistema pode inserir (via função chamada da aplicação)
CREATE POLICY "Sistema insere histórico de download"
ON public.pdf_download_history
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- 5️⃣ CRIAR VIEW PARA STATISTICAS
CREATE OR REPLACE VIEW public.pdf_download_stats AS
SELECT 
  pt.id as plano_id,
  pt.numero_emenda,
  pt.parlamentar,
  COUNT(pdh.id) as total_downloads,
  MAX(pdh.downloaded_at) as ultimo_download,
  COUNT(DISTINCT pdh.user_id) as usuarios_unicos,
  pt.created_at as plano_criado_em,
  pt.updated_at as plano_atualizado_em
FROM public.planos_trabalho pt
LEFT JOIN public.pdf_download_history pdh ON pt.id = pdh.plano_id
GROUP BY pt.id, pt.numero_emenda, pt.parlamentar, pt.created_at, pt.updated_at
ORDER BY total_downloads DESC;

-- ✅ CONFIRMAÇÃO
SELECT '✅ Tabela pdf_download_history criada com sucesso!' as resultado;
SELECT '✅ Índices criados!' as resultado;
SELECT '✅ RLS habilitado!' as resultado;
SELECT '✅ View de estatísticas criada!' as resultado;
SELECT '📊 PRÓXIMOS PASSOS:' as info;
SELECT '    1. Executar este script no Supabase SQL Editor' as info;
SELECT '    2. Modificar App.tsx para registrar downloads' as info;
SELECT '    3. Testar a funcionalidade' as info;
