-- Tabela de configurações globais da aplicação
CREATE TABLE IF NOT EXISTS public.app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  updated_by UUID REFERENCES auth.users(id)
);

-- Inserir valor padrão do mínimo de caracteres da justificativa
INSERT INTO public.app_settings (key, value)
VALUES ('min_justificativa', '2000')
ON CONFLICT (key) DO NOTHING;

-- RLS: qualquer usuário autenticado pode LER
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "app_settings_select" ON public.app_settings
  FOR SELECT TO authenticated USING (true);

-- Somente admins podem atualizar (via RPC abaixo)
CREATE POLICY "app_settings_update_admin" ON public.app_settings
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Função RPC para admin atualizar uma configuração
CREATE OR REPLACE FUNCTION public.set_app_setting(p_key TEXT, p_value TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Verificar se o usuário é admin
  IF NOT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Acesso negado: apenas administradores podem alterar configurações globais';
  END IF;

  INSERT INTO public.app_settings (key, value, updated_at, updated_by)
  VALUES (p_key, p_value, NOW(), auth.uid())
  ON CONFLICT (key) DO UPDATE
    SET value = EXCLUDED.value,
        updated_at = NOW(),
        updated_by = auth.uid();
END;
$$;

GRANT EXECUTE ON FUNCTION public.set_app_setting TO authenticated;
