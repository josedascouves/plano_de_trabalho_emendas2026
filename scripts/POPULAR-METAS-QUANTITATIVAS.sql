-- ==============================================================================
-- SCRIPT: Popular Metas Quantitativas no Banco de Dados
-- ==============================================================================
-- Data: 2026-03-03
-- Objetivo: Inserir grupos de ação e ações específicas na tabela de metas
-- ==============================================================================

-- ==============================================================================
-- CRIAÇÃO DA TABELA - METAS QUANTITATIVAS
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.metas_quantitativas (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  grupo_acao TEXT NOT NULL,
  acao_especifica TEXT NOT NULL,
  descricao TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(grupo_acao, acao_especifica)
);

CREATE INDEX IF NOT EXISTS idx_metas_quantitativas_grupo ON public.metas_quantitativas(grupo_acao);

-- ==============================================================================
-- INSERÇÃO DE DADOS - METAS QUANTITATIVAS
-- ==============================================================================

-- ALTA COMPLEXIDADE
INSERT INTO public.metas_quantitativas (grupo_acao, acao_especifica) VALUES
('ALTA COMPLEXIDADE', 'Acidente Vascular Cerebral'),
('ALTA COMPLEXIDADE', 'Cardiovascular'),
('ALTA COMPLEXIDADE', 'Centro de Queimados'),
('ALTA COMPLEXIDADE', 'Deficiência Auditiva'),
('ALTA COMPLEXIDADE', 'Deformidade Craniofacial'),
('ALTA COMPLEXIDADE', 'Hemodiálise'),
('ALTA COMPLEXIDADE', 'Mamografia Móvel'),
('ALTA COMPLEXIDADE', 'Neurocirurgia'),
('ALTA COMPLEXIDADE', 'Neuromusculares'),
('ALTA COMPLEXIDADE', 'Obesidade'),
('ALTA COMPLEXIDADE', 'Oftalmologia'),
('ALTA COMPLEXIDADE', 'Onco - Diagnóstico Câncer do Colo de Útero'),
('ALTA COMPLEXIDADE', 'Onco - Diagnóstico de Câncer de Mama'),
('ALTA COMPLEXIDADE', 'Onco - Oncologia'),
('ALTA COMPLEXIDADE', 'Procedimentos Cirúrgicos'),
('ALTA COMPLEXIDADE', 'Procedimentos Clínicos'),
('ALTA COMPLEXIDADE', 'Procedimentos com Finalidade Diagnóstica'),
('ALTA COMPLEXIDADE', 'Processo Transexualizador'),
('ALTA COMPLEXIDADE', 'Serviço de Atenção Hematológica e ou Hemoterapica'),
('ALTA COMPLEXIDADE', 'Terapia Nutricional, Enteral e Parenteral'),
('ALTA COMPLEXIDADE', 'Terapia Renal Substitutiva'),
('ALTA COMPLEXIDADE', 'Transplantes'),
('ALTA COMPLEXIDADE', 'Tratamento da Lipoatrofia Facial HIV/Aids'),
('ALTA COMPLEXIDADE', 'Traumatologia e Ortopedia')
ON CONFLICT (grupo_acao, acao_especifica) DO NOTHING;

-- ATENÇÃO DOMICILIAR
INSERT INTO public.metas_quantitativas (grupo_acao, acao_especifica) VALUES
('ATENÇÃO DOMICILIAR', 'Equipe Multiprofissional de Atenção Domiciliar'),
('ATENÇÃO DOMICILIAR', 'Equipe de Cuidados Paliativos'),
('ATENÇÃO DOMICILIAR', 'Programa Melhor Em Casa - Telessaúde')
ON CONFLICT (grupo_acao, acao_especifica) DO NOTHING;

-- CENTRAL DE REGULAÇÃO
INSERT INTO public.metas_quantitativas (grupo_acao, acao_especifica) VALUES
('CENTRAL DE REGULAÇÃO', 'Central de Regulação')
ON CONFLICT (grupo_acao, acao_especifica) DO NOTHING;

-- METAS QUALITATIVAS
INSERT INTO public.metas_quantitativas (grupo_acao, acao_especifica) VALUES
('METAS QUALITATIVAS', 'Adequação de Ambiência'),
('METAS QUALITATIVAS', 'Adoção de Políticas de Humanização'),
('METAS QUALITATIVAS', 'Aperfeiçoamento de Práticas'),
('METAS QUALITATIVAS', 'Condições de Funcionamento das Unidades'),
('METAS QUALITATIVAS', 'Correto Funcionamento das Comissões Hospitalares'),
('METAS QUALITATIVAS', 'Implantação de Protocolos'),
('METAS QUALITATIVAS', 'Média de Permanência'),
('METAS QUALITATIVAS', 'Satisfação do Usuário'),
('METAS QUALITATIVAS', 'Taxa de Ocupação'),
('METAS QUALITATIVAS', 'Tempo Médio de Realização de Procedimentos')
ON CONFLICT (grupo_acao, acao_especifica) DO NOTHING;

-- MÉDIA COMPLEXIDADE
INSERT INTO public.metas_quantitativas (grupo_acao, acao_especifica) VALUES
('MÉDIA COMPLEXIDADE', 'Policlínica/ Clínica/ Centro De Especialidade'),
('MÉDIA COMPLEXIDADE', 'Procedimentos Cirúrgicos'),
('MÉDIA COMPLEXIDADE', 'Procedimentos Clínicos'),
('MÉDIA COMPLEXIDADE', 'Procedimentos com Finalidade Diagnóstica'),
('MÉDIA COMPLEXIDADE', 'Procedimentos de Reabilitação'),
('MÉDIA COMPLEXIDADE', 'Serviço de Atenção Domiciliar (Programa Melhor em Casa)'),
('MÉDIA COMPLEXIDADE', 'Órteses, Próteses e Materiais Especiais (Não Relacionadas ao Ato Cirúrgico)')
ON CONFLICT (grupo_acao, acao_especifica) DO NOTHING;

-- PESSOA COM DEFICIÊNCIA
INSERT INTO public.metas_quantitativas (grupo_acao, acao_especifica) VALUES
('PESSOA COM DEFICIÊNCIA', 'CER - Centro Especializado em Reabilitação'),
('PESSOA COM DEFICIÊNCIA', 'Núcleo de Atenção a Criança e Adolescente com Transtorno do Especto Autista'),
('PESSOA COM DEFICIÊNCIA', 'Oficina Ortopédica'),
('PESSOA COM DEFICIÊNCIA', 'Transporte Sanitário Adaptado')
ON CONFLICT (grupo_acao, acao_especifica) DO NOTHING;

-- REDE DE URGÊNCIA
INSERT INTO public.metas_quantitativas (grupo_acao, acao_especifica) VALUES
('REDE DE URGÊNCIA', 'CIATox'),
('REDE DE URGÊNCIA', 'Leitos de Retaguarda'),
('REDE DE URGÊNCIA', 'Porta de Entrada'),
('REDE DE URGÊNCIA', 'UPA - Unidade de Pronto Atendimento')
ON CONFLICT (grupo_acao, acao_especifica) DO NOTHING;

-- REDE MATERNA INFANTIL
INSERT INTO public.metas_quantitativas (grupo_acao, acao_especifica) VALUES
('REDE MATERNA INFANTIL', 'Ambulatório Gestação E Puerpério Alto Risco'),
('REDE MATERNA INFANTIL', 'Ambulatório Seguimento Recém-nascido E Criança'),
('REDE MATERNA INFANTIL', 'CGBP - Casa De Gestante, Bebê e Puérpera'),
('REDE MATERNA INFANTIL', 'CPN - Centro Parto Normal'),
('REDE MATERNA INFANTIL', 'Central de Regulação do Acesso - Qualificação Rede Alyne'),
('REDE MATERNA INFANTIL', 'Leitos Gestação Alto Risco'),
('REDE MATERNA INFANTIL', 'Leitos Obstétricos Clínicos e Cirúrgicos'),
('REDE MATERNA INFANTIL', 'Transporte inter-hospitalar da Rede Alyne'),
('REDE MATERNA INFANTIL', 'Unidade Cuidados Intermediários Neonatal Canguru'),
('REDE MATERNA INFANTIL', 'Unidade Cuidados Intermediários Neonatal Convencional')
ON CONFLICT (grupo_acao, acao_especifica) DO NOTHING;

-- SAÚDE DO TRABALHADOR
INSERT INTO public.metas_quantitativas (grupo_acao, acao_especifica) VALUES
('SAÚDE DO TRABALHADOR', 'Centro de Referência em Saúde do Trabalhador')
ON CONFLICT (grupo_acao, acao_especifica) DO NOTHING;

-- SAÚDE MENTAL
INSERT INTO public.metas_quantitativas (grupo_acao, acao_especifica) VALUES
('SAÚDE MENTAL', 'CAPS - Centro de Atenção Psicossocial'),
('SAÚDE MENTAL', 'Centro de Convivência'),
('SAÚDE MENTAL', 'Equipes de Atenção Psicossocial para Deinstitucionalização'),
('SAÚDE MENTAL', 'Leitos de Saúde Mental (Hospital Geral)'),
('SAÚDE MENTAL', 'Serviço Residencial Terapêutico'),
('SAÚDE MENTAL', 'UA - Unidade de Acolhimento')
ON CONFLICT (grupo_acao, acao_especifica) DO NOTHING;

-- SERVIÇO DE ATENDIMENTO MÓVEL DE URGÊNCIA - SAMU
INSERT INTO public.metas_quantitativas (grupo_acao, acao_especifica) VALUES
('SERVIÇO DE ATENDIMENTO MÓVEL DE URGÊNCIA - SAMU', 'SAMU - Serviço de Atendimento Móvel de Urgência'),
('SERVIÇO DE ATENDIMENTO MÓVEL DE URGÊNCIA - SAMU', 'SAMU MTT - Medicamento Trombolítico Tenecteplase')
ON CONFLICT (grupo_acao, acao_especifica) DO NOTHING;

-- UNIDADE DE CUIDADOS PROLONGADOS
INSERT INTO public.metas_quantitativas (grupo_acao, acao_especifica) VALUES
('UNIDADE DE CUIDADOS PROLONGADOS', 'Leitos UCP')
ON CONFLICT (grupo_acao, acao_especifica) DO NOTHING;

-- UNIDADE DE TERAPIA INTENSIVA
INSERT INTO public.metas_quantitativas (grupo_acao, acao_especifica) VALUES
('UNIDADE DE TERAPIA INTENSIVA', 'Leitos UTI Adulto'),
('UNIDADE DE TERAPIA INTENSIVA', 'Leitos UTI Neonatal'),
('UNIDADE DE TERAPIA INTENSIVA', 'Leitos UTI Pediátrico'),
('UNIDADE DE TERAPIA INTENSIVA', 'Leitos UTI Queimados'),
('UNIDADE DE TERAPIA INTENSIVA', 'Leitos Unidade Coronariana - UCO'),
('UNIDADE DE TERAPIA INTENSIVA', 'Leitos de Unidade de Cuidados Intermediário Adulto - UCIa'),
('UNIDADE DE TERAPIA INTENSIVA', 'Leitos de Unidade de Cuidados Intermediário Pediátrico - UCIp')
ON CONFLICT (grupo_acao, acao_especifica) DO NOTHING;

-- ==============================================================================
-- VERIFICAÇÃO
-- ==============================================================================

-- Listar todos os grupos de ação cadastrados
SELECT DISTINCT grupo_acao 
FROM public.metas_quantitativas 
ORDER BY grupo_acao;

-- Contar total de metas quantitativas
SELECT COUNT(*) as total_metas_quantitativas
FROM public.metas_quantitativas;

-- Listar todas as metas por grupo
SELECT grupo_acao, COUNT(*) as quantidade
FROM public.metas_quantitativas
GROUP BY grupo_acao
ORDER BY grupo_acao;
