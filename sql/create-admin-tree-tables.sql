-- ============================================================
--  Tabelas editáveis pelo admin: Programas, Metas Quantitativas
--  (Ações/Serviços) e Naturezas de Despesa
-- ============================================================
-- ATENÇÃO: A tabela public.acoes_servicos JÁ EXISTE com dados de planos.
-- Por isso a tabela de catálogo usa o nome acoes_servicos_catalogo.

-- 1. PROGRAMAS ORÇAMENTÁRIOS
CREATE TABLE IF NOT EXISTS public.programas_orcamentarios (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome       TEXT NOT NULL UNIQUE,
  ordem      INTEGER NOT NULL DEFAULT 0,
  ativo      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CATÁLOGO DE AÇÕES / SERVIÇOS POR PROGRAMA (categoria vinculada a um programa)
--    NOTA: nome diferente de acoes_servicos que já é usada para dados de planos
CREATE TABLE IF NOT EXISTS public.acoes_servicos_catalogo (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  programa_id UUID REFERENCES public.programas_orcamentarios(id) ON DELETE CASCADE,
  categoria   TEXT NOT NULL,
  item        TEXT NOT NULL,
  ordem       INTEGER NOT NULL DEFAULT 0,
  ativo       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (programa_id, categoria, item)
);

-- 3. METAS QUANTITATIVAS (categoria + item, independentes de programa)
--    NOTA: metas_quantitativas já existe com outro schema; usar _catalogo
CREATE TABLE IF NOT EXISTS public.metas_quantitativas_catalogo (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  categoria  TEXT NOT NULL,
  item       TEXT NOT NULL,
  ordem      INTEGER NOT NULL DEFAULT 0,
  ativo      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (categoria, item)
);

-- 4. NATUREZAS DE DESPESA
CREATE TABLE IF NOT EXISTS public.naturezas_despesa (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo     TEXT NOT NULL UNIQUE,
  descricao  TEXT NOT NULL,
  ordem      INTEGER NOT NULL DEFAULT 0,
  ativo      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- RLS
-- ============================================================

ALTER TABLE public.programas_orcamentarios      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.acoes_servicos_catalogo      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.metas_quantitativas_catalogo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.naturezas_despesa            ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes para evitar erro de duplicata
DROP POLICY IF EXISTS "po_select"   ON public.programas_orcamentarios;
DROP POLICY IF EXISTS "po_admin"    ON public.programas_orcamentarios;
DROP POLICY IF EXISTS "as_select"   ON public.acoes_servicos_catalogo;
DROP POLICY IF EXISTS "asc_select"  ON public.acoes_servicos_catalogo;
DROP POLICY IF EXISTS "as_admin"    ON public.acoes_servicos_catalogo;
DROP POLICY IF EXISTS "asc_admin"   ON public.acoes_servicos_catalogo;
DROP POLICY IF EXISTS "mq_select"   ON public.metas_quantitativas_catalogo;
DROP POLICY IF EXISTS "mq_admin"    ON public.metas_quantitativas_catalogo;
DROP POLICY IF EXISTS "nd_select"   ON public.naturezas_despesa;
DROP POLICY IF EXISTS "nd_admin"    ON public.naturezas_despesa;

-- Leitura por qualquer usuário autenticado
CREATE POLICY "po_select"  ON public.programas_orcamentarios  FOR SELECT TO authenticated USING (true);
CREATE POLICY "asc_select" ON public.acoes_servicos_catalogo  FOR SELECT TO authenticated USING (true);
CREATE POLICY "mq_select"  ON public.metas_quantitativas_catalogo  FOR SELECT TO authenticated USING (true);
CREATE POLICY "nd_select"  ON public.naturezas_despesa        FOR SELECT TO authenticated USING (true);

-- Escrita somente para admins
-- Usamos profiles.role para evitar dependência circular com user_roles
CREATE POLICY "po_admin" ON public.programas_orcamentarios FOR ALL TO authenticated
  USING   ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin')
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

CREATE POLICY "asc_admin" ON public.acoes_servicos_catalogo FOR ALL TO authenticated
  USING   ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin')
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

CREATE POLICY "mq_admin" ON public.metas_quantitativas_catalogo FOR ALL TO authenticated
  USING   ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin')
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

CREATE POLICY "nd_admin" ON public.naturezas_despesa FOR ALL TO authenticated
  USING   ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin')
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

-- 5. NATUREZAS DE DESPESA DISPONÍVEIS POR PROGRAMA
--    Permite configurar quais naturezas aparecem para cada programa no formulário
CREATE TABLE IF NOT EXISTS public.programa_naturezas_catalogo (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  programa_id UUID REFERENCES public.programas_orcamentarios(id) ON DELETE CASCADE,
  codigo      TEXT NOT NULL,
  descricao   TEXT NOT NULL,
  ordem       INTEGER NOT NULL DEFAULT 0,
  ativo       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (programa_id, codigo)
);

ALTER TABLE public.programa_naturezas_catalogo ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "pnc_select" ON public.programa_naturezas_catalogo;
DROP POLICY IF EXISTS "pnc_admin"  ON public.programa_naturezas_catalogo;

CREATE POLICY "pnc_select" ON public.programa_naturezas_catalogo FOR SELECT TO authenticated USING (true);

CREATE POLICY "pnc_admin" ON public.programa_naturezas_catalogo FOR ALL TO authenticated
  USING   ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin')
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin');

-- ============================================================
-- Notificar PostgREST para recarregar o schema
-- ============================================================
NOTIFY pgrst, 'reload schema';
