
import { Diretriz, AcaoServico, NaturezaDespesa } from './types';

export const DIRETRIZES: Diretriz[] = [
  {
    id: 'd1',
    numero: 1,
    titulo: 'Reafirmar o SUS como política de Estado cuja gestão e financiamento se dão de forma solidária e integrada entre as três esferas de governo',
    objetivos: [
      { 
        id: 'o1-1', 
        titulo: 'Garantir a gestão bipartite com pactuação em CIB, CIR e no Colegiado de Gestão Macrorregional', 
        metas: [
          { id: 'm1-1-1', descricao: 'Capacitar os integrantes das Comissões Intergestores Regionais (CIR) sobre os mecanismos de governança do SUS' },
          { id: 'm1-1-2', descricao: 'Consolidar os Comitês Executivos de Governança das Redes de Atenção à Saúde nas 18 RRAS' }
        ] 
      },
      { 
        id: 'o1-2', 
        titulo: 'Promover o debate do modelo de financiamento do SUS', 
        metas: [
          { id: 'm1-2-1', descricao: 'Promover fóruns de discussão para modelo de financiamento do SUS' }
        ] 
      },
      { 
        id: 'o1-3', 
        titulo: 'Incentivar a participação da Comunidade e a capacitação para o Controle Social na Gestão do SUS', 
        metas: [
          { id: 'm1-3-1', descricao: 'Promover iniciativas para a capacitação dos conselheiros do Conselho Estadual de Saúde' },
          { id: 'm1-3-2', descricao: 'Emitir pareceres conclusivos e manifestações anuais sobre os instrumentos de planejamento do SUS (PES, PAS, RAG e RDQAs)' },
          { id: 'm1-3-3', descricao: 'Capacitar as Ouvidorias do SUS das Unidades de Saúde sob gestão estadual para usar integralmente o Sistema Ouvidor SES/SP' },
          { id: 'm1-3-4', descricao: 'Realizar Conferência Estadual de Saúde' },
          { id: 'm1-3-5', descricao: 'Implantar o Sistema Ouvidor SES/SP - SMS nos municípios com Ouvidoria do SUS' },
          { id: 'm1-3-6', descricao: 'Apoiar iniciativas para capacitação dos Conselheiros Municipais de Saúde nos 645 municipios do Estado de SP' }
        ] 
      },
      { 
        id: 'o1-4', 
        titulo: 'Revisão do modelo de financiamento do SUS no ESP nos serviços de Saúde com vistas a ampliação ao acesso à assistência à Saúde - Tabela SUS Paulista', 
        metas: [
          { id: 'm1-4-1', descricao: 'Execução de 95% dos recursos previstos para Tabela SUS Paulista' }
        ] 
      }
    ]
  },
  {
    id: 'd2',
    numero: 2,
    titulo: 'Fortalecer a Gestão Estadual do SUS São Paulo, com foco na governança regional para aprimoramento das redes de atenção à saúde, em articulação com os municípios',
    objetivos: [
      { 
        id: 'o2-1', 
        titulo: 'Rever a organização dos processos de trabalho da SES, visando a ação integrada da gestão estadual', 
        metas: [
          { id: 'm2-1-1', descricao: 'Realizar reunião presencial e/ou via web para contribuir com a capacitação técnica de servidores da área de auditoria da gestão estadual e municipal' },
          { id: 'm2-1-2', descricao: 'Elaborar a revisão da Secretaria de Estado da Saúde, conforme Decreto nº 67.435 de 2023 - Art. 13' },
          { id: 'm2-1-3', descricao: 'Manter ações de auditoria assistencial em pelo menos 80% dos equipamentos sob gestão estadual para análise e monitoramento das normas vigentes do sistema de saúde' },
          { id: 'm2-1-4', descricao: 'Capacitar as 17 CTAR para padronização de Modelos de Relatórios e Conceitos' }
        ] 
      },
      { 
        id: 'o2-2', 
        titulo: 'Coordenar a realização do Planejamento Regional Integrado no Estado de São Paulo', 
        metas: [
          { id: 'm2-2-1', descricao: 'Realizar as etapas de programação de ações e serviços de saúde por gestor/serviço e de alocação de recursos por macrorregião de saúde' },
          { id: 'm2-2-2', descricao: 'Dar continuidade ao processo de regionalização da saúde no ESP com as etapas de confirmação ou ajuste da configuração das regiões/macrorregiões, definição de prioridades, plano de ação e organização da rede' }
        ] 
      },
      { 
        id: 'o2-3', 
        titulo: 'Implementar a gestão compartilhada da regulação do acesso a assistência à saúde nas regiões e macrorregiões', 
        metas: [
          { id: 'm2-3-1', descricao: 'Implantar processos de regulação do acesso nas macrorregiões de saúde com gestão compartilhada entre a gestão estadual e os municípios' }
        ] 
      },
      { 
        id: 'o2-4', 
        titulo: 'Apoiar financeiramente os municípios para ações em saúde relacionadas à Atenção Básica e ações de vigilância epidemiológica (IGM SUS Paulista)', 
        metas: [
          { id: 'm2-4-1', descricao: 'Transferir anualmente recursos financeiros aos municípios, na modalidade fundo a fundo por meio do Incentivo à Gestão Municipal - IGM SUS Paulista em 100% dos municípios aderentes' },
          { id: 'm2-4-2', descricao: 'Transferir anualmente recursos financeiros aos municípios, na modalidade fundo a fundo por meio do Incentivo à Gestão Municipal - IGM SUS Paulista - perspectiva de equidade nos critérios de distribuição' }
        ] 
      }
    ]
  },
  {
    id: 'd3',
    numero: 3,
    titulo: 'Garantir o acesso da população em tempo oportuno à atenção integral à saúde, aperfeiçoar a qualidade dos serviços de saúde e integrar a atenção primária à saúde a especializada',
    objetivos: [
      { 
        id: 'o3-1', 
        titulo: 'Induzir a ampliação da cobertura da Atenção Primária à Saúde, priorizando a Estratégia da Saúde da Família', 
        metas: [
          { id: 'm3-1-1', descricao: 'Promover a ampliação do número de Equipes de Saúde da Família' }
        ] 
      },
      { 
        id: 'o3-2', 
        titulo: 'Promover a saúde da população e protegê-la em relação aos agravos a saúde, incluindo acidentes e violências', 
        metas: [
          { id: 'm3-2-1', descricao: 'Promover a aplicação do percentual de acompanhamento das condicionalidades da saúde na população beneficiária do Programa Bolsa Família' },
          { id: 'm3-2-2', descricao: 'Induzir a ampliação das atividades coletivas na APS direcionadas para o autocuidado' },
          { id: 'm3-2-3', descricao: 'Ampliar o acolhimento de vítimas de violência sexual aguda com a realização de Profilaxia Pós Exposição (PEP) nas unidades de saúde' }
        ] 
      },
      { 
        id: 'o3-3', 
        titulo: 'Organizar e qualificar o acesso à rede de atenção a saúde, integrando a Atenção Primária à Saúde a assistência ambulatorial especializada e hospitalar', 
        metas: [
          { id: 'm3-3-1', descricao: 'Assegurar a oferta de primeiras consultas e garantir o acesso de novos pacientes' },
          { id: 'm3-3-2', descricao: 'Gerenciar a utilização dos leitos hospitalares administrados por Organizações Sociais de Saúde (OSS) por meio da redução da média de permanência institucional' },
          { id: 'm3-3-3', descricao: 'Ativação de 1200 leitos nos Hospitais próprios da SES' },
          { id: 'm3-3-4', descricao: 'Ampliar de 11 para 16 o nº de AMEs que realizam todo o conjunto de procedimentos diagnósticos para o câncer de mama e do colo de útero' },
          { id: 'm3-3-5', descricao: 'Promover a organização da rede ambulatorial de alto risco às gestantes nas 62 Regiões de Saúde' },
          { id: 'm3-3-6', descricao: 'Gerenciar a utilização dos leitos hospitalares da administração direta por meio da redução da média de permanência institucional' }
        ] 
      },
      { 
        id: 'o3-4', 
        titulo: 'Qualificar os instrumentos de contratualização (Contrato de Gestão, Convênios e Contrato Programa)', 
        metas: [
          { id: 'm3-4-1', descricao: 'Manter o Monitoramento do cumprimento das Metas contratadas e Conveniadas garantindo respostas às necessidades de Saúde da População' }
        ] 
      },
      { 
        id: 'o3-5', 
        titulo: 'Induzir a ampliação da cobertura de Saúde Bucal na Atenção Primária à Saúde', 
        metas: [
          { id: 'm3-5-1', descricao: 'Promover a ampliação do número de equipes de Saúde Bucal (ESB)' }
        ] 
      },
      { 
        id: 'o3-6', 
        titulo: 'Reestruturar a assistência farmacêutica de modo a garantir à população o acesso aos medicamentos padronizados no SUS', 
        metas: [
          { id: 'm3-6-1', descricao: 'Garantir a disponibilidade dos medicamentos nas unidades públicas estaduais de saúde' },
          { id: 'm3-6-2', descricao: 'Apoiar e fortalecer a Assistência Farmacêutica na Atenção Primária a Saúde' },
          { id: 'm3-6-3', descricao: 'Inovar processos de Assistência Farmacêutica com Recursos Tecnológicos' },
          { id: 'm3-6-4', descricao: 'Manter o programa de entrega de medicamentos do Componente Especializado da Assistência Farmacêutica e Protocolos Estaduais de forma presencial e na residência do paciente' }
        ] 
      },
      { 
        id: 'o3-7', 
        titulo: 'Promover o aumento da oferta de Órgãos e Tecidos para Transplantes', 
        metas: [
          { id: 'm3-7-1', descricao: 'Ampliar o número de notificações de potenciais doadores' }
        ] 
      },
      { 
        id: 'o3-8', 
        titulo: 'Estimular o uso racional de hemocomponentes e hemoderivados, com segurança', 
        metas: [
          { id: 'm3-8-1', descricao: 'Implantar o sistema de gerenciamento (software) da Hemorrede estadual para organizar as condições operacionais das agências transfusionais' }
        ] 
      },
      { 
        id: 'o3-9', 
        titulo: 'Fortalecer a vigilância e o monitoramento da linha de cuidado para portadores de doença renal em todos os seus estágios', 
        metas: [
          { id: 'm3-9-1', descricao: 'Ampliar a adesão ao Sistema de Regulação Estadual de Acesso à TRS' },
          { id: 'm3-9-2', descricao: 'Implantar Processos de Rastreamento e Classificação de Risco para Doença Renal Crônica (DRC) na Atenção Primária à Saúde (APS)' },
          { id: 'm3-9-3', descricao: 'Ampliar a adesão ao SISTRS (Sistema de Informações sobre Terapia Renal Substitutiva)' }
        ] 
      },
      { 
        id: 'o3-10', 
        titulo: 'Fortalecer a Rede de Atenção Psicossocial (RAPS)', 
        metas: [
          { id: 'm3-10-1', descricao: 'Aprimorar Programas Estratégicos de Saúde Mental nas Regiões de Saúde' }
        ] 
      },
      { 
        id: 'o3-11', 
        titulo: 'Aperfeiçoar e modernizar a Rede Estadual de Saúde', 
        metas: [
          { id: 'm3-11-1', descricao: 'Executar Reformas / ampliação nas unidades de saúde' },
          { id: 'm3-11-2', descricao: 'Realizar obras de adequação para acessibilidade em hospitais próprios do Estado' },
          { id: 'm3-11-3', descricao: 'Implantar o serviço de Engenharia Clínica (gestão e manutenção de equipamentos médico hospitalares) nas unidades próprias do estado' },
          { id: 'm3-11-4', descricao: 'Executar obras de adequação com vistas à obtenção do Auto de Vistoria do Corpo de Bombeiros (AVCB)' },
          { id: 'm3-11-5', descricao: 'Renovar o parque tecnológico de equipamentos médicos das unidades hospitalares e ambulatoriais próprias' }
        ] 
      }
    ]
  },
  {
    id: 'd4',
    numero: 4,
    titulo: 'Induzir a adoção do modelo de atenção à saúde com foco nas condições crônicas na rede SUS, priorizando na Atenção Primária à Saúde a Estratégia de Saúde da Família',
    objetivos: [
      { 
        id: 'o4-1', 
        titulo: 'Fomentar mecanismos de cuidado integral e hierarquizado nos diferentes níveis de atenção existentes na rede de atenção à saúde', 
        metas: [
          { id: 'm4-1-1', descricao: 'Atualizar a Linha de Cuidado (LC) da gestante com a inclusão do cuidado à gestante de alto risco' },
          { id: 'm4-1-2', descricao: 'Apoiar a implantação da Linha de Cuidado do RN de alto risco nas macrorregiões' },
          { id: 'm4-1-3', descricao: 'Atualizar as LC de hipertensão e diabetes' },
          { id: 'm4-1-4', descricao: 'Induzir junto aos municípios alinhamento às Diretrizes da Política Estadual de Saude Bucal, com foco regional' },
          { id: 'm4-1-5', descricao: 'Apoiar a organização dos processos de trabalho na atenção primária à saude (APS) referentes as linhas de cuidados (gestante, criança, hipertensão e diabetes), mediado por plano de trabalho pactuado com o gestor' },
          { id: 'm4-1-6', descricao: 'Formular a Linha de Cuidado para o RN de alto risco' }
        ] 
      },
      { 
        id: 'o4-2', 
        titulo: 'Fortalecer o apoio técnico aos municípios para organização da Atenção Primária à Saúde, na perspectiva do modelo de atenção as condições crônicas', 
        metas: [
          { id: 'm4-2-1', descricao: 'Desenvolver planos de ação de apoio técnico nos municípios apoiados pelos (AAPS)' },
          { id: 'm4-2-2', descricao: 'Recompor integralmente o quadro dos Articuladores da Saúde da Mulher (23 ASM)' },
          { id: 'm4-2-3', descricao: 'Promover o funcionamento regular dos Grupos Técnicos de Atenção Primária à Saúde em todo o território de cada DRS' },
          { id: 'm4-2-4', descricao: 'Recompor o quadro dos Articuladores da Atenção Primária à Saúde (AAPS)' }
        ] 
      }
    ]
  },
  {
    id: 'd5',
    numero: 5,
    titulo: 'Promover a atenção integral às pessoas em seus diferentes ciclos de vida e dos segmentos específicos da população',
    objetivos: [
      { 
        id: 'o5-1', 
        titulo: 'Qualificar o cuidado da saúde da criança e do adolescente em suas diferentes dimensões e necessidades', 
        metas: [
          { id: 'm5-1-1', descricao: 'Reduzir a mortalidade infantil no Estado' },
          { id: 'm5-1-2', descricao: 'Apoiar os municípios no aprimoramento do registro de dados nutricionais na APS' }
        ] 
      },
      { 
        id: 'o5-2', 
        titulo: 'Qualificar o cuidado da saúde da mulher em suas diferentes dimensões e necessidades', 
        metas: [
          { id: 'm5-2-1', descricao: 'Reduzir a mortalidade materna' },
          { id: 'm5-2-2', descricao: 'Aumentar a razão de exame Citopatologico em 20%' },
          { id: 'm5-2-3', descricao: 'Fortalecer as ações relacionadas aos direitos reprodutivos nas maternidades do Estado' },
          { id: 'm5-2-4', descricao: 'Aumentar a razão de exame de Mamografia de rastreamento em 20%' }
        ] 
      },
      { 
        id: 'o5-3', 
        titulo: 'Qualificar o cuidado da saúde do homem em suas diferentes dimensões e necessidades', 
        metas: [
          { id: 'm5-3-1', descricao: 'Apoiar os municípios para ampliar o nº de consultas de pré-natal do parceiro' }
        ] 
      },
      { 
        id: 'o5-4', 
        titulo: 'Qualificar o cuidado a saúde da população idosa, promovendo o envelhecimento ativo e saudável', 
        metas: [
          { id: 'm5-4-1', descricao: 'Aumentar o número de Instituições que participam do Programa Instituição Amiga do Idoso' },
          { id: 'm5-4-2', descricao: 'Capacitar os Profissionais da Atenção Primária à Saúde (APS) dos municípios do estado de São Paulo para avaliação Multifuncional do Idoso' }
        ] 
      },
      { 
        id: 'o5-5', 
        titulo: 'Fortalecer a atenção à Saúde das Populações Vulneráveis', 
        metas: [
          { id: 'm5-5-1', descricao: 'Garantir o acesso a Rede de Cuidados à Pessoa com Deficiência, por meio da regulação de oferta dos leitos de internação da Rede Lucy Montoro' },
          { id: 'm5-5-2', descricao: 'Garantir e ampliar o acesso à Ações de Atenção Primária à Saúde, intramuros, nas unidades prisionais, incluindo Telemedicina' },
          { id: 'm5-5-3', descricao: 'Aprimorar a articulação entre os entes federados para a melhoria da Atenção à Saúde da População Indígena aldeada' },
          { id: 'm5-5-4', descricao: 'Ampliar o número de regiões de saúde apoiadas tecnicamente na organização de serviços de atenção à saúde integral da população trans' },
          { id: 'm5-5-5', descricao: 'Apoiar tecnicamente as Regiões de Saúde para a melhoria das iniquidades em saúde da população negra' },
          { id: 'm5-5-6', descricao: 'Garantir o acesso a Rede de Cuidados à Pessoa com Deficiência, por meio da regulação de oferta das consultas ambulatoriais da Rede Lucy Montoro (1ª consulta) e dos Centros Especializados de Reabilitação-CER sob gestão Estadual' },
          { id: 'm5-5-7', descricao: 'Identificar e mapear regionalmente as iniquidades em saúde da população negra incluindo a população quilombola' },
          { id: 'm5-5-8', descricao: 'Ampliar o Nº de deficiências atendidas pelas Unidades da Rede Lucy Montoro' }
        ] 
      },
      { 
        id: 'o5-6', 
        titulo: 'Consolidar o programa de Triagem Neonatal', 
        metas: [
          { id: 'm5-6-1', descricao: 'Ampliar a triagem neonatal biológica na Rede Regional de Saúde e implementar de forma escalonada as doenças a serem rastreadas no exame do "teste do pezinho", de acordo com as 5 etapas estabelecidas pelo Programa' },
          { id: 'm5-6-2', descricao: 'Monitorar a cobertura do Programa de Triagem Neonatal Biológica e garantir o acesso dos recém-nascidos ao exame na Rede Regional de Saúde do SUS - SP' },
          { id: 'm5-6-3', descricao: 'Implantar Programa de Triagem Auditiva Neonatal – TAN e garantir o acesso dos recém-nascidos ao exame na Rede Regional de Saúde-SUS no Estado de SP' }
        ] 
      },
      { id: 'o5-7', titulo: 'Implantar a Rede Integrada de Assistência aos Pacientes com Doenças Genéticas Raras', metas: [] }
    ]
  },
  {
    id: 'd6',
    numero: 6,
    titulo: 'Reduzir e prevenir riscos relacionados à saúde da população por meio das ações de vigilância, promoção e prevenção',
    objetivos: [
      { 
        id: 'o6-1', 
        titulo: 'Fortalecer o Sistema Estadual de Vigilância em Saúde', 
        metas: [
          { id: 'm6-1-1', descricao: 'Ampliar a proporção de municípios na cobertura da vacina inativada poliomielite - VIP (D3) em crianças menores de 12 meses de idade' },
          { id: 'm6-1-2', descricao: 'Ampliar o percentual de diagnostico de hanseníase com avaliação de incapacidade' },
          { id: 'm6-1-3', descricao: 'Ampliar o diagnóstico da Hepatite C na população de 15 a 69 anos' },
          { id: 'm6-1-4', descricao: 'Ampliar o percentual de cura dos novos casos de tuberculose notificados no período' },
          { id: 'm6-1-5', descricao: 'Ampliar a Vigilância Genômica de arbovírus urbanos em todas as RRAS do estado de São Paulo' },
          { id: 'm6-1-6', descricao: 'Ampliar o percentual de investigação com início em até 48 horas dos óbitos por dengue e Chikungunya' },
          { id: 'm6-1-7', descricao: 'Ampliar a proporção de municípios na cobertura da vacina sarampo, caxumba e Rubéola-SCR (D1) em crianças com um ano de idade' },
          { id: 'm6-1-8', descricao: 'Promover o aprimoramento de ações de vigilância da Raiva por RRAS' },
          { id: 'm6-1-9', descricao: 'Ampliar o percentual de tratamento com penicilina, de gestantes diagnosticadas com sífilis no pré-natal' },
          { id: 'm6-1-10', descricao: 'Implementar a atenção às infecções na atenção às Infecções Sexualmente Transmissíveis IST/Aids nos municípios habilitados na política de incentivo' },
          { id: 'm6-1-11', descricao: 'Assegurar a confirmação laboratorial dos casos notificados de sarampo e Rubéola' },
          { id: 'm6-1-12', descricao: 'Notificar e investigar casos de paralisia flácida aguda (PFA) em menores de 15 anos, garantindo a sensibilidade do sistema de vigilância para detecção de possíveis casos de poliomielite' },
          { id: 'm6-1-13', descricao: 'Encerrar oportunamente os casos de doenças de notificação compulsória imediatas (DNCI), exceto agravos cujo prazo de encerramento não tenha sido pactuado' }
        ] 
      },
      { 
        id: 'o6-2', 
        titulo: 'Promover a Vigilância em Saúde nas áreas de produtos e serviços de interesse da saúde, meio ambiente e saúde do trabalhador', 
        metas: [
          { id: 'm6-2-1', descricao: 'Inspecionar Serviços de Quimioterapia' },
          { id: 'm6-2-2', descricao: 'Manter a Investigação eventos - sentinelas, relacionados ao Ciclo do Sangue, notificados no Notivisa' },
          { id: 'm6-2-3', descricao: 'Inspecionar estabelecimentos fabricantes de medicamentos, insumos farmacêuticos ativos e de produtos para saúde de classe de risco III e IV programados para inspeção no Planejamento Anual Baseado no Risco' },
          { id: 'm6-2-4', descricao: 'Coletar amostras planejadas anualmente no Programa Paulista de Alimentos (PPA)' },
          { id: 'm6-2-5', descricao: 'Instituir Comitês de Toxico vigilância nas Redes Regionais de Atenção à Saúde (RRAS)' },
          { id: 'm6-2-6', descricao: 'Apoiar os Centros de Referência em Saúde do Trabalhador (CEREST) para atuação no controle de risco e de agravos à saúde relacionados ao trabalho' },
          { id: 'm6-2-7', descricao: 'Realizar ações estruturantes planejadas para Vigilância em Saúde Ambiental (VSA)' },
          { id: 'm6-2-8', descricao: 'Realizar ações programadas de Vigilância em Saúde de Populações Expostas aos Agrotóxicos (VSPEA)' },
          { id: 'm6-2-9', descricao: 'Realizar ações estruturantes de Vigilância em Saúde do Trabalhador (VISAT)' },
          { id: 'm6-2-10', descricao: 'Serviços de Diálise atendendo ao Programa Estadual de Monitoramento da Água Tratada para Diálise – Serviços de Diálise (PEMAT - SD)' },
          { id: 'm6-2-11', descricao: 'Analisar amostras de água para consumo humano previstas na Diretriz Nacional' }
        ] 
      },
      { 
        id: 'o6-3', 
        titulo: 'Aprimorar a detecção e resposta às emergências em saúde pública', 
        metas: [
          { id: 'm6-3-1', descricao: 'Realizar ações estruturantes planejadas em Vigilância em Saúde Ambiental Associados aos Desastres (Vigi desastres) no ESP' },
          { id: 'm6-3-2', descricao: 'Fortalecer políticas regionais estratégicas e ampliar a capacidade de respostas dos Laboratórios Estaduais de Saúde Pública' },
          { id: 'm6-3-3', descricao: 'Incorporar de forma oportuna, métodos de diagnósticos voltados para as emergências em saúde pública' }
        ] 
      },
      { 
        id: 'o6-4', 
        titulo: 'Promover ações de apoio ao desenvolvimento de Políticas com impacto na saúde da população', 
        metas: [
          { id: 'm6-4-1', descricao: 'Unidades Assistenciais da SES-SP com gestão de carbono e energia instituídos, conforme diretrizes da Política Estadual de Mudanças Climáticas (PEMC)' },
          { id: 'm6-4-2', descricao: 'Divulgar referenciais técnicos, projetos e práticas de gestão da SESSP alinhadas com os objetivos da Política Estadual de Mudanças Climáticas (PEMC)' }
        ] 
      }
    ]
  },
  {
    id: 'd7',
    numero: 7,
    titulo: 'Fortalecer as ações de gestão do trabalho e de educação no SUS São Paulo',
    objetivos: [
      { 
        id: 'o7-1', 
        titulo: 'Revisar as carreiras de Estado na Saúde, compatibilizando com a Política Estadual de Recursos Humanos', 
        metas: [
          { id: 'm7-1-1', descricao: 'Mapear carreiras de Estado específicas para a gestão do SUS' }
        ] 
      },
      { 
        id: 'o7-2', 
        titulo: 'Estabelecer modelos para operação dos equipamentos de saúde da SES', 
        metas: [
          { id: 'm7-2-1', descricao: 'Identificar os modelos de operação dos equipamentos de Saúde das SES' }
        ] 
      },
      { 
        id: 'o7-3', 
        titulo: 'Formar e capacitar profissionais para a área da saúde', 
        metas: [
          { id: 'm7-3-1', descricao: 'Capacitar os servidores da administração direta da SES/SP' },
          { id: 'm7-3-2', descricao: 'Cursos de capacitação em conhecimento técnico-científico para trabalhadores do SUS/SP oferecidos pelo Instituto de Saúde (IS) da CCTIES' },
          { id: 'm7-3-3', descricao: 'Especializar profissionais da área da saúde, exceto Médicos, para as instituições de saúde' },
          { id: 'm7-3-4', descricao: 'Formar e capacitar profissionais por meio das Escolas Técnicas do SUS/SP para as instituições de saúde' },
          { id: 'm7-3-5', descricao: 'Formar Médicos por meio do Programa de Residência Médica para as instituições de saúde' }
        ] 
      },
      { 
        id: 'o7-4', 
        titulo: 'Apoiar os municípios na formação e qualificação dos trabalhadores do SUS, com ênfase na atenção primária', 
        metas: [
          { id: 'm7-4-1', descricao: 'Capacitar profissionais na área de Vigilância em Saúde e Gestão' },
          { id: 'm7-4-2', descricao: 'Apoiar municípios com cobertura de ESF > 75%, para a execução de projeto de formação e qualificação das equipes de Saúde da Família para organização das ações na perspectiva da atenção às condições crônicas' },
          { id: 'm7-4-3', descricao: 'Apoiar os Departamentos Regionais de Saúde na qualificação e implementação de 57 projetos dos Planos Regionais de Educação Permanente em Saúde (PREPS)' }
        ] 
      },
      { 
        id: 'o7-5', 
        titulo: 'Promover ações para melhoria da qualidade de vida e do ambiente profissional na SES/SP', 
        metas: [
          { id: 'm7-5-1', descricao: 'Realizar ações de segurança e saúde do trabalhador e de qualidade de vida aos servidores do Estado de São Paulo' }
        ] 
      },
      { 
        id: 'o7-6', 
        titulo: 'Qualificar a Política Estadual de Humanização (PEH) nas Unidades de Saúde da SES', 
        metas: [
          { id: 'm7-6-1', descricao: 'Unidades de saúde da SES com Planos de Segurança do Paciente (PSP)' },
          { id: 'm7-6-2', descricao: 'Unidades de Saúde da SES com Planos Institucionais de Humanização (PIH) qualificados' },
          { id: 'm7-6-3', descricao: 'Unidades de Saúde da SES com Grupos de Trabalho de Humanização (GTH) qualificados' },
          { id: 'm7-6-4', descricao: 'Unidades de saúde da SES com o Núcleo de Segurança do Paciente (NSP) instituído e cadastrado na Anvisa' }
        ] 
      }
    ]
  },
  {
    id: 'd8',
    numero: 8,
    titulo: 'Desenvolver política Estadual de ciência, tecnologia e inovação em saúde, incluindo a saúde digital',
    objetivos: [
      { 
        id: 'o8-1', 
        titulo: 'Elaborar e implementar Política Estadual de Saúde Digital, alinhada à Política Nacional de Saúde Digital', 
        metas: [
          { id: 'm8-1-1', descricao: 'Implantação de TELE APS em 60 unidades básicas de saúde (UBS)' },
          { id: 'm8-1-2', descricao: 'Implantação de TELE UTI em 36 hospitais próprios do estado' },
          { id: 'm8-1-3', descricao: 'Implantação de TELE AME em 1 ambulatório médico do Estado para atendimento remoto à saúde' },
          { id: 'm8-1-4', descricao: 'Implantação do serviço de Telesaúde em unidades da População Privada de Liberdade (PPL)' },
          { id: 'm8-1-5', descricao: 'Implementação do programa de inovação em saúde digital' }
        ] 
      },
      { 
        id: 'o8-2', 
        titulo: 'Fortalecer o Polo Industrial da Saúde do Estado de São Paulo, rumo a auto suficiência, com a participação estratégica do Instituto Butantan e FURP', 
        metas: [
          { id: 'm8-2-1', descricao: 'Produção e Fornecimento de Medicamentos para SES/SP, Ministério da Saúde e Outros Clientes' },
          { id: 'm8-2-2', descricao: 'Desenvolvimento de Novas Tecnologias' },
          { id: 'm8-2-3', descricao: 'Atender a demanda do Ministério da Saúde' }
        ] 
      },
      { 
        id: 'o8-3', 
        titulo: 'Fomentar o desenvolvimento de pesquisas de interesse para o SUS', 
        metas: [
          { id: 'm8-3-1', descricao: 'Elaborar estudos na área de Avaliação de Tecnologias em Saúde (ATS) – Sínteses de Evidências, Pareceres Técnico Científicos (PTC), Avaliação Econômica (AE), Avaliação de Impacto Orçamentário' },
          { id: 'm8-3-2', descricao: 'Número de Projetos de Pesquisas firmados em inovação pelos Núcleos de Inovação Tecnológica (NITs)' },
          { id: 'm8-3-3', descricao: 'Desenvolver projetos de pesquisa que visem atender as demandas do SUS' }
        ] 
      }
    ]
  }
];

export const PROGRAMAS = [
  "EMENDA INDIVIDUAL - CUSTEIO MAC - 2E90",
  "EMENDA INDIVIDUAL - PMAE COMPONENTE CIRURGIA - (PNRF/MUTIRÃO)",
  "PORTARIA 10.169 - PARCELA SUPLEMENTAR - CUSTEIO DA MÉDIA E ALTA COMPLEXIDADE",
  "PORTARIA 10.169 - PARCELA SUPLEMENTAR - PROGRAMA AGORA TEM ESPECIALISTA"
];

export const ACOES_SERVICOS_POR_PROGRAMA: Record<string, AcaoServico[]> = {
  "EMENDA INDIVIDUAL - CUSTEIO MAC - 2E90": [
    {
      categoria: 'ALTA COMPLEXIDADE',
      itens: ['ACIDENTE VASCULAR CEREBRAL', 'CARDIOVASCULAR', 'CENTRO DE QUEIMADOS', 'DEFICIENCIA AUDITIVA', 'DEFORMIDADE CRANIOFACIAL', 'DOENÇAS RARAS', 'HEMODIALISE', 'MAMOGRAFIA MOVEL', 'NEUROCIRURGIA', 'NEUROMUSCULARES', 'OBESIDADE', 'OFTALMOLOGIA', 'ONCO – DIAGNÓSTICO CÂNCER DO COLO DE ÚTERO', 'ONCO – DIAGNÓSTICO DE CÂNCER DE MAMA', 'ONCO - ONCOLOGIA', 'PROCEDIMENTOS CIRURGICOS', 'PROCEDIMENTOS CLINICOS', 'PROCEDIMENTOS COM FINALIDADE DIAGNOSTICA', 'PROCESSO TRANSEXUALIZADOR', 'TERAPIA NUTRICIONAL, ENTERAL E PARENTERAL', 'TERAPIA RENAL SUBSTITUTIVA', 'TRATAMENTO DA LIPOATROFIA FACIAL HIV/AIDS', 'TRAUMATOLOGIA E ORTOPEDIA']
    },
    {
      categoria: 'ATENÇÃO DOMICILIAR',
      itens: ['EQUIPE DE CUIDADOS PALIATIVOS', 'EQUIPE MULTIPROFISSIONAL DE ATENÇÃO DOMICILIAR', 'PROGRAMA MELHOR EM CASA - TELESSAÚDE']
    },
    {
      categoria: 'CENTRAL DE REGULACAO',
      itens: ['CENTRAL DE REGULACAO']
    },
    {
      categoria: 'MÉDIA COMPLEXIDADE',
      itens: ['ORTESES, PROTESES E MATERIAIS ESPECIAIS', 'POLICLINICA/CLÍNICA/CENTRO DE ESPECIALIDADE', 'PROCEDIMENTOS CIRURGICOS', 'PROCEDIMENTOS COM FINALIDADE DIAGNOSTICA', 'PROCEDIMENTOS CLINICOS']
    },
    {
      categoria: 'PESSOA COM DEFICIENCIA',
      itens: ['CER - CENTRO ESPECIALIZADO EM REABILITACAO', 'TRANSPORTE SANITÁRIO ADAPTADO']
    },
    {
      categoria: 'REDE DE URGENCIA',
      itens: ['LEITOS DE RETAGUARDA', 'PORTA DE ENTRADA', 'UPA']
    },
    {
      categoria: 'SAUDE MENTAL',
      itens: ['CAPS - CENTRO DE ATENCAO PSICOSSOCIAL', 'CENTRO DE CONVIVENCIA', 'EQUIPES DE ATENÇÃO PSICOSSOCIAL', 'SERVIÇO RESIDENCIAL TERAPÊUTICO', 'UNIDADE DE ACOLHIMENTO']
    }
  ],
  "EMENDA INDIVIDUAL - PMAE COMPONENTE CIRURGIA - (PNRF/MUTIRÃO)": [
    {
      categoria: 'CARDIOLOGIA',
      itens: ['Cardiologia - Alta Complexidade', 'Cardiologia - Média Complexidade']
    },
    {
      categoria: 'GINECOLOGIA',
      itens: ['Ginecologia - Alta Complexidade', 'Ginecologia - Baixa Complexidade', 'Ginecologia - Média Complexidade']
    },
    {
      categoria: 'OFTALMOLOGIA',
      itens: ['Oftalmologia - Alta Complexidade', 'Oftalmologia - Baixa Complexidade', 'Oftalmologia - Média Complexidade']
    },
    {
      categoria: 'ONCOLOGIA',
      itens: ['Oncologia - Alta Complexidade', 'Oncologia - Baixa Complexidade', 'Oncologia - Média Complexidade']
    },
    {
      categoria: 'ORTOPEDIA',
      itens: ['ORTOPEDIA - Alta Complexidade', 'ORTOPEDIA - Baixa Complexidade', 'ORTOPEDIA - Média Complexidade']
    },
    {
      categoria: 'ONCOLOGIA OU OUTROS',
      itens: ['Oncologia ou Outros - Alta Complexidade', 'Oncologia ou Outros - Média Complexidade']
    },
    {
      categoria: 'OTORRINOLARINGOLOGIA',
      itens: ['Otorrinolaringologia - Alta Complexidade', 'Otorrinolaringologia - Baixa Complexidade', 'Otorrinolaringologia - Média Complexidade']
    },
    {
      categoria: 'OUTRAS CIRURGIAS',
      itens: ['Outras Cirurgias - Alta Complexidade', 'Outras Cirurgias - Baixa Complexidade', 'Outras Cirurgias - Média Complexidade']
    },
    {
      categoria: 'OFERTAS DE CUIDADOS INTEGRADOS - OCI',
      itens: ['OCI em Cardiologia', 'OCI em Ginecologia', 'OCI em Oftalmologia', 'OCI em Oncologia', 'OCI em Ortopedia', 'OCI em Otorrinolaringologia']
    }
  ],
  "PORTARIA 10.169 - PARCELA SUPLEMENTAR - CUSTEIO DA MÉDIA E ALTA COMPLEXIDADE": [
    {
      categoria: 'III - REDE ALYNE',
      itens: [
        'Casa da Gestante, Bebê e Puerpéra (CGBP)',
        'Centro de Parto Normal (CPN)',
        'Parto e Nascimento Alto Risco',
        'Parto e Nascimento Baixo Risco',
        'Pré-Natal de Alto Risco',
        'Seguimento do RN e Criança de Risco',
        'Unidades Neonatais'
      ]
    },
    {
      categoria: 'IV - POLÍTICA NACIONAL DE PREVENÇÃO E CONTROLE DE CÂNCER',
      itens: [
        'Anatomia Patológica - Anticorpos para Imunoistoquímica',
        'Anatomia Patológica - Reagentes em Geral',
        'Cirurgia Oncológica - Material para Cirurgia Videolaparoscópica',
        'Medicina Nuclear - Diagnóstico em Oncologia',
        'Medicina Nuclear - Radiofármacos',
        'Medicina Nuclear - Teranóstico',
        'Quimioterapia - Custeio para Infusão',
        'Quimioterapia - Custeio para Quimioterápicos e Agentes Antineoplásicos Padronizados na CONITEC',
        'Radiointervenção - Material para Drenagem Biliar Percutânea',
        'Radiointervenção - Material para Nefrostomia',
        'Radiointervenção - Material para Radioablação',
        'Radioterapia - Custeio de Procedimentos em Radioterapia',
        'Radioterapia - Custeio para o Transporte Sanitário',
        'Radioterapia - Tratamento Fora de Domicílio',
        'Reabilitação – Próteses'
      ]
    },
    {
      categoria: 'VI - CUSTEIO DE OUTRAS AÇÕES DA MÉDIA E ALTA COMPLEXIDADE',
      itens: [
        'Alta Complexidade',
        'Atenção Domiciliar',
        'Central de Regulação',
        'Média Complexidade',
        'Outros - Apresentar Justificativa',
        'Pessoa com Deficiência',
        'Rede Materna Infantil',
        'Rede de Urgência',
        'SAMU',
        'Saúde Mental',
        'Saúde do Trabalhador',
        'Unidade Coronariana',
        'Unidade de Cuidados Prolongados',
        'Unidade de Terapia Intensiva'
      ]
    }
  ],
  "PORTARIA 10.169 - PARCELA SUPLEMENTAR - PROGRAMA AGORA TEM ESPECIALISTA": [
    {
      categoria: 'I - PROGRAMA AGORA TEM ESPECIALISTA - COMPONENTE AMBULATORIAL',
      itens: [
        'OCI em Cardiologia',
        'OCI em Ginecologia',
        'OCI em Oftalmologia',
        'OCI em Oncologia',
        'OCI em Ortopedia',
        'OCI em Otorrinolaringologia'
      ]
    },
    {
      categoria: 'II - PROGRAMA AGORA TEM ESPECIALISTA - COMPONENTE CIRÚRGICO',
      itens: [
        'Cardiologia - Alta Complexidade',
        'Cardiologia - Média Complexidade',
        'Ginecologia - Alta Complexidade',
        'Ginecologia - Baixa Complexidade',
        'Ginecologia - Média Complexidade',
        'Oftalmologia - Alta Complexidade',
        'Oftalmologia - Baixa Complexidade',
        'Oftalmologia - Média Complexidade',
        'Oncologia - Alta Complexidade',
        'Oncologia - Baixa Complexidade',
        'Oncologia - Média Complexidade',
        'Oncologia ou Outros - Alta Complexidade',
        'Oncologia ou Outros - Média Complexidade',
        'Ortopédia - Alta Complexidade',
        'Ortopédia - Baixa Complexidade',
        'Ortopédia - Média Complexidade',
        'Otorrinolaringologia - Alta Complexidade',
        'Otorrinolaringologia - Baixa Complexidade',
        'Otorrinolaringologia - Média Complexidade',
        'Outras Cirurgias - Alta Complexidade',
        'Outras Cirurgias - Baixa Complexidade',
        'Outras Cirurgias - Média Complexidade'
      ]
    },
    {
      categoria: 'VI - CUSTEIO DE OUTRAS AÇÕES DA MÉDIA E ALTA COMPLEXIDADE',
      itens: [
        'Alta Complexidade',
        'Atenção Domiciliar',
        'Central de Regulação',
        'Média Complexidade',
        'Outros - Apresentar Justificativa',
        'Pessoa com Deficiência',
        'Rede Materna Infantil',
        'Rede de Urgência',
        'SAMU',
        'Saúde Mental',
        'Saúde do Trabalhador',
        'Unidade Coronariana',
        'Unidade de Cuidados Prolongados',
        'Unidade de Terapia Intensiva'
      ]
    }
  ]
};

export const METAS_QUALITATIVAS_OPTIONS = [
  'ADEQUAÇÃO DE AMBIÊNCIA',
  'ADOÇÃO DE POLÍTICAS DE HUMANIZAÇÃO',
  'APERFEIÇOAMENTO DE PRÁTICAS',
  'CONDIÇÕES DE FUNCIONAMENTO DAS UNIDADES',
  'CORRETO FUNCIONAMENTO DAS COMISSÕES HOSPITALARES',
  'IMPLANTAÇÃO DE PROTOCOLOS',
  'MÉDIA DE PERMANÊNCIA',
  'SATISFAÇÃO DO USUÁRIO',
  'TAXA DE OCUPAÇÃO',
  'TEMPO MÉDIO DE REALIZAÇÃO DE PROCEDIMENTOS'
];

export const NATUREZAS_DESPESA: NaturezaDespesa[] = [
  { codigo: '339004', descricao: 'CONTRATACAO POR TEMPO DETERMINADO - PES.CIVIL' },
  { codigo: '339092', descricao: 'DESPESAS DE EXERCICIOS ANTERIORES' },
  { codigo: '339037', descricao: 'LOCACAO DE MAO-DE-OBRA' },
  { codigo: '339030', descricao: 'MATERIAL DE CONSUMO' },
  { codigo: '339039', descricao: 'OUTROS SERVICOS DE TERCEIROS-PESSOA JURIDICA' },
  { codigo: '339033', descricao: 'PASSAGENS E DESPESAS COM LOCOMOÇÃO' },
  { codigo: '339040', descricao: 'SERVICOS DE TECNOLOGIA DA INFORMACAO E COMUNICACAO - PESSOA JURIDICA' },
  { codigo: '335043', descricao: 'SUBVENCOES SOCIAIS' },
  { codigo: '335085', descricao: 'TRANSFERENCIAS POR MEIO DE CONTRATO DE GESTAO' }
];
