-- Tabela de configurações globais da aplicação
CREATE TABLE IF NOT EXISTS public.app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Inserir valor padrão do mínimo de caracteres da justificativa
INSERT INTO public.app_settings (key, value)
VALUES ('min_justificativa', '0')
ON CONFLICT (key) DO NOTHING;

-- Recarregar cache do PostgREST para reconhecer a nova tabela
NOTIFY pgrst, 'reload schema';

-- RLS: qualquer usuário autenticado pode LER
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "app_settings_select" ON public.app_settings
  FOR SELECT TO authenticated USING (true);

-- Somente admins podem inserir/atualizar
CREATE POLICY "app_settings_upsert_admin" ON public.app_settings
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

