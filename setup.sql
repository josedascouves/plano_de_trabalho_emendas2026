
-- SCRIPT DE CONFIGURAÇÃO COMPLETO DO BANCO DE DADOS SES-SP 2026
-- Local: Supabase SQL Editor (https://supabase.com/dashboard/project/tlpmspfnswaxwqzmwski/sql/new)

-- ==========================================
-- 1. LIMPEZA (OPCIONAL - Cuidado se já houver dados)
-- ==========================================
-- DROP TABLE IF EXISTS public.naturezas_despesa_plano;
-- DROP TABLE IF EXISTS public.metas_qualitativas;
-- DROP TABLE IF EXISTS public.acoes_servicos;
-- DROP TABLE IF EXISTS public.planos_trabalho;
-- DROP TABLE IF EXISTS public.profiles;

-- ==========================================
-- 2. TABELAS
-- ==========================================

-- Tabela de Perfis (Estende o Auth do Supabase)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL PRIMARY KEY,
  full_name TEXT NOT NULL,
  role TEXT CHECK (role IN ('admin', 'user')) DEFAULT 'user',
  email TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela Principal: Planos de Trabalho
CREATE TABLE public.planos_trabalho (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  parlamentar TEXT NOT NULL,
  numero_emenda TEXT NOT NULL,
  valor_total NUMERIC(15, 2),
  programa TEXT,
  beneficiario_nome TEXT,
  beneficiario_cnpj TEXT,
  cnes TEXT,
  justificativa TEXT,
  pdf_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users NOT NULL
);

-- Tabela: Metas Quantitativas (Ações e Serviços)
CREATE TABLE public.acoes_servicos (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  plano_id UUID REFERENCES public.planos_trabalho ON DELETE CASCADE NOT NULL,
  categoria TEXT,
  item TEXT,
  meta TEXT,
  valor NUMERIC(15, 2)
);

-- Tabela: Metas Qualitativas
CREATE TABLE public.metas_qualitativas (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  plano_id UUID REFERENCES public.planos_trabalho ON DELETE CASCADE NOT NULL,
  meta_descricao TEXT,
  indicador TEXT
);

-- Tabela: Naturezas de Despesa (Execução Financeira)
CREATE TABLE public.naturezas_despesa_plano (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  plano_id UUID REFERENCES public.planos_trabalho ON DELETE CASCADE NOT NULL,
  codigo TEXT,
  valor NUMERIC(15, 2)
);

-- ==========================================
-- 3. SEGURANÇA (RLS)
-- ==========================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.planos_trabalho ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.acoes_servicos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.metas_qualitativas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.naturezas_despesa_plano ENABLE ROW LEVEL SECURITY;

-- Políticas para Profiles
CREATE POLICY "Profiles visíveis por usuários autenticados" ON public.profiles FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Usuários editam próprio perfil" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Políticas para Planos de Trabalho
CREATE POLICY "Usuários veem próprios planos ou admins todos" ON public.planos_trabalho FOR SELECT 
USING (auth.uid() = created_by OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

CREATE POLICY "Usuários inserem próprios planos" ON public.planos_trabalho FOR INSERT 
WITH CHECK (auth.uid() = created_by);

-- Políticas para Sub-tabelas (Acesso via vínculo com o Plano)
CREATE POLICY "Acesso metas quant via dono/admin" ON public.acoes_servicos FOR ALL
USING (EXISTS (
  SELECT 1 FROM public.planos_trabalho 
  WHERE id = acoes_servicos.plano_id AND (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin')
));

CREATE POLICY "Acesso metas qual via dono/admin" ON public.metas_qualitativas FOR ALL
USING (EXISTS (
  SELECT 1 FROM public.planos_trabalho 
  WHERE id = metas_qualitativas.plano_id AND (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin')
));

CREATE POLICY "Acesso naturezas via dono/admin" ON public.naturezas_despesa_plano FOR ALL
USING (EXISTS (
  SELECT 1 FROM public.planos_trabalho 
  WHERE id = naturezas_despesa_plano.plano_id AND (created_by = auth.uid() OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin')
));

-- ==========================================
-- 4. AUTOMAÇÃO (Triggers)
-- ==========================================

-- Função para criar profile automático ao registrar
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role, email)
  VALUES (
    new.id, 
    COALESCE(new.raw_user_meta_data->>'full_name', 'Usuário SES'), 
    COALESCE(new.raw_user_meta_data->>'role', 'user'),
    new.email
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger de criação de perfil
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==========================================
-- 5. IMPORTANTE: STORAGE
-- ==========================================
-- 1. Vá em Storage no menu lateral do Supabase.
-- 2. Crie um novo Bucket chamado: planos-trabalho-pdfs
-- 3. Marque como "Public" (ou configure políticas de upload para usuários autenticados).
