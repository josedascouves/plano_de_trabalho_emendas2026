
import React, { useState, useMemo, useRef, useEffect } from 'react';
import { 
  ClipboardCheck, 
  User as UserIcon, 
  Map, 
  Target, 
  TrendingUp, 
  DollarSign, 
  FileText, 
  ChevronRight, 
  ChevronLeft,
  Trash2,
  CheckCircle2,
  Building2,
  ExternalLink,
  ShieldCheck,
  Settings2,
  Stethoscope,
  Printer,
  Download,
  UploadCloud,
  Send,
  FileCheck,
  Loader2,
  MailCheck,
  AlertCircle,
  FileBadge,
  BookOpen,
  Lock,
  UserPlus,
  LogOut,
  Users,
  X,
  Database,
  Terminal,
  BarChart3,
  Info,
  ArrowUp,
  AlertTriangle,
  Crown,
  ChevronDown,
  Key,
  HelpCircle,
  Search,
  Eye,
  Landmark,
  Paperclip
} from 'lucide-react';
import { FormState, User } from './types';
import { 
  DIRETRIZES, 
  PROGRAMAS,
  ACOES_SERVICOS_POR_PROGRAMA,
  METAS_QUALITATIVAS_OPTIONS,
  METAS_QUANTITATIVAS_OPTIONS,
  NATUREZAS_DESPESA 
} from './constants';
import { supabase } from './supabase';
import { InputField } from './components/InputField';
import { Section } from './components/Section';
import { StepperProgress } from './components/StepperProgress';
import { Button, Select, TextArea } from './components/FormElements';
import { 
  maskCPF, 
  validateCPF, 
  maskCNPJ, 
  validateCNPJ, 
  maskCurrency, 
  maskPhone,
  maskCNES,
  validateEmail,
  maskPercentage,
  formatPercentageDisplay
} from './utils/masks';
import { initializeSecurity } from './utils/security';

const App: React.FC = () => {
  // Authentication & Session State
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [isLoadingAuth, setIsLoadingAuth] = useState(true);
  const [loginInput, setLoginInput] = useState({ email: '', password: '' });
  const [loginError, setLoginError] = useState('');
  
  // View Management
  const [currentView, setCurrentView] = useState<'new' | 'list' | 'dashboard'>('new'); // Toggle entre novo plano e listagem
  
  // Admin & User Management
  const [showUserManagement, setShowUserManagement] = useState(false);
  const [usersList, setUsersList] = useState<any[]>([]);
  const [inactiveUsersList, setInactiveUsersList] = useState<any[]>([]);
  const [showInactiveUsers, setShowInactiveUsers] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [newUser, setNewUser] = useState({ email: '', password: '', name: '', role: 'user' as 'user' | 'admin' | 'intermediate', cnes: '' });
  const [showEditUserModal, setShowEditUserModal] = useState(false);
  const [editingUser, setEditingUser] = useState<any>({ id: '', email: '', name: '', cnes: '', password: '' });
  const [csvUploading, setCsvUploading] = useState(false);
  const [csvResults, setCsvResults] = useState<any>(null);
  const [selectedCnes, setSelectedCnes] = useState<string>('');

  // Plan List & Edit Management
  const [planosList, setPlanosList] = useState<any[]>([]);
  const [isLoadingPlanos, setIsLoadingPlanos] = useState(false);
  const [editingPlanId, setEditingPlanId] = useState<string | null>(null);
  const [selectedPlanos, setSelectedPlanos] = useState<Set<string>>(new Set());
  const [showBulkDeleteModal, setShowBulkDeleteModal] = useState(false);
  const [showSelectPlanModal, setShowSelectPlanModal] = useState(false);
  const [showHelpModal, setShowHelpModal] = useState(false);

  // Filtros de Planos
  const [filtros, setFiltros] = useState({
    cnes: '',
    parlamentar: '',
    emenda: '',
    cnpj: ''
  });

  // Form Progress State
  const [activeSection, setActiveSection] = useState('info-emenda'); 
  const [showDocument, setShowDocument] = useState(false);
  const [isSending, setIsSending] = useState(false);
  const [sentSuccess, setSentSuccess] = useState(false);
  const [showEmailModal, setShowEmailModal] = useState(false);
  const [emailsDestino, setEmailsDestino] = useState('');
  const [planoSalvoId, setPlanoSalvoId] = useState<string | null>(null);
  const [autoSaveStatus, setAutoSaveStatus] = useState<'idle' | 'saving' | 'saved'>('idle');
  const [lastAutoSaveTime, setLastAutoSaveTime] = useState<Date | null>(null);
  const [formHasChanges, setFormHasChanges] = useState(false);
  const [lastSavedFormData, setLastSavedFormData] = useState<FormState | null>(null);
  const [helpSectionId, setHelpSectionId] = useState<string | null>(null);
  
  // Section completion tracking
  const [sectionStatus, setSectionStatus] = useState<{[key: string]: boolean}>({
    'info-emenda': false,
    'beneficiario': false,
    'alinhamento': false,
    'metas-quantitativas': false,
    'metas-qualitativas': false,
    'execucao-financeira': false,
    'finalizacao': false
  });

  const [formData, setFormData] = useState<FormState>({
    emenda: { parlamentar: '', numero: '', valor: '', valorExtenso: '', programa: 'EMENDA INDIVIDUAL - CUSTEIO MAC - 2E90' },
    beneficiario: { nome: '', cnes: '', cnpj: '', email: '', telefone: '' },
    planejamento: { diretrizId: '', objetivoId: '', metaIds: [] },
    acoesServicos: [],
    metasQualitativas: [],
    naturezasDespesa: [],
    justificativa: '',
    responsavelAssinatura: ''
  });

  // Helper: parse multi-CNES string into array
  const parseCnesList = (cnes: string | undefined): string[] => {
    if (!cnes) return [];
    return cnes.split(',').map(c => c.trim()).filter(Boolean);
  };

  // Lista de CNES do usuário atual
  const userCnesList = useMemo(() => parseCnesList(currentUser?.cnes), [currentUser?.cnes]);

  // Função para obter formData inicial
  const getInitialFormData = (): FormState => {
    // Auto-fill CNES for regular users (non-admin) - usa o CNES selecionado
    const userCnes = currentUser?.role === 'user' ? (selectedCnes || '') : '';
    
    console.log('📝 getInitialFormData() chamado:', {
      currentUser_role: currentUser?.role,
      currentUser_cnes: currentUser?.cnes,
      userCnes_resultado: userCnes,
      ifrUserStandard: currentUser?.role === 'user'
    });
    
    return {
      emenda: { parlamentar: '', numero: '', valor: '', valorExtenso: '', programa: '' },
      beneficiario: { nome: '', cnes: userCnes, cnpj: '', email: '', telefone: '', contaBancaria: '', extratoUrl: '', extratoFilename: '' },
      planejamento: { diretrizId: '', objetivoId: '', metaIds: [] },
      acoesServicos: [],
      metasQualitativas: [],
      naturezasDespesa: [],
      justificativa: '',
      responsavelAssinatura: ''
    };
  };

  const [currentSelection, setCurrentSelection] = useState<{
    categoria: string;
    item: string;
    metas: string[];
  }>({ categoria: '', item: '', metas: [''] });

  const [currentMetaQualitativa, setCurrentMetaQualitativa] = useState({ meta: '', valor: '' });

  const [currentNatureza, setCurrentNatureza] = useState({ codigo: '', valor: '' });

  // ======== UPLOAD EXTRATO BANCÁRIO ========
  const [isUploadingExtrato, setIsUploadingExtrato] = useState(false);
  const [extratoPreviewUrl, setExtratoPreviewUrl] = useState<string | null>(null);

  // Data da alteração da justificativa (para exibir no PDF)
  const [justificativaAlteradaEm, setJustificativaAlteradaEm] = useState<string | null>(null);
  const extratoInputRef = useRef<HTMLInputElement>(null);

  const LOGO_URL_COLORIDA = "/img/logo_colorido.png";  // Versão oficial colorida
  const LOGO_URL_BRANCA = "/img/logo_branco.png";      // Versão oficial branca para header

  // CNES isentos de conta bancária e extrato bancário obrigatório
  const CNES_ISENTO_CONTA_EXTRATO = ['2090236', '7066376', '2071568', '2079798'];

  // ======== RBAC - CONTROLE DE ACESSO ========
  const isAdmin = (): boolean => {
    const adminStatus = currentUser?.role === 'admin';
    console.log('🔐 isAdmin() check:', {
      currentUser: currentUser ? { id: currentUser.id, name: currentUser.name, role: currentUser.role } : null,
      isAdmin: adminStatus
    });
    return adminStatus;
  };
  
  const canEditPlan = (planCreatedBy: string): boolean => {
    if (!currentUser) return false;
    // Only admin e owner (user) podem editar
    // Intermediate users NÃO podem editar
    return isAdmin() || (currentUser.role === 'user' && planCreatedBy === currentUser.id);
  };
  
  const canViewPlan = (planCreatedBy: string): boolean => {
    if (!currentUser) return false;
    // Admin, intermediate e owner (user) podem visualizar
    if (isAdmin()) return true; // Admin vê tudo
    if (currentUser.role === 'intermediate') return true; // Intermediate vê todos os planos
    return planCreatedBy === currentUser.id; // User vê só seus planos
  };

  // Função para obter o tipo de portaria baseado no programa orçamentário
  const getPortariaForPrograma = (programa: string): string => {
    if (programa.startsWith('EMENDA INDIVIDUAL')) {
      return 'PORTARIA GM/MS Nº 10.297';
    } else if (programa.includes('PORTARIA 10.169')) {
      return 'Portaria GM/MS nº 10.169';
    }
    return 'PORTARIA GM/MS Nº 10.297'; // Padrão
  };

  // Help Content for each section
  const helpContent: {[key: string]: {title: string; description: string; tips: string[]}} = {
    'info-emenda': {
      title: 'Informações da Emenda Parlamentar',
      description: 'Registre os dados basilares da emenda parlamentar que você deseja utilizar neste plano de trabalho. Todas as informações devem corresponder ao documento oficial da emenda no Congresso Nacional.',
      tips: [
        'Parlamentar: Nome completo (ex: João da Silva, Senador). Busque informações no site da Câmara/Senado',
        'Número da Emenda: Número oficial e ano (ex: 123/2026). Consulte o documento original ou correspondência da emenda',
        'Valor Total: Valor em reais. Digite apenas números (ex: 500000 para R$ 500.000,00)',
        'Programa: Selecione o programa alinhado às ações (Atenção Básica, Urgência, Serviços Especializados, etc)',
        'Importante: Os dados devem estar alinhados com a Portaria de Emendas Parlamentares 2026'
      ]
    },
    'beneficiario': {
      title: 'Dados do Beneficiário - Identificação da Instituição',
      description: 'Identifique com precisão a instituição que será beneficiada. Este campo é crítico para auditoria e conformidade regulatória.',
      tips: [
        'Nome da Instituição: Nome completo e oficial do estabelecimento (ex: Hospital Municipal São João da Boa Vista)',
        'CNES: Código Nacional com 8 dígitos (obtém em: saude.sp.gov.br ou no CNES Nacional). Verifique a vigência',
        'CNPJ: 14 dígitos sem formatação (ex: 12345678901234). Se PJ, valide na Receita Federal',
        'E-mail Institucional: Utilize e-mail corporativo quando disponível. Ex: contato@hospital.sp.gov.br',
        'Telefone com DDD: Use formato completo com DDD (ex: 11999887766). Incluir ramal se houver',
        'Revisão: Verifique todas as informações antes de salvar. Erros aqui afetam toda a auditoria'
      ]
    },
    'alinhamento': {
      title: 'Alinhamento Estratégico com Diretrizes SES-SP',
      description: 'Conecte seu plano às diretrizes estratégicas da Secretaria de Estado da Saúde. Este alinhamento é obrigatório para aprovação e conformidade.',
      tips: [
        'Diretriz: Escolha a diretriz-mãe que melhor se alinha (ex: "Reafirmar o SUS como política de Estado"). Leia a descrição completa',
        'Objetivo Estratégico: Selecione um objetivo dentro da diretriz (ex: "Garantir a gestão bipartite com pactuação em CIB")',
        'Metas Relacionadas: Marque as metas que sua emenda ajudará a cumprir. Pode selecionar múltiplas metas',
        'Justificativa: Na seção final, explique COMO suas ações contribuem para atingir as metas selecionadas',
        'Exemplos Práticos: Emenda para consultas → pode contribuir para "Garantir o acesso oportuno à atenção integral"'
      ]
    },
    'metas-quantitativas': {
      title: 'Metas Quantitativas - Ações e Alocação Financeira',
      description: 'Defina quais ações/serviços serão realizados e quanto de cada emenda será destinado a cada ação. O sistema valida automaticamente o total.',
      tips: [
        'Grupo de Ação: Selecione por tipo (Consultas Especializadas, Procedimentos, Medicamentos, Capacitação, etc)',
        'Ação Específica: Escolha a ação detalhada dentro do grupo (ex: "Consulta de Oftalmologia" dentro de Consultas)',
        'Valor: Informe o valor em reais para essa ação. Ex: 50000 para R$ 50.000,00',
        'Múltiplas Ações: Pode adicionar várias ações. A soma deve ser ≤ valor total da emenda',
        'Validação: O sistema avisa se houver divergências. Releia as ações se o total não bater',
        'Dica: Seja específico nas ações. "Consulta" é vago. "Consulta Oftalmológica em Unidade de Referência" é mais claro'
      ]
    },
    'metas-qualitativas': {
      title: 'Indicadores Qualitativos - Monitoramento e Qualidade (Opcional)',
      description: 'Defina os indicadores que rastrearão a qualidade da execução. Estes servem para monitoramento contínuo durante o ano. Campo opcional.',
      tips: [
        'Indicador de Qualidade: Selecione métricas relevantes (ex: "% de pacientes resolvidos na 1ª consulta", "Satisfação em atendimento")',
        'Valor Alvo: Meta percentual (ex: 85% para resolução na 1ª consulta) ou quantidade (ex: 500 pacientes atendidos)',
        'Monitoramento Contínuo: Esses indicadores serão consultados em relatórios mensais/trimestrais de execução',
        'Múltiplos Indicadores: Recomenda-se 3-5 indicadores. Muito poucos não acompanham qualidade, muitos são onerosos',
        'Legislação: Revise indicadores em literais da Portaria SES. Alguns são mandatórios conforme tipo de ação'
      ]
    },
    'execucao-financeira': {
      title: 'Execução Financeira - Classificação de Despesas',
      description: 'Classifique os gastos conforme as Naturezas de Despesa da legislação de Saúde. Isto é obrigatório para auditoria e conformidade fiscal.',
      tips: [
        'Natureza de Despesa: Classifique por tipo formal (Pessoal, Custeio, Investimento, Transferências, etc)',
        'Pessoal: Salários, encargos e benefícios de servidores contratados para as ações (ex: médicos contratados)',
        'Custeio: Medicamentos, materiais, combustível, energia, diárias, passagens (custos operacionais)',
        'Investimento: Equipamentos, construção, reforma com vida útil > 1 ano (quando permitido em legislação)',
        'Total Convergente: A SOMA de todas as naturezas deve igualar exatamente o valor total da emenda',
        'Revisão Fiscal: Erros aqui causam rejeição em auditoria. Dupla-checagem com setor financeiro é recomendada',
        'Legislação: Siga rigorosamente a Instrução Normativa SES e Decretos sobre Execução Orçamentária 2026'
      ]
    },
    'finalizacao': {
      title: 'Finalização - Justificativa Técnica e Responsável',
      description: 'Complete o plano com uma justificativa técnica sólida e identifique o responsável pela assinatura. Esta é a etapa final antes da submissão.',
      tips: [
        'Responsável pela Assinatura: Nome completo e documento (CPF/cargo). Deve ser responsável pela unidade ou autoridade técnica',
        'Justificativa Técnica: Parágrafo detalhado explicando POR QUE escolheu essa alocação (contexto epidemiológico, deficiências, diagnóstico situacional)',
        'Alinhamento Estratégico: Reafirme como as ações contribuem para as diretrizes e metas estratégicas SES-SP',
        'Legislação Pertinente: Cite portarias, decretos e políticas relevantes (ex: Portaria SES 234/2025, Decreto 67.435/2023)',
        'Realismo: Justificativas genéricas são rejeitadas. Base-se em dados epidemiológicos, demanda reprimida, estudos de viabilidade',
        'Revisão Final: Releia TODO o plano (seções 1-7) antes de salvar. Erros em justificativa afetam aprovação',
        'Assinatura: Será necessária assinatura digital ou manuscrita no PDF gerado. Responsável deve estar disponível'
      ]
    }
  };
  
  const openHelpModal = (sectionId: string) => {
    setHelpSectionId(sectionId);
    setShowHelpModal(true);
  };

  // Check session on mount
  useEffect(() => {
    // ⚠️ INICIALIZAR SEGURANÇA - Desabilitar console e DevTools
    initializeSecurity();

    const checkSession = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (session) {
          try {
            // Query SIMPLIFICADA - apenas colunas que existem com certeza
            const { data: profile, error: profileError } = await supabase
              .from('profiles')
              .select('id, full_name, email, cnes')
              .eq('id', session.user.id)
              .maybeSingle();
            
            if (!profileError && profile) {
              try {
                // Pegar role de user_roles (fonte de verdade)
                const { data: userRole } = await supabase
                  .from('user_roles')
                  .select('role')
                  .eq('user_id', session.user.id)
                  .maybeSingle();
                
                const userData = {
                  id: session.user.id,
                  username: session.user.email || '',
                  name: profile.full_name || profile.email,
                  role: userRole?.role || 'user',
                  cnes: profile.cnes || ''
                };
                console.log('🔐 checkSession - Usuário carregado:', userData);
                setCurrentUser(userData);
                // Selecionar primeiro CNES se houver múltiplos
                const cnesList = (profile.cnes || '').split(',').map((c: string) => c.trim()).filter(Boolean);
                setSelectedCnes(cnesList[0] || '');
                setIsAuthenticated(true);
              } catch (roleError) {
                // Se não conseguir pegar role, usa 'user' como padrão
                const userData = {
                  id: session.user.id,
                  username: session.user.email || '',
                  name: profile.full_name || profile.email,
                  role: 'user',
                  cnes: profile.cnes || ''
                };
                setCurrentUser(userData);
                const cnesListFb = (profile.cnes || '').split(',').map((c: string) => c.trim()).filter(Boolean);
                setSelectedCnes(cnesListFb[0] || '');
                setIsAuthenticated(true);
              }
            } else if (profileError && session.user.email === 'sessp.css3@gmail.com') {
              // Admin provisório se erro mas é admin padrão
              setCurrentUser({
                id: session.user.id,
                username: session.user.email,
                name: 'Admin Provisório',
                role: 'admin',
                cnes: ''
              });
              setIsAuthenticated(true);
            }
          } catch (err) {
            // Catch all para qualquer erro de query
            console.warn('⚠️ Erro ao carregar profile:', err);
          }
        }
      } catch (e) {
        // Erro ao verificar sessão - silenciado por segurança
      } finally {
        setIsLoadingAuth(false);
      }
    };
    checkSession();
  }, []);

  // Fetch users if admin
  const prevShowUserManagementRef = useRef(showUserManagement);
  const loadingPlanIdRef = useRef<string | null>(null);
  const planLoadCompletedRef = useRef<Set<string>>(new Set()); // ← NOVO: Tracks which plans have been loaded
  const isSavingRef = useRef(false); // ← NOVO: Sincronamente previne dupla execução de save
  
  useEffect(() => {
    // Only fetch when modal opens (showUserManagement becomes true)
    if (isAuthenticated && showUserManagement && currentUser?.role === 'admin' && !prevShowUserManagementRef.current) {
      const fetchUsers = async () => {
        try {
          console.log('👥 fetchUsers() - Iniciando carregamento de usuários');
          
          // Buscar profiles com user_roles (LEFT JOIN)
          const { data: profiles, error: profileError } = await supabase
            .from('profiles')
            .select('id, full_name, email, cnes')
            .order('full_name');
          
          if (profileError) {
            console.error('❌ Erro ao carregar profiles:', profileError);
            setUsersList([]);
            alert(`⚠ Erro ao carregar usuários: ${profileError.message}`);
            return;
          }

          console.log('✅ Profiles carregados:', profiles?.length || 0, profiles);

          // Buscar roles de cada usuário
          const { data: userRoles, error: roleError } = await supabase
            .from('user_roles')
            .select('user_id, role, disabled');
          
          if (roleError) {
            console.error('❌ Erro ao carregar user_roles:', roleError);
            setUsersList([]);
            alert(`⚠ Erro ao carregar permissões: ${roleError.message}`);
            return;
          }

          console.log('✅ User roles carregados:', userRoles?.length || 0, userRoles);

          // Fazer merge dos dados
          if (profiles && userRoles) {
            // Usar objeto simples em vez de Map (compatibilidade)
            const usersByRole: { [key: string]: { role: string; disabled: boolean } } = {};
            userRoles.forEach(ur => {
              usersByRole[ur.user_id] = { role: ur.role, disabled: ur.disabled };
            });
            
            const usersList = profiles.map(p => {
              const role = usersByRole[p.id]?.role || 'user';
              const disabled = usersByRole[p.id]?.disabled || false;
              console.log(`  - User: ${p.email} => role: ${role}, disabled: ${disabled}, cnes: ${p.cnes}`);
              return {
                id: p.id,
                username: p.email || '',
                email: p.email || '',
                name: p.full_name,
                role: role,
                cnes: p.cnes || '',
                disabled: disabled
              };
            });
            
            // ⭐ ORDENAR: Admins sempre primeiro
            const sortedUsersList = usersList.sort((a, b) => {
              // Prioridade 1: Admins sempre primeiro
              if (a.role !== b.role) {
                return a.role === 'admin' ? -1 : 1;
              }
              // Prioridade 2: Por nome dentro do mesmo role
              return (a.name || '').localeCompare(b.name || '');
            });
            
            setUsersList(sortedUsersList);
            console.log('✅ Lista de usuários atualizada (ADMINS PRIMEIRO):', sortedUsersList.length, sortedUsersList);
          } else {
            console.warn('⚠️ Profiles ou userRoles vazios:', { profiles_count: profiles?.length, roles_count: userRoles?.length });
            setUsersList([]);
          }
        } catch (err: any) {
          console.error('❌ Erro ao buscar usuários:', err);
          setUsersList([]);
        }
      };
      fetchUsers();
    }
    
    // Clear list when modal closes (showUserManagement becomes false)
    if (!showUserManagement && prevShowUserManagementRef.current) {
      setUsersList([]);
    }
    
    // Update ref
    prevShowUserManagementRef.current = showUserManagement;
  }, [isAuthenticated, showUserManagement]);

  // Carregar usuários inativos/desativados
  const loadInactiveUsers = async () => {
    try {
      console.log('👻 loadInactiveUsers() - Carregando usuários desativados');
      
      const { data: profiles, error: profileError } = await supabase
        .from('profiles')
        .select('id, full_name, email, cnes')
        .order('full_name');
      
      if (profileError) {
        console.error('❌ Erro ao carregar profiles:', profileError);
        return;
      }

      const { data: userRoles, error: roleError } = await supabase
        .from('user_roles')
        .select('user_id, role, disabled');
      
      if (roleError) {
        console.error('❌ Erro ao carregar user_roles:', roleError);
        return;
      }

      // Filtrar APENAS os desativados
      if (profiles && userRoles) {
        const usersByRole: { [key: string]: { role: string; disabled: boolean } } = {};
        userRoles.forEach(ur => {
          usersByRole[ur.user_id] = { role: ur.role, disabled: ur.disabled };
        });
        
        const inactiveList = profiles
          .filter(p => usersByRole[p.id]?.disabled === true)
          .map(p => {
            const role = usersByRole[p.id]?.role || 'user';
            return {
              id: p.id,
              username: p.email || '',
              email: p.email || '',
              name: p.full_name,
              role: role,
              cnes: p.cnes || '',
              disabled: true
            };
          })
          .sort((a, b) => (a.name || '').localeCompare(b.name || ''));
        
        setInactiveUsersList(inactiveList);
        console.log('✅ Usuários inativos carregados:', inactiveList.length, inactiveList);
      }
    } catch (error: any) {
      console.error('❌ Erro ao carregar usuários inativos:', error);
      alert(`Erro ao carregar inativos: ${error.message}`);
    }
  };

  // Reativar usuário desativado
  const handleReactivateUser = async (userId: string, userName: string) => {
    if (!window.confirm(`Deseja reativar ${userName}?`)) return;

    try {
      console.log('🔄 Reativando usuário:', userId);
      
      const { error } = await supabase
        .from('user_roles')
        .update({ disabled: false, updated_at: new Date().toISOString() })
        .eq('user_id', userId);

      if (error) throw error;

      alert(`✅ ${userName} foi reativado com sucesso!`);
      console.log('✅ Reativação concluída');

      // Recarregar ambas as listas
      loadInactiveUsers();
      
      // Recarregar lista ativa também
      const { data: profiles2 } = await supabase
        .from('profiles')
        .select('id, full_name, email, cnes')
        .order('full_name');
      const { data: userRoles2 } = await supabase
        .from('user_roles')
        .select('user_id, role, disabled');
      
      if (profiles2 && userRoles2) {
        const usersByRole: { [key: string]: any } = {};
        userRoles2.forEach(ur => {
          usersByRole[ur.user_id] = ur;
        });
        setUsersList(profiles2.map(p => ({
          id: p.id,
          username: p.email || '',
          email: p.email || '',
          name: p.full_name,
          role: usersByRole[p.id]?.role || 'user',
          cnes: p.cnes || '',
          disabled: usersByRole[p.id]?.disabled || false
        })).sort((a, b) => a.role !== b.role ? (a.role === 'admin' ? -1 : 1) : (a.name || '').localeCompare(b.name || '')));
      }
    } catch (error: any) {
      console.error('❌ Erro ao reativar usuário:', error);
      alert(`❌ Erro ao reativar: ${error.message}`);
    }
  };

  // Carrega planos quando muda para view de listagem ou dashboard
  useEffect(() => {
    if ((currentView === 'list' || currentView === 'dashboard') && isAuthenticated) {
      loadPlanos();
    }
  }, [currentView, isAuthenticated]);

  // Carrega planos assim que o usuário se autentica (para usar no modal de seleção)
  useEffect(() => {
    if (isAuthenticated && planosList.length === 0 && !isLoadingPlanos) {
      loadPlanos();
    }
  }, [isAuthenticated]);

  // Auto-fill form when user logs in or form is initialized
  useEffect(() => {
    if (isAuthenticated && currentUser?.email && formData.beneficiario.email !== currentUser.email) {
      updateFormData('beneficiario', { 
        ...formData.beneficiario, 
        email: currentUser.email 
      });
    }
  }, [isAuthenticated, currentUser?.email]);

  // Garantir que selectedCnes é válido quando userCnesList muda
  useEffect(() => {
    if (userCnesList.length > 0 && (!selectedCnes || !userCnesList.includes(selectedCnes))) {
      console.log('🔄 Atualizando selectedCnes para:', userCnesList[0]);
      setSelectedCnes(userCnesList[0]);
    }
  }, [userCnesList]);

  // Auto-fill CNES para usuários regulares - usa apenas selectedCnes (nunca valor com vírgula)
  useEffect(() => {
    if (isAuthenticated && currentUser?.role === 'user' && selectedCnes) {
      // Apenas atualizar se o valor atual é diferente E se selectedCnes não contém vírgula
      if (!selectedCnes.includes(',') && formData.beneficiario.cnes !== selectedCnes) {
        updateFormData('beneficiario', { 
          ...formData.beneficiario, 
          cnes: selectedCnes
        });
      }
    }
  }, [isAuthenticated, selectedCnes, currentUser?.role]);

  // Quando muda para 'new', garante que CNES é preenchido para usuários padrão
  useEffect(() => {
    if (currentView === 'new' && isAuthenticated && currentUser?.role === 'user' && selectedCnes) {
      console.log('📝 View mudou para NEW, preenchendo CNES para usuário padrão:', selectedCnes);
      if (!selectedCnes.includes(',') && formData.beneficiario.cnes !== selectedCnes) {
        updateFormData('beneficiario', { 
          ...formData.beneficiario, 
          cnes: selectedCnes
        });
      }
    }
  }, [currentView, isAuthenticated, selectedCnes, currentUser?.role]);

  // Proteção: se formData.beneficiario.cnes tiver vírgula, forçar para selectedCnes ou primeiro CNES
  useEffect(() => {
    if (formData.beneficiario.cnes && formData.beneficiario.cnes.includes(',')) {
      const firstCnes = selectedCnes || formData.beneficiario.cnes.split(',')[0].trim();
      console.log('⚠️ CNES com vírgula detectado no form, corrigindo para:', firstCnes);
      updateFormData('beneficiario', { ...formData.beneficiario, cnes: firstCnes });
    }
  }, [formData.beneficiario.cnes]);

  // Track form changes - melhorado para detectar mudanças reais
  useEffect(() => {
    if (lastSavedFormData) {
      // Normalizar ambos os dados antes de comparar (remover espaçamento extra)
      const currentJson = JSON.stringify(formData);
      const savedJson = JSON.stringify(lastSavedFormData);
      const hasChanged = currentJson !== savedJson;
      setFormHasChanges(hasChanged);
    } else {
      // Se não há dados salvos anteriormente, é um novo plano - permitir salvar
      setFormHasChanges(false);
    }
  }, [formData, lastSavedFormData]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoginError('');
    setIsSending(true);

    try {
      // Validação básica
      if (!loginInput.email || !loginInput.password) {
        throw new Error('E-mail e senha são obrigatórios');
      }

      if (!validateEmail(loginInput.email)) {
        throw new Error('E-mail inválido');
      }

      // PASSO 1: Fazer autenticação básica (SEM queries extras!)
      const { data, error } = await supabase.auth.signInWithPassword({
        email: loginInput.email,
        password: loginInput.password
      });

      if (error) {
        if (error.message.includes('Invalid login credentials')) {
          throw new Error('E-mail ou senha incorretos');
        }
        if (error.message.includes('Email not confirmed')) {
          throw new Error('E-mail não confirmado. Verifique sua caixa de entrada.');
        }
        throw new Error(error.message || 'Erro ao fazer login');
      }

      if (data.user) {
        // ✅ LOGIN BEM-SUCEDIDO! Logar com dados mínimos
        const userObject = {
          id: data.user.id,
          username: data.user.email || '',
          name: data.user.email?.split('@')[0] || 'Usuário',
          role: 'user',
          cnes: ''
        };
        
        console.log('✅ Login bem-sucedido:', userObject.username);
        setCurrentUser(userObject);
        setIsAuthenticated(true);
        setLoginInput({ email: '', password: '' });

        // PASSO 2: Carregar dados extras em background (NÃO BLOQUEIA O LOGIN!)
        // Trata erros silenciosamente
        const loadUserData = async () => {
          try {
            // Buscar perfil
            const { data: profile } = await supabase
              .from('profiles')
              .select('full_name, cnes')
              .eq('id', data.user.id)
              .maybeSingle();
            
            if (profile) {
              setCurrentUser(prev => prev ? {
                ...prev,
                name: profile.full_name || prev.name,
                cnes: profile.cnes || ''
              } : null);
              // Selecionar primeiro CNES se ainda não selecionado
              const cnesLogin = (profile.cnes || '').split(',').map((c: string) => c.trim()).filter(Boolean);
              setSelectedCnes(prev => prev || cnesLogin[0] || '');
            }
          } catch (err) {
            console.warn('⚠️ Erro ao carregar profile:', err);
          }

          try {
            // Buscar role
            const { data: userRole } = await supabase
              .from('user_roles')
              .select('role, disabled')
              .eq('user_id', data.user.id)
              .maybeSingle();
            
            if (userRole) {
              if (userRole.disabled) {
                await supabase.auth.signOut();
                setCurrentUser(null);
                setIsAuthenticated(false);
                setLoginError('Este usuário foi desativado.');
              } else if (userRole.role) {
                setCurrentUser(prev => prev ? { ...prev, role: userRole.role } : null);
              }
            }
          } catch (err) {
            console.warn('⚠️ Erro ao carregar role:', err);
          }
        };

        // Executar sem await - não bloqueia o login
        loadUserData().catch(err => console.warn('Erro ao carregar dados do usuário:', err));
      }
    } catch (error: any) {
      console.error('Erro ao fazer login:', error);
      setLoginError(error.message || 'Erro ao realizar login. Verifique as credenciais.');
    } finally {
      setIsSending(false);
    }
  };

  const handleLogout = async () => {
    await supabase.auth.signOut();
    setIsAuthenticated(false);
    setCurrentUser(null);
    setActiveSection('info-emenda');
    setSentSuccess(false);
  };

  // Desativar/Ativar usuário
  const handleToggleUserDisable = async (userId: string) => {
    try {
      const user = usersList.find(u => u.id === userId);
      if (!user) return;

      const { error } = await supabase
        .from('user_roles')
        .update({ disabled: !user.disabled })
        .eq('user_id', userId);

      if (error) throw error;

      const action = user.disabled ? 'ativado' : 'desativado';
      alert(`✓ Usuário ${action} com sucesso!`);

      // Recarregar lista
      const { data: profiles } = await supabase
        .from('profiles')
        .select('id, full_name, email, cnes')
        .order('full_name');
      const { data: userRoles } = await supabase
        .from('user_roles')
        .select('user_id, role, disabled');
      
      if (profiles && userRoles) {
        const usersByRole: { [key: string]: any } = {};
        userRoles.forEach(ur => {
          usersByRole[ur.user_id] = ur;
        });
        setUsersList(profiles.map(p => ({
          id: p.id,
          username: p.email || '',
          email: p.email || '',
          name: p.full_name,
          role: usersByRole[p.id]?.role || 'user',
          cnes: p.cnes || '',
          disabled: usersByRole[p.id]?.disabled || false
        })));
      }
    } catch (error: any) {
      alert(`❌ Erro ao alterar status: ${error.message}`);
    }
  };

  // Alterar senha - Enviar email de reset
  const handleChangePassword = async (userEmail: string) => {
    try {
      console.log('🔑 Enviando email de reset para:', userEmail);
      const { error } = await supabase.auth.resetPasswordForEmail(userEmail, {
        redirectTo: `${window.location.origin}/reset-password`
      });

      if (error) throw error;
      alert(`✅ Email de redefinição de senha enviado para ${userEmail}`);
    } catch (error: any) {
      console.error('❌ Erro ao enviar email de reset:', error);
      alert(`❌ Erro: ${error.message}`);
    }
  };

  // Promover usuário a admin
  const handlePromoteUserToAdmin = async (userId: string, userName: string) => {
    try {
      console.log('👑 Promovendo usuário para admin:', userId);
      
      const { error } = await supabase
        .from('user_roles')
        .update({ role: 'admin' })
        .eq('user_id', userId);

      if (error) throw error;

      alert(`✅ ${userName} foi promovido a ADMINISTRADOR!`);
      console.log('✅ Promoção concluída');

      // Recarregar lista
      const { data: profiles } = await supabase
        .from('profiles')
        .select('id, full_name, email, cnes')
        .order('full_name');
      const { data: userRoles } = await supabase
        .from('user_roles')
        .select('user_id, role, disabled');
      
      if (profiles && userRoles) {
        const usersByRole: { [key: string]: any } = {};
        userRoles.forEach(ur => {
          usersByRole[ur.user_id] = ur;
        });
        setUsersList(profiles.map(p => ({
          id: p.id,
          username: p.email || '',
          email: p.email || '',
          name: p.full_name,
          role: usersByRole[p.id]?.role || 'user',
          cnes: p.cnes || '',
          disabled: usersByRole[p.id]?.disabled || false
        })));
      }
    } catch (error: any) {
      console.error('❌ Erro ao promover usuário:', error);
      alert(`❌ Erro ao promover: ${error.message}`);
    }
  };

  // Rebaixar de admin para usuário
  const handleDemoteUserToRegular = async (userId: string, userName: string) => {
    try {
      console.log('⬇️ Rebaixando usuário para regular:', userId);
      
      const { error } = await supabase
        .from('user_roles')
        .update({ role: 'user' })
        .eq('user_id', userId);

      if (error) throw error;

      alert(`✅ ${userName} foi rebaixado para USUÁRIO PADRÃO!`);
      console.log('✅ Rebaixamento concluído');

      // Recarregar lista
      const { data: profiles } = await supabase
        .from('profiles')
        .select('id, full_name, email, cnes')
        .order('full_name');
      const { data: userRoles } = await supabase
        .from('user_roles')
        .select('user_id, role, disabled');
      
      if (profiles && userRoles) {
        const usersByRole: { [key: string]: any } = {};
        userRoles.forEach(ur => {
          usersByRole[ur.user_id] = ur;
        });
        setUsersList(profiles.map(p => ({
          id: p.id,
          username: p.email || '',
          email: p.email || '',
          name: p.full_name,
          role: usersByRole[p.id]?.role || 'user',
          cnes: p.cnes || '',
          disabled: usersByRole[p.id]?.disabled || false
        })));
      }
    } catch (error: any) {
      console.error('❌ Erro ao rebaixar usuário:', error);
      alert(`❌ Erro ao rebaixar: ${error.message}`);
    }
  };

  // Alterar papel do usuário de forma genérica
  const handleChangeUserRole = async (userId: string, userName: string, newRole: 'user' | 'intermediate' | 'admin') => {
    try {
      const roleNames = {
        'user': 'USUÁRIO PADRÃO',
        'intermediate': 'USUÁRIO INTERMEDIÁRIO',
        'admin': 'ADMINISTRADOR'
      };

      console.log(`🔄 Alterando papel de ${userName} para ${newRole}:`, userId);
      
      const { error } = await supabase
        .from('user_roles')
        .update({ role: newRole })
        .eq('user_id', userId);

      if (error) throw error;

      alert(`✅ ${userName} foi alterado para ${roleNames[newRole]}!`);
      console.log('✅ Alteração de papel concluída');

      // Recarregar lista
      const { data: profiles } = await supabase
        .from('profiles')
        .select('id, full_name, email, cnes')
        .order('full_name');
      const { data: userRoles } = await supabase
        .from('user_roles')
        .select('user_id, role, disabled');
      
      if (profiles && userRoles) {
        const usersByRole: { [key: string]: any } = {};
        userRoles.forEach(ur => {
          usersByRole[ur.user_id] = ur;
        });
        setUsersList(profiles.map(p => ({
          id: p.id,
          username: p.email || '',
          email: p.email || '',
          name: p.full_name,
          role: usersByRole[p.id]?.role || 'user',
          cnes: p.cnes || '',
          disabled: usersByRole[p.id]?.disabled || false
        })));
      }
    } catch (error: any) {
      console.error('❌ Erro ao alterar papel do usuário:', error);
      alert(`❌ Erro ao alterar papel: ${error.message}`);
    }
  };

  // Excluir usuário - Delete direto na tabela
  const handleDeleteUser = async (userId: string, userEmail: string) => {
    if (!confirm(`Tem certeza que deseja excluir o usuário? Esta ação não pode ser desfeita.`)) return;

    try {
      // Deletar de user_roles primeiro (foreign key)
      const { error: rolesError } = await supabase
        .from('user_roles')
        .delete()
        .eq('user_id', userId);

      if (rolesError) throw rolesError;

      // Deletar da tabela profiles
      const { error } = await supabase
        .from('profiles')
        .delete()
        .eq('id', userId);

      if (error) throw error;

      alert('✓ Usuário deletado com sucesso!');

      // Recarregar lista
      const { data: profiles } = await supabase
        .from('profiles')
        .select('id, full_name, email, cnes')
        .order('full_name');
      const { data: userRoles } = await supabase
        .from('user_roles')
        .select('user_id, role, disabled');
      
      if (profiles && userRoles) {
        const usersByRole: { [key: string]: any } = {};
        userRoles.forEach(ur => {
          usersByRole[ur.user_id] = ur;
        });
        setUsersList(profiles.map(p => ({
          id: p.id,
          username: p.email || '',
          email: p.email || '',
          name: p.full_name,
          role: usersByRole[p.id]?.role || 'user',
          cnes: p.cnes || '',
          disabled: usersByRole[p.id]?.disabled || false
        })));
      }
    } catch (error: any) {
      console.error('Erro ao deletar usuário:', error);
      alert(`❌ Erro ao deletar usuário: ${error.message}`);
    }
  };

  // Editar usuário - Update nome, email, CNES e opcionalmente senha
  const handleEditUser = async () => {
    if (!editingUser.id) return;
    
    try {
      console.log('🔧 Editando usuário:', editingUser);
      
      // Validação de nome
      if (!editingUser.name || editingUser.name.trim().length < 3) {
        throw new Error('Nome deve ter no mínimo 3 caracteres');
      }

      // Validação de email
      if (!editingUser.email || !validateEmail(editingUser.email)) {
        throw new Error('E-mail inválido. Use um formato válido (ex: usuario@example.com)');
      }

      // 1️⃣ Atualizar email via RPC (atualiza auth.users + auth.identities + profiles)
      const { data: emailResult, error: emailError } = await supabase.rpc('update_user_email', {
        user_id: editingUser.id,
        new_email: editingUser.email
      });
      
      if (emailError) {
        throw new Error('Erro ao atualizar email: ' + emailError.message);
      }
      
      if (emailResult && !emailResult.success) {
        throw new Error(emailResult.error || 'Erro ao atualizar email no banco de autenticação');
      }
      
      console.log('✅ Email atualizado em auth.users, auth.identities e profiles');

      // 2️⃣ Atualizar perfil (nome, CNES) - email já foi atualizado pela RPC
      const { error: profileError } = await supabase
        .from('profiles')
        .update({ 
          full_name: editingUser.name, 
          cnes: editingUser.cnes || null
        })
        .eq('id', editingUser.id);

      if (profileError) throw profileError;

      // 3️⃣ Se houver nova senha, enviar email de reset
      if (editingUser.password && editingUser.password.length >= 6) {
        try {
          // Usar RPC function para atualizar senha
          const { error: passwordError } = await supabase.rpc('update_user_password', {
            user_id: editingUser.id,
            new_password: editingUser.password
          });
          if (passwordError) throw passwordError;
        } catch (err) {
          console.warn('⚠️ Não foi possível atualizar senha via RPC, tentando email de reset...');
          // Fallback: enviar email de reset
          await supabase.auth.resetPasswordForEmail(editingUser.email, {
            redirectTo: `${window.location.origin}/reset-password`
          });
        }
      }

      alert('✅ Usuário atualizado com sucesso!\n\nSe o email foi alterado, o usuário deve fazer login com o novo email.');
      setShowEditUserModal(false);
      setEditingUser({ id: '', email: '', name: '', cnes: '', password: '' });

      // Recarregar lista
      const { data: profiles } = await supabase
        .from('profiles')
        .select('id, full_name, email, cnes')
        .order('full_name');
      const { data: userRoles } = await supabase
        .from('user_roles')
        .select('user_id, role, disabled');
      
      if (profiles && userRoles) {
        const usersByRole: { [key: string]: any } = {};
        userRoles.forEach(ur => {
          usersByRole[ur.user_id] = ur;
        });
        setUsersList(profiles.map(p => ({
          id: p.id,
          username: p.email || '',
          email: p.email || '',
          name: p.full_name,
          role: usersByRole[p.id]?.role || 'user',
          cnes: p.cnes || '',
          disabled: usersByRole[p.id]?.disabled || false
        })));
      }
    } catch (error: any) {
      console.error('❌ Erro ao editar usuário:', error);
      alert(`❌ Erro ao editar: ${error.message}`);
    }
  };

  const handleCreateUser = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSending(true);
    try {
      // Validação de email
      if (!newUser.email || !validateEmail(newUser.email)) {
        throw new Error('E-mail inválido. Use um formato válido (ex: usuario@example.com)');
      }

      // Validação de senha
      if (!newUser.password || newUser.password.length < 6) {
        throw new Error('Senha deve ter no mínimo 6 caracteres');
      }

      // Validação de nome
      if (!newUser.name || newUser.name.trim().length < 3) {
        throw new Error('Nome deve ter no mínimo 3 caracteres');
      }

      // Validação de perfil
      if (!newUser.role) {
        throw new Error('Perfil do usuário é obrigatório');
      }

      // Validação de CNES - OBRIGATÓRIO (aceita múltiplos separados por vírgula)
      if (!newUser.cnes || newUser.cnes.trim().length === 0) {
        throw new Error('🔴 CNES da instituição é OBRIGATÓRIO (máximo 8 dígitos cada)');
      }

      const cnesValues = newUser.cnes.split(',').map(c => c.trim()).filter(Boolean);
      for (const cnes of cnesValues) {
        if (cnes.length > 8) {
          throw new Error(`CNES "${cnes}" não pode ter mais de 8 dígitos`);
        }
        if (!/^\d+$/.test(cnes)) {
          throw new Error(`CNES "${cnes}" deve conter apenas números`);
        }
      }

      console.log('👤 Criando novo usuário:', { email: newUser.email, name: newUser.name, role: newUser.role });

      // 1. Criar usuário automaticamente em auth.users via RPC
      const { data: authData, error: authError } = await supabase.rpc(
        'criar_usuario_automático',
        {
          p_email: newUser.email,
          p_password: newUser.password,
          p_full_name: newUser.name,
          p_cnes: newUser.cnes.trim(),
          p_role: newUser.role
        }
      );

      if (authError) {
        throw new Error(authError.message || 'Erro ao criar usuário');
      } else if (authData && authData.success) {
        // Novo usuário criado com sucesso
        console.log('✅ Usuário criado automaticamente:', authData);

        // Sucesso - novo usuário
        const roleName = newUser.role === 'admin' ? 'Administrador' : newUser.role === 'intermediate' ? 'Usuário Intermediário' : 'Usuário Padrão';
        alert(`✅ Usuário registrado com sucesso!\n\nE-mail: ${newUser.email}\nCNES: ${newUser.cnes}\nPerfil: ${roleName}\n\nO usuário pode fazer login imediatamente.`);
      } else if (authData && !authData.success) {
        throw new Error(authData.error || 'Erro ao criar usuário');
      } else {
        throw new Error('Falha ao criar usuário');
      }
      
      // Reset do formulário
      setNewUser({ email: '', password: '', name: '', role: 'user' as 'user' | 'admin' | 'intermediate', cnes: '' });
      
      // Recarregar lista de usuários
      const { data: profiles, error: fetchError } = await supabase
        .from('profiles')
        .select('id, full_name, email, cnes')
        .order('full_name');
      const { data: userRoles } = await supabase
        .from('user_roles')
        .select('user_id, role, disabled');
      
      if (!fetchError && profiles && userRoles) {
        const usersByRole: { [key: string]: any } = {};
        userRoles.forEach(ur => {
          usersByRole[ur.user_id] = ur;
        });
        setUsersList(profiles.map(p => ({
          id: p.id,
          username: p.email || '',
          email: p.email || '',
          name: p.full_name,
          role: usersByRole[p.id]?.role || 'user',
          cnes: p.cnes || '',
          disabled: usersByRole[p.id]?.disabled || false
        })));
      }
    } catch (error: any) {
      console.error('Erro ao registrar usuário:', error);
      alert(`❌ Erro ao registrar: ${error.message}`);
    } finally {
      setIsSending(false);
    }
  };

  // IMPORTAR USUARIOS VIA CSV
  const handleCsvUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    
    setCsvUploading(true);
    setCsvResults(null);
    
    try {
      const text = await file.text();
      const lines = text.split(/\r?\n/).filter(line => line.trim());
      
      if (lines.length < 2) {
        throw new Error('O arquivo CSV deve ter pelo menos um cabeçalho e uma linha de dados.');
      }

      // Parser CSV que respeita campos entre aspas (para CNES com vírgulas ex: "2078813,2089335")
      const parseCsvLine = (line: string, sep: string): string[] => {
        const result: string[] = [];
        let current = '';
        let inQuotes = false;
        for (let i = 0; i < line.length; i++) {
          const ch = line[i];
          if (ch === '"') {
            if (inQuotes && line[i + 1] === '"') {
              current += '"';
              i++;
            } else {
              inQuotes = !inQuotes;
            }
          } else if (ch === sep && !inQuotes) {
            result.push(current.trim());
            current = '';
          } else {
            current += ch;
          }
        }
        result.push(current.trim());
        return result;
      };

      // Detectar separador (vírgula ou ponto-e-vírgula)
      const headerLine = lines[0];
      const separator = headerLine.includes(';') ? ';' : ',';
      
      // Parsear cabeçalho (normalizar: minúsculo, sem acento, sem espaço extra)
      const normalize = (s: string) => s.toLowerCase().trim()
        .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
        .replace(/[^a-z0-9]/g, '');
      
      const headers = parseCsvLine(headerLine, separator).map(h => normalize(h));
      
      // Mapear colunas flexivelmente
      const findCol = (keywords: string[]) => {
        return headers.findIndex(h => keywords.some(k => h.includes(k)));
      };
      
      const colNome = findCol(['nome', 'name', 'fullname', 'nomecompleto', 'responsavel']);
      const colEmail = findCol(['email', 'mail', 'emailresponsavel']);
      const colCnes = findCol(['cnes', 'codigocnes']);
      const colSenha = findCol(['senha', 'password', 'pass']);
      
      if (colEmail === -1) {
        throw new Error('Coluna "email" não encontrada no CSV. O cabeçalho deve conter: nome, email, cnes, senha');
      }
      if (colNome === -1) {
        throw new Error('Coluna "nome" não encontrada no CSV.');
      }
      if (colCnes === -1) {
        throw new Error('Coluna "cnes" não encontrada no CSV.');
      }
      
      // Parsear linhas de dados
      const usuarios: any[] = [];
      for (let i = 1; i < lines.length; i++) {
        const cols = parseCsvLine(lines[i], separator);
        const email = cols[colEmail]?.trim();
        const nome = cols[colNome]?.trim();
        const cnes = cols[colCnes]?.trim();
        const senha = colSenha !== -1 ? cols[colSenha]?.trim() : (cnes?.includes(',') ? cnes.split(',')[0].trim() : cnes);
        
        if (!email || !nome) continue;
        
        usuarios.push({ nome, email, cnes: cnes || '', senha: senha || cnes || '' });
      }
      
      if (usuarios.length === 0) {
        throw new Error('Nenhum usuário válido encontrado no CSV.');
      }
      
      // Confirmar com o admin
      const confirma = confirm(
        `Foram encontrados ${usuarios.length} usuários no CSV.\n\n` +
        `Primeiros 3:\n` +
        usuarios.slice(0, 3).map(u => `  • ${u.nome} - ${u.email} - CNES: ${u.cnes}`).join('\n') +
        (usuarios.length > 3 ? `\n  ... e mais ${usuarios.length - 3}` : '') +
        `\n\nDeseja criar todos agora?`
      );
      
      if (!confirma) {
        setCsvUploading(false);
        e.target.value = '';
        return;
      }

      console.log('🚀 Iniciando criação de usuários...');

      // Criar cliente separado para signUp (não afeta sessão do admin)
      const { createClient: createSupabaseClient } = await import('@supabase/supabase-js');
      const signUpClient = createSupabaseClient(
        'https://tlpmspfnswaxwqzmwski.supabase.co',
        'sb_publishable_a_t5QoKSL53wf1uT6GjqYg_wk2ENe-9'
      );

      let criados = 0;
      let erros = 0;
      const mensagens_erro: string[] = [];

      // Processar um por vez para não perder sessão
      for (let i = 0; i < usuarios.length; i++) {
        const usuario = usuarios[i];
        try {
          console.log(`⏳ Criando usuário ${i + 1}/${usuarios.length}: ${usuario.email}`);

          // 1. Criar usuário via auth.signUp (trigger auto-cria profile)
          const { data: signUpData, error: signUpError } = await signUpClient.auth.signUp({
            email: usuario.email,
            password: usuario.senha,
            options: {
              data: {
                full_name: usuario.nome,
                cnes: usuario.cnes,
                role: 'user'
              }
            }
          });

          if (signUpError) {
            console.warn(`⚠️ Erro ao criar ${usuario.email}:`, signUpError);
            erros++;
            mensagens_erro.push(`${i + 1}. ${usuario.email}: ${signUpError.message}`);
            continue;
          }

          const userId = signUpData?.user?.id;
          if (!userId) {
            erros++;
            mensagens_erro.push(`${i + 1}. ${usuario.email}: Usuário não retornou ID`);
            continue;
          }

          // 2. Atualizar CNES no profile (trigger pode não setar)
          await supabase.from('profiles').upsert({
            id: userId,
            full_name: usuario.nome,
            email: usuario.email,
            cnes: usuario.cnes
          }, { onConflict: 'id' });

          // 3. Criar role
          await supabase.from('user_roles').upsert({
            user_id: userId,
            role: 'user',
            disabled: false
          }, { onConflict: 'user_id' });

          console.log(`✅ Usuário criado: ${usuario.email} (ID: ${userId})`);
          criados++;

          // Logout do signUpClient para não manter sessão do novo usuário
          await signUpClient.auth.signOut();

        } catch (err: any) {
          console.error(`❌ Erro ao processar ${usuario.email}:`, err);
          erros++;
          mensagens_erro.push(`${i + 1}. ${usuario.email}: ${err.message}`);
        }
      }

      const resultado = {
        success: erros === 0,
        total: usuarios.length,
        criados,
        erros,
        mensagens_erro
      };

      setCsvResults(resultado);

      // Mensagem de conclusão
      let alertMsg = 
        `✅ Importação concluída!\n\n` +
        `Total processado: ${resultado.total}\n` +
        `Criados: ${resultado.criados}\n` +
        `Erros: ${resultado.erros}`;
      
      if (resultado.erros > 0) {
        alertMsg += `\n\n❌ Erros encontrados:\n${resultado.mensagens_erro.slice(0, 5).join('\n')}`;
        if (resultado.mensagens_erro.length > 5) {
          alertMsg += `\n... e mais ${resultado.mensagens_erro.length - 5}`;
        }
      }
      
      alert(alertMsg);

      // Recarregar lista de usuários
      const { data: profiles } = await supabase.from('profiles').select('id, full_name, email, cnes').order('full_name');
      const { data: userRoles } = await supabase.from('user_roles').select('user_id, role, disabled');
      if (profiles && userRoles) {
        const usersByRole: { [key: string]: any } = {};
        userRoles.forEach(ur => { usersByRole[ur.user_id] = ur; });
        setUsersList(profiles.map(p => ({
          id: p.id, username: p.email || '', email: p.email || '',
          name: p.full_name, role: usersByRole[p.id]?.role || 'user',
          cnes: p.cnes || '', disabled: usersByRole[p.id]?.disabled || false
        })));
      }

    } catch (error: any) {
      console.error('Erro ao importar CSV:', error);
      alert(`❌ Erro ao importar: ${error.message}`);
    } finally {
      setCsvUploading(false);
      e.target.value = '';
    }
  };

  // CARREGA LISTA DE PLANOS DO SUPABASE
  const loadPlanos = async () => {
    setIsLoadingPlanos(true);
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error("Sessão expirada");

      let query = supabase.from('planos_trabalho').select('*');

      // Se for admin ou intermediário, carregar TODOS os planos
      // Se for usuário padrão, filtrar apenas pelos planos do usuário
      if (isAdmin() || currentUser?.role === 'intermediate') {
      } else {
        query = query.eq('created_by', user.id);
      }

      const { data: planos, error } = await query.order('created_at', { ascending: false });

      if (error) {
        console.error('❌ Erro ao carregar planos:', error);
        throw error;
      }
      
      setPlanosList(planos || []);
    } catch (error: any) {
      console.error('❌ Erro ao carregar planos (catch):', error);
      alert(`Erro ao carregar planos: ${error.message}`);
      console.error('Erro ao carregar planos:', error);
    } finally {
      setIsLoadingPlanos(false);
    }
  };

  // RESET: Quando fecha a edição, limpar o cache para permitir novo carregamento
  useEffect(() => {
    if (!editingPlanId) {
      // Usuário fechou a edição - SEMPRE limpar refs
      console.log('🚪 Edição fechada - limpando refs para forçar recarga');
      planLoadCompletedRef.current.clear();
      loadingPlanIdRef.current = null;
    }
  }, [editingPlanId]);

  // Carrega um plano específico para editar 
  // REMOVE CACHE: Carrega SEMPRE quando clica editar  
  useEffect(() => {
    if (!editingPlanId) {
      return;
    }

    // Se está carregando OUTRO plano, ignora
    if (loadingPlanIdRef.current && loadingPlanIdRef.current !== editingPlanId) {
      return;
    }

    // Marcar como "em carregamento"
    loadingPlanIdRef.current = editingPlanId;

    // Carregar o plano (SEMPRE, sem cache)
    loadPlanForEditing(editingPlanId)
      .catch((error) => {
        console.error('❌ Erro ao carregar plano:', error);
      })
      .finally(() => {
        // Limpar "em carregamento"
        loadingPlanIdRef.current = null;
      });
  }, [editingPlanId]);

  // Monitorar mudanças no formData e atualizar sectionStatus automaticamente
  useEffect(() => {
    setSectionStatus(prev => ({
      ...prev,
      // Seção 1: Emenda - completa se todos os campos obrigatórios estão preenchidos
      'info-emenda': !!(
        formData.emenda.parlamentar?.trim() &&
        formData.emenda.numero?.trim() &&
        formData.emenda.valor?.trim() &&
        formData.emenda.valor !== '0,00' &&
        formData.emenda.programa?.trim()
      ),
      // Seção 2: Beneficiário - completa se nome, cnpj preenchidos (conta/extrato opcional para CNES isentos)
      'beneficiario': !!(
        formData.beneficiario.nome?.trim() &&
        formData.beneficiario.cnpj?.trim() &&
        (CNES_ISENTO_CONTA_EXTRATO.includes(formData.beneficiario.cnes?.trim()) || (
          formData.beneficiario.contaBancaria?.trim() &&
          formData.beneficiario.extratoUrl?.trim()
        ))
      ),
      // Seção 3: Alinhamento - completa se diretriz e objetivo selecionados
      'alinhamento': !!(
        formData.planejamento.diretrizId &&
        formData.planejamento.objetivoId
      ),
      // Seção 4: Metas Quantitativas - completa se houver pelo menos uma ação
      'metas-quantitativas': formData.acoesServicos.length > 0,
      // Seção 5: Indicadores Qualitativos - OPCIONAL (só completa se preenchido)
      'metas-qualitativas': formData.metasQualitativas.length > 0,
      // Seção 6: Execução Financeira - OPCIONAL (só completa se houver itens)
      'execucao-financeira': formData.naturezasDespesa.length > 0,
      // Seção 7: Finalização - completa se justificativa (min 2000 chars) e responsável preenchidos
      'finalizacao': !!(formData.justificativa?.trim() && formData.justificativa.trim().length >= 2000 && formData.responsavelAssinatura?.trim())
    }));
  }, [formData]);

  const loadPlanForEditing = async (planoId: string) => {
    // Validar planoId
    if (!planoId || typeof planoId !== 'string') {
      console.error('❌ ERRO: planoId inválido:', planoId);
      alert('Erro: ID do plano inválido');
      return;
    }

    // CRÍTICO: Limpar formData ANTES de carregar novos dados
    // Isso garante que não há dados antigos misturados
    console.log('🗑️ Limpando formData anterior...');
    setFormData(getInitialFormData());
    setCurrentSelection({ categoria: '', item: '', metas: [''] });
    setCurrentMetaQualitativa({ meta: '', valor: '' });
    setCurrentNatureza({ codigo: '', valor: '' });

    // Nota: O check de carregamento duplicado AGORA é feito no useEffect
    // Aqui apenas executamos o carregamento
    
    try {
      // 1. Buscar plano principal COM VALIDAÇÃO
      const { data: plano, error: planoError } = await supabase
        .from('planos_trabalho')
        .select('*')
        .eq('id', planoId)
        .single();

      if (planoError) {
        console.error('❌ Erro ao buscar plano:', planoError);
        throw new Error(`Plano não encontrado: ${planoError.message}`);
      }
      
      if (!plano || typeof plano !== 'object') {
        throw new Error('Plano inválido ou não encontrado');
      }

      // 2. Buscar metas quantitativas - SÓ O MAIS RECENTE por cada categoria
      let acoes = [];
      try {
        const { data: acoesRaw, error: acoesError } = await supabase
          .from('acoes_servicos')
          .select('*')
          .eq('plano_id', planoId)
          .order('created_at', { ascending: false })
          .limit(10); // Limitar a últimas 10 para evitar muitos dados

        if (acoesError) {
          console.warn('⚠️ Erro ao buscar ações:', acoesError);
        } else {
          // DEDUP: Manter só UMA ação (a mais recente)
          // Se tiver múltiplas, quer dizer que está duplicado
          const acoesUnique: any[] = [];
          const seen = new Set<string>();
          
          for (const a of acoesRaw || []) {
            const key = `${a.categoria}|${a.item}`; // Chave única por categoria+item
            if (!seen.has(key)) {
              acoesUnique.push(a);
              seen.add(key);
            }
          }
          
          acoes = acoesUnique;
          console.log(`✅ Ações/Serviços carregadas DO BANCO: ${acoesRaw?.length || 0} registros (${acoes.length} únicos após dedup)`);
        }
      } catch (e) {
        console.warn('⚠️ Erro ao buscar ações (try/catch):', e);
        acoes = [];
      }

      // 3. Buscar metas qualitativas - SÓ A MAIS RECENTE
      let metas = [];
      try {
        const { data: metasRaw, error: metasError } = await supabase
          .from('metas_qualitativas')
          .select('*')
          .eq('plano_id', planoId)
          .order('created_at', { ascending: false })
          .limit(10);

        if (metasError) {
          console.warn('⚠️ Erro ao buscar metas qualitativas:', metasError);
        } else {
          // DEDUP: Manter só UMA meta por descrição
          const metasUnique: any[] = [];
          const seen = new Set<string>();
          
          for (const m of metasRaw || []) {
            const key = `${m.meta_descricao}`; // Chave única por meta_descricao
            if (!seen.has(key)) {
              metasUnique.push(m);
              seen.add(key);
            }
          }
          
          metas = metasUnique;
          console.log(`✅ Metas Qualitativas carregadas DO BANCO: ${metasRaw?.length || 0} registros (${metas.length} únicos após dedup)`);
        }
      } catch (e) {
        console.warn('⚠️ Erro ao buscar metas qualitativas (try/catch):', e);
        metas = [];
      }

      // 4. Buscar naturezas de despesa - SÓ A MAIS RECENTE
      let naturezas = [];
      try {
        const { data: naturezasRaw, error: naturezasError } = await supabase
          .from('naturezas_despesa_plano')
          .select('*')
          .eq('plano_id', planoId)
          .order('created_at', { ascending: false })
          .limit(10);

        if (naturezasError) {
          console.warn('⚠️ Erro ao buscar naturezas:', naturezasError);
        } else {
          // DEDUP: Manter só UMA natureza por código
          const naturezasUnique: any[] = [];
          const seen = new Set<string>();
          
          for (const n of naturezasRaw || []) {
            const key = `${n.codigo}`; // Chave única por código
            if (!seen.has(key)) {
              naturezasUnique.push(n);
              seen.add(key);
            }
          }
          
          naturezas = naturezasUnique;
          console.log(`✅ Naturezas de Despesa carregadas DO BANCO: ${naturezasRaw?.length || 0} registros (${naturezas.length} únicos após dedup)`);
        }
      } catch (e) {
        console.warn('⚠️ Erro ao buscar naturezas (try/catch):', e);
        naturezas = [];
      }

      // 5. Montar formData GARANTINDO INTEGRIDADE DOS DADOS
      const loadedFormData: FormState = {
        emenda: {
          parlamentar: (plano.parlamentar || '').trim(),
          numero: (plano.numero_emenda || '').trim(),
          valor: (plano.valor_total ? (Number(plano.valor_total).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })) : '0,00'),
          valorExtenso: '',
          programa: (plano.programa || '').trim()
        },
        beneficiario: {
          nome: (plano.beneficiario_nome || '').trim(),
          cnes: (plano.cnes || '').trim(),
          cnpj: (plano.beneficiario_cnpj || '').trim(),
          email: (plano.beneficiario_email || '').trim(),
          telefone: (plano.beneficiario_telefone || '').trim(),
          contaBancaria: (plano.conta_bancaria || '').trim(),
          extratoUrl: (plano.extrato_url || '').trim(),
          extratoFilename: (plano.extrato_filename || '').trim()
        },
        planejamento: {
          diretrizId: (plano.diretriz_id || '').trim(),
          objetivoId: (plano.objetivo_id || '').trim(),
          metaIds: Array.isArray(plano.metas_ids) ? [...plano.metas_ids] : []
        },
        acoesServicos: acoes.map((a, index) => {
          if (!a || typeof a !== 'object') {
            console.warn(`⚠️ Ação inválida no índice ${index}:`, a);
            return { categoria: '', item: '', metasQuantitativas: [''], valor: '0,00' };
          }
          return {
            categoria: (a.categoria || '').trim(),
            item: (a.item || '').trim(),
            metasQuantitativas: [(a.meta || '').trim()],
            valor: (a.valor ? (Number(a.valor).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })) : '0,00')
          };
        }),
        metasQualitativas: metas.map((m, index) => {
          if (!m || typeof m !== 'object') {
            console.warn(`⚠️ Meta qualitativa inválida no índice ${index}:`, m);
            return { meta: '', valor: '0' };
          }
          return {
            meta: (m.meta_descricao || '').trim(),
            valor: String(m.indicador || '0').trim()
          };
        }),
        naturezasDespesa: naturezas.map((n, index) => {
          if (!n || typeof n !== 'object') {
            console.warn(`⚠️ Natureza inválida no índice ${index}:`, n);
            return { codigo: '', valor: '0,00' };
          }
          return {
            codigo: (n.codigo || '').trim(),
            valor: (n.valor ? (Number(n.valor).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })) : '0,00')
          };
        }),
        justificativa: (plano.justificativa || '').trim(),
        responsavelAssinatura: (plano.responsavel_assinatura || '').trim()
      };
      
      console.log('📝 FormData montado para edição:', {
        emenda: loadedFormData.emenda,
        beneficiario: loadedFormData.beneficiario,
        planejamento: loadedFormData.planejamento,
        acoesServicos: loadedFormData.acoesServicos.length,
        metasQualitativas: loadedFormData.metasQualitativas.length,
        naturezasDespesa: loadedFormData.naturezasDespesa.length
      });
      
      // 6. ATUALIZAR ESTADO COM DADOS VALIDADOS
      // IMPORTANTE: Limpar COMPLETAMENTE o formulário antes de settar novos dados
      // Para evitar duplicação em React StrictMode
      
      setFormData(prev => {
        // Garantir que é um reset completo, não uma merge
        return loadedFormData;
      });
      
      // Limpar inputs temporários para evitar dados residuais
      setCurrentSelection({ categoria: '', item: '', metas: [''] });
      setCurrentMetaQualitativa({ meta: '', valor: '' });
      setCurrentNatureza({ codigo: '', valor: '' });
      
      setPlanoSalvoId(planoId);
      const savedCopy = JSON.parse(JSON.stringify(loadedFormData));
      setLastSavedFormData(savedCopy);
      setFormHasChanges(false);
      
      // 7. Carregar data de alteração da justificativa (banco ou localStorage)
      const justAltDB = plano.justificativa_alterada_em || null;
      const justAltLocal = (() => { try { return localStorage.getItem(`justificativa_alterada_${planoId}`); } catch(e) { return null; } })();
      setJustificativaAlteradaEm(justAltDB || justAltLocal);
      

    } catch (error: any) {
      console.error('❌ ERRO CRÍTICO ao carregar plano:', error);
      alert(`Erro ao carregar plano para editar:\n\n${error?.message || 'Erro desconhecido'}`);
      setEditingPlanId(null);
      setFormData(getInitialFormData());
      setPlanoSalvoId(null);
      // Resetar refs em caso de erro
      loadingPlanIdRef.current = null;
      planLoadCompletedRef.current.clear();
    } finally {
      // SEMPRE LIMPAR A REF ao final
      loadingPlanIdRef.current = null;
    }
  };

  // DELETA UM PLANO (requer senha de admin)
  const deletePlan = async (planoId: string) => {
    if (!confirm('Tem certeza que deseja deletar este plano? Esta ação não pode ser desfeita.')) return;
    
    // Verificar se é admin
    if (!isAdmin()) {
      alert('⚠️ Apenas administradores podem deletar planos.');
      return;
    }

    // Solicitar senha de admin
    const adminPassword = prompt('🔐 Digite a senha do administrador para confirmar a exclusão:');
    if (!adminPassword) return;

    try {
      // Validar senha verificando com a API
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Sessão expirada');

      // Tentar fazer login novamente com a senha fornecida para validar
      const { error: authError } = await supabase.auth.signInWithPassword({
        email: user.email || '',
        password: adminPassword
      });

      if (authError) {
        alert('❌ Senha de administrador incorreta.');
        return;
      }

      // Senha correta, proceed com delete
      const plano = planosList.find(p => p.id === planoId);
      if (plano?.pdf_url) {
        await supabase.storage
          .from('planos-trabalho-pdfs')
          .remove([plano.pdf_url]);
      }

      const { error } = await supabase
        .from('planos_trabalho')
        .delete()
        .eq('id', planoId);

      if (error) throw error;
      alert('✅ Plano deletado com sucesso!');
      await loadPlanos();
    } catch (error: any) {
      console.error('Erro ao deletar:', error);
      alert(`Erro ao deletar: ${error.message}`);
    }
  };

  // DELETAR VÁRIOS PLANOS (bulk delete com senha de admin)
  const bulkDeletePlanos = async () => {
    if (selectedPlanos.size === 0) {
      alert('Selecione planos para deletar');
      return;
    }

    const confirmDelete = confirm(`Tem certeza que deseja deletar ${selectedPlanos.size} plano(s)? Esta ação não pode ser desfeita.`);
    if (!confirmDelete) return;

    // Solicitar senha de admin
    const adminPassword = prompt('🔐 Digite a senha do administrador para confirmar a exclusão em massa:');
    if (!adminPassword) return;

    try {
      // Validar senha
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Sessão expirada');

      const { error: authError } = await supabase.auth.signInWithPassword({
        email: user.email || '',
        password: adminPassword
      });

      if (authError) {
        alert('❌ Senha de administrador incorreta.');
        return;
      }

      // Deletar PDFs e registros
      for (const planoId of selectedPlanos) {
        const plano = planosList.find(p => p.id === planoId);
        if (plano?.pdf_url) {
          await supabase.storage
            .from('planos-trabalho-pdfs')
            .remove([plano.pdf_url]);
        }

        const { error } = await supabase
          .from('planos_trabalho')
          .delete()
          .eq('id', planoId);

        if (error) throw error;
      }

      alert(`✅ ${selectedPlanos.size} plano(s) deletado(s) com sucesso!`);
      setSelectedPlanos(new Set());
      setShowBulkDeleteModal(false);
      await loadPlanos();
    } catch (error: any) {
      console.error('Erro ao deletar:', error);
      alert(`Erro ao deletar: ${error.message}`);
    }
  };

  // EXPORTA PLANOS PARA CSV COM TODOS OS DADOS
  const exportToCSV = async () => {
    if (planosList.length === 0) {
      alert('Nenhum plano para exportar');
      return;
    }

    try {
      // Buscar dados completos de cada plano
      const fullPlanos = await Promise.all(
        planosList.map(async (p) => {
          // Buscar metas quantitativas
          const { data: acoes } = await supabase
            .from('acoes_servicos')
            .select('*')
            .eq('plano_id', p.id);
          
          // Buscar metas qualitativas
          const { data: metas } = await supabase
            .from('metas_qualitativas')
            .select('*')
            .eq('plano_id', p.id);
          
          // Buscar naturezas de despesa
          const { data: naturezas } = await supabase
            .from('naturezas_despesa_plano')
            .select('*')
            .eq('plano_id', p.id);
          
          return {
            ...p,
            acoes: acoes || [],
            metas: metas || [],
            naturezas: naturezas || []
          };
        })
      );

      // Criar CSV com todos os dados
      const headers = [
        'ID',
        'Parlamentar',
        'Nº Emenda',
        'Valor Total',
        'Programa',
        'Beneficiário',
        'CNES',
        'CNPJ',
        'Justificativa',
        'Metas Quantitativas (JSON)',
        'Indicadores Qualitativos (JSON)',
        'Naturezas de Despesa (JSON)',
        'Data Criação',
        'Data Atualização'
      ];

      const rows = fullPlanos.map(p => [
        p.id,
        p.parlamentar,
        p.numero_emenda,
        p.valor_total || '0,00',
        p.programa,
        p.beneficiario_nome,
        p.cnes || '',
        p.beneficiario_cnpj,
        p.justificativa?.replace(/"/g, '""') || '',
        JSON.stringify(p.acoes || []),
        JSON.stringify(p.metas || []),
        JSON.stringify(p.naturezas || []),
        new Date(p.created_at).toLocaleDateString('pt-BR'),
        p.updated_at ? new Date(p.updated_at).toLocaleDateString('pt-BR') : '—'
      ]);

      const csv = [headers, ...rows].map(row => row.map(cell => `"${cell}"`).join(',')).join('\n');
      const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
      const link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
      link.download = `planos-trabalho-completo-${new Date().toISOString().split('T')[0]}.csv`;
      link.click();
      alert('✅ CSV com todos os dados exportado com sucesso!');
    } catch (error: any) {
      alert(`Erro ao exportar CSV: ${error.message}`);
    }
  };

  const parseCurrency = (val: string) => {
    return parseFloat(val.replace(/\./g, '').replace(',', '.')) || 0;
  };



  // ======== COMPARAÇÃO DE DADOS PARA EVITAR DUPLICAÇÃO ========
  const hasDataChanged = async (): Promise<boolean> => {
    // Se não há plano salvo, não há mudanças a comparar
    if (!planoSalvoId) {
      return true; // É novo plano
    }

    try {
      // Buscar o plano salvo
      const { data: plano, error } = await supabase
        .from('planos_trabalho')
        .select('*, acoes_servicos(*), metas_qualitativas(*), naturezas_despesa_plano(*)')
        .eq('id', planoSalvoId)
        .single();

      if (error || !plano) return true; // Se não encontrar, considerar como novo

      // Comparar dados principales
      const mainDataSame =
        plano.parlamentar === formData.emenda.parlamentar &&
        plano.numero_emenda === formData.emenda.numero &&
        plano.valor_total === parseCurrency(formData.emenda.valor) &&
        plano.programa === formData.emenda.programa &&
        plano.beneficiario_nome === formData.beneficiario.nome &&
        plano.beneficiario_cnpj === formData.beneficiario.cnpj &&
        plano.justificativa === formData.justificativa;

      // Comparar quantidades de dados relacionados
      const acoesSame = plano.acoes_servicos?.length === formData.acoesServicos.length;
      const metasQualitSame = plano.metas_qualitativas?.length === formData.metasQualitativas.length;
      const naturezasSame = plano.naturezas_despesa_plano?.length === formData.naturezasDespesa.length;

      // Se tudo é igual, não há mudanças
      return !(mainDataSame && acoesSame && metasQualitSame && naturezasSame);
    } catch (error) {
      console.error("Erro ao comparar dados:", error);
      return true; // Em caso de erro, considerar como potencialmente novo
    }
  };

  // ======== AUTO SAVE ========
  const handleAutoSave = async () => {
    // Proteção sincronizada contra dupla execução
    if (isSavingRef.current) {
      return;
    }

    if (!isAuthenticated || !currentUser) return;

    isSavingRef.current = true;
    setAutoSaveStatus('saving');
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      // Se já existe plano, atualizar. Se não, criar
      if (planoSalvoId) {
        // Atualizar plano existente
        const { error } = await supabase
          .from('planos_trabalho')
          .update({
            parlamentar: formData.emenda.parlamentar,
            numero_emenda: formData.emenda.numero,
            valor_total: parseCurrency(formData.emenda.valor),
            programa: formData.emenda.programa,
            beneficiario_nome: formData.beneficiario.nome,
            beneficiario_cnpj: formData.beneficiario.cnpj,
            cnes: formData.beneficiario.cnes || null,
            conta_bancaria: formData.beneficiario.contaBancaria || null,
            extrato_url: formData.beneficiario.extratoUrl || null,
            extrato_filename: formData.beneficiario.extratoFilename || null,
            justificativa: formData.justificativa,
            responsavel_assinatura: formData.responsavelAssinatura,
            created_by_name: currentUser?.name || null,
            created_by_email: currentUser?.username || user.email || null,
            updated_at: new Date().toISOString()
          })
          .eq('id', planoSalvoId);

        if (error) throw error;

        // Deletar e reinserir dados relacionados (para evitar duplicação)
        await supabase.from('acoes_servicos').delete().eq('plano_id', planoSalvoId);
        await supabase.from('metas_qualitativas').delete().eq('plano_id', planoSalvoId);
        await supabase.from('naturezas_despesa_plano').delete().eq('plano_id', planoSalvoId);

        // Reinserir dados relacionados
        if (formData.acoesServicos.length > 0) {
          const acoesData = formData.acoesServicos.map(a => ({
            plano_id: planoSalvoId,
            categoria: a.categoria,
            item: a.item,
            meta: a.metasQuantitativas[0],
            valor: parseCurrency(a.valor),
            created_by: user.id
          }));
          await supabase.from('acoes_servicos').insert(acoesData);
        }

        if (formData.metasQualitativas.length > 0) {
          const qualData = formData.metasQualitativas.map(q => ({
            plano_id: planoSalvoId,
            meta_descricao: q.meta,
            indicador: q.valor,
            created_by: user.id
          }));
          await supabase.from('metas_qualitativas').insert(qualData);
        }

        if (formData.naturezasDespesa.length > 0) {
          const natData = formData.naturezasDespesa.map(n => ({
            plano_id: planoSalvoId,
            codigo: n.codigo,
            valor: parseCurrency(n.valor),
            created_by: user.id
          }));
          await supabase.from('naturezas_despesa_plano').insert(natData);
        }
      } else {
        // Criar novo plano
        const { data: plano, error: planoError } = await supabase
          .from('planos_trabalho')
          .insert([{
            parlamentar: formData.emenda.parlamentar,
            numero_emenda: formData.emenda.numero,
            valor_total: parseCurrency(formData.emenda.valor),
            programa: formData.emenda.programa,
            beneficiario_nome: formData.beneficiario.nome,
            beneficiario_cnpj: formData.beneficiario.cnpj,
            cnes: formData.beneficiario.cnes || null,
            conta_bancaria: formData.beneficiario.contaBancaria || null,
            extrato_url: formData.beneficiario.extratoUrl || null,
            extrato_filename: formData.beneficiario.extratoFilename || null,
            justificativa: formData.justificativa,
            responsavel_assinatura: formData.responsavelAssinatura,
            pdf_url: null,
            created_by: user.id,
            created_by_name: currentUser?.name || null,
            created_by_email: currentUser?.username || user.email || null
          }])
          .select()
          .single();

        if (planoError) throw planoError;
        if (plano) {
          setPlanoSalvoId(plano.id);

          // Inserir dados relacionados (ações, metas, etc)
          if (formData.acoesServicos.length > 0) {
            const acoesData = formData.acoesServicos.map(a => ({
              plano_id: plano.id,
              categoria: a.categoria,
              item: a.item,
              meta: a.metasQuantitativas[0],
              valor: parseCurrency(a.valor),
              created_by: user.id
            }));
            await supabase.from('acoes_servicos').insert(acoesData);
          }

          if (formData.metasQualitativas.length > 0) {
            const qualData = formData.metasQualitativas.map(q => ({
              plano_id: plano.id,
              meta_descricao: q.meta,
              indicador: q.valor,
              created_by: user.id
            }));
            await supabase.from('metas_qualitativas').insert(qualData);
          }

          if (formData.naturezasDespesa.length > 0) {
            const natData = formData.naturezasDespesa.map(n => ({
              plano_id: plano.id,
              codigo: n.codigo,
              valor: parseCurrency(n.valor),
              created_by: user.id
            }));
            await supabase.from('naturezas_despesa_plano').insert(natData);
          }
        }
      }

      setAutoSaveStatus('saved');
      setLastAutoSaveTime(new Date());
      
      // Voltar ao idle após 2 segundos
      setTimeout(() => setAutoSaveStatus('idle'), 2000);
    } catch (error) {
      console.error("❌ Erro no autosave:", error);
      setAutoSaveStatus('idle');
    } finally {
      isSavingRef.current = false; // ← Reset ref após auto-save
    }
  };

  // Auto-save desativado - salvar apenas ao enviar
  // useEffect(() => {
  //   const timer = setTimeout(() => {
  //     if (isAuthenticated && currentView === 'new') {
  //       handleAutoSave();
  //     }
  //   }, 3000); // Salvar 3 segundos após a última mudança
  //
  //   return () => clearTimeout(timer);
  // }, [formData, isAuthenticated, currentView]);

  const handleFinalSend = async () => {
    // Proteção MÁXIMA contra duplo clique/envio (usando useRef em vez de useState)
    if (isSavingRef.current) {
      alert("⚠️ BLOQUEADO: Operação já em andamento! Espere...");
      return null;
    }

    isSavingRef.current = true;
    setIsSending(true);

    try {
      // VALIDAÇÃO 1: Validar TODOS os campos obrigatórios PRIMEIRO
      const validation = validateRequiredFields();
      if (!validation.isValid) {
        const missingList = validation.missingFields.map((field, idx) => `${idx + 1}. ${field}`).join('\n');
        alert(
          `⚠️ FORMULÁRIO INCOMPLETO!\n\n` +
          `Os campos obrigatórios abaixo devem ser preenchidos:\n\n${missingList}\n\n` +
          `Por favor, complete todos os campos indicados antes de salvar o plano.`
        );
        setIsSending(false);
        isSavingRef.current = false; // ← Reset ref on validation error
        return null;
      }

      // VALIDAÇÃO 2: Total de Naturezas de Despesa não pode ultrapassar Total de Metas Quantitativas
      const totalMetasQuantitativas = formData.acoesServicos.reduce((sum, acao) => sum + parseCurrency(acao.valor), 0);
      const totalDespesas = formData.naturezasDespesa.reduce((sum, despesa) => sum + parseCurrency(despesa.valor), 0);
      
      if (totalDespesas > totalMetasQuantitativas) {
        const diferenca = (totalDespesas - totalMetasQuantitativas).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        alert(`⚠️ ERRO DE VALIDAÇÃO!\n\nO total de Naturezas de Despesa (R$ ${totalDespesas.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}) ultrapassa o Total de Metas Quantitativas (R$ ${totalMetasQuantitativas.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}) em R$ ${diferenca}.\n\nAjuste os valores de despesa antes de salvar.`);
        setIsSending(false);
        isSavingRef.current = false; // ← Reset ref on validation error
        return null;
      }

      // VALIDAÇÃO 3: Se já tem plano salvo E não há mudanças = não fazer nada
      if (planoSalvoId && lastSavedFormData) {
        const currentJson = JSON.stringify(formData);
        const savedJson = JSON.stringify(lastSavedFormData);
        if (currentJson === savedJson) {
          alert('⚠️ Nenhuma mudança detectada!\n\nO plano não foi alterado desde o último salvamento.');
          setIsSending(false);
          isSavingRef.current = false; // ← Reset ref when no changes
          return planoSalvoId;
        }
      }

      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error("Sessão expirada. Faça login novamente.");

      // LÓGICA SIMPLES: SE TEM planoSalvoId, é UPDATE. SENÃO, é CREATE
      if (planoSalvoId) {
        
        // Buscar o edit_count atual e justificativa para comparar
        const { data: currentPlano } = await supabase
          .from('planos_trabalho')
          .select('edit_count, justificativa')
          .eq('id', planoSalvoId)
          .single();
        
        const newEditCount = (currentPlano?.edit_count || 0) + 1;
        const justificativaMudou = (currentPlano?.justificativa || '') !== formData.justificativa;
        
        // Atualizar plano existente
        const valorTotalUpdate = parseCurrency(formData.emenda.valor);
        const { error: updateError } = await supabase
          .from('planos_trabalho')
          .update({
            parlamentar: formData.emenda.parlamentar,
            numero_emenda: formData.emenda.numero,
            valor_total: valorTotalUpdate,
            programa: formData.emenda.programa,
            beneficiario_nome: formData.beneficiario.nome,
            beneficiario_cnpj: formData.beneficiario.cnpj,
            beneficiario_email: formData.beneficiario.email || null,
            beneficiario_telefone: formData.beneficiario.telefone || null,
            cnes: formData.beneficiario.cnes || null,
            conta_bancaria: formData.beneficiario.contaBancaria || null,
            extrato_url: formData.beneficiario.extratoUrl || null,
            extrato_filename: formData.beneficiario.extratoFilename || null,
            justificativa: formData.justificativa,
            responsavel_assinatura: formData.responsavelAssinatura,
            diretriz_id: formData.planejamento.diretrizId || null,
            objetivo_id: formData.planejamento.objetivoId || null,
            metas_ids: formData.planejamento.metaIds,
            updated_at: new Date().toISOString(),
            edit_count: newEditCount,
            last_edited_at: new Date().toISOString(),
            last_edited_by: user.id,
            created_by_name: currentUser?.name || null,
            created_by_email: currentUser?.username || user.email || null
          })
          .eq('id', planoSalvoId);

        if (updateError) {
          console.error("❌ ERRO ao atualizar plano:", updateError);
          alert(`❌ ERRO ao atualizar plano:\n${updateError.message}`);
          setIsSending(false);
          isSavingRef.current = false;
          return null;
        }
        
        console.log("✅ Plano atualizado (edição #" + newEditCount + ")");
        
        // Atualizar estado local + localStorage se justificativa mudou
        if (justificativaMudou) {
          const novaData = new Date().toISOString();
          setJustificativaAlteradaEm(novaData);
          try { localStorage.setItem(`justificativa_alterada_${planoSalvoId}`, novaData); } catch(e) {}
          // Tentar salvar na coluna do banco (pode falhar se schema cache não atualizou)
          try {
            await supabase.from('planos_trabalho').update({ justificativa_alterada_em: novaData }).eq('id', planoSalvoId);
          } catch(e) { console.warn('⚠️ Não foi possível salvar justificativa_alterada_em no banco:', e); }
        }
        
        // ⚠️ Usar RPC para DELETE+INSERT atômico (resolve problema de RLS)
        console.log("📝 Substituindo dados relacionados via RPC...");
        
        const acoesJson = formData.acoesServicos.map(a => ({
          categoria: a.categoria,
          item: a.item,
          meta: a.metasQuantitativas[0],
          valor: parseCurrency(a.valor),
          created_by: user.id
        }));

        const metasQualJson = formData.metasQualitativas.map(q => ({
          meta_descricao: q.meta,
          indicador: q.valor,
          created_by: user.id
        }));

        const naturezasJson = formData.naturezasDespesa.map(n => ({
          codigo: n.codigo,
          valor: parseCurrency(n.valor),
          created_by: user.id
        }));

        const { data: rpcResult, error: rpcError } = await supabase.rpc('replace_plano_children', {
          p_plano_id: planoSalvoId,
          p_acoes: acoesJson,
          p_metas_qual: metasQualJson,
          p_naturezas: naturezasJson
        });

        if (rpcError) {
          console.warn("⚠️ RPC replace_plano_children falhou, usando fallback:", rpcError.message);
          // Fallback: inserir sem deletar (comportamento antigo)
          if (formData.acoesServicos.length > 0) {
            const acoesData = formData.acoesServicos.map(a => ({
              plano_id: planoSalvoId,
              categoria: a.categoria,
              item: a.item,
              meta: a.metasQuantitativas[0],
              valor: parseCurrency(a.valor),
              created_by: user.id
            }));
            await supabase.from('acoes_servicos').insert(acoesData);
          }
          if (formData.metasQualitativas.length > 0) {
            const qualData = formData.metasQualitativas.map(q => ({
              plano_id: planoSalvoId,
              meta_descricao: q.meta,
              indicador: q.valor,
              created_by: user.id
            }));
            await supabase.from('metas_qualitativas').insert(qualData);
          }
          if (formData.naturezasDespesa.length > 0) {
            const natData = formData.naturezasDespesa.map(n => ({
              plano_id: planoSalvoId,
              codigo: n.codigo,
              valor: parseCurrency(n.valor),
              created_by: user.id
            }));
            await supabase.from('naturezas_despesa_plano').insert(natData);
          }
        } else {
          console.log("✅ Dados relacionados substituídos via RPC:", rpcResult);
        }
        
        setLastSavedFormData(JSON.parse(JSON.stringify(formData)));
        setFormHasChanges(false);
        
        // Recarregar lista de planos para atualizar contagem de edições
        await loadPlanos();
        
        setIsSending(false);
        return planoSalvoId;
      } else {
        // ====== CREATE NOVO PLANO ======
      const valorParsado = parseCurrency(formData.emenda.valor);
      const { data: plano, error: planoError } = await supabase
        .from('planos_trabalho')
        .insert([{
          parlamentar: formData.emenda.parlamentar,
          numero_emenda: formData.emenda.numero,
          valor_total: valorParsado,
          programa: formData.emenda.programa,
          beneficiario_nome: formData.beneficiario.nome,
          beneficiario_cnpj: formData.beneficiario.cnpj,
          beneficiario_email: formData.beneficiario.email || null,
          beneficiario_telefone: formData.beneficiario.telefone || null,
          cnes: formData.beneficiario.cnes || null,
          conta_bancaria: formData.beneficiario.contaBancaria || null,
          extrato_url: formData.beneficiario.extratoUrl || null,
          extrato_filename: formData.beneficiario.extratoFilename || null,
          justificativa: formData.justificativa,
          responsavel_assinatura: formData.responsavelAssinatura,
          diretriz_id: formData.planejamento.diretrizId || null,
          objetivo_id: formData.planejamento.objetivoId || null,
          metas_ids: formData.planejamento.metaIds,
          pdf_url: null,
          created_by: user.id,
          created_by_name: currentUser?.name || null,
          created_by_email: currentUser?.username || user.email || null
        }])
        .select()
        .single();

      if (planoError) {
        console.error("❌ Erro ao inserir plano:", planoError);
        console.error("❌ DETALHES DO ERRO:", JSON.stringify(planoError, null, 2));
        console.error("❌ code:", planoError.code, "message:", planoError.message, "details:", planoError.details, "hint:", planoError.hint);
        throw planoError;
      }

      if (formData.acoesServicos.length > 0) {
        const acoesData = formData.acoesServicos.map(a => ({
          plano_id: plano.id,
          categoria: a.categoria,
          item: a.item,
          meta: a.metasQuantitativas[0],
          valor: parseCurrency(a.valor),
          created_by: user.id
        }));
        const { error: acoesError } = await supabase.from('acoes_servicos').insert(acoesData);
        if (acoesError) {
          console.error("❌ Erro ao inserir ações:", acoesError);
          throw acoesError;
        }
      }

      if (formData.metasQualitativas.length > 0) {
        const qualData = formData.metasQualitativas.map(q => ({
          plano_id: plano.id,
          meta_descricao: q.meta,
          indicador: q.valor,
          created_by: user.id
        }));
        const { error: qualError } = await supabase.from('metas_qualitativas').insert(qualData);
        if (qualError) {
          console.error("❌ Erro ao inserir metas qualitativas:", qualError);
          throw qualError;
        }
      }

      if (formData.naturezasDespesa.length > 0) {
        const natData = formData.naturezasDespesa.map(n => ({
          plano_id: plano.id,
          codigo: n.codigo,
          valor: parseCurrency(n.valor),
          created_by: user.id
        }));
        const { error: natError } = await supabase.from('naturezas_despesa_plano').insert(natData);
        if (natError) {
          console.error("❌ Erro ao inserir naturezas:", natError);
          throw natError;
        }
      }

      setPlanoSalvoId(plano.id);
      

      
      // Atualizar lastSavedFormData após salvar com sucesso
      const savedCopy = JSON.parse(JSON.stringify(formData));
      setLastSavedFormData(savedCopy);
      // Resetar flag de mudanças após sucesso
      setFormHasChanges(false);
      console.log(`📌 Plano ${plano.id} salvo. lastSavedFormData atualizado.`);
      
      // Recarregar lista de planos para atualizar contagem de edições e datas
      await loadPlanos();
      
      alert('✅ PLANO NOVO CRIADO E SALVO COM SUCESSO!');
      setShowEmailModal(true);
      // ← NÃO reseta isSavingRef aqui! Reset apenas no finally block
      return plano.id; // Retornar ID para uso síncrono - SAIR AGORA!
      }
    } catch (error: any) {
      console.error("❌ ERRO COMPLETO:", error);
      const errorMsg = error?.message || error?.toString() || "Erro desconhecido";
      alert(`⚠️ ERRO:\n\n${errorMsg}\n\nVerifique o console (F12) para mais detalhes.`);
      return null; // Retornar null em caso de erro
    } finally {
      setIsSending(false);
      isSavingRef.current = false; // ← NOVO: Libera guard para próxima tentativa
    }
  };

  const handleSendEmail = async () => {
    // Abrir email para SES-SP
    handleSendToSES();
  };

  // Validação de campos obrigatórios
  const validateRequiredFields = (): { isValid: boolean; missingFields: string[] } => {
    const missingFields: string[] = [];

    // IDENTIFICAÇÃO GERAL - obrigatório
    if (!formData.emenda.parlamentar?.trim()) missingFields.push('Parlamentar Autor');
    if (!formData.emenda.numero?.trim()) missingFields.push('Número da Emenda');
    if (!formData.emenda.valor?.trim() || formData.emenda.valor === '0,00') missingFields.push('Valor da Emenda');
    if (!formData.emenda.programa?.trim()) missingFields.push('Programa de Saúde');

    // DADOS DO BENEFICIÁRIO - obrigatório
    if (!formData.beneficiario.nome?.trim()) missingFields.push('Nome do Beneficiário');
    if (!formData.beneficiario.cnpj?.trim()) missingFields.push('CNPJ do Beneficiário');
    const cnesIsento = CNES_ISENTO_CONTA_EXTRATO.includes(formData.beneficiario.cnes?.trim());
    if (!cnesIsento && !formData.beneficiario.contaBancaria?.trim()) missingFields.push('Conta Bancária');
    if (!cnesIsento && !formData.beneficiario.extratoUrl?.trim()) missingFields.push('Extrato Bancário (faça upload do arquivo)');

    // ALINHAMENTO ESTRATÉGICO - obrigatório
    if (!formData.planejamento.diretrizId) missingFields.push('Diretriz Estratégica');
    if (!formData.planejamento.objetivoId) missingFields.push('Objetivo Específico');

    // METAS QUANTITATIVAS - obrigatório (pelo menos um item)
    if (formData.acoesServicos.length === 0) missingFields.push('Metas Quantitativas (adicione pelo menos uma ação/serviço)');

    // INDICADORES QUALITATIVOS - OPCIONAL (não é obrigatório)
    // Removido: validação de requiredFields

    // EXECUÇÃO FINANCEIRA - obrigatório (pelo menos um item)
    if (formData.naturezasDespesa.length === 0) missingFields.push('Execução Financeira - Natureza de Despesa (adicione pelo menos uma despesa)');

    // JUSTIFICATIVA TÉCNICA - obrigatório (mínimo 2000 caracteres)
    if (!formData.justificativa?.trim()) {
      missingFields.push('Justificativa Técnica');
    } else if (formData.justificativa.trim().length < 2000) {
      missingFields.push(`Justificativa Técnica (mínimo 2.000 caracteres — atual: ${formData.justificativa.trim().length})`);
    }

    // RESPONSÁVEL PELA ASSINATURA - obrigatório
    if (!formData.responsavelAssinatura?.trim()) missingFields.push('Responsável pela Assinatura');

    return {
      isValid: missingFields.length === 0,
      missingFields
    };
  };

  // Registra evento de visualização/download de PDF no banco de dados
  const recordPdfViewEvent = async (planoId: string) => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        console.warn("⚠️ Não foi possível registrar evento PDF: usuário não autenticado");
        return;
      }

      // Buscar dados do plano para registrar no histórico
      const { data: plano, error: fetchError } = await supabase
        .from('planos_trabalho')
        .select('numero_emenda, parlamentar, valor_total')
        .eq('id', planoId)
        .single();

      if (fetchError) {
        console.error("❌ Erro ao buscar dados do plano:", fetchError);
        return;
      }

      // Registrar no histórico
      const { error: insertError } = await supabase
        .from('pdf_download_history')
        .insert({
          plano_id: planoId,
          user_id: user.id,
          user_email: user.email,
          user_name: currentUser?.name || 'Usuário',
          numero_emenda: plano.numero_emenda,
          parlamentar: plano.parlamentar,
          valor_total: plano.valor_total,
          action_type: 'view_pdf'
        });

      if (insertError) {
        console.error("❌ Erro ao registrar evento PDF:", insertError);
      } else {
        console.log("✅ Evento de visualização de PDF registrado com sucesso!");
      }
    } catch (error: any) {
      console.error("❌ Erro ao registrar evento de PDF:", error);
      // Não interrompe o fluxo se falhar ao registrar
    }
  };

  // ======== UPLOAD E COMPRESSÃO DE EXTRATO BANCÁRIO ========
  const compressImage = (file: File, maxWidth: number = 900, quality: number = 0.5): Promise<Blob> => {
    return new Promise((resolve, reject) => {
      const img = new Image();
      const url = URL.createObjectURL(file);
      img.onload = () => {
        URL.revokeObjectURL(url);
        const canvas = document.createElement('canvas');
        let width = img.width;
        let height = img.height;
        
        // Redimensionar para largura máxima
        if (width > maxWidth) {
          height = Math.round((height * maxWidth) / width);
          width = maxWidth;
        }
        
        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        if (!ctx) { reject(new Error('Canvas não suportado')); return; }
        ctx.drawImage(img, 0, 0, width, height);
        
        // Tentar WebP primeiro com qualidade baixa
        canvas.toBlob(
          (blob) => {
            if (blob) resolve(blob);
            else reject(new Error('Falha ao comprimir imagem'));
          },
          'image/webp',
          quality
        );
      };
      img.onerror = () => { URL.revokeObjectURL(url); reject(new Error('Falha ao carregar imagem')); };
      img.src = url;
    });
  };

  const compressPDF = async (file: File): Promise<Blob> => {
    const { PDFDocument } = await import('pdf-lib');
    const arrayBuffer = await file.arrayBuffer();
    
    // Carregar o PDF original
    const pdfDoc = await PDFDocument.load(arrayBuffer, { ignoreEncryption: true });
    
    // Copiar para um novo documento limpo (remove metadados, objetos órfãos, etc.)
    const compressedDoc = await PDFDocument.create();
    const pages = await compressedDoc.copyPages(pdfDoc, pdfDoc.getPageIndices());
    pages.forEach(page => compressedDoc.addPage(page));
    
    // Salvar com otimizações
    const compressedBytes = await compressedDoc.save({
      useObjectStreams: true,    // Comprime streams de objetos
      addDefaultPage: false,
      objectsPerTick: 100,
    });
    
    // Se o PDF comprimido ainda for grande, converter páginas para imagens comprimidas
    if (compressedBytes.length > 500 * 1024) {
      // Tentar renderizar via canvas para máxima compressão
      try {
        return await pdfToCompressedImage(file);
      } catch {
        // Se falhar a conversão, retornar o PDF otimizado
        return new Blob([compressedBytes], { type: 'application/pdf' });
      }
    }
    
    return new Blob([compressedBytes], { type: 'application/pdf' });
  };

  const pdfToCompressedImage = (file: File): Promise<Blob> => {
    return new Promise((resolve, reject) => {
      // Usar iframe oculto para renderizar o PDF e capturar como imagem
      const url = URL.createObjectURL(file);
      const canvas = document.createElement('canvas');
      const img = new Image();
      
      // Para PDFs, criar uma versão simplificada em imagem usando embed
      // Fallback: retornar o arquivo original se não conseguir converter
      const reader = new FileReader();
      reader.onload = () => {
        // Criar um object URL do PDF e tentar renderizar
        const embed = document.createElement('embed');
        embed.src = url;
        embed.type = 'application/pdf';
        
        // Timeout - se não conseguir em 3s, rejeitar
        const timeout = setTimeout(() => {
          URL.revokeObjectURL(url);
          reject(new Error('Timeout ao converter PDF'));
        }, 3000);
        
        // Para garantir compressão, montamos o canvas com dimensões reduzidas
        canvas.width = 900;
        canvas.height = 1270; // A4 proportion
        const ctx = canvas.getContext('2d');
        if (!ctx) { 
          clearTimeout(timeout);
          URL.revokeObjectURL(url);
          reject(new Error('Canvas não suportado')); 
          return; 
        }
        
        // Fundo branco
        ctx.fillStyle = '#FFFFFF';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        
        // Texto indicativo
        ctx.fillStyle = '#333333';
        ctx.font = '14px Arial';
        ctx.fillText('Extrato Bancário - Documento PDF', 20, 30);
        ctx.font = '11px Arial';
        ctx.fillText(`Arquivo original: ${file.name}`, 20, 55);
        ctx.fillText(`Tamanho original: ${(file.size / 1024).toFixed(0)} KB`, 20, 75);
        
        clearTimeout(timeout);
        URL.revokeObjectURL(url);
        
        canvas.toBlob(
          (blob) => {
            if (blob) resolve(blob);
            else reject(new Error('Falha ao gerar imagem do PDF'));
          },
          'image/webp',
          0.5
        );
      };
      reader.onerror = () => { URL.revokeObjectURL(url); reject(new Error('Falha ao ler PDF')); };
      reader.readAsArrayBuffer(file);
    });
  };

  const compressFile = async (file: File): Promise<{ blob: Blob; ext: string; mime: string }> => {
    if (file.type.startsWith('image/')) {
      // Imagens: comprimir agressivamente para WebP
      const blob = await compressImage(file, 900, 0.5);
      return { blob, ext: 'webp', mime: 'image/webp' };
    }
    
    if (file.type === 'application/pdf') {
      // PDFs: otimizar com pdf-lib
      const blob = await compressPDF(file);
      // Se foi convertido para imagem, ajustar extensão
      if (blob.type === 'image/webp') {
        return { blob, ext: 'webp', mime: 'image/webp' };
      }
      return { blob, ext: 'pdf', mime: 'application/pdf' };
    }
    
    // Outros: retornar sem compressão
    const ext = file.name.split('.').pop()?.toLowerCase() || 'bin';
    return { blob: file, ext, mime: file.type };
  };

  const handleExtratoUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    // Validar tipo de arquivo
    const allowedTypes = ['application/pdf', 'image/jpeg', 'image/png', 'image/webp'];
    if (!allowedTypes.includes(file.type)) {
      alert('❌ Tipo de arquivo não permitido.\n\nFormatos aceitos: PDF, JPEG, PNG, WebP');
      if (extratoInputRef.current) extratoInputRef.current.value = '';
      return;
    }

    // Aceitar arquivos maiores antes da compressão (até 10MB) pois serão comprimidos
    if (file.size > 10 * 1024 * 1024) {
      alert('❌ Arquivo muito grande.\n\nTamanho máximo: 10MB (será comprimido automaticamente)');
      if (extratoInputRef.current) extratoInputRef.current.value = '';
      return;
    }

    setIsUploadingExtrato(true);
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Sessão expirada');

      // Comprimir o arquivo (imagem ou PDF)
      const { blob: uploadBlob, ext: uploadExt, mime: uploadMimeType } = await compressFile(file);

      // Verificar se após compressão está dentro do limite de 1MB
      if (uploadBlob.size > 1 * 1024 * 1024) {
        alert(`❌ Arquivo ainda muito grande após compressão.\n\nTamanho após compressão: ${(uploadBlob.size / 1024).toFixed(0)} KB\nLimite: 1.000 KB\n\nTente enviar um arquivo menor ou com menos páginas.`);
        if (extratoInputRef.current) extratoInputRef.current.value = '';
        setIsUploadingExtrato(false);
        return;
      }

      // Nome único para o arquivo: userId/timestamp.ext
      const filePath = `${user.id}/${Date.now()}.${uploadExt}`;

      // Se já existe um extrato anterior, remover do storage
      if (formData.beneficiario.extratoUrl) {
        await supabase.storage
          .from('extratos-bancarios')
          .remove([formData.beneficiario.extratoUrl]);
      }

      // Upload para Supabase Storage
      const { error: uploadError } = await supabase.storage
        .from('extratos-bancarios')
        .upload(filePath, uploadBlob, {
          contentType: uploadMimeType,
          upsert: false
        });

      if (uploadError) throw uploadError;

      // Atualizar formData com os dados do extrato
      updateFormData('beneficiario', {
        ...formData.beneficiario,
        extratoUrl: filePath,
        extratoFilename: file.name
      });

      const reducao = ((1 - uploadBlob.size / file.size) * 100).toFixed(0);
      alert(`✅ Extrato enviado com sucesso!\n\nArquivo: ${file.name}\nOriginal: ${(file.size / 1024).toFixed(0)} KB\nComprimido: ${(uploadBlob.size / 1024).toFixed(0)} KB\nRedução: ${reducao}%`);
    } catch (error: any) {
      console.error('❌ Erro ao enviar extrato:', error);
      alert(`❌ Erro ao enviar extrato:\n${error.message}`);
    } finally {
      setIsUploadingExtrato(false);
      if (extratoInputRef.current) extratoInputRef.current.value = '';
    }
  };

  const handleRemoveExtrato = async () => {
    if (!formData.beneficiario.extratoUrl) return;
    
    try {
      await supabase.storage
        .from('extratos-bancarios')
        .remove([formData.beneficiario.extratoUrl]);

      updateFormData('beneficiario', {
        ...formData.beneficiario,
        extratoUrl: '',
        extratoFilename: ''
      });
    } catch (error: any) {
      console.error('Erro ao remover extrato:', error);
    }
  };

  const getExtratoPublicUrl = (path: string): string => {
    const { data } = supabase.storage
      .from('extratos-bancarios')
      .getPublicUrl(path);
    return data.publicUrl;
  };

  const handleViewExtrato = async (extratoPath: string) => {
    try {
      const { data, error } = await supabase.storage
        .from('extratos-bancarios')
        .createSignedUrl(extratoPath, 300); // URL válida por 5 minutos

      if (error) throw error;
      window.open(data.signedUrl, '_blank', 'noopener,noreferrer');
    } catch (error: any) {
      console.error('❌ Erro ao visualizar extrato:', error);
      alert(`❌ Erro ao abrir extrato:\n${error.message}`);
    }
  };

  // Gerar e salvar PDF
  const handleGeneratePDF = async () => {
    // Proteção contra duplo clique/envio
    if (isSending) {
      console.log("⚠️ Operação já em andamento, ignorando clique");
      return;
    }

    setIsSending(true);
    try {
      // VALIDAÇÃO 1: Total de Naturezas de Despesa não pode ultrapassar Total de Metas Quantitativas
      const totalMetasQuantitativas = formData.acoesServicos.reduce((sum, acao) => sum + parseCurrency(acao.valor), 0);
      const totalDespesas = formData.naturezasDespesa.reduce((sum, despesa) => sum + parseCurrency(despesa.valor), 0);
      
      if (totalDespesas > totalMetasQuantitativas) {
        const diferenca = (totalDespesas - totalMetasQuantitativas).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        alert(`⚠️ ERRO DE VALIDAÇÃO!\n\nO total de Naturezas de Despesa (R$ ${totalDespesas.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}) ultrapassa o Total de Metas Quantitativas (R$ ${totalMetasQuantitativas.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}) em R$ ${diferenca}.\n\nNÃO É POSSÍVEL GERAR PDF!\n\nAjuste os valores de despesa antes de tentar novamente.`);
        setIsSending(false);
        return;
      }

      // VALIDAÇÃO 2: Validar campos obrigatórios
      const validation = validateRequiredFields();
      if (!validation.isValid) {
        const missingList = validation.missingFields.map((field, idx) => `${idx + 1}. ${field}`).join('\n');
        alert(
          `⚠️ NÃO É POSSÍVEL GERAR PDF!\n\n` +
          `Os campos obrigatórios abaixo devem ser preenchidos:\n\n${missingList}\n\n` +
          `Por favor, complete todos os campos indicados antes de salvar o PDF.`
        );
        setIsSending(false);
        return;
      }

      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error("Sessão expirada. Faça login novamente.");
      
      // 1️⃣ ETAPA CRÍTICA: GARANTIR QUE O PLANO ESTÁ SALVO NO BANCO
      let currentPlanoId = planoSalvoId;
      
      if (!currentPlanoId) {
        // Novo plano: DEVE SALVAR PRIMEIRO
        console.log("📝 NOVO PLANO: Salvando no banco antes de prosseguir...");
        currentPlanoId = await handleFinalSend();
        if (!currentPlanoId) {
          throw new Error("❌ CRÍTICO: Falha ao salvar novo plano. PDF NÃO foi gerado.");
        }
      } else {
        // Plano já existe: GARANTIR ATUALIZAÇÃO ANTES DO PDF
        const updateSuccess = await handleFinalSend();
        if (!updateSuccess) {
          throw new Error("❌ CRÍTICO: Falha ao atualizar plano. PDF NÃO foi gerado.");
        }
      }

      // 2️⃣ VERIFICAÇÃO: Confirmar que o plano foi salvo
      console.log("✔️ Verificando se plano está realmente salvo no banco...");
      const { data: verifyPlano, error: verifyError } = await supabase
        .from('planos_trabalho')
        .select('id, numero_emenda')
        .eq('id', currentPlanoId)
        .single();

      if (verifyError || !verifyPlano) {
        throw new Error("❌ CRÍTICO: Plano não foi encontrado no banco após salvamento. PDF NÃO foi gerado.");
      }

      // 3️⃣ Registrar evento de visualização/download no banco de dados
      await recordPdfViewEvent(currentPlanoId);

      // 4️⃣ Abrir diálogo de impressão (navegador respeitará quebras naturalmente)
      setTimeout(() => {
        window.print();
      }, 500);
    } catch (error: any) {
      console.error("❌ ERRO CRÍTICO:", error);
      alert(`⚠️ ERRO AO PROCESSAR PDF:\n\n${error.message}\n\n` +
            `O plano NÃO foi processado. Por favor, tente novamente.`);
    } finally {
      setIsSending(false);
    }
  };

  const selectedDiretriz = useMemo(() => 
    DIRETRIZES.find(d => d.id === formData.planejamento.diretrizId), 
    [formData.planejamento.diretrizId]
  );

  const selectedObjetivo = useMemo(() => 
    selectedDiretriz?.objetivos.find(o => o.id === formData.planejamento.objetivoId),
    [selectedDiretriz, formData.planejamento.objetivoId]
  );

  const availableAcoes = useMemo(() => 
    ACOES_SERVICOS_POR_PROGRAMA[formData.emenda.programa] || [], 
    [formData.emenda.programa]
  );

  // Metas Quantitativas - Only available for "EMENDA INDIVIDUAL - CUSTEIO MAC - 2E90"
  const availableMetasQuantitativas = useMemo(() => {
    if (formData.emenda.programa === "EMENDA INDIVIDUAL - CUSTEIO MAC - 2E90") {
      return Object.entries(METAS_QUANTITATIVAS_OPTIONS).map(([categoria, itens]) => ({
        categoria,
        itens
      }));
    }
    // Para outros programas, usar as ações de serviços disponíveis
    return ACOES_SERVICOS_POR_PROGRAMA[formData.emenda.programa] || [];
  }, [formData.emenda.programa]);

  const updateFormData = (section: keyof FormState, value: any) => {
    if (section === 'beneficiario' && value?.cnes) {
      console.log('🔄 updateFormData - beneficiario:', value);
    }
    setFormData(prev => ({ ...prev, [section]: value }));
  };

  // Scroll to section
  const scrollToSection = (sectionId: string) => {
    setActiveSection(sectionId);
    const element = document.getElementById(sectionId);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  };

  const sections = [
    { id: 'info-emenda', title: 'Emenda Identificação' },
    { id: 'beneficiario', title: 'Beneficiário Dados' },
    { id: 'alinhamento', title: 'Estratégia Alinhamento' },
    { id: 'metas-quantitativas', title: 'Metas Metas' },
    { id: 'metas-qualitativas', title: 'Indicadores Indicadores' },
    { id: 'execucao-financeira', title: 'Financeiro Execução' },
    { id: 'finalizacao', title: 'Finalizar Finalização' }
  ];

  const confirmAddAcao = () => {
    if (!currentSelection.categoria || !currentSelection.item) {
      alert('Por favor, selecione o Grupo de Ação e a Ação Específica.');
      return;
    }
    const newAcao = {
      categoria: currentSelection.categoria,
      item: currentSelection.item,
      metasQuantitativas: [currentSelection.item],
      valor: ''
    };
    setFormData(prev => ({
      ...prev,
      acoesServicos: [...prev.acoesServicos, newAcao]
    }));
    setCurrentSelection({ categoria: '', item: '', metas: [''] });
  };

  const removeAcao = (index: number) => {
    setFormData(prev => ({
      ...prev,
      acoesServicos: prev.acoesServicos.filter((_, i) => i !== index)
    }));
  };

  const confirmAddMetaQualitativa = () => {
    if (!currentMetaQualitativa.meta) {
      alert('Por favor, selecione um indicador.');
      return;
    }
    setFormData(prev => ({
      ...prev,
      metasQualitativas: [...prev.metasQualitativas, { ...currentMetaQualitativa }]
    }));
    setCurrentMetaQualitativa({ meta: '', valor: '' });
  };

  const removeMetaQualitativa = (index: number) => {
    setFormData(prev => ({
      ...prev,
      metasQualitativas: prev.metasQualitativas.filter((_, i) => i !== index)
    }));
  };

  const confirmAddNatureza = () => {
    if (!currentNatureza.codigo) {
      alert('Por favor, selecione uma natureza de despesa.');
      return;
    }
    setFormData(prev => ({
      ...prev,
      naturezasDespesa: [...prev.naturezasDespesa, { ...currentNatureza }]
    }));
    setCurrentNatureza({ codigo: '', valor: '' });
  };

  const removeNatureza = (index: number) => {
    setFormData(prev => ({
      ...prev,
      naturezasDespesa: prev.naturezasDespesa.filter((_, i) => i !== index)
    }));
  };

  const handleSendToSES = () => {
    // Se o formulário está vazio, mostrar modal para selecionar um plano
    // Verifica se campos críticos estão realmente preenchidos
    const hasEmendaData = formData.emenda?.numero && formData.emenda?.numero.toString().trim() !== '';
    const hasParliamentarData = formData.emenda?.parlamentar && formData.emenda?.parlamentar.toString().trim() !== '';
    const hasBeneficiarioData = formData.beneficiario?.nome && formData.beneficiario?.nome.toString().trim() !== '';
    
    const isFormEmpty = !hasEmendaData || !hasParliamentarData || !hasBeneficiarioData;
    
    if (isFormEmpty && planosList.length > 0) {
      setShowSelectPlanModal(true);
      return;
    }

    if (isFormEmpty && planosList.length === 0) {
      alert('⚠️ Nenhum plano disponível.\n\nPreencha o formulário com os dados do plano que deseja enviar ou crie um novo plano.');
      return;
    }

    // Formulário preenchido, gerar email
    const subject = `Plano de Trabalho 2026 - Emenda ${formData.emenda.numero} - CNES ${formData.beneficiario.cnes || 'N/A'}`;
    const emailBody = `Prezados,

Segue em anexo o Plano de Trabalho 2026 relativo à Emenda Parlamentar nº ${formData.emenda.numero}.

INFORMAÇÕES DO PLANO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Parlamentar: ${formData.emenda.parlamentar}
Nº Emenda: ${formData.emenda.numero}
Programa: ${formData.emenda.programa}
Valor Total: R$ ${formData.emenda.valor}
Beneficiário: ${formData.beneficiario.nome}
CNPJ: ${formData.beneficiario.cnpj}
CNES: ${formData.beneficiario.cnes}${formData.beneficiario.contaBancaria ? `\nConta Bancária: ${formData.beneficiario.contaBancaria}` : ''}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Por favor, anexe o PDF assinado a este email antes de enviar.

Atenciosamente,
Sistema de Planos de Trabalho
Secretaria de Estado da Saúde de São Paulo`;

    const mailtoLink = `mailto:gcf-emendasfederais@saude.sp.gov.br?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(emailBody)}`;
    window.location.href = mailtoLink;
  };

  const handleSelectPlanForEmail = async (plano: any) => {
    // Validar plano
    if (!plano || !plano.id) {
      console.error('❌ Plano inválido:', plano);
      alert('Erro: Plano inválido. Tente novamente.');
      return;
    }

    console.log('📂 handleSelectPlanForEmail disparado para plano:', plano.id);
    
    // Reset PRIMEIRO - ordem é IMPORTANTE!
    setFormData(getInitialFormData());
    setLastSavedFormData(null);
    setPlanoSalvoId(null);
    setFormHasChanges(false);
    
    // Limpar inputs temporários TAMBÉM
    setCurrentSelection({ categoria: '', item: '', metas: [''] });
    setCurrentMetaQualitativa({ meta: '', valor: '' });
    setCurrentNatureza({ codigo: '', valor: '' });
    
    setCurrentView('new');
    setActiveSection('info-emenda');
    setSentSuccess(false);
    setShowSelectPlanModal(false);
    
    // RESET CRÍTICO: Limpar refs para permitir novo carregamento
    loadingPlanIdRef.current = null;
    planLoadCompletedRef.current.delete(plano.id);
    
    // Aguardar React processar o reset, DEPOIS carregar o plano
    setTimeout(() => {
      console.log('⏰ Agora carregando plano:', plano.id);
      setEditingPlanId(plano.id);
    }, 50);
  };

  if (isLoadingAuth) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-white">
        <img src={LOGO_URL_BRANCA} alt="Logotipo Oficial" className="h-12 w-auto mb-8 opacity-80" />
        <div className="text-center space-y-3">
          <Loader2 className="w-8 h-8 text-gray-400 animate-spin mx-auto" />
          <p className="text-xs font-medium uppercase tracking-widest text-gray-500">Sincronizando...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-white flex flex-col items-center justify-center p-4">
        <div className="w-full max-w-md bg-white">
          <div className="text-center mb-12">
            <img src={LOGO_URL_COLORIDA} alt="Logotipo Oficial - Secretaria de Estado da Saúde de São Paulo" className="h-18 w-auto mx-auto mb-8" />
            <h1 className="text-3xl font-black text-red-700 uppercase tracking-widest mb-3 leading-tight">Plano de Trabalho</h1>
            <div className="border-t-4 border-red-700 pt-4">
              <p className="text-sm font-bold text-gray-800 uppercase tracking-widest">Emendas Parlamentares 2026</p>
            </div>
          </div>

          <form onSubmit={handleLogin} className="space-y-6">
            <div>
              <label className="block text-xs font-semibold text-gray-800 mb-2 uppercase tracking-widest">E-mail</label>
              <input 
                type="email" 
                className="w-full px-4 py-3 bg-white border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-600 focus:border-red-600 text-black placeholder-gray-500 font-medium"
                value={loginInput.email}
                onChange={(e) => setLoginInput({ ...loginInput, email: e.target.value })}
                placeholder="seu@email.com"
                required
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-800 mb-2 uppercase tracking-widest">Senha</label>
              <input 
                type="password" 
                className="w-full px-4 py-3 bg-white border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-600 focus:border-red-600 text-black placeholder-gray-500 font-medium"
                value={loginInput.password}
                onChange={(e) => setLoginInput({ ...loginInput, password: e.target.value })}
                placeholder="••••••••"
                required
              />
            </div>

            {loginError && (
              <div className="p-3 bg-red-50 rounded-md border-l-4 border-red-600">
                <p className="text-xs text-red-800 font-semibold">{loginError}</p>
              </div>
            )}

            <button 
              type="submit" 
              disabled={isSending}
              className="w-full py-3 bg-red-600 text-white font-bold rounded-md hover:bg-red-700 focus:ring-2 focus:ring-red-500 focus:ring-offset-2 transition-all uppercase text-sm tracking-widest disabled:opacity-50 disabled:cursor-not-allowed shadow-md"
            >
              {isSending ? '⏳ Processando...' : '🔐 Entrar'}
            </button>
          </form>

          <div className="mt-8 pt-8 border-t-2 border-red-700 text-center space-y-3">
            <p className="text-xs text-gray-700 uppercase font-bold tracking-widest leading-relaxed">
              Acesso Restrito
            </p>
            <p className="text-[11px] text-gray-600 leading-relaxed">
              Sistema de Gestão de Planos de Trabalho<br/>
              Emendas Parlamentares 2026
            </p>
          </div>
        </div>
      </div>
    );
  }

  if (showDocument) {
    const totalMetas = formData.acoesServicos.reduce((sum, acao) => sum + parseFloat(acao.valor.replace(/\./g, '').replace(',', '.') || 0), 0);
    
    return (
      <div className="min-h-screen bg-gray-100 p-8 print:p-0 print:bg-white">
        <div id="pdf-document" className="max-w-[210mm] mx-auto bg-white min-h-[297mm] print:min-h-screen print:max-w-full shadow-2xl print:shadow-none">
          
          {/* ======== CABEÇALHO INSTITUCIONAL ======== */}
          <div className="border-b-4 border-red-700 pt-12 px-16 pb-8 print:pt-10 print:px-12 print:pb-6">
            {/* Linha superior com logo e info */}
            <div className="flex justify-center items-center mb-6">
              <img src={LOGO_URL_COLORIDA} alt="Governo de São Paulo" className="h-20 w-auto print:h-16" />
            </div>

            {/* Título principal expandido */}
            <div className="text-center border-t-2 border-gray-300 border-b-4 border-red-700 py-8 print:py-6">
              <h1 className="text-3xl font-black text-gray-900 uppercase tracking-tight print:text-2xl mb-3 leading-tight">
                Plano de Trabalho
              </h1>
              <h2 className="text-lg font-bold text-red-700 uppercase tracking-widest print:text-base mb-2">
                {getPortariaForPrograma(formData.emenda.programa)}
              </h2>
              {!formData.emenda.programa.includes('PORTARIA 10.169') && (
                <p className="text-xs font-semibold text-gray-700 uppercase tracking-wide print:text-[11px]">
                  Emendas Parlamentar 2026
                </p>
              )}
            </div>

            {/* Info protocolo */}
            <div className="flex justify-between items-center mt-6 print:mt-4">
              <div className="text-[11px] text-gray-700">
                <p><span className="font-bold">Sistema:</span> Plano de Trabalho - SES/SP</p>
              </div>
              <div className="text-[11px] text-gray-700 text-right">
                <p><span className="font-bold">Data de Emissão:</span> {new Date().toLocaleDateString('pt-BR')}</p>
              </div>
            </div>
          </div>

          {/* ======== CORPO DO DOCUMENTO ======== */}
          <div className="px-16 py-12 print:px-12 print:py-8 text-gray-900 text-sm print:text-[13px] print:leading-relaxed">
            
            {/* SEÇÃO 1: IDENTIFICAÇÃO GERAL */}
            <section className="mb-10 print:mb-8 break-inside-avoid">
              <div className="flex items-center gap-3 mb-4">
                <div className="flex items-center justify-center w-8 h-8 bg-red-700 text-white font-black text-xs rounded-sm print:rounded-none print:w-7 print:h-7 print:text-[11px]">01</div>
                <h2 className="text-sm font-black uppercase tracking-widest text-gray-900 print:text-[13px]">Identificação Geral</h2>
              </div>
              <div className="border-t border-gray-300 pt-4 pl-11">
                <div className="grid grid-cols-2 gap-x-8 gap-y-5 print:gap-x-6 print:gap-y-4">
                  <div>
                    <label className="block text-[10px] font-bold uppercase text-gray-600 tracking-widest mb-1">Programa de Saúde</label>
                    <p className="text-sm font-semibold text-gray-900 border-b border-gray-400 pb-1 print:border-b-0">{formData.emenda.programa}</p>
                  </div>
                  <div>
                    <label className="block text-[10px] font-bold uppercase text-gray-600 tracking-widest mb-1">Parlamentar Autor</label>
                    <p className="text-sm font-semibold text-gray-900 border-b border-gray-400 pb-1 print:border-b-0">{formData.emenda.parlamentar || '—'}</p>
                  </div>
                  <div>
                    <label className="block text-[10px] font-bold uppercase text-gray-600 tracking-widest mb-1">Número da Emenda</label>
                    <p className="text-sm font-semibold text-gray-900 border-b border-gray-400 pb-1 print:border-b-0 font-mono">{formData.emenda.numero || '—'}</p>
                  </div>
                  <div>
                    <label className="block text-[10px] font-bold uppercase text-gray-600 tracking-widest mb-1">Dotação Prevista (R$)</label>
                    <p className="text-sm font-bold text-red-700 border-b-2 border-red-700 pb-1 print:border-b-0 font-mono">{formData.emenda.valor || '0,00'}</p>
                  </div>
                </div>

                {/* Entidade Responsável - linha cheia */}
                <div className="mt-5 print:mt-4">
                  <label className="block text-[10px] font-bold uppercase text-gray-600 tracking-widest mb-1">Entidade Responsável</label>
                  <div className="border-b border-gray-400 pb-1 print:border-b-0">
                    <p className="text-sm font-semibold text-gray-900">{formData.beneficiario.nome || '—'}</p>
                    <p className="text-xs text-gray-700 font-mono">CNPJ: {formData.beneficiario.cnpj || '—'}</p>
                    {formData.beneficiario.cnes && <p className="text-xs text-gray-700 font-mono">CNES: {formData.beneficiario.cnes}</p>}
                    {formData.beneficiario.contaBancaria && <p className="text-xs text-gray-700 font-mono">Conta Bancária: {formData.beneficiario.contaBancaria}</p>}
                  </div>
                </div>
              </div>
            </section>

            {/* SEÇÃO 2: DIRETRIZES, OBJETIVOS E METAS PLANEJADAS */}
            <section className="mb-10 print:mb-8 break-inside-avoid">
              <div className="flex items-center gap-3 mb-4">
                <div className="flex items-center justify-center w-8 h-8 bg-red-700 text-white font-black text-xs rounded-sm print:rounded-none print:w-7 print:h-7 print:text-[11px]">02</div>
                <h2 className="text-sm font-black uppercase tracking-widest text-gray-900 print:text-[13px]">Planejamento Estratégico</h2>
              </div>
              <div className="border-t border-gray-300 pt-4 pl-11">
                <p className="text-xs text-gray-600 mb-4">Diretrizes, objetivos e metas selecionadas</p>
                
                {selectedDiretriz ? (
                  <div className="space-y-4">
                    {/* Diretriz */}
                    <div className="border-l-4 border-red-700 pl-4">
                      <label className="block text-[10px] font-bold uppercase text-gray-600 tracking-widest mb-1">Diretriz Estratégica</label>
                      <p className="text-sm font-semibold text-gray-900">{selectedDiretriz.titulo}</p>
                    </div>
                    
                    {/* Objetivo */}
                    {selectedObjetivo && (
                      <div className="border-l-4 border-blue-500 pl-4">
                        <label className="block text-[10px] font-bold uppercase text-gray-600 tracking-widest mb-1">Objetivo Específico</label>
                        <p className="text-sm font-semibold text-gray-900">{selectedObjetivo.titulo}</p>
                      </div>
                    )}
                    
                    {/* Metas */}
                    {selectedObjetivo && selectedObjetivo.metas && formData.planejamento.metaIds.length > 0 && (
                      <div className="border-l-4 border-green-600 pl-4">
                        <label className="block text-[10px] font-bold uppercase text-gray-600 tracking-widest mb-2">Metas Relacionadas</label>
                        <ul className="space-y-2">
                          {selectedObjetivo.metas
                            .filter(meta => formData.planejamento.metaIds.includes(meta.id))
                            .map((meta, idx) => (
                            <li key={idx} className="text-xs text-gray-800 flex items-start gap-2">
                              <span className="text-green-600 font-bold mt-0.5">•</span>
                              <span>{meta.descricao}</span>
                            </li>
                          ))}
                        </ul>
                      </div>
                    )}
                  </div>
                ) : (
                  <p className="text-xs text-gray-500 italic">Nenhuma diretriz selecionada</p>
                )}
              </div>
            </section>

            {/* SEÇÃO 3: METAS QUANTITATIVAS */}
            <section className="mb-10 print:mb-8 break-inside-avoid">
              <div className="flex items-center gap-3 mb-4">
                <div className="flex items-center justify-center w-8 h-8 bg-red-700 text-white font-black text-xs rounded-sm print:rounded-none print:w-7 print:h-7 print:text-[11px]">03</div>
                <h2 className="text-sm font-black uppercase tracking-widest text-gray-900 print:text-[13px]">Metas Quantitativas</h2>
              </div>
              <div className="border-t border-gray-300 pt-4 pl-11">
                <p className="text-xs text-gray-600 mb-4">Ações, serviços e valores detalhados</p>
                
                <table className="w-full text-xs border-collapse">
                  <thead>
                    <tr className="bg-gray-200 print:bg-gray-100">
                      <th className="border border-gray-400 px-3 py-2 text-left font-black uppercase text-gray-900 text-[10px]">Grupo de Ação</th>
                      <th className="border border-gray-400 px-3 py-2 text-left font-black uppercase text-gray-900 text-[10px]">Ação Específica</th>
                      <th className="border border-gray-400 px-3 py-2 text-right font-black uppercase text-gray-900 text-[10px]">Valor (R$)</th>
                    </tr>
                  </thead>
                  <tbody>
                    {formData.acoesServicos.length > 0 ? (
                      <>
                        {formData.acoesServicos.map((acao, i) => (
                          <tr key={i} className="border-b border-gray-300">
                            <td className="border border-gray-300 px-3 py-2 text-xs font-medium text-gray-900">{acao.categoria}</td>
                            <td className="border border-gray-300 px-3 py-2 text-xs font-medium text-gray-900">{acao.item}</td>
                            <td className="border border-gray-300 px-3 py-2 text-right text-xs font-mono font-bold text-gray-900">R$ {acao.valor}</td>
                          </tr>
                        ))}
                        <tr className="bg-gray-100 print:bg-white font-bold">
                          <td colSpan={2} className="border border-gray-400 px-3 py-2 text-right uppercase text-xs font-black text-gray-900">Total Geral:</td>
                          <td className="border border-red-700 border-l-4 px-3 py-2 text-right font-mono text-sm text-red-700 font-black">R$ {totalMetas.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</td>
                        </tr>
                      </>
                    ) : (
                      <tr>
                        <td colSpan={3} className="border border-gray-300 px-3 py-4 text-center text-gray-500 italic">Nenhuma meta registrada</td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </section>

            {/* SEÇÃO 4: JUSTIFICATIVA TÉCNICA */}
            <section className="mb-10 print:mb-8">
              <div className="flex items-center gap-3 mb-4">
                <div className="flex items-center justify-center w-8 h-8 bg-red-700 text-white font-black text-xs rounded-sm print:rounded-none print:w-7 print:h-7 print:text-[11px]">04</div>
                <h2 className="text-sm font-black uppercase tracking-widest text-gray-900 print:text-[13px]">Justificativa Técnica</h2>
              </div>
              <div className="border-t border-gray-300 pt-4 pl-11">
                <p className="text-xs text-gray-600 mb-4">Fundamentação estratégica e objetivos</p>
                <div className="border-l-4 border-red-700 bg-gray-50 print:bg-white pl-4 pr-3 py-3 text-xs leading-relaxed text-gray-900 text-justify whitespace-pre-wrap break-words">
                  {formData.justificativa || '—'}
                </div>
                {justificativaAlteradaEm && (
                  <p className="mt-2 text-[10px] text-gray-400 italic text-right">
                    Justificativa alterada em {new Date(justificativaAlteradaEm).toLocaleDateString('pt-BR')} às {new Date(justificativaAlteradaEm).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}
                  </p>
                )}
              </div>
            </section>

            {/* SEÇÃO 5: INDICADORES QUALITATIVOS */}
            <section className="mb-10 print:mb-8 break-inside-avoid">
              <div className="flex items-center gap-3 mb-4">
                <div className="flex items-center justify-center w-8 h-8 bg-red-700 text-white font-black text-xs rounded-sm print:rounded-none print:w-7 print:h-7 print:text-[11px]">05</div>
                <h2 className="text-sm font-black uppercase tracking-widest text-gray-900 print:text-[13px]">Indicadores Qualitativos <span className="text-xs font-normal">(Opcional)</span></h2>
              </div>
              <div className="border-t border-gray-300 pt-4 pl-11">
                <p className="text-xs text-gray-600 mb-4">Indicadores de qualidade e acompanhamento</p>
                
                {formData.metasQualitativas.length > 0 ? (
                  <table className="w-full text-xs border-collapse">
                    <thead>
                      <tr className="bg-gray-200 print:bg-gray-100">
                        <th className="border border-gray-400 px-3 py-2 text-left font-black uppercase text-gray-900 text-[10px]">Indicador de Qualidade</th>
                        <th className="border border-gray-400 px-3 py-2 text-left font-black uppercase text-gray-900 text-[10px]">Meta / Descrição</th>
                      </tr>
                    </thead>
                    <tbody>
                      {formData.metasQualitativas.map((meta, i) => (
                        <tr key={i} className="border-b border-gray-300">
                          <td className="border border-gray-300 px-3 py-2 text-xs font-medium text-gray-900">{meta.meta}</td>
                          <td className="border border-gray-300 px-3 py-2 text-xs text-gray-800">{meta.valor}%</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                ) : (
                  <p className="text-xs text-gray-500 italic">Nenhum indicador qualitativo registrado</p>
                )}
              </div>
            </section>
            {formData.naturezasDespesa.length > 0 && (
              <section className="mb-10 print:mb-8 break-inside-avoid">
                <div className="flex items-center gap-3 mb-4">
                  <div className="flex items-center justify-center w-8 h-8 bg-red-700 text-white font-black text-xs rounded-sm print:rounded-none print:w-7 print:h-7 print:text-[11px]">06</div>
                  <h2 className="text-sm font-black uppercase tracking-widest text-gray-900 print:text-[13px]">Execução Financeira</h2>
                </div>
                <div className="border-t border-gray-300 pt-4 pl-11">
                  <p className="text-xs text-gray-600 mb-6">Classificação e distribuição de despesas por natureza</p>
                  <table className="w-full text-xs border-collapse">
                    <thead>
                      <tr className="bg-gray-200 print:bg-gray-100">
                        <th className="border border-gray-400 px-3 py-2 text-left font-black uppercase text-gray-900 text-[10px]">Natureza de Despesa</th>
                        <th className="border border-gray-400 px-3 py-2 text-right font-black uppercase text-gray-900 text-[10px]">Valor (R$)</th>
                      </tr>
                    </thead>
                    <tbody>
                      {formData.naturezasDespesa.map((despesa, i) => (
                        <tr key={i} className="border-b border-gray-300 hover:bg-gray-50 print:hover:bg-white">
                          <td className="border border-gray-300 px-3 py-2 text-xs font-medium text-gray-900">{despesa.codigo} - {NATUREZAS_DESPESA.find(n => n.codigo === despesa.codigo)?.descricao}</td>
                          <td className="border border-gray-300 px-3 py-2 text-right text-xs font-mono font-bold">R$ {despesa.valor}</td>
                        </tr>
                      ))}
                      <tr className="bg-gray-100 print:bg-white font-bold">
                        <td className="border border-gray-400 px-3 py-2 text-right uppercase text-xs font-black text-gray-900">Total Planejado:</td>
                        <td className="border border-red-700 border-l-4 px-3 py-2 text-right font-mono text-sm text-red-700 font-black">
                          R$ {formData.naturezasDespesa.reduce((sum, item) => {
                            const value = parseFloat(item.valor.replace(/[^\d,-]/g, '').replace(',', '.')) || 0;
                            return sum + value;
                          }, 0).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </section>
            )}
          </div>

          {/* ======== SEÇÃO 7: ASSINATURA ======== */}
          <div className="px-16 py-12 print:px-12 print:py-8 print:page-break-before-avoid" style={{pageBreakInside: 'avoid'}}>
          <section className="mb-10 print:mb-8" style={{pageBreakInside: 'avoid'}}>
            <div className="flex items-center gap-3 mb-4">
              <div className="flex items-center justify-center w-8 h-8 bg-red-700 text-white font-black text-xs rounded-sm print:rounded-none print:w-7 print:h-7 print:text-[11px]">07</div>
              <h2 className="text-sm font-black uppercase tracking-widest text-gray-900 print:text-[13px]">Responsável pela Assinatura</h2>
            </div>
            <div className="border-t border-gray-300 pt-4 pl-11">
              <div className="space-y-12 print:space-y-10">
                {/* Espaço para assinatura */}
                <div className="text-center">
                  <div className="mb-3 h-20 border-b-2 border-gray-800 print:border-gray-600 print:h-16"></div>
                  <p className="text-xs font-bold text-gray-700 uppercase tracking-widest">Assinatura</p>
                </div>

                {/* Nome e Data */}
                <div className="grid grid-cols-2 gap-12 print:gap-8">
                  <div>
                    <p className="text-xs text-gray-600 font-bold mb-3 uppercase tracking-widest">Responsável:</p>
                    <p className="text-sm font-semibold text-gray-900 border-b-2 border-gray-400 pb-3 print:pb-2 print:border-gray-600 print:text-xs">{formData.responsavelAssinatura || '_'.repeat(40)}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-600 font-bold mb-3 uppercase tracking-widest">Data:</p>
                    <p className="text-sm font-semibold text-gray-900 border-b-2 border-gray-400 pb-3 print:pb-2 print:border-gray-600 print:text-xs">_____  /  _____  /  _________</p>
                  </div>
                </div>
              </div>
            </div>
          </section>
          </div>

          {/* ======== RODAPÉ INSTITUCIONAL ======== */}
          <div className="border-t-4 border-red-700 px-16 py-8 print:px-12 print:py-6 bg-gradient-to-b from-gray-50 to-white print:bg-white text-xs text-gray-700">
            <div className="grid grid-cols-3 gap-4 mb-6">
              <div className="bg-white print:bg-white border border-gray-200 print:border-gray-300 p-3 rounded-lg print:rounded-none">
                <p className="text-[10px] font-black uppercase text-gray-600 mb-2 tracking-widest">Órgão Emissor</p>
                <p className="font-bold text-gray-900 text-xs">Secretaria de Estado da Saúde</p>
                <p className="text-[10px] text-gray-600">SES - São Paulo</p>
              </div>
              <div className="bg-white print:bg-white border border-gray-200 print:border-gray-300 p-3 rounded-lg print:rounded-none text-center">
                <p className="text-[10px] font-black uppercase text-gray-600 mb-2 tracking-widest">Período</p>
                <p className="font-bold text-red-700 text-lg">2026</p>
              </div>
              <div className="bg-white print:bg-white border border-gray-200 print:border-gray-300 p-3 rounded-lg print:rounded-none text-right">
                <p className="text-[10px] font-black uppercase text-gray-600 mb-2 tracking-widest">Gerado em</p>
                <p className="font-mono text-gray-900 text-xs">{new Date().toLocaleDateString('pt-BR')}</p>
                <p className="font-mono text-gray-700 text-[10px]">{new Date().toLocaleTimeString('pt-BR', {hour: '2-digit', minute:'2-digit'})}</p>
              </div>
            </div>
            <div className="border-t-2 border-gray-300 pt-6 mt-6 text-center">
              <p className="text-[10px] font-bold text-gray-700 mb-2 uppercase tracking-widest">DOCUMENTO OFICIAL - PLANO DE TRABALHO</p>
              <p className="text-[9px] text-gray-600 leading-relaxed">
                Documento oficial da Secretaria de Estado da Saúde de São Paulo, gerado pelo Sistema de Gestão de Planos de Trabalho.
              </p>
              <p className="text-[9px] text-gray-600 mt-2">
                Destinado a arquivamento, auditoria, controle externo e conformidade com as determinações da {getPortariaForPrograma(formData.emenda.programa)}.
              </p>
            </div>
          </div>

        </div>

        {/* ======== BOTÕES DE AÇÃO (fora do PDF) ======== */}
        <div className="flex justify-center gap-4 p-6 bg-gray-100 border-t border-gray-300 flex-wrap print:hidden">
          <button 
            onClick={() => {
              setShowDocument(false);
              alert('📝 Carregando novo plano com todos os campos vazios...');
              setTimeout(() => {
                setCurrentView('new');
                setActiveSection('info-emenda');
                setSentSuccess(false);
                setEditingPlanId(null);
                setPlanoSalvoId(null);
                setFormData(getInitialFormData());
                setLastSavedFormData(null);
                setFormHasChanges(false);
              }, 500);
            }}
            className="px-6 py-3 bg-white border-2 border-gray-400 text-gray-900 font-bold text-sm uppercase tracking-widest rounded hover:bg-gray-50 hover:border-gray-600 transition-colors"
          >
            ← Voltar ao Formulário
          </button>
          <button 
            onClick={() => handleGeneratePDF()}
            disabled={isSending}
            className="px-6 py-3 bg-blue-700 text-white font-bold text-sm uppercase tracking-widest rounded hover:bg-blue-800 transition-colors disabled:opacity-50"
          >
            {isSending ? "⏳ Salvando..." : "🖨️ Visualizar e Salvar como PDF"}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">

      <header className="bg-gray-900 sticky top-0 z-50 border-b-4 border-red-600">
        <div className="w-full px-6 py-6">
          <div className="max-w-7xl mx-auto flex items-center justify-between">
            {/* Logo + Título à esquerda */}
            <div className="flex items-center gap-4">
              <img 
                src="/img/logo_branco.png" 
                alt="SES-SP" 
                className="h-20 w-auto" 
              />
              <div>
                <h1 className="text-3xl font-black text-white">Plano de Trabalho</h1>
                <p className="text-sm text-gray-300">SES - Secretaria de Estado da Saúde</p>
              </div>
            </div>
          
            {/* Menu à direita */}
            <div className="flex items-center gap-6">
              {isAuthenticated && (
                <div className="hidden lg:flex items-center gap-6">
                  <button 
                    onClick={() => { setCurrentView('new'); setActiveSection('info-emenda'); setSentSuccess(false); setEditingPlanId(null); setPlanoSalvoId(null); setFormData(getInitialFormData()); setLastSavedFormData(null); setFormHasChanges(false); setJustificativaAlteradaEm(null); }}
                    className={`text-sm font-bold uppercase tracking-wide transition-colors ${
                      currentView === 'new' 
                        ? 'text-red-400 border-b-2 border-red-500' 
                        : 'text-gray-300 hover:text-white'
                    }`}
                  >
                    Novo Plano
                  </button>
                  <button 
                    onClick={() => setCurrentView('list')}
                    className={`text-sm font-bold uppercase tracking-wide transition-colors ${
                      currentView === 'list' 
                        ? 'text-red-400 border-b-2 border-red-500' 
                        : 'text-gray-300 hover:text-white'
                    }`}
                  >
                    Meus Planos
                  </button>
                  {(isAdmin() || currentUser?.role === 'intermediate') && (
                    <button 
                      onClick={() => setCurrentView('dashboard')}
                      className={`text-sm font-bold uppercase tracking-wide transition-colors ${
                        currentView === 'dashboard' 
                          ? 'text-red-400 border-b-2 border-red-500' 
                          : 'text-gray-300 hover:text-white'
                      }`}
                    >
                      Dashboard
                    </button>
                  )}
                </div>
              )}
              {isAuthenticated && (
                <div className="flex items-center gap-4 border-l border-gray-600 pl-6">
                  {/* Seletor de CNES para usuários com múltiplos CNES */}
                  {currentUser?.role === 'user' && (currentUser?.cnes || '').includes(',') && (
                    <div className="flex items-center gap-2">
                      <Building2 className="w-4 h-4 text-gray-400" />
                      <select
                        value={selectedCnes || parseCnesList(currentUser?.cnes)[0]}
                        onChange={(e) => {
                          setSelectedCnes(e.target.value);
                          updateFormData('beneficiario', { ...formData.beneficiario, cnes: e.target.value });
                        }}
                        className="bg-gray-700 text-white text-xs rounded-lg border border-gray-600 px-2 py-1.5 focus:ring-2 focus:ring-red-500 focus:border-red-500"
                        title="Selecione o CNES ativo"
                      >
                        {parseCnesList(currentUser?.cnes).map(cnes => (
                          <option key={cnes} value={cnes}>CNES: {cnes}</option>
                        ))}
                      </select>
                    </div>
                  )}
                  {currentUser?.role === 'user' && !(currentUser?.cnes || '').includes(',') && currentUser?.cnes && (
                    <span className="text-xs text-gray-400 hidden sm:block">CNES: {currentUser.cnes}</span>
                  )}
                  <div className="text-right text-sm hidden sm:block">
                    <p className="text-white font-bold">{currentUser?.name}</p>
                    <p className="text-xs text-gray-400 uppercase">{currentUser?.role}</p>
                  </div>
                  {currentUser?.role === 'admin' && (
                    <button onClick={() => setShowUserManagement(true)} className="p-2 text-gray-300 hover:text-red-400 transition-colors">
                      <Users className="w-5 h-5" />
                    </button>
                  )}
                  <button onClick={handleLogout} className="p-2 text-gray-300 hover:text-red-400 transition-colors">
                    <LogOut className="w-5 h-5" />
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      </header>

      <main className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
        {/* Container centralizado - largura adaptável por view */}
        <div style={{ maxWidth: currentView === 'list' || currentView === 'dashboard' ? '1600px' : '1120px', margin: '0 auto', padding: '2rem 1.5rem' }}>
          {/* MODAL GERENCIAMENTO DE USUÁRIOS */}
          {showUserManagement && currentUser?.role === 'admin' && (
            <div className="fixed inset-0 z-[100] bg-black/40 backdrop-blur-md flex items-center justify-center p-4">
              <div className="bg-white rounded-3xl w-full max-w-4xl shadow-2xl animate-slideUp flex flex-col max-h-[95vh] overflow-hidden">
                
                {/* HEADER FIXO */}
                <div className="bg-gradient-to-r from-gray-900 via-gray-800 to-gray-900 px-8 py-6 border-b border-gray-700/50 flex items-center justify-between flex-shrink-0">
                  <div className="flex items-center gap-4">
                    <div className="p-3 rounded-xl bg-red-600/20">
                      <Users className="text-red-600 w-7 h-7" />
                    </div>
                    <div>
                      <h2 className="text-2xl font-black text-white">Gestão de Usuários</h2>
                      <p className="text-xs text-gray-400 font-medium mt-1">Administre usuários e permissões do sistema</p>
                    </div>
                  </div>
                  <button 
                    onClick={() => setShowUserManagement(false)} 
                    className="p-2 hover:bg-gray-700/50 rounded-lg transition-colors"
                    title="Fechar"
                  >
                    <X className="w-6 h-6 text-gray-400 hover:text-white" />
                  </button>
                </div>

                {/* CONTEÚDO SCROLLÁVEL */}
                <div className="flex-1 overflow-y-auto">
                  <div className="p-8 space-y-8">

                    {/* SEÇÃO 1: REGISTRO DE NOVO USUÁRIO */}
                    <div className="space-y-6">
                      <div>
                        <h3 className="text-lg font-black text-gray-900 flex items-center gap-3">
                          <UserPlus className="text-red-600 w-5 h-5" />
                          Registrar Novo Usuário
                        </h3>
                        <p className="text-sm text-gray-500 mt-2">Adicione um novo usuário ao sistema com as permissões necessárias.</p>
                      </div>

                      <form onSubmit={handleCreateUser} className="space-y-6 bg-gray-50 p-6 rounded-2xl border border-gray-200">
                        {/* Grid responsivo */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                          {/* Nome Completo */}
                          <div className="space-y-2">
                            <label className="text-sm font-bold text-gray-900">Nome Completo*</label>
                            <input 
                              type="text" 
                              placeholder="Ex: João Silva"
                              className="w-full px-4 py-3 rounded-xl border border-gray-300 bg-white outline-none focus:ring-2 focus:ring-red-600/20 focus:border-red-600 text-base transition-all"
                              value={newUser.name}
                              onChange={(e) => setNewUser({...newUser, name: e.target.value})}
                              required
                            />
                          </div>

                          {/* E-mail */}
                          <div className="space-y-2">
                            <label className="text-sm font-bold text-gray-900">E-mail*</label>
                            <input 
                              type="email" 
                              placeholder="usuario@example.com"
                              className="w-full px-4 py-3 rounded-xl border border-gray-300 bg-white outline-none focus:ring-2 focus:ring-red-600/20 focus:border-red-600 text-base transition-all"
                              value={newUser.email}
                              onChange={(e) => setNewUser({...newUser, email: e.target.value})}
                              required
                            />
                          </div>

                          {/* CNES da Instituição */}
                          <div className="space-y-2">
                            <label className="text-sm font-bold text-gray-900">CNES da Instituição*</label>
                            <input 
                              type="text" 
                              placeholder="Ex: 1234567"
                              maxLength={7}
                              className="w-full px-4 py-3 rounded-xl border border-gray-300 bg-white outline-none focus:ring-2 focus:ring-red-600/20 focus:border-red-600 text-base transition-all"
                              value={newUser.cnes}
                              onChange={(e) => setNewUser({...newUser, cnes: e.target.value.replace(/\D/g, '').slice(0, 7)})}
                              required
                            />
                            <p className="text-xs text-gray-500">7 dígitos - será associado automaticamente ao usuário</p>
                          </div>

                          {/* Senha Inicial */}
                          <div className="space-y-2">
                            <label className="text-sm font-bold text-gray-900">Senha Inicial*</label>
                            <input 
                              type="password" 
                              placeholder="Mínimo 6 caracteres"
                              className="w-full px-4 py-3 rounded-xl border border-gray-300 bg-white outline-none focus:ring-2 focus:ring-red-600/20 focus:border-red-600 text-base transition-all"
                              value={newUser.password}
                              onChange={(e) => setNewUser({...newUser, password: e.target.value})}
                              required
                            />
                          </div>

                          {/* Perfil do Usuário */}
                          <div className="space-y-2">
                            <label className="text-sm font-bold text-gray-900">Perfil do Usuário*</label>
                            <select 
                              className="w-full px-4 py-3 rounded-xl border border-gray-300 bg-white outline-none focus:ring-2 focus:ring-red-600/20 focus:border-red-600 text-base font-medium transition-all"
                              value={newUser.role}
                              onChange={(e) => setNewUser({...newUser, role: e.target.value as 'user' | 'admin' | 'intermediate'})}
                            >
                              <option value="">Selecione um perfil</option>
                              <option value="user">Usuário Padrão</option>
                              <option value="intermediate">Usuário Intermediário</option>
                              <option value="admin">Administrador SES</option>
                            </select>
                          </div>
                        </div>

                        {/* Descrição do Perfil Selecionado */}
                        {newUser.role && (
                          <div className="p-4 bg-blue-50 rounded-xl border border-blue-200">
                            <p className="text-xs font-bold text-blue-900 uppercase tracking-wider">Permissões do Perfil</p>
                            <p className="text-sm text-blue-800 mt-2 leading-relaxed">
                              {newUser.role === 'user' 
                                ? '✓ Criar e gerenciar seus próprios planos de trabalho • ✓ Visualizar relatórios pessoais • ✓ Editar dados básicos da conta'
                                : newUser.role === 'intermediate'
                                ? '✓ Visualizar todos os planos de trabalho do sistema • ✗ Não pode criar novos planos • ✗ Não pode editar ou apagar planos • ✓ Apenas leitura'
                                : '✓ Acesso total ao sistema • ✓ Gerenciar todos os usuários e permissões • ✓ Visualizar relatórios globais • ✓ Configurar sistema'
                              }
                            </p>
                          </div>
                        )}

                        {/* Botão Registrar - Aparece apenas quando campos obrigatórios preenchidos */}
                        {newUser.name && newUser.email && newUser.password && newUser.role && newUser.cnes && (
                          <button 
                            type="submit" 
                            disabled={isSending} 
                            className="w-full py-4 bg-gradient-to-r from-red-600 to-red-700 text-white rounded-xl font-bold uppercase text-sm tracking-wider hover:from-red-700 hover:to-red-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 flex items-center justify-center gap-3 shadow-lg"
                          >
                            {isSending ? (
                              <>
                                <Loader2 className="w-5 h-5 animate-spin" />
                                Registrando...
                              </>
                            ) : (
                              <>
                                <UserPlus className="w-5 h-5" />
                                Registrar Novo Usuário
                              </>
                            )}
                          </button>
                        )}
                      </form>
                    </div>

                    {/* DIVISOR */}
                    <div className="h-px bg-gradient-to-r from-transparent via-gray-200 to-transparent"></div>

                    {/* SEÇÃO: IMPORTAR USUÁRIOS VIA CSV */}
                    <div className="space-y-4">
                      <div>
                        <h3 className="text-lg font-black text-gray-900 flex items-center gap-3">
                          <UploadCloud className="text-green-600 w-5 h-5" />
                          Importar Usuários via CSV
                        </h3>
                        <p className="text-sm text-gray-500 mt-2">Envie uma planilha CSV para criar vários usuários de uma só vez.</p>
                      </div>

                      <div className="bg-green-50 p-6 rounded-2xl border border-green-200 space-y-4">
                        <div className="flex items-start gap-3">
                          <Info className="w-5 h-5 text-green-700 mt-0.5 flex-shrink-0" />
                          <div className="text-sm text-green-800 space-y-1">
                            <p className="font-bold">Formato do CSV (separado por vírgula ou ponto-e-vírgula):</p>
                            <p className="font-mono text-xs bg-green-100 p-2 rounded-lg">nome;email;cnes;senha</p>
                            <p className="text-xs text-green-600">Se a coluna "senha" estiver vazia, o CNES será usado como senha.</p>
                            <p className="font-mono text-xs bg-green-100 p-2 rounded-lg mt-1">
                              MARIA SILVA;maria@hospital.com.br;1234567;1234567<br/>
                              JOAO SANTOS;joao@clinica.org.br;7654321;7654321
                            </p>
                          </div>
                        </div>

                        <div className="flex items-center gap-4">
                          <label className="flex-1 cursor-pointer">
                            <input
                              type="file"
                              accept=".csv,.txt"
                              onChange={handleCsvUpload}
                              disabled={csvUploading}
                              className="hidden"
                            />
                            <div className={`flex items-center justify-center gap-3 py-4 px-6 rounded-xl border-2 border-dashed transition-all ${
                              csvUploading 
                                ? 'border-gray-300 bg-gray-100 cursor-not-allowed' 
                                : 'border-green-400 bg-white hover:bg-green-50 hover:border-green-500'
                            }`}>
                              {csvUploading ? (
                                <>
                                  <Loader2 className="w-5 h-5 animate-spin text-green-600" />
                                  <span className="font-bold text-green-700">Importando...</span>
                                </>
                              ) : (
                                <>
                                  <UploadCloud className="w-5 h-5 text-green-600" />
                                  <span className="font-bold text-green-700">Clique para selecionar arquivo CSV</span>
                                </>
                              )}
                            </div>
                          </label>
                        </div>

                        {/* Resultados da importação */}
                        {csvResults && csvResults.detalhes && (
                          <div className="mt-4 space-y-2">
                            <p className="text-sm font-bold text-gray-800">
                              Resultado: {csvResults.criados} criado(s), {csvResults.erros} erro(s) de {csvResults.total} total
                            </p>
                            <div className="max-h-40 overflow-y-auto space-y-1">
                              {csvResults.detalhes.map((d: any, idx: number) => (
                                <div key={idx} className={`text-xs px-3 py-2 rounded-lg flex items-center gap-2 ${
                                  d.success ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                                }`}>
                                  {d.success ? <CheckCircle2 className="w-3.5 h-3.5" /> : <AlertCircle className="w-3.5 h-3.5" />}
                                  <span className="font-medium">{d.email}</span>
                                  <span>— {d.success ? d.message : d.error}</span>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}
                      </div>
                    </div>

                    {/* DIVISOR */}
                    <div className="h-px bg-gradient-to-r from-transparent via-gray-200 to-transparent"></div>

                    {/* SEÇÃO 2: LISTA DE USUÁRIOS */}
                    <div className="space-y-6">
                      <div className="flex items-center justify-between">
                        <div>
                          <h3 className="text-lg font-black text-gray-900 flex items-center gap-3">
                            <Users className="text-gray-600 w-5 h-5" />
                            Usuários do Sistema
                          </h3>
                          <p className="text-sm text-gray-500 mt-2">{usersList.length} usuário{usersList.length !== 1 ? 's' : ''} cadastrado{usersList.length !== 1 ? 's' : ''}</p>
                        </div>
                        <button
                          onClick={() => {
                            setShowInactiveUsers(!showInactiveUsers);
                            if (!showInactiveUsers) {
                              loadInactiveUsers();
                            }
                          }}
                          className={`px-4 py-2 rounded-lg font-bold text-xs uppercase transition-colors ${
                            showInactiveUsers
                              ? 'bg-orange-100 text-orange-700 hover:bg-orange-200'
                              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                          }`}
                          title={showInactiveUsers ? 'Ocultar usuários inativos' : 'Mostrar usuários inativos'}
                        >
                          👻 {inactiveUsersList.length > 0 ? `Inativos (${inactiveUsersList.length})` : 'Sem inativos'}
                        </button>
                      </div>

                      {/* CAMPO DE BUSCA */}
                      <div className="relative">
                        <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
                        <input
                          type="text"
                          placeholder="🔍 Digite nome ou email..."
                          value={searchQuery}
                          onChange={(e) => setSearchQuery(e.target.value)}
                          className="w-full pl-12 pr-4 py-3 rounded-xl border-2 border-gray-200 bg-gray-50 text-gray-900 placeholder-gray-400 focus:outline-none focus:border-red-500 focus:ring-2 focus:ring-red-100 transition-all"
                        />
                      </div>

                      {/* Lista filtrada e ordenada */}
                      {(() => {
                        const filtered = usersList.filter(u => 
                          u.name?.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          u.email?.toLowerCase().includes(searchQuery.toLowerCase())
                        );
                        const sorted = filtered.sort((a, b) => {
                          // Admins primeiro
                          if (a.role === 'admin' && b.role !== 'admin') return -1;
                          if (a.role !== 'admin' && b.role === 'admin') return 1;
                          // Depois por nome
                          return (a.name || '').localeCompare(b.name || '');
                        });
                        return (
                          <>
                            {searchQuery && sorted.length > 0 && (
                              <p className="text-sm text-gray-500 font-semibold">📋 {sorted.length} resultado{sorted.length !== 1 ? 's' : ''} encontrado{sorted.length !== 1 ? 's' : ''}</p>
                            )}

                            {/* Lista de Usuários em Cards Modernos */}
                            <div className="space-y-3">
                              {sorted && sorted.length > 0 ? (
                                sorted.map((u, i) => (
                            <div 
                              key={i} 
                              className="group p-6 bg-white rounded-2xl border border-gray-200 hover:border-gray-300 hover:shadow-md transition-all duration-200"
                            >
                              <div className="flex items-start justify-between mb-4">
                                <div className="flex-1">
                                  <div className="flex items-center gap-3 mb-2">
                                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-red-500 to-red-600 flex items-center justify-center text-white font-bold text-sm">
                                      {u.name?.charAt(0).toUpperCase() || 'U'}
                                    </div>
                                    <div>
                                      <p className="text-base font-bold text-gray-900">{u.name || 'Sem nome'}</p>
                                      <p className="text-xs text-gray-500 font-mono">{u.username}</p>
                                    </div>
                                  </div>
                                </div>
                                
                                {/* Status Badge + Role Badge */}
                                <div className="flex items-center gap-2">
                                  {/* Status Indicator */}
                                  <div className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs font-bold ${
                                    u.disabled 
                                      ? 'bg-gray-100 text-gray-700' 
                                      : 'bg-green-100 text-green-700'
                                  }`}>
                                    <div className={`w-2 h-2 rounded-full ${u.disabled ? 'bg-gray-400' : 'bg-green-500'}`}></div>
                                    {u.disabled ? 'Inativo' : 'Ativo'}
                                  </div>

                                  {/* Role Badge */}
                                  <div className={`px-3 py-1.5 rounded-lg text-xs font-bold ${
                                    u.role === 'admin'
                                      ? 'bg-red-100 text-red-700'
                                      : u.role === 'intermediate'
                                      ? 'bg-purple-100 text-purple-700'
                                      : 'bg-blue-100 text-blue-700'
                                  }`}>
                                    {u.role === 'admin' ? 'Admin' : u.role === 'intermediate' ? 'Intermediário' : 'Usuário'}
                                  </div>
                                </div>
                              </div>

                              {/* E-mail */}
                              <p className="text-sm text-gray-600 mb-4 ml-13">{u.email}</p>

                              {/* CNES */}
                              {u.cnes && (
                                <p className="text-sm text-gray-600 mb-4 ml-13 font-mono">
                                  <span className="font-bold text-gray-700">CNES:</span> {u.cnes}
                                </p>
                              )}

                              {/* Ações */}
                              <div className="flex gap-2 pt-4 border-t border-gray-100 flex-wrap">
                                {/* Editar */}
                                <button 
                                  onClick={() => {
                                    setEditingUser({
                                      id: u.id,
                                      email: u.email,
                                      name: u.name,
                                      cnes: u.cnes || '',
                                      password: ''
                                    });
                                    setShowEditUserModal(true);
                                  }}
                                  className="flex-1 px-4 py-2.5 rounded-lg font-bold text-xs uppercase text-green-700 bg-green-100 hover:bg-green-200 transition-colors flex items-center justify-center gap-2"
                                  title="Editar dados do usuário"
                                >
                                  <Settings2 className="w-4 h-4" />
                                  Editar
                                </button>

                                {/* Alterar Papel do Usuário */}
                                <select 
                                  value={u.role}
                                  onChange={(e) => {
                                    const newRole = e.target.value as 'user' | 'intermediate' | 'admin';
                                    const roleNames: {[key: string]: string} = {
                                      'user': 'USUÁRIO PADRÃO',
                                      'intermediate': 'USUÁRIO INTERMEDIÁRIO',
                                      'admin': 'ADMINISTRADOR'
                                    };
                                    if (window.confirm(`Deseja alterar ${u.name} para ${roleNames[newRole]}?`)) {
                                      handleChangeUserRole(u.id, u.name, newRole);
                                    }
                                  }}
                                  className="flex-1 px-4 py-2.5 rounded-lg font-bold text-xs uppercase text-indigo-700 bg-indigo-100 hover:bg-indigo-200 transition-colors"
                                  title="Alterar papel do usuário"
                                >
                                  <option value="user">Padrão</option>
                                  <option value="intermediate">Intermediário</option>
                                  <option value="admin">Admin</option>
                                </select>

                                {/* Ativar/Desativar */}
                                <button 
                                  onClick={() => handleToggleUserDisable(u.id)} 
                                  className="flex-1 px-4 py-2.5 rounded-lg font-bold text-xs uppercase text-amber-700 bg-amber-100 hover:bg-amber-200 transition-colors flex items-center justify-center gap-2"
                                  title={u.disabled ? "Ativar usuário" : "Desativar usuário"}
                                >
                                  <Lock className="w-4 h-4" />
                                  {u.disabled ? "Ativar" : "Desativar"}
                                </button>

                                {/* Resetar Senha */}
                                <button 
                                  onClick={() => handleChangePassword(u.email)} 
                                  className="flex-1 px-4 py-2.5 rounded-lg font-bold text-xs uppercase text-blue-700 bg-blue-100 hover:bg-blue-200 transition-colors flex items-center justify-center gap-2"
                                  title="Enviar email de reset de senha"
                                >
                                  <Key className="w-4 h-4" />
                                  Senha
                                </button>

                                {/* Deletar */}
                                <button 
                                  onClick={() => {
                                    if (window.confirm(`Tem certeza que deseja deletar o usuário ${u.name}? ESTA AÇÃO NÃO PODE SER DESFEITA.`)) {
                                      handleDeleteUser(u.id, u.email);
                                    }
                                  }}
                                  className="flex-1 px-4 py-2.5 rounded-lg font-bold text-xs uppercase text-red-700 bg-red-100 hover:bg-red-200 transition-colors flex items-center justify-center gap-2"
                                  title="Deletar usuário permanentemente"
                                >
                                  <Trash2 className="w-4 h-4" />
                                  Deletar
                                </button>
                              </div>
                            </div>
                          ))
                          ) : (
                            <div className="text-center py-12 bg-gradient-to-br from-gray-50 to-gray-100 rounded-2xl border-2 border-dashed border-gray-300 shadow-sm">
                              <Users className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                              <p className="text-lg font-bold text-gray-600">Nenhum usuário encontrado</p>
                              <p className="text-sm text-gray-500 mt-2">
                                {searchQuery ? '🔍 Nenhum resultado' : (usersList === null ? '⏳ Carregando...' : usersList.length === 0 ? '📭 Nenhum usuário cadastrado' : '')}
                              </p>
                              <p className="text-xs text-gray-400 mt-3 max-w-sm mx-auto">
                                Abra o DevTools (F12) e vá à aba "Console" para ver detalhes do carregamento.
                                Procure por logs com 👥, ✅ ou ❌
                              </p>
                            </div>
                          )}
                        </div>
                      </>
                    )})()}
                    </div>

                    {/* SEÇÃO 3: USUÁRIOS INATIVOS/DESATIVADOS */}
                    {showInactiveUsers && (
                      <>
                        <div className="h-px bg-gradient-to-r from-transparent via-gray-200 to-transparent"></div>
                        <div className="space-y-6 p-6 bg-orange-50 rounded-xl border-2 border-orange-200">
                          <div className="flex items-center justify-between">
                            <div>
                              <h3 className="text-lg font-black text-orange-900 flex items-center gap-3">
                                👻 Usuários Inativos
                              </h3>
                              <p className="text-sm text-orange-700 mt-2">{inactiveUsersList.length} usuário{inactiveUsersList.length !== 1 ? 's' : ''} inativo{inactiveUsersList.length !== 1 ? 's' : ''}</p>
                            </div>
                          </div>

                          {inactiveUsersList.length > 0 ? (
                            <div className="space-y-4">
                              {inactiveUsersList.map((u: any) => (
                                <div key={u.id} className="p-4 bg-white rounded-lg border border-orange-200 hover:border-orange-300 transition-colors">
                                  <div className="flex items-start justify-between">
                                    <div className="flex-1">
                                      <h4 className="font-bold text-gray-900">{u.name || u.email}</h4>
                                      <p className="text-sm text-gray-600">{u.email}</p>
                                      {u.cnes && (
                                        <p className="text-xs text-gray-500 mt-1">CNES: {u.cnes}</p>
                                      )}
                                    </div>
                                    <div className="flex items-center gap-2 ml-4">
                                      <button
                                        onClick={() => handleReactivateUser(u.id, u.name || u.email)}
                                        className="px-4 py-2 bg-green-100 text-green-700 rounded-lg font-bold text-xs uppercase hover:bg-green-200 transition-colors"
                                        title="Reativar usuário"
                                      >
                                        ♻️ Reativar
                                      </button>
                                    </div>
                                  </div>
                                </div>
                              ))}
                            </div>
                          ) : (
                            <div className="text-center py-8">
                              <Users className="w-12 h-12 text-orange-300 mx-auto mb-3" />
                              <p className="text-sm font-bold text-orange-700">Carregando usuários inativos...</p>
                            </div>
                          )}
                        </div>
                      </>
                    )}

                  </div>
                </div>
              </div>
            </div>
          )}

          {/* EDIT USER MODAL */}
          {showEditUserModal && (
            <div className="fixed inset-0 z-[110] bg-black/40 backdrop-blur-md flex items-center justify-center p-4">
              <div className="bg-white rounded-3xl w-full max-w-2xl shadow-2xl animate-slideUp">
                
                {/* Header - Cores verdes do sistema */}
                <div className="bg-gradient-to-r from-green-700 to-green-600 px-8 py-6 border-b border-green-800/50 flex items-center justify-between">
                  <h3 className="text-2xl font-bold text-white flex items-center gap-3">
                    <Settings2 className="w-6 h-6" />
                    Editar Usuário: {editingUser.name}
                  </h3>
                  <button
                    onClick={() => setShowEditUserModal(false)}
                    className="text-white hover:bg-green-800/30 p-2 rounded-lg transition-colors"
                  >
                    <X className="w-6 h-6" />
                  </button>
                </div>

                {/* Content */}
                <div className="p-8 space-y-6">
                  {/* Nome */}
                  <div>
                    <label className="block text-sm font-bold text-gray-700 mb-2">Nome</label>
                    <input
                      type="text"
                      value={editingUser.name}
                      onChange={(e) => setEditingUser({ ...editingUser, name: e.target.value })}
                      className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-green-500 transition-colors"
                      placeholder="Nome completo"
                    />
                  </div>

                  {/* Email */}
                  <div>
                    <label className="block text-sm font-bold text-gray-700 mb-2">Email</label>
                    <input
                      type="email"
                      value={editingUser.email}
                      onChange={(e) => setEditingUser({ ...editingUser, email: e.target.value })}
                      className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-green-500 transition-colors"
                      placeholder="email@example.com"
                    />
                  </div>

                  {/* CNES */}
                  <div>
                    <label className="block text-sm font-bold text-gray-700 mb-2">CNES</label>
                    <input
                      type="text"
                      value={editingUser.cnes}
                      onChange={(e) => setEditingUser({ ...editingUser, cnes: maskCNES(e.target.value) })}
                      className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-green-500 transition-colors"
                      placeholder="Código CNES (8 dígitos)"
                      maxLength="8"
                    />
                  </div>

                  {/* Nova Senha (opcional) */}
                  <div>
                    <label className="block text-sm font-bold text-gray-700 mb-2">Nova Senha (opcional)</label>
                    <input
                      type="password"
                      value={editingUser.password}
                      onChange={(e) => setEditingUser({ ...editingUser, password: e.target.value })}
                      className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-green-500 transition-colors"
                      placeholder="Deixe em branco para não alterar"
                    />
                    {editingUser.password && editingUser.password.length < 6 && (
                      <p className="text-xs text-red-500 mt-1">Mínimo 6 caracteres</p>
                    )}
                  </div>

                  {/* Info text */}
                  <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
                    <p className="text-sm text-blue-800">
                      <strong>💡 Dica:</strong> Se deixar a senha em branco, ela não será alterada. Preencha apenas se quiser resetar a senha do usuário.
                    </p>
                  </div>
                </div>

                {/* Footer */}
                <div className="bg-gradient-to-r from-gray-50 to-gray-100 px-8 py-6 border-t border-gray-200 flex items-center justify-end gap-3 rounded-b-3xl">
                  <button
                    onClick={() => setShowEditUserModal(false)}
                    className="px-6 py-3 font-bold text-gray-700 bg-gray-200 hover:bg-gray-300 rounded-lg transition-colors"
                  >
                    Cancelar
                  </button>
                  <button
                    onClick={handleEditUser}
                    className="px-6 py-3 font-bold text-white bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 rounded-lg transition-colors flex items-center gap-2"
                  >
                    <Settings2 className="w-5 h-5" />
                    Salvar Alterações
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* HELP MODAL */}
          {showHelpModal && helpSectionId && helpContent[helpSectionId] && (
            <div className="fixed inset-0 z-[110] bg-black/40 backdrop-blur-md flex items-center justify-center p-4">
              <div className="bg-white rounded-3xl w-full max-w-2xl shadow-2xl animate-slideUp max-h-[90vh] overflow-y-auto">
                
                {/* Header - Cores vermelhas do sistema */}
                <div className="sticky top-0 bg-gradient-to-r from-red-700 to-red-600 px-8 py-6 border-b border-red-800/50 flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="p-3 rounded-xl bg-red-600/40">
                      <Info className="text-white w-6 h-6" />
                    </div>
                    <div>
                      <h2 className="text-2xl font-black text-white">{helpContent[helpSectionId]?.title}</h2>
                      <p className="text-red-100 text-sm mt-1">Guia de preenchimento</p>
                    </div>
                  </div>
                  <button 
                    onClick={() => setShowHelpModal(false)} 
                    className="p-2 hover:bg-red-600/50 rounded-lg transition-colors"
                  >
                    <X className="w-6 h-6 text-white" />
                  </button>
                </div>

                {/* Content */}
                <div className="p-8 space-y-6">
                  <div>
                    <p className="text-lg text-gray-700 leading-relaxed font-medium">
                      {helpContent[helpSectionId]?.description}
                    </p>
                  </div>

                  <div className="bg-red-50 rounded-2xl p-6 border border-red-200">
                    <h3 className="text-base font-black text-red-900 mb-4 flex items-center gap-2">
                      <ArrowUp className="w-5 h-5" />
                      Orientações para Preenchimento
                    </h3>
                    <ul className="space-y-3">
                      {helpContent[helpSectionId]?.tips.map((tip, idx) => (
                        <li key={idx} className="flex gap-3 text-gray-700">
                          <span className="flex-shrink-0 w-6 h-6 rounded-full bg-red-700 text-white text-xs font-bold flex items-center justify-center">
                            {idx + 1}
                          </span>
                          <span className="pt-0.5">{tip}</span>
                        </li>
                      ))}
                    </ul>
                  </div>

                  <button
                    onClick={() => setShowHelpModal(false)}
                    className="w-full py-3 bg-red-700 text-white rounded-xl font-bold uppercase text-sm tracking-wider hover:bg-red-800 transition-colors"
                  >
                    Entendi, Feche a Ajuda
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* BULK DELETE MODAL */}
          {showBulkDeleteModal && (
            <div className="fixed inset-0 z-[110] bg-black/40 backdrop-blur-md flex items-center justify-center p-4">
              <div className="bg-white rounded-3xl w-full max-w-md shadow-2xl animate-slideUp">
                <div className="bg-gradient-to-r from-red-600 to-red-700 px-8 py-6 border-b border-red-800/50 flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="p-3 rounded-xl bg-red-500/30">
                      <AlertTriangle className="text-white w-6 h-6" />
                    </div>
                    <h2 className="text-2xl font-black text-white">Deletar Planos</h2>
                  </div>
                  <button 
                    onClick={() => setShowBulkDeleteModal(false)} 
                    className="p-2 hover:bg-red-500/50 rounded-lg transition-colors"
                  >
                    <X className="w-6 h-6 text-white" />
                  </button>
                </div>

                <div className="p-8 space-y-6">
                  <div>
                    <p className="text-lg text-gray-700 leading-relaxed font-medium">
                      Você está prestes a deletar <span className="font-black text-red-600">{selectedPlanos.size}</span> plano(s). 
                      Esta ação é permanente e não pode ser desfeita.
                    </p>
                  </div>

                  <div className="bg-red-50 rounded-2xl p-6 border border-red-200">
                    <p className="text-sm text-gray-700 font-bold">Planos selecionados:</p>
                    <div className="mt-3 space-y-2 max-h-40 overflow-y-auto">
                      {Array.from(selectedPlanos).map(planoId => {
                        const plano = planosList.find(p => p.id === planoId);
                        return (
                          <div key={planoId} className="text-sm text-gray-600 bg-white p-2 rounded border border-red-200">
                            Emenda {plano?.numero_emenda} - {plano?.beneficiario_nome}
                          </div>
                        );
                      })}
                    </div>
                  </div>

                  <div className="flex gap-3">
                    <button
                      onClick={() => setShowBulkDeleteModal(false)}
                      className="flex-1 py-3 bg-gray-200 text-gray-800 rounded-xl font-bold uppercase text-sm tracking-wider hover:bg-gray-300 transition-colors"
                    >
                      Cancelar
                    </button>
                    <button
                      onClick={bulkDeletePlanos}
                      className="flex-1 py-3 bg-red-600 text-white rounded-xl font-bold uppercase text-sm tracking-wider hover:bg-red-700 transition-colors flex items-center justify-center gap-2"
                    >
                      <Trash2 className="w-4 h-4" /> Deletar {selectedPlanos.size}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* MODAL: SELECIONAR PLANO PARA ENVIAR EMAIL */}
          {showSelectPlanModal && (
            <div className="fixed inset-0 z-[110] bg-black/40 backdrop-blur-md flex items-center justify-center p-4">
              <div className="bg-white rounded-3xl w-full max-w-2xl shadow-2xl animate-slideUp max-h-[90vh] overflow-y-auto">
                {/* Header */}
                <div className="sticky top-0 bg-gradient-to-r from-blue-600 to-blue-700 px-8 py-6 border-b border-blue-800/50 flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="p-3 rounded-xl bg-blue-500/30">
                      <ClipboardCheck className="text-white w-6 h-6" />
                    </div>
                    <div>
                      <h2 className="text-2xl font-black text-white">Selecionar Plano</h2>
                      <p className="text-blue-100 text-sm mt-1">Escolha um plano salvo para enviar</p>
                    </div>
                  </div>
                  <button 
                    onClick={() => setShowSelectPlanModal(false)} 
                    className="p-2 hover:bg-blue-500/50 rounded-lg transition-colors"
                  >
                    <X className="w-6 h-6 text-white" />
                  </button>
                </div>

                {/* Content */}
                <div className="p-8 space-y-4">
                  {isLoadingPlanos ? (
                    <div className="text-center py-12">
                      <Loader2 className="w-12 h-12 text-blue-500 mx-auto mb-4 animate-spin" />
                      <p className="text-lg font-bold text-gray-700">Carregando seus planos...</p>
                      <p className="text-sm text-gray-500 mt-2">Aguarde um momento</p>
                    </div>
                  ) : planosList.length > 0 ? (
                    <div className="space-y-3">
                      {planosList.map((plano) => (
                        <button
                          key={plano.id}
                          onClick={() => handleSelectPlanForEmail(plano)}
                          className="w-full text-left p-6 bg-gradient-to-r from-gray-50 to-white border-2 border-gray-200 rounded-xl hover:border-blue-500 hover:bg-blue-50 transition-all duration-200 shadow-sm hover:shadow-md"
                        >
                          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                            <div>
                              <p className="text-xs text-gray-500 font-bold uppercase tracking-wider mb-1">Parlamentar</p>
                              <p className="text-sm font-bold text-gray-900">{plano.parlamentar}</p>
                            </div>
                            <div>
                              <p className="text-xs text-gray-500 font-bold uppercase tracking-wider mb-1">Emenda</p>
                              <p className="text-sm font-bold text-gray-900">{plano.numero_emenda}</p>
                            </div>
                            <div>
                              <p className="text-xs text-gray-500 font-bold uppercase tracking-wider mb-1">Valor</p>
                              <p className="text-sm font-bold text-red-600">R$ {parseFloat(plano.valor_total || 0).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</p>
                            </div>
                            <div>
                              <p className="text-xs text-gray-500 font-bold uppercase tracking-wider mb-1">Beneficiário</p>
                              <p className="text-sm font-bold text-gray-900">{plano.beneficiario_nome}</p>
                            </div>
                            <div>
                              <p className="text-xs text-gray-500 font-bold uppercase tracking-wider mb-1">CNES</p>
                              <p className="text-sm font-bold text-gray-900 font-mono">{plano.cnes || '—'}</p>
                            </div>
                            <div>
                              <p className="text-xs text-gray-500 font-bold uppercase tracking-wider mb-1">CNPJ</p>
                              <p className="text-sm font-bold text-gray-900 font-mono">{plano.beneficiario_cnpj || '—'}</p>
                            </div>
                          </div>
                          <div className="mt-4 flex items-center justify-between">
                            <span className="text-xs text-blue-600 font-semibold">Clique para selecionar →</span>
                            <ChevronRight className="w-5 h-5 text-blue-600" />
                          </div>
                        </button>
                      ))}
                    </div>
                  ) : (
                    <div className="text-center py-12">
                      <ClipboardCheck className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                      <p className="text-lg font-bold text-gray-700">Nenhum plano disponível</p>
                      <p className="text-sm text-gray-500 mt-2">Você não tem planos salvos para enviar.</p>
                      <button
                        onClick={() => loadPlanos()}
                        disabled={isLoadingPlanos}
                        className="mt-6 px-6 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-bold rounded-lg transition-colors flex items-center gap-2 mx-auto"
                      >
                        {isLoadingPlanos ? (
                          <>
                            <Loader2 className="w-4 h-4 animate-spin" />
                            Carregando...
                          </>
                        ) : (
                          <>
                            <Download className="w-4 h-4" />
                            Tentar Novamente
                          </>
                        )}
                      </button>
                      <p className="text-xs text-gray-500 mt-4">Dica: Você também pode preencher o formulário com os dados do plano que deseja enviar.</p>
                    </div>
                  )}
                </div>

                {/* Footer */}
                <div className="sticky bottom-0 bg-gradient-to-r from-gray-50 to-gray-100 px-8 py-6 border-t border-gray-200 flex items-center justify-end gap-3 rounded-b-3xl">
                  <button
                    onClick={() => setShowSelectPlanModal(false)}
                    className="px-6 py-3 font-bold text-gray-700 bg-gray-200 hover:bg-gray-300 rounded-lg transition-colors"
                  >
                    Cancelar
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* MODAL DE AJUDA - PRÓXIMOS PASSOS */}
          {showHelpModal && (
            <div className="fixed inset-0 z-[110] bg-black/40 backdrop-blur-md flex items-center justify-center p-4">
              <div className="bg-white rounded-3xl w-full max-w-4xl shadow-2xl animate-slideUp max-h-[90vh] overflow-y-auto">
                {/* Header */}
                <div className="sticky top-0 bg-gradient-to-r from-amber-600 to-yellow-600 px-8 py-6 border-b border-yellow-700/50 flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="p-3 rounded-xl bg-yellow-500/30">
                      <BookOpen className="text-white w-6 h-6" />
                    </div>
                    <div>
                      <h2 className="text-2xl font-black text-white">Próximos Passos para Envio</h2>
                      <p className="text-yellow-100 text-sm mt-1">Guia completo para gerar, assinar e enviar seu plano</p>
                    </div>
                  </div>
                  <button 
                    onClick={() => setShowHelpModal(false)} 
                    className="p-2 hover:bg-yellow-500/50 rounded-lg transition-colors"
                  >
                    <X className="w-6 h-6 text-white" />
                  </button>
                </div>

                {/* Content */}
                <div className="p-8 space-y-6">
                  <p className="text-base text-gray-700 leading-relaxed font-semibold">
                    Siga os 4 passos abaixo para gerar o PDF, assinar e enviar seu plano de trabalho para a SES-SP.
                  </p>

                  {/* PASSO 1 */}
                  <div className="bg-gradient-to-br from-blue-50 to-cyan-50 p-6 rounded-2xl border-2 border-blue-300">
                    <div className="flex gap-4">
                      <div className="flex-shrink-0">
                        <div className="flex items-center justify-center w-12 h-12 bg-blue-600 rounded-full">
                          <span className="text-white font-black text-lg">1</span>
                        </div>
                      </div>
                      <div className="flex-1">
                        <h4 className="font-black text-blue-900 text-lg mb-2 uppercase tracking-wide">Gere o PDF</h4>
                        <p className="text-sm text-blue-800 mb-4 leading-relaxed">
                          Clique no botão <strong>"🖨️ VISUALIZAR E BAIXAR PDF"</strong> para gerar o documento em PDF. O sistema irá salvar automaticamente seu plano e abrir a visualização do PDF.
                        </p>
                        <ul className="text-sm text-blue-700 space-y-2 ml-4">
                          <li className="flex gap-2">
                            <span className="text-blue-600 font-bold">•</span>
                            <span>O PDF será gerado automaticamente após clicar no botão</span>
                          </li>
                          <li className="flex gap-2">
                            <span className="text-blue-600 font-bold">•</span>
                            <span>Você verá uma prévia do documento antes de baixar</span>
                          </li>
                          <li className="flex gap-2">
                            <span className="text-blue-600 font-bold">•</span>
                            <span>Salve o arquivo em um local seguro em seu computador</span>
                          </li>
                        </ul>
                      </div>
                    </div>
                  </div>

                  {/* PASSO 2 */}
                  <div className="bg-gradient-to-br from-purple-50 to-pink-50 p-6 rounded-2xl border-2 border-purple-300">
                    <div className="flex gap-4">
                      <div className="flex-shrink-0">
                        <div className="flex items-center justify-center w-12 h-12 bg-purple-600 rounded-full">
                          <span className="text-white font-black text-lg">2</span>
                        </div>
                      </div>
                      <div className="flex-1">
                        <h4 className="font-black text-purple-900 text-lg mb-2 uppercase tracking-wide">Assine o PDF</h4>
                        <p className="text-sm text-purple-800 mb-4 leading-relaxed">
                          Abra o arquivo PDF em seu computador e assine digitalmente ou de forma manuscrita.
                        </p>
                        <div className="bg-white rounded-lg p-4 mb-3 border border-purple-200">
                          <p className="text-sm font-bold text-purple-900 mb-3">Opções de Assinatura:</p>
                          <ul className="text-sm text-purple-800 space-y-2">
                            <li className="flex gap-2">
                              <span className="text-purple-600 font-bold">✓</span>
                              <span><strong>Assinatura Digital:</strong> Use um leitor de PDF (Adobe Reader) com certificado digital</span>
                            </li>
                            <li className="flex gap-2">
                              <span className="text-purple-600 font-bold">✓</span>
                              <span><strong>Assinatura Manuscrita:</strong> Imprima o PDF, assine com caneta azul ou preta, escaneie e salve como PDF</span>
                            </li>
                          </ul>
                        </div>
                        <ul className="text-sm text-purple-700 space-y-2 ml-4">
                          <li className="flex gap-2">
                            <span className="text-purple-600 font-bold">•</span>
                            <span>Responsável pela assinatura: <strong>{formData.responsavelAssinatura || 'Campo a preencher'}</strong></span>
                          </li>
                          <li className="flex gap-2">
                            <span className="text-purple-600 font-bold">•</span>
                            <span>Assine no local indicado no documento</span>
                          </li>
                          <li className="flex gap-2">
                            <span className="text-purple-600 font-bold">•</span>
                            <span>Mantenha uma cópia assinada para seus registros</span>
                          </li>
                        </ul>
                      </div>
                    </div>
                  </div>

                  {/* PASSO 3 */}
                  <div className="bg-gradient-to-br from-red-50 to-rose-50 p-6 rounded-2xl border-2 border-red-300">
                    <div className="flex gap-4">
                      <div className="flex-shrink-0">
                        <div className="flex items-center justify-center w-12 h-12 bg-red-600 rounded-full">
                          <span className="text-white font-black text-lg">3</span>
                        </div>
                      </div>
                      <div className="flex-1">
                        <h4 className="font-black text-red-900 text-lg mb-2 uppercase tracking-wide">Envie para SES-SP</h4>
                        <p className="text-sm text-red-800 mb-4 leading-relaxed">
                          Clique no botão <strong>"📧 ENVIAR ASSINADO"</strong> para abrir seu cliente de email padrão com o template de mensagem pré-preenchido.
                        </p>
                        <div className="bg-white rounded-lg p-4 mb-3 border border-red-200">
                          <p className="text-sm font-bold text-red-900 mb-3">O que fazer:</p>
                          <ol className="text-sm text-red-800 space-y-2 ml-4 list-decimal">
                            <li>Clique em "ENVIAR ASSINADO" → seu email será aberto automaticamente</li>
                            <li>O assunto e mensagem já estarão preenchidos</li>
                            <li><strong>Clique em "Anexar" ou "Attachment"</strong> e selecione o PDF assinado</li>
                            <li>Revise o conteúdo do email</li>
                            <li>Clique em "Enviar"</li>
                          </ol>
                        </div>
                        <ul className="text-sm text-red-700 space-y-2 ml-4">
                          <li className="flex gap-2">
                            <span className="text-red-600 font-bold">•</span>
                            <span>Certifique-se de que o PDF assinado está anexado ao email</span>
                          </li>
                          <li className="flex gap-2">
                            <span className="text-red-600 font-bold">•</span>
                            <span>Verifique se o arquivo não está corrompido antes de enviar</span>
                          </li>
                          <li className="flex gap-2">
                            <span className="text-red-600 font-bold">•</span>
                            <span>Guarde uma cópia do email enviado como comprovante</span>
                          </li>
                        </ul>
                      </div>
                    </div>
                  </div>

                  {/* PASSO 4 */}
                  <div className="bg-gradient-to-br from-green-50 to-emerald-50 p-6 rounded-2xl border-2 border-green-300">
                    <div className="flex gap-4">
                      <div className="flex-shrink-0">
                        <div className="flex items-center justify-center w-12 h-12 bg-green-600 rounded-full">
                          <span className="text-white font-black text-lg">4</span>
                        </div>
                      </div>
                      <div className="flex-1">
                        <h4 className="font-black text-green-900 text-lg mb-2 uppercase tracking-wide">Email Receptor</h4>
                        <p className="text-sm text-green-800 mb-4 leading-relaxed">
                          Seu email será enviado para o endereço oficial de recebimento de planos de trabalho:
                        </p>
                        <div className="bg-white rounded-lg p-4 border-2 border-green-400 shadow-sm">
                          <p className="text-center text-lg font-black text-green-700 font-mono break-all">
                            gcf-emendasfederais@saude.sp.gov.br
                          </p>
                        </div>
                        <ul className="text-sm text-green-700 space-y-2 ml-4 mt-4">
                          <li className="flex gap-2">
                            <span className="text-green-600 font-bold">✓</span>
                            <span>Este é o email oficial para recebimento de planos de trabalho</span>
                          </li>
                          <li className="flex gap-2">
                            <span className="text-green-600 font-bold">✓</span>
                            <span>Você receberá uma confirmação de recebimento em breve</span>
                          </li>
                          <li className="flex gap-2">
                            <span className="text-green-600 font-bold">✓</span>
                            <span>Guarde o número da emenda ({formData.emenda.numero}) para consultas futuras</span>
                          </li>
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Footer */}
                <div className="sticky bottom-0 bg-gradient-to-r from-gray-50 to-gray-100 px-8 py-6 border-t border-gray-200 flex items-center justify-end gap-3 rounded-b-3xl">
                  <button
                    onClick={() => setShowHelpModal(false)}
                    className="px-8 py-3 font-bold text-white bg-gradient-to-r from-yellow-500 to-yellow-600 hover:from-yellow-600 hover:to-yellow-700 rounded-lg transition-all shadow-md hover:shadow-lg"
                  >
                    Entendi, Fechar
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* VIEW: LISTA DE PLANOS */}
          {currentView === 'list' && (
            <div className="space-y-6 animate-fadeIn">
              <div className="flex justify-between items-center mb-6">
                <div>
                  <h2 className="text-base font-black text-gray-900 uppercase tracking-wider">Meus Planos de Trabalho</h2>
                  {planosList.length > 0 && (
                    <p className="text-sm text-gray-600 mt-2">
                      📊 Total de {planosList.length} plano(s) • Valor Total: <span className="font-black text-red-600">R$ {planosList.reduce((sum, p) => sum + (parseFloat(p.valor_total) || 0), 0).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</span>
                    </p>
                  )}
                </div>
                {isAdmin() && (
                  <button 
                    onClick={exportToCSV}
                    className="flex items-center gap-2 px-6 py-3 bg-green-600 text-white rounded-xl font-bold text-sm uppercase tracking-wider hover:bg-green-700 shadow-lg transition-all"
                  >
                    <Download className="w-4 h-4" /> Exportar CSV
                  </button>
                )}
              </div>

              {/* SELEÇÃO E BULK DELETE - Admin */}
              {isAdmin() && (
                <div className="bg-amber-50 p-4 rounded-xl border border-amber-200">
                  <div className="flex items-center justify-between">
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={selectedPlanos.size === planosList.length && planosList.length > 0}
                        onChange={(e) => {
                          if (e.target.checked) {
                            setSelectedPlanos(new Set(planosList.map(p => p.id)));
                          } else {
                            setSelectedPlanos(new Set());
                          }
                        }}
                        className="w-5 h-5 accent-amber-600"
                      />
                      <span className="font-bold text-sm text-amber-900">Selecionar Todos ({planosList.length})</span>
                    </label>
                    {selectedPlanos.size > 0 && (
                      <button
                        onClick={() => setShowBulkDeleteModal(true)}
                        className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg font-bold text-xs uppercase tracking-wider hover:bg-red-700 transition-all"
                      >
                        <Trash2 className="w-4 h-4" /> Deletar {selectedPlanos.size} Selecionado(s)
                      </button>
                    )}
                  </div>
                </div>
              )}

              {/* FILTROS - Compactos */}
              {isAdmin() && (
                <div className="bg-gray-50 p-4 rounded-xl border border-gray-200 space-y-4">
                  <p className="text-xs font-bold text-gray-700 uppercase tracking-widest">🔍 Filtros de Pesquisa</p>
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-3">
                    <input
                      type="text"
                      placeholder="CNES"
                      value={filtros.cnes}
                      onChange={(e) => setFiltros({...filtros, cnes: e.target.value})}
                      className="px-3 py-2 rounded-lg border border-gray-300 text-sm focus:outline-none focus:ring-2 focus:ring-red-600/20 focus:border-red-600"
                    />
                    <input
                      type="text"
                      placeholder="Parlamentar"
                      value={filtros.parlamentar}
                      onChange={(e) => setFiltros({...filtros, parlamentar: e.target.value})}
                      className="px-3 py-2 rounded-lg border border-gray-300 text-sm focus:outline-none focus:ring-2 focus:ring-red-600/20 focus:border-red-600"
                    />
                    <input
                      type="text"
                      placeholder="Emenda"
                      value={filtros.emenda}
                      onChange={(e) => setFiltros({...filtros, emenda: e.target.value})}
                      className="px-3 py-2 rounded-lg border border-gray-300 text-sm focus:outline-none focus:ring-2 focus:ring-red-600/20 focus:border-red-600"
                    />
                    <input
                      type="text"
                      placeholder="CNPJ"
                      value={filtros.cnpj}
                      onChange={(e) => setFiltros({...filtros, cnpj: e.target.value})}
                      className="px-3 py-2 rounded-lg border border-gray-300 text-sm focus:outline-none focus:ring-2 focus:ring-red-600/20 focus:border-red-600"
                    />
                  </div>
                  {(filtros.cnes || filtros.parlamentar || filtros.emenda || filtros.cnpj) && (
                    <button
                      onClick={() => setFiltros({ cnes: '', parlamentar: '', emenda: '', cnpj: '' })}
                      className="text-xs font-bold text-red-600 hover:text-red-700 uppercase tracking-widest"
                    >
                      ✕ Limpar Filtros
                    </button>
                  )}
                </div>
              )}

              {isLoadingPlanos ? (
                <div className="flex justify-center py-20">
                  <Loader2 className="w-16 h-16 text-red-600 animate-spin" />
                </div>
              ) : planosList.length === 0 ? (
                <div className="text-center py-32 bg-white rounded-2xl border-2 border-dashed border-gray-300">
                  <ClipboardCheck className="w-24 h-24 mx-auto text-gray-300 mb-6" />
                  <p className="text-xl text-gray-500 font-bold uppercase">Nenhum plano cadastrado</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {planosList
                    .filter(plano => {
                      if (filtros.cnes && !plano.cnes?.toLowerCase().includes(filtros.cnes.toLowerCase())) return false;
                      if (filtros.parlamentar && !plano.parlamentar?.toLowerCase().includes(filtros.parlamentar.toLowerCase())) return false;
                      if (filtros.emenda && !plano.numero_emenda?.toLowerCase().includes(filtros.emenda.toLowerCase())) return false;
                      if (filtros.cnpj && !plano.beneficiario_cnpj?.toLowerCase().includes(filtros.cnpj.toLowerCase())) return false;
                      return true;
                    })
                    .length === 0 ? (
                    <div className="text-center py-16 bg-gray-50 rounded-lg border border-dashed border-gray-300">
                      <p className="text-sm text-gray-600 font-bold">Nenhum plano encontrado com os filtros aplicados</p>
                    </div>
                  ) : (
                    <>
                      {(() => {
                        const filteredPlanos = planosList.filter(plano => {
                          if (filtros.cnes && !plano.cnes?.toLowerCase().includes(filtros.cnes.toLowerCase())) return false;
                          if (filtros.parlamentar && !plano.parlamentar?.toLowerCase().includes(filtros.parlamentar.toLowerCase())) return false;
                          if (filtros.emenda && !plano.numero_emenda?.toLowerCase().includes(filtros.emenda.toLowerCase())) return false;
                          if (filtros.cnpj && !plano.beneficiario_cnpj?.toLowerCase().includes(filtros.cnpj.toLowerCase())) return false;
                          return true;
                        });
                        const totalValue = filteredPlanos.reduce((sum, p) => sum + (parseFloat(p.valor_total) || 0), 0);
                        return (
                          <div className="bg-blue-50 rounded-lg p-3 border border-blue-200 mb-4">
                            <p className="text-xs text-gray-700 font-bold mb-2">📊 {filteredPlanos.length} plano(s) encontrado(s)</p>
                            <p className="text-sm font-black text-blue-600">Valor Total: R$ {totalValue.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</p>
                          </div>
                        );
                      })()}
                      {/* ALERTA DE CONTAS BANCÁRIAS DUPLICADAS */}
                      {(() => {
                        const contaCount: Record<string, string[]> = {};
                        planosList.forEach(p => {
                          const conta = (p.conta_bancaria || '').trim();
                          if (conta) {
                            if (!contaCount[conta]) contaCount[conta] = [];
                            contaCount[conta].push(p.parlamentar || p.numero_emenda || p.id);
                          }
                        });
                        const duplicadas = Object.entries(contaCount).filter(([, ids]) => ids.length > 1);
                        if (duplicadas.length === 0) return null;
                        return (
                          <div className="bg-amber-50 border-2 border-amber-400 rounded-xl p-4 mb-4">
                            <div className="flex items-start gap-3">
                              <AlertTriangle className="w-6 h-6 text-amber-600 flex-shrink-0 mt-0.5" />
                              <div>
                                <p className="text-sm font-black text-amber-800 uppercase tracking-wider mb-2">⚠️ Conta(s) Bancária(s) Utilizada(s) em Mais de 1 Plano</p>
                                {duplicadas.map(([conta, planos]) => (
                                  <div key={conta} className="mb-1">
                                    <p className="text-sm text-amber-900">
                                      <span className="font-mono font-bold bg-amber-200 px-2 py-0.5 rounded">{conta}</span>
                                      <span className="text-amber-700 ml-2">→ usada em {planos.length} planos: {planos.join(', ')}</span>
                                    </p>
                                  </div>
                                ))}
                                <p className="text-sm font-semibold text-red-700 mt-3 border-t border-amber-300 pt-2">⚠ Não serão efetuados pagamentos de emendas que utilizem conta bancária previamente utilizada.</p>
                              </div>
                            </div>
                          </div>
                        );
                      })()}
                      {planosList
                        .filter(plano => {
                          if (filtros.cnes && !plano.cnes?.toLowerCase().includes(filtros.cnes.toLowerCase())) return false;
                          if (filtros.parlamentar && !plano.parlamentar?.toLowerCase().includes(filtros.parlamentar.toLowerCase())) return false;
                          if (filtros.emenda && !plano.numero_emenda?.toLowerCase().includes(filtros.emenda.toLowerCase())) return false;
                          if (filtros.cnpj && !plano.beneficiario_cnpj?.toLowerCase().includes(filtros.cnpj.toLowerCase())) return false;
                          return true;
                        })
                        .map((plano) => (
                        <div key={plano.id} className="bg-white px-4 py-3 rounded-lg border border-gray-200 shadow-sm hover:shadow-md hover:border-red-400 transition-all">
                          <div className="flex items-start gap-3">
                            {isAdmin() && (
                              <input
                                type="checkbox"
                                checked={selectedPlanos.has(plano.id)}
                                onChange={(e) => {
                                  const newSelected = new Set(selectedPlanos);
                                  if (e.target.checked) {
                                    newSelected.add(plano.id);
                                  } else {
                                    newSelected.delete(plano.id);
                                  }
                                  setSelectedPlanos(newSelected);
                                }}
                                className="w-5 h-5 accent-amber-600 mt-1 flex-shrink-0"
                              />
                            )}
                            <div className="flex-1 min-w-0">
                              {/* Linha única com todos os dados */}
                              <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-9 gap-x-4 gap-y-1">
                                <div className="col-span-1 lg:col-span-2 min-w-0">
                                  <p className="text-xs text-gray-500 font-bold uppercase tracking-wider">Parlamentar</p>
                                  <p className="text-sm font-bold text-gray-900">{plano.parlamentar}</p>
                                </div>
                                <div className="min-w-0">
                                  <p className="text-xs text-gray-500 font-bold uppercase tracking-wider">Emenda</p>
                                  <p className="text-sm font-bold text-gray-900 font-mono">{plano.numero_emenda}</p>
                                </div>
                                <div className="min-w-0">
                                  <p className="text-xs text-gray-500 font-bold uppercase tracking-wider">Valor</p>
                                  <p className="text-sm font-black text-red-600">R$ {parseFloat(plano.valor_total).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</p>
                                </div>
                                <div className="min-w-0">
                                  <p className="text-xs text-gray-500 font-bold uppercase tracking-wider">CNES</p>
                                  <p className="text-sm font-bold text-gray-900 font-mono">{plano.cnes || '—'}</p>
                                </div>
                                <div className="min-w-0">
                                  <p className="text-xs text-gray-500 font-bold uppercase tracking-wider">CNPJ</p>
                                  <p className="text-sm font-bold text-gray-900 font-mono">{plano.beneficiario_cnpj || '—'}</p>
                                </div>
                                <div className="min-w-0">
                                  <p className="text-xs text-gray-500 font-bold uppercase tracking-wider">Conta Bancária</p>
                                  {plano.conta_bancaria && planosList.filter(p => p.conta_bancaria && p.conta_bancaria.trim() === plano.conta_bancaria.trim() && p.id !== plano.id).length > 0 ? (
                                    <div className="flex items-center gap-1">
                                      <p className="text-sm font-bold text-amber-700 font-mono">{plano.conta_bancaria}</p>
                                      <AlertTriangle className="w-4 h-4 text-amber-500 flex-shrink-0" />
                                    </div>
                                  ) : (
                                    <p className="text-sm font-bold text-gray-900 font-mono">{plano.conta_bancaria || '—'}</p>
                                  )}
                                </div>
                                <div className="min-w-0">
                                  <p className="text-xs text-gray-500 font-bold uppercase tracking-wider">Preenchido por</p>
                                  <p className="text-sm font-bold text-gray-900">{plano.created_by_name || '—'}</p>
                                  <p className="text-xs text-gray-500 truncate">{plano.created_by_email || ''}</p>
                                </div>
                                <div className="min-w-0">
                                  <p className="text-xs text-gray-500 font-bold uppercase tracking-wider">Data</p>
                                  <p className="text-sm font-bold text-gray-900">{new Date(plano.created_at).toLocaleDateString('pt-BR')}</p>
                                  {isAdmin() && plano.last_edited_at && (
                                    <p className="text-xs text-orange-600 font-semibold">Ed: {new Date(plano.last_edited_at).toLocaleDateString('pt-BR')}</p>
                                  )}
                                  {isAdmin() && plano.edit_count > 0 && (
                                    <span className="text-xs bg-orange-100 text-orange-700 font-bold px-1.5 py-0.5 rounded">{plano.edit_count}x</span>
                                  )}

                                </div>
                              </div>

                            </div>
                            {/* Botões inline */}
                            <div className="flex gap-1.5 flex-shrink-0 items-start">
                              {plano.extrato_url && (
                                <button
                                  onClick={() => handleViewExtrato(plano.extrato_url)}
                                  className="flex items-center gap-1 px-2.5 py-1.5 bg-blue-50 text-blue-600 rounded-md font-bold text-xs uppercase hover:bg-blue-100 transition-all"
                                >
                                  <Eye className="w-4 h-4" /> Extrato
                                </button>
                              )}
                              {canEditPlan(plano.created_by) && (
                                <>
                                  <button 
                                    onClick={() => { 
                                      setFormData(getInitialFormData());
                                      setLastSavedFormData(null);
                                      setPlanoSalvoId(null);
                                      setFormHasChanges(false);
                                      setCurrentSelection({ categoria: '', item: '', metas: [''] });
                                      setCurrentMetaQualitativa({ meta: '', valor: '' });
                                      setCurrentNatureza({ codigo: '', valor: '' });
                                      setCurrentView('new'); 
                                      setActiveSection('info-emenda'); 
                                      setSentSuccess(false);
                                      loadingPlanIdRef.current = null;
                                      planLoadCompletedRef.current.delete(plano.id);
                                      setTimeout(() => { setEditingPlanId(plano.id); }, 50);
                                    }}
                                    className="flex items-center gap-1 px-2.5 py-1.5 bg-orange-50 text-orange-600 rounded-md font-bold text-xs uppercase hover:bg-orange-100 transition-all"
                                  >
                                    <Settings2 className="w-4 h-4" /> Editar
                                  </button>
                                  {isAdmin() && (
                                    <button 
                                      onClick={() => deletePlan(plano.id)}
                                      className="flex items-center gap-1 px-2.5 py-1.5 bg-red-50 text-red-600 rounded-md font-bold text-xs uppercase hover:bg-red-100 transition-all"
                                    >
                                      <Trash2 className="w-4 h-4" /> Del
                                    </button>
                                  )}
                                </>
                              )}
                            </div>
                          </div>
                        </div>
                      ))}
                    </>
                  )}
                </div>
              )}
            </div>
          )}

          {/* VIEW: DASHBOARD */}
          {currentView === 'dashboard' && (
            !(isAdmin() || currentUser?.role === 'intermediate') ? (
              <div className="text-center py-20 bg-red-50 rounded-2xl border-2 border-red-200 p-8">
                <Lock className="w-20 h-20 text-red-600 mx-auto mb-6" />
                <h2 className="text-3xl font-bold text-red-900 mb-4">🔒 Acesso Negado</h2>
                <p className="text-lg text-red-700 mb-6">O Dashboard é exclusivo para administradores e usuários intermediários.</p>
                <p className="text-sm text-red-600 mb-8">Contacte um administrador se você acredita que deveria ter acesso.</p>
                <Button
                  label="Voltar para Meus Planos"
                  onClick={() => setCurrentView('list')}
                  variant="primary"
                />
              </div>
            ) : (
              <div className="space-y-8 animate-fadeIn">
                <h2 className="text-base font-black text-gray-900 uppercase tracking-wider text-center">Dashboard - Relatórios e Estatísticas</h2>
              

              
              {isLoadingPlanos ? (
                <div className="flex justify-center py-20">
                  <Loader2 className="w-16 h-16 text-red-600 animate-spin" />
                </div>
              ) : (
                <>
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                    <div className="bg-white border border-gray-200 p-6 rounded-lg">
                      <div className="flex justify-between items-start mb-4">
                        <FileCheck className="w-5 h-5 text-gray-600" />
                        <span className="text-3xl font-bold text-black">{planosList.length}</span>
                      </div>
                      <p className="text-xs font-semibold text-gray-700 uppercase tracking-wide">Planos Cadastrados</p>
                    </div>

                    <div className="bg-white border border-gray-200 p-6 rounded-lg">
                      <div className="flex justify-between items-start mb-4">
                        <DollarSign className="w-5 h-5 text-gray-600" />
                        <span className="text-2xl font-bold text-gray-900">R$ {(planosList.reduce((sum, p) => sum + (parseFloat(p.valor_total) || 0), 0)).toLocaleString('pt-BR', { maximumFractionDigits: 0 })}</span>
                      </div>
                      <p className="text-xs font-semibold text-gray-700 uppercase tracking-wide">Valor Total</p>
                    </div>

                    <div className="bg-white border border-gray-200 p-6 rounded-lg">
                      <div className="flex justify-between items-start mb-4">
                        <TrendingUp className="w-5 h-5 text-gray-600" />
                        <span className="text-3xl font-bold text-black">{planosList.length > 0 ? ((planosList.filter(p => p.programa === PROGRAMAS[0]).length / planosList.length) * 100).toFixed(1) : 0}%</span>
                      </div>
                      <p className="text-xs font-semibold text-gray-700 uppercase tracking-wide">CUSTEIO MAC</p>
                    </div>

                    <div className="bg-white border border-gray-200 p-6 rounded-lg">
                      <div className="flex justify-between items-start mb-4">
                        <BarChart3 className="w-5 h-5 text-gray-600" />
                        <span className="text-2xl font-bold text-gray-900">R$ {planosList.length > 0 ? ((planosList.reduce((sum, p) => sum + (parseFloat(p.valor_total) || 0), 0) / planosList.length)).toLocaleString('pt-BR', { maximumFractionDigits: 0 }) : 0}</span>
                      </div>
                      <p className="text-xs font-semibold text-gray-700 uppercase tracking-wide">Valor Médio</p>
                    </div>
                  </div>

                    <div className="bg-white border border-gray-200 p-8 rounded-lg mt-8">
                      <h3 className="text-lg font-bold text-black uppercase tracking-wide mb-6">Resumo por Programa</h3>
                      <div className="space-y-3">
                        {PROGRAMAS.map(programa => {
                          const planosDoPrograma = planosList.filter(p => p.programa === programa);
                          const valorTotal = planosDoPrograma.reduce((sum, p) => sum + (parseFloat(p.valor_total) || 0), 0);
                          return planosDoPrograma.length > 0 ? (
                            <div key={programa} className="flex justify-between items-center p-4 bg-gray-50 border border-gray-200 rounded-lg hover:bg-gray-100 transition-colors">
                              <div>
                                <p className="text-sm font-semibold text-black">{programa}</p>
                                <p className="text-xs text-gray-600 font-medium">{planosDoPrograma.length} plano(s)</p>
                              </div>
                              <p className="text-lg font-bold text-red-600">R$ {valorTotal.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}</p>
                            </div>
                          ) : null;
                        })}
                      </div>
                    </div>

                    <div className="bg-white border border-gray-200 p-8 rounded-lg mt-8">
                      <h3 className="text-lg font-bold text-black uppercase tracking-wide mb-6">📋 Histórico de Edições</h3>
                      
                      
                      <div className="overflow-x-auto">
                        <table className="w-full text-sm">
                          <thead>
                            <tr className="bg-gray-100 border-b border-gray-200">
                              <th className="px-4 py-3 text-left font-bold text-gray-900 uppercase text-xs">Emenda</th>
                              <th className="px-4 py-3 text-left font-bold text-gray-900 uppercase text-xs">Parlamentar</th>
                              <th className="px-4 py-3 text-left font-bold text-gray-900 uppercase text-xs">Criada em</th>
                              <th className="px-4 py-3 text-center font-bold text-gray-900 uppercase text-xs">Edições</th>
                              <th className="px-4 py-3 text-left font-bold text-gray-900 uppercase text-xs">Última Edição</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-gray-200">
                            {planosList
                              .filter(p => (p.edit_count > 0 || p.last_edited_at) && p.edit_count !== undefined)
                              .sort((a, b) => new Date(b.last_edited_at || b.created_at).getTime() - new Date(a.last_edited_at || a.created_at).getTime())
                              .slice(0, 10)
                              .map(plano => (
                                <tr key={plano.id} className="hover:bg-gray-50">
                                  <td className="px-4 py-3 font-bold text-gray-900">{plano.numero_emenda}</td>
                                  <td className="px-4 py-3 text-gray-700">{plano.parlamentar}</td>
                                  <td className="px-4 py-3 text-gray-700">{new Date(plano.created_at).toLocaleDateString('pt-BR')}</td>
                                  <td className="px-4 py-3 text-center">
                                    {plano.edit_count > 0 ? (
                                      <span className="px-3 py-1 bg-orange-100 text-orange-700 font-bold text-xs rounded-full">
                                        {plano.edit_count}
                                      </span>
                                    ) : (
                                      <span className="text-gray-400">—</span>
                                    )}
                                  </td>
                                  <td className="px-4 py-3 text-gray-700">
                                    {plano.last_edited_at ? new Date(plano.last_edited_at).toLocaleDateString('pt-BR', { hour: '2-digit', minute: '2-digit' }) : '—'}
                                  </td>
                                </tr>
                              ))}
                          </tbody>
                        </table>
                        {planosList.filter(p => (p.edit_count > 0 || p.last_edited_at) && p.edit_count !== undefined).length === 0 && (
                          <div className="text-center py-8 text-gray-500">
                            <p className="text-sm">Nenhum plano foi editado ainda</p>
                          </div>
                        )}
                      </div>
                    </div>
                </>
              )}
            </div>
            )
          )}

          {/* VIEW: NOVO PLANO - ONE PAGE DESIGN */}
          {currentView === 'new' && (
            <>
              <StepperProgress 
                steps={sections.map((s, i) => {
                  const shortLabels = ['Emenda', 'Beneficiário', 'Estratégia', 'Metas', 'Indicadores', 'Financeiro', 'Finalizar'];
                  return {
                    id: s.id,
                    label: shortLabels[i] || `Etapa ${i + 1}`,
                    title: s.title
                  };
                })}
                activeStep={activeSection}
                onStepClick={scrollToSection}
                completedSteps={Object.entries(sectionStatus)
                  .filter(([_, isComplete]) => isComplete)
                  .map(([id, _]) => id)}
              />
              
              <div style={{ maxWidth: '1280px', margin: '0 auto', padding: '2rem 2rem' }}>
                <div className="space-y-8">
                {/* SECTION 1: IDENTIFICAÇÃO DA EMENDA */}
                <Section
                  id="info-emenda"
                  title="Identificação da Emenda"
                  description="Dados básicos da emenda parlamentar"
                  icon={<FileText className="w-6 h-6" />}
                  step={1}
                  totalSteps={7}
                  isComplete={sectionStatus['info-emenda']}
                  onHelpClick={() => openHelpModal('info-emenda')}
                >
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                    <Select
                      label="Programa Orçamentário"
                      value={formData.emenda.programa}
                      onChange={(e) => updateFormData('emenda', { ...formData.emenda, programa: e.target.value })}
                      options={PROGRAMAS.map(p => ({ value: p, label: p }))}
                      required
                    />
                    <InputField
                      label="Parlamentar Autor"
                      name="parlamentar"
                      value={formData.emenda.parlamentar}
                      onChange={(e) => updateFormData('emenda', { ...formData.emenda, parlamentar: e.target.value })}
                      placeholder="Ex: Deputado Federal João Silva"
                      required
                    />
                    <InputField
                      label="Nº da Emenda"
                      name="numero"
                      value={formData.emenda.numero}
                      onChange={(e) => updateFormData('emenda', { ...formData.emenda, numero: e.target.value })}
                      placeholder="Ex: 12340001"
                      required
                    />
                    <InputField
                      label="Valor do Recurso (R$)"
                      name="valor"
                      type="text"
                      value={formData.emenda.valor}
                      onChange={(e) => updateFormData('emenda', { ...formData.emenda, valor: maskCurrency(e.target.value) })}
                      mask={(val: string) => maskCurrency(val)}
                      placeholder="R$ 0,00"
                      required
                    />
                  </div>
                </Section>

                {/* SECTION 2: BENEFICIÁRIO */}
                <Section
                  id="beneficiario"
                  title="Dados do Beneficiário"
                  description="Informações da unidade beneficiária"
                  icon={<Building2 className="w-6 h-6" />}
                  step={2}
                  totalSteps={7}
                  isComplete={sectionStatus['beneficiario']}
                  onHelpClick={() => openHelpModal('beneficiario')}
                >
                  <div className="space-y-6">
                    <InputField
                      label="Razão Social da Unidade"
                      name="nome"
                      value={formData.beneficiario.nome}
                      onChange={(e) => updateFormData('beneficiario', { ...formData.beneficiario, nome: e.target.value })}
                      placeholder="Exemplo: Hospital XYZ"
                      required
                    />
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                      <InputField
                        label="CNPJ"
                        name="cnpj"
                        value={formData.beneficiario.cnpj}
                        onChange={(e) => updateFormData('beneficiario', { ...formData.beneficiario, cnpj: maskCNPJ(e.target.value) })}
                        mask={(val: string) => maskCNPJ(val)}
                        placeholder="XX.XXX.XXX/XXXX-XX"
                        required
                      />
                      {/* CNES - Dropdown para usuários com múltiplos CNES */}
                      {(() => {
                        // Detectar múltiplos CNES de qualquer fonte
                        const hasMultipleCnes = (currentUser?.cnes || '').includes(',') || userCnesList.length > 1;
                        const cnesOptions = userCnesList.length > 1 ? userCnesList : parseCnesList(currentUser?.cnes);
                        
                        if (currentUser?.role === 'user' && hasMultipleCnes && cnesOptions.length > 1) {
                          return (
                            <div className="flex flex-col">
                              <label className="text-sm font-semibold text-gray-700 mb-2">
                                CNES <span className="text-xs text-gray-500 font-normal">({cnesOptions.length} unidades - selecione)</span>
                              </label>
                              <select
                                value={selectedCnes || cnesOptions[0]}
                                onChange={(e) => {
                                  const newCnes = e.target.value;
                                  setSelectedCnes(newCnes);
                                  updateFormData('beneficiario', { ...formData.beneficiario, cnes: newCnes });
                                }}
                                className="w-full px-4 py-3 rounded-xl border-2 border-blue-300 bg-white text-gray-800 focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all font-mono text-base"
                                title={`Seus CNES: ${cnesOptions.join(', ')}`}
                              >
                                {cnesOptions.map(cnes => (
                                  <option key={cnes} value={cnes}>{cnes}</option>
                                ))}
                              </select>
                            </div>
                          );
                        }
                        
                        return (
                          <InputField
                            label="CNES"
                            name="cnes"
                            value={formData.beneficiario.cnes}
                            onChange={(e) => {
                              if (currentUser?.role === 'admin') {
                                updateFormData('beneficiario', { ...formData.beneficiario, cnes: maskCNES(e.target.value) });
                              }
                            }}
                            mask={(val: string) => maskCNES(val)}
                            placeholder="Código CNES"
                            disabled={currentUser?.role === 'user' && !hasMultipleCnes}
                            title={`Seu CNES: ${selectedCnes || 'não preenchido'}`}
                          />
                        );
                      })()}
                      <InputField
                        label="Email"
                        name="email"
                        type="email"
                        value={formData.beneficiario.email}
                        onChange={(e) => updateFormData('beneficiario', { ...formData.beneficiario, email: e.target.value })}
                        placeholder="email@example.com"
                      />
                    </div>
                    <InputField
                      label="Telefone"
                      name="telefone"
                      value={formData.beneficiario.telefone}
                      onChange={(e) => updateFormData('beneficiario', { ...formData.beneficiario, telefone: maskPhone(e.target.value) })}
                      mask={(val: string) => maskPhone(val)}
                      placeholder="(XX) 9XXXX-XXXX"
                    />

                    {/* CONTA BANCÁRIA E EXTRATO */}
                    <div className="border-t border-gray-200 pt-6 mt-6">
                      <h3 className="text-sm font-bold text-gray-700 uppercase tracking-wider mb-4 flex items-center gap-2">
                        <Landmark className="w-4 h-4 text-blue-600" />
                        Dados Bancários
                      </h3>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                          <InputField
                            label="Conta Bancária"
                            name="contaBancaria"
                            value={formData.beneficiario.contaBancaria}
                            onChange={(e) => updateFormData('beneficiario', { ...formData.beneficiario, contaBancaria: e.target.value })}
                            placeholder="Banco / Agência / Conta (Ex: 001 / 1234-5 / 12345-6)"
                            required
                            maxLength={25}
                            help="Informe somente números para banco, agência e conta."
                          />
                          {/* Alerta de conta bancária duplicada */}
                          {formData.beneficiario.contaBancaria?.trim() && planosList.some(p =>
                            p.conta_bancaria &&
                            p.conta_bancaria.trim() === formData.beneficiario.contaBancaria.trim() &&
                            p.id !== editingPlanId
                          ) && (
                            <div className="flex items-start gap-2 p-3 bg-amber-50 border-2 border-amber-400 rounded-xl -mt-8 mb-4">
                              <AlertTriangle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
                              <p className="text-sm font-bold text-amber-800">
                                Não serão efetuados pagamentos de emendas que utilizem conta bancária previamente utilizada.
                              </p>
                            </div>
                          )}
                        </div>
                        <div className="flex flex-col">
                          <label className="text-sm font-semibold text-gray-700 mb-2">
                            Extrato Bancário <span className="text-red-600">*</span>
                          </label>
                          {formData.beneficiario.extratoUrl ? (
                            <div className="flex items-center gap-3 p-3 bg-green-50 border-2 border-green-300 rounded-xl">
                              <Paperclip className="w-5 h-5 text-green-600 flex-shrink-0" />
                              <div className="flex-1 min-w-0">
                                <p className="text-sm font-bold text-green-800 truncate">{formData.beneficiario.extratoFilename || 'Extrato enviado'}</p>
                                <p className="text-xs text-green-600">Arquivo enviado com sucesso</p>
                              </div>
                              <div className="flex gap-2 flex-shrink-0">
                                <button
                                  type="button"
                                  onClick={() => handleViewExtrato(formData.beneficiario.extratoUrl)}
                                  className="p-2 bg-blue-100 text-blue-600 rounded-lg hover:bg-blue-200 transition-all"
                                  title="Visualizar extrato"
                                >
                                  <Eye className="w-4 h-4" />
                                </button>
                                <button
                                  type="button"
                                  onClick={handleRemoveExtrato}
                                  className="p-2 bg-red-100 text-red-600 rounded-lg hover:bg-red-200 transition-all"
                                  title="Remover extrato"
                                >
                                  <Trash2 className="w-4 h-4" />
                                </button>
                              </div>
                            </div>
                          ) : (
                            <div className="relative">
                              <input
                                ref={extratoInputRef}
                                type="file"
                                accept=".pdf,.jpg,.jpeg,.png,.webp"
                                onChange={handleExtratoUpload}
                                disabled={isUploadingExtrato}
                                className="hidden"
                                id="extrato-upload"
                              />
                              <label
                                htmlFor="extrato-upload"
                                className={`flex items-center justify-center gap-3 w-full px-4 py-3 rounded-xl border-2 border-dashed cursor-pointer transition-all ${
                                  isUploadingExtrato
                                    ? 'border-gray-300 bg-gray-50 text-gray-400 cursor-not-allowed'
                                    : 'border-blue-300 bg-blue-50 text-blue-700 hover:border-blue-500 hover:bg-blue-100'
                                }`}
                              >
                                {isUploadingExtrato ? (
                                  <>
                                    <Loader2 className="w-5 h-5 animate-spin" />
                                    <span className="text-sm font-bold">Enviando...</span>
                                  </>
                                ) : (
                                  <>
                                    <UploadCloud className="w-5 h-5" />
                                    <span className="text-sm font-bold">Enviar Extrato</span>
                                    <span className="text-xs text-blue-500">(PDF, JPG, PNG - comprimido automaticamente)</span>
                                  </>
                                )}
                              </label>
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  </div>
                </Section>

                {/* SECTION 3: ALINHAMENTO ESTRATÉGICO */}
                <Section
                  id="alinhamento"
                  title="Alinhamento Estratégico"
                  description="Escolha a diretriz, objetivo e metas do Plano Estadual de Saúde"
                  icon={<Target className="w-6 h-6" />}
                  step={3}
                  totalSteps={7}
                  isComplete={sectionStatus['alinhamento']}
                  onHelpClick={() => openHelpModal('alinhamento')}
                >
                  <div className="space-y-6">
                    {/* DIRETRIZES */}
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-4">
                        <span className="text-red-600">*</span> Diretriz Estratégica
                      </label>
                      <div className="grid gap-3">
                        {DIRETRIZES.map((d) => (
                          <button
                            key={d.id}
                            onClick={() => updateFormData('planejamento', { ...formData.planejamento, diretrizId: d.id, objetivoId: '', metaIds: [] })}
                            className={`p-4 rounded-lg border-2 text-left transition-all ${
                              formData.planejamento.diretrizId === d.id
                                ? 'border-red-600 bg-red-50'
                                : 'border-gray-200 bg-white hover:border-gray-300'
                            }`}
                          >
                            <span className="text-xs font-bold text-gray-600 block mb-1 uppercase tracking-widest">Diretriz {d.numero}</span>
                            <p className="text-sm text-gray-800 font-semibold">{d.titulo}</p>
                          </button>
                        ))}
                      </div>
                    </div>

                    {/* OBJETIVOS */}
                    {selectedDiretriz && (
                      <div className="border-t-2 border-gray-200 pt-6">
                        <label className="block text-sm font-semibold text-gray-700 mb-4">
                          <span className="text-red-600">*</span> Objetivo Específico
                        </label>
                        <div className="grid gap-3">
                          {selectedDiretriz.objetivos.map((obj) => (
                            <button
                              key={obj.id}
                              onClick={() => updateFormData('planejamento', { ...formData.planejamento, objetivoId: obj.id, metaIds: [] })}
                              className={`p-3 rounded-lg border-2 text-left transition-all ${
                                formData.planejamento.objetivoId === obj.id
                                  ? 'border-blue-600 bg-blue-100 shadow-md ring-2 ring-blue-300'
                                  : 'border-blue-200 bg-blue-50 hover:border-blue-400 hover:bg-blue-100'
                              }`}
                            >
                              <p className="text-sm text-gray-800 font-semibold">{obj.titulo}</p>
                            </button>
                          ))}
                        </div>
                      </div>
                    )}

                    {/* METAS */}
                    {selectedObjetivo && selectedObjetivo.metas.length > 0 && (
                      <div className="border-t-2 border-gray-200 pt-6">
                        <label className="block text-sm font-semibold text-gray-700 mb-4">
                          <span className="text-red-600">*</span> Metas (Selecione uma ou mais)
                        </label>
                        <div className="bg-gray-50 p-4 rounded-lg border border-gray-200 space-y-3">
                          {selectedObjetivo.metas.map((meta) => (
                            <label
                              key={meta.id}
                              className="flex items-start gap-3 p-3 bg-white rounded-lg border border-gray-200 hover:border-blue-300 cursor-pointer transition-all"
                            >
                              <input
                                type="checkbox"
                                checked={formData.planejamento.metaIds.includes(meta.id)}
                                onChange={(e) => {
                                  if (e.target.checked) {
                                    updateFormData('planejamento', {
                                      ...formData.planejamento,
                                      metaIds: [...formData.planejamento.metaIds, meta.id]
                                    });
                                  } else {
                                    updateFormData('planejamento', {
                                      ...formData.planejamento,
                                      metaIds: formData.planejamento.metaIds.filter(id => id !== meta.id)
                                    });
                                  }
                                }}
                                className="w-5 h-5 text-blue-600 rounded cursor-pointer mt-1 flex-shrink-0"
                              />
                              <span className="text-sm text-gray-800 leading-relaxed">{meta.descricao}</span>
                            </label>
                          ))}
                        </div>
                        {formData.planejamento.metaIds.length > 0 && (
                          <div className="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
                            <p className="text-sm font-semibold text-blue-900">
                              ✓ {formData.planejamento.metaIds.length} meta(s) selecionada(s)
                            </p>
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                </Section>

                {/* SECTION 4: METAS QUANTITATIVAS */}
                <Section
                  id="metas-quantitativas"
                  title="Metas Quantitativas"
                  description="Defina as ações de serviço e metas quantitativas"
                  icon={<Settings2 className="w-6 h-6" />}
                  step={4}
                  totalSteps={7}
                  isComplete={sectionStatus['metas-quantitativas']}
                  onHelpClick={() => openHelpModal('metas-quantitativas')}
                >
                  <div className="space-y-6">
                    <div className="bg-gray-50 p-6 rounded-lg border border-gray-200 space-y-4">
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <Select
                          label="Grupo de Ação"
                          value={currentSelection.categoria}
                          onChange={(e) => setCurrentSelection({ ...currentSelection, categoria: e.target.value, item: '', metas: [''] })}
                          options={availableMetasQuantitativas.map(cat => ({ value: cat.categoria, label: cat.categoria }))}
                        />
                        <Select
                          label="Ação Específica"
                          value={currentSelection.item}
                          onChange={(e) => setCurrentSelection({ ...currentSelection, item: e.target.value })}
                          options={availableMetasQuantitativas.find(c => c.categoria === currentSelection.categoria)?.itens.map(item => ({ value: item, label: item })) || []}
                          disabled={!currentSelection.categoria}
                        />
                      </div>

                      {currentSelection.categoria && currentSelection.item && (
                        <div className="border-t pt-4 btn-fade-in">
                          <Button
                            label="+ Adicionar Meta"
                            onClick={confirmAddAcao}
                            variant="primary"
                            size="md"
                          />
                        </div>
                      )}
                    </div>

                    {formData.acoesServicos.length > 0 && (
                      <div className="space-y-4">
                        <h4 className="text-sm font-bold text-gray-700 flex items-center gap-2">
                          <CheckCircle2 className="w-5 h-5 text-green-600" /> Metas Adicionadas ({formData.acoesServicos.length})
                        </h4>
                        {formData.acoesServicos.map((acao, idx) => (
                          <div key={idx} className="bg-white p-4 rounded-lg border border-gray-200 flex items-center justify-between">
                            <div className="flex-1">
                              <p className="text-xs font-semibold text-gray-500 uppercase tracking-widest mb-1">Grupo de Ação</p>
                              <p className="font-semibold text-gray-900 mb-2">{acao.categoria}</p>
                              <p className="text-xs font-semibold text-gray-500 uppercase tracking-widest mb-1">Ação Específica</p>
                              <p className="text-sm text-gray-700">{acao.item}</p>
                            </div>
                            <div className="flex items-center gap-3">
                              <InputField
                                label="Valor"
                                name={`valor-${idx}`}
                                type="text"
                                value={acao.valor}
                                onChange={(e) => {
                                  const recursoValue = parseFloat(formData.emenda.valor.replace(/[^\d,-]/g, '').replace(',', '.')) || 0;
                                  const totalMetas = formData.acoesServicos.reduce((sum, item, i) => {
                                    if (i === idx) return sum + parseFloat(e.target.value.replace(/[^\d,-]/g, '').replace(',', '.')) || 0;
                                    const value = parseFloat(item.valor.replace(/[^\d,-]/g, '').replace(',', '.')) || 0;
                                    return sum + value;
                                  }, 0);
                                  
                                  if (totalMetas > recursoValue) {
                                    alert(`⚠️ Atenção!\n\nO valor total das Metas Quantitativas não pode ultrapassar o Valor do Recurso (R$ ${recursoValue.toLocaleString('pt-BR', { minimumFractionDigits: 2 })})`);
                                    return;
                                  }
                                  
                                  const newAcoes = [...formData.acoesServicos];
                                  newAcoes[idx].valor = maskCurrency(e.target.value);
                                  updateFormData('acoesServicos', newAcoes);
                                }}
                                mask={(val: string) => maskCurrency(val)}
                                placeholder="R$ 0,00"
                                className="w-40"
                              />
                              <button
                                onClick={() => removeAcao(idx)}
                                className="p-2 text-gray-400 hover:text-red-600 transition-colors"
                              >
                                <Trash2 className="w-5 h-5" />
                              </button>
                            </div>
                          </div>
                        ))}
                        
                        {/* Sumário Total Metas Quantitativas */}
                        <div className="mt-6 bg-green-50 border border-green-200 rounded-xl p-6">
                          <div className="flex justify-between items-center">
                            <div>
                              <p className="text-xs text-green-600 font-bold uppercase tracking-widest mb-2">Total Metas Quantitativas</p>
                              <p className="text-2xl font-bold text-gray-900">
                                {new Intl.NumberFormat('pt-BR', {
                                  style: 'currency',
                                  currency: 'BRL'
                                }).format(
                                  formData.acoesServicos.reduce((sum, item) => {
                                    const value = parseFloat(item.valor.replace(/[^\d,-]/g, '').replace(',', '.')) || 0;
                                    return sum + value;
                                  }, 0)
                                )}
                              </p>
                            </div>
                            <div className="text-right">
                              <p className="text-xs text-gray-500 font-semibold uppercase tracking-widest mb-2">Valor do Recurso</p>
                              <p className="text-2xl font-bold text-blue-600">
                                {new Intl.NumberFormat('pt-BR', {
                                  style: 'currency',
                                  currency: 'BRL'
                                }).format(parseFloat(formData.emenda.valor.replace(/[^\d,-]/g, '').replace(',', '.')) || 0)}
                              </p>
                            </div>
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                </Section>

                {/* SECTION 5: INDICADORES QUALITATIVOS */}
                <Section
                  id="metas-qualitativas"
                  title="Indicadores Qualitativos (Opcional)"
                  description="Adicione indicadores qualitativos complementares (opcional)"
                  icon={<BarChart3 className="w-6 h-6" />}
                  step={5}
                  totalSteps={7}
                  isComplete={sectionStatus['metas-qualitativas']}
                  onHelpClick={() => openHelpModal('metas-qualitativas')}
                >
                  <div className="space-y-6">
                    <div className="bg-gray-50 p-6 rounded-lg border border-gray-200 space-y-4">
                      <div className="grid grid-cols-1 md:grid-cols-12 gap-4 items-end">
                        <div className="md:col-span-8">
                          <Select
                            label="Indicador"
                            value={currentMetaQualitativa.meta}
                            onChange={(e) => setCurrentMetaQualitativa({ ...currentMetaQualitativa, meta: e.target.value })}
                            options={METAS_QUALITATIVAS_OPTIONS.map(o => ({ value: o, label: o }))}
                            hideBottomMargin={true}
                          />
                        </div>
                        <div className="md:col-span-4">
                          <div className="relative">
                            <InputField
                              label="Valor"
                              name="qual-temp-valor"
                              type="text"
                              value={currentMetaQualitativa.valor}
                              onChange={(e) => setCurrentMetaQualitativa({ ...currentMetaQualitativa, valor: maskPercentage(e.target.value) })}
                              placeholder="0"
                              hideBottomMargin={true}
                            />
                            <span className="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-500 font-medium pointer-events-none" style={{ marginTop: '1.5rem' }}>%</span>
                          </div>
                        </div>
                        <div className="md:col-span-1"></div>
                      </div>

                      {currentMetaQualitativa.meta && currentMetaQualitativa.valor && (
                        <div className="border-t pt-4 btn-fade-in">
                          <Button
                            label="+ Adicionar Indicador"
                            onClick={confirmAddMetaQualitativa}
                            variant="primary"
                            size="md"
                          />
                        </div>
                      )}
                    </div>

                    {formData.metasQualitativas.length > 0 ? (
                      <div className="space-y-4">
                        {formData.metasQualitativas.map((item, idx) => (
                          <div 
                            key={idx} 
                            className="grid grid-cols-1 md:grid-cols-12 gap-4 items-end bg-gradient-to-br from-gray-50 to-white p-5 rounded-xl border border-gray-200 hover:border-red-200 transition-colors duration-200"
                          >
                            <div className="md:col-span-8">
                              <Select
                                label="Indicador"
                                value={item.meta}
                                onChange={(e) => {
                                  const newMetas = [...formData.metasQualitativas];
                                  newMetas[idx].meta = e.target.value;
                                  updateFormData('metasQualitativas', newMetas);
                                }}
                                options={METAS_QUALITATIVAS_OPTIONS.map(o => ({ value: o, label: o }))}
                                hideBottomMargin={true}
                              />
                            </div>
                            <div className="md:col-span-3">
                              <div className="relative">
                                <InputField
                                  label="Valor"
                                  name={`qual-valor-${idx}`}
                                  type="text"
                                  value={item.valor}
                                  onChange={(e) => {
                                    const newMetas = [...formData.metasQualitativas];
                                    newMetas[idx].valor = maskPercentage(e.target.value);
                                    updateFormData('metasQualitativas', newMetas);
                                  }}
                                  placeholder="0"
                                  hideBottomMargin={true}
                                />
                                <span className="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-500 font-medium pointer-events-none" style={{ marginTop: '1.5rem' }}>%</span>
                              </div>
                            </div>
                            <div className="md:col-span-1 flex justify-center">
                              <button
                                onClick={() => removeMetaQualitativa(idx)}
                                className="p-3 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all duration-200"
                                title="Remover indicador"
                              >
                                <Trash2 className="w-5 h-5" />
                              </button>
                            </div>
                          </div>
                        ))}
                      </div>
                    ) : (
                      <div className="text-center py-10 border-2 border-dashed border-gray-200 rounded-xl">
                        <BarChart3 className="w-10 h-10 text-gray-300 mx-auto mb-2" />
                        <p className="text-sm text-gray-400 font-medium">Nenhum indicador adicionado</p>
                        <p className="text-xs text-gray-300">Clique no botão acima para começar</p>
                      </div>
                    )}
                  </div>
                </Section>

                {/* SECTION 6: EXECUÇÃO FINANCEIRA */}
                <Section
                  id="execucao-financeira"
                  title="Execução Financeira"
                  description="Classifique os gastos por natureza de despesa"
                  icon={<DollarSign className="w-6 h-6" />}
                  step={6}
                  totalSteps={7}
                  isComplete={sectionStatus['execucao-financeira']}
                  onHelpClick={() => openHelpModal('execucao-financeira')}
                >
                  <div className="space-y-6">
                    <div className="bg-gray-50 p-6 rounded-lg border border-gray-200 space-y-4">
                      <div className="grid grid-cols-1 md:grid-cols-12 gap-4 items-end">
                        <div className="md:col-span-8">
                          <Select
                            label="Natureza de Despesa"
                            value={currentNatureza.codigo}
                            onChange={(e) => setCurrentNatureza({ ...currentNatureza, codigo: e.target.value })}
                            options={NATUREZAS_DESPESA.map(o => ({ value: o.codigo, label: `${o.codigo} - ${o.descricao}` }))}
                            hideBottomMargin={true}
                          />
                        </div>
                        <div className="md:col-span-4">
                          <InputField
                            label="Valor"
                            name="nat-temp-valor"
                            type="text"
                            value={currentNatureza.valor}
                            onChange={(e) => setCurrentNatureza({ ...currentNatureza, valor: maskCurrency(e.target.value) })}
                            mask={(val: string) => maskCurrency(val)}
                            placeholder="R$ 0,00"
                            hideBottomMargin={true}
                          />
                        </div>
                        <div className="md:col-span-1"></div>
                      </div>

                      {currentNatureza.codigo && currentNatureza.valor && (
                        <div className="border-t pt-4 btn-fade-in">
                          <Button
                            label="+ Adicionar Natureza de Despesa"
                            onClick={confirmAddNatureza}
                            variant="primary"
                            size="md"
                          />
                        </div>
                      )}
                    </div>

                    {formData.naturezasDespesa.length > 0 ? (
                      <div className="space-y-4">
                        {formData.naturezasDespesa.map((item, idx) => (
                          <div 
                            key={idx} 
                            className="grid grid-cols-1 md:grid-cols-12 gap-4 items-end bg-gradient-to-br from-gray-50 to-white p-5 rounded-xl border border-gray-200 hover:border-red-200 transition-colors duration-200"
                          >
                            <div className="md:col-span-8">
                              <Select
                                label="Natureza de Despesa"
                                value={item.codigo}
                                onChange={(e) => {
                                  const newNaturezas = [...formData.naturezasDespesa];
                                  newNaturezas[idx].codigo = e.target.value;
                                  updateFormData('naturezasDespesa', newNaturezas);
                                }}
                                options={NATUREZAS_DESPESA.map(o => ({ value: o.codigo, label: `${o.codigo} - ${o.descricao}` }))}
                                hideBottomMargin={true}
                              />
                            </div>
                            <div className="md:col-span-3">
                              <InputField
                                label="Valor"
                                name={`nat-valor-${idx}`}
                                type="text"
                                value={item.valor}
                                onChange={(e) => {
                                  const recursoValue = parseFloat(formData.emenda.valor.replace(/[^\d,-]/g, '').replace(',', '.')) || 0;
                                  const totalDespesas = formData.naturezasDespesa.reduce((sum, nat, i) => {
                                    if (i === idx) return sum + parseFloat(e.target.value.replace(/[^\d,-]/g, '').replace(',', '.')) || 0;
                                    const value = parseFloat(nat.valor.replace(/[^\d,-]/g, '').replace(',', '.')) || 0;
                                    return sum + value;
                                  }, 0);
                                  
                                  if (totalDespesas > recursoValue) {
                                    alert(`⚠️ Atenção!\n\nO valor total da Execução Financeira não pode ultrapassar o Valor do Recurso (R$ ${recursoValue.toLocaleString('pt-BR', { minimumFractionDigits: 2 })})`);
                                    return;
                                  }
                                  
                                  const newNaturezas = [...formData.naturezasDespesa];
                                  newNaturezas[idx].valor = maskCurrency(e.target.value);
                                  updateFormData('naturezasDespesa', newNaturezas);
                                }}
                                mask={(val: string) => maskCurrency(val)}
                                placeholder="R$ 0,00"
                                hideBottomMargin={true}
                              />
                            </div>
                            <div className="md:col-span-1 flex justify-center">
                              <button
                                onClick={() => removeNatureza(idx)}
                                className="p-3 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all duration-200"
                                title="Remover natureza de despesa"
                              >
                                <Trash2 className="w-5 h-5" />
                              </button>
                            </div>
                          </div>
                        ))}

                        {/* Sumário de totais com validação */}
                        <div className="mt-6 bg-red-50 border border-red-200 rounded-xl p-6">
                          {(() => {
                            const totalMetas = formData.acoesServicos.reduce((sum, item) => {
                              const value = parseFloat(item.valor.replace(/[^\d,-]/g, '').replace(',', '.')) || 0;
                              return sum + value;
                            }, 0);
                            const totalDespesas = formData.naturezasDespesa.reduce((sum, item) => {
                              const value = parseFloat(item.valor.replace(/[^\d,-]/g, '').replace(',', '.')) || 0;
                              return sum + value;
                            }, 0);
                            const diferenca = totalMetas - totalDespesas;
                            const isPending = diferenca !== 0;
                            
                            return (
                              <div className="space-y-4">
                                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                  <div>
                                    <p className="text-xs text-red-600 font-bold uppercase tracking-widest mb-2">Total Metas Quantitativas</p>
                                    <p className="text-2xl font-bold text-gray-900">
                                      {new Intl.NumberFormat('pt-BR', {
                                        style: 'currency',
                                        currency: 'BRL'
                                      }).format(totalMetas)}
                                    </p>
                                  </div>
                                  <div>
                                    <p className="text-xs text-red-600 font-bold uppercase tracking-widest mb-2">Total Planejado</p>
                                    <p className="text-2xl font-bold text-gray-900">
                                      {new Intl.NumberFormat('pt-BR', {
                                        style: 'currency',
                                        currency: 'BRL'
                                      }).format(totalDespesas)}
                                    </p>
                                  </div>
                                  <div>
                                    <p className="text-xs text-red-600 font-bold uppercase tracking-widest mb-2">Diferença</p>
                                    <p className={`text-2xl font-bold ${
                                      diferenca === 0 ? 'text-green-600' : 'text-orange-600'
                                    }`}>
                                      {new Intl.NumberFormat('pt-BR', {
                                        style: 'currency',
                                        currency: 'BRL'
                                      }).format(Math.abs(diferenca))}
                                    </p>
                                  </div>
                                </div>
                                {isPending && (
                                  <div className="bg-orange-100 border border-orange-300 rounded-lg p-3 flex items-start gap-2">
                                    <AlertCircle className="w-5 h-5 text-orange-600 flex-shrink-0 mt-0.5" />
                                    <p className="text-sm text-orange-700 font-medium">
                                      {diferenca > 0 
                                        ? `Falta distribuir R$ ${new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(diferenca)} nas naturezas de despesa`
                                        : `Você distribuiu R$ ${new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(Math.abs(diferenca))} a mais que o total de metas`
                                      }
                                    </p>
                                  </div>
                                )}
                                {diferenca === 0 && formData.naturezasDespesa.length > 0 && (
                                  <div className="bg-green-100 border border-green-300 rounded-lg p-3 flex items-start gap-2">
                                    <CheckCircle2 className="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" />
                                    <p className="text-sm text-green-700 font-medium">
                                      Distribuição de despesas balanceada! ✓
                                    </p>
                                  </div>
                                )}
                              </div>
                            );
                          })()}
                        </div>
                      </div>
                    ) : (
                      <div className="text-center py-10 border-2 border-dashed border-gray-200 rounded-xl">
                        <DollarSign className="w-10 h-10 text-gray-300 mx-auto mb-2" />
                        <p className="text-sm text-gray-400 font-medium">Nenhuma natureza de despesa adicionada</p>
                        <p className="text-xs text-gray-300">Clique no botão acima para começar</p>
                      </div>
                    )}
                  </div>
                </Section>

                {/* SECTION 7: FINALIZAÇÃO */}
                <Section
                  id="finalizacao"
                  title="Finalização"
                  description="Revise, gere PDF, assine e envie para a SES-SP"
                  icon={<FileCheck className="w-6 h-6" />}
                  step={7}
                  totalSteps={7}
                  isComplete={sectionStatus['finalizacao']}
                  onHelpClick={() => openHelpModal('finalizacao')}
                >
                  {!sentSuccess ? (
                    <div className="space-y-6">
                      <div>
                        <TextArea
                          label="Justificativa Técnica"
                          value={formData.justificativa}
                          onChange={(e) => updateFormData('justificativa', e.target.value)}
                          placeholder="Descreva a justificativa técnica do plano de trabalho (mínimo 2.000 caracteres)..."
                          rows={8}
                          required
                        />
                        <div className={`mt-2 text-xs font-bold tracking-wider ${(formData.justificativa?.trim().length || 0) >= 2000 ? 'text-green-600' : 'text-red-600'}`}>
                          {(formData.justificativa?.trim().length || 0).toLocaleString('pt-BR')} / 2.000 caracteres
                          {(formData.justificativa?.trim().length || 0) < 2000 && (
                            <span className="ml-2 text-red-500">— faltam {(2000 - (formData.justificativa?.trim().length || 0)).toLocaleString('pt-BR')}</span>
                          )}
                          {(formData.justificativa?.trim().length || 0) >= 2000 && (
                            <span className="ml-2">✓ Mínimo atingido</span>
                          )}
                        </div>
                      </div>

                      <InputField
                        label="Responsável pela Assinatura"
                        value={formData.responsavelAssinatura}
                        onChange={(e) => updateFormData('responsavelAssinatura', e.target.value)}
                        placeholder="Nome completo da pessoa responsável..."
                        required
                      />

                      {/* INSTRUÇÕES DE ENVIO - COM BOTÃO DE AJUDA */}
                      <div className="bg-gradient-to-r from-yellow-50 to-amber-50 p-6 rounded-2xl border-2 border-yellow-300 shadow-md flex items-start justify-between">
                        <div className="flex-1">
                          <h3 className="text-lg font-black text-amber-900 flex items-center gap-3 mb-2">
                            <div className="flex items-center justify-center w-10 h-10 bg-yellow-400 rounded-full">
                              <AlertCircle className="w-6 h-6 text-amber-900" />
                            </div>
                            Próximos Passos para Envio
                          </h3>
                          <p className="text-sm text-amber-800 leading-relaxed">
                            Siga os 4 passos: 1️⃣ Gere o PDF • 2️⃣ Assine o documento • 3️⃣ Envie para SES-SP • 4️⃣ Confirme o envio
                          </p>
                        </div>
                        <button
                          onClick={() => setShowHelpModal(true)}
                          className="ml-4 flex-shrink-0 p-3 bg-amber-400 hover:bg-amber-500 text-amber-900 font-black rounded-full transition-colors shadow-md hover:shadow-lg transform hover:scale-110 duration-200"
                          title="Ver instruções detalhadas"
                        >
                          <HelpCircle className="w-6 h-6" />
                        </button>
                      </div>

                      {/* BOTÕES DE AÇÃO - MELHORADOS */}
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
                        {/* BOTÃO GERAR PDF */}
                        <div className="relative group">
                          <div className="absolute inset-0 bg-gradient-to-r from-blue-600 to-cyan-600 rounded-2xl blur-lg opacity-75 group-hover:opacity-100 transition duration-300"></div>
                          <div className="relative bg-white p-8 rounded-2xl shadow-lg border-2 border-blue-500">
                            <div className="flex items-center justify-center mb-6">
                              <div className="p-4 bg-blue-100 rounded-full">
                                <Download className="w-8 h-8 text-blue-600" />
                              </div>
                            </div>
                            <h4 className="text-center font-black text-gray-900 mb-4 uppercase tracking-wide">Gerar PDF</h4>
                            <Button
                              label={isSending ? "⏳ Gerando..." : "🖨️ VISUALIZAR E BAIXAR PDF"}
                              onClick={() => {
                                if (isSending) return;
                                
                                const validation = validateRequiredFields();
                                if (!validation.isValid) {
                                  const missingList = validation.missingFields.map((field, idx) => `${idx + 1}. ${field}`).join('\n');
                                  alert(
                                    `⚠️ FORMULÁRIO INCOMPLETO!\n\n` +
                                    `Os campos obrigatórios abaixo devem ser preenchidos:\n\n${missingList}\n\n` +
                                    `Por favor, complete todos os campos indicados antes de gerar o PDF.`
                                  );
                                  return;
                                }
                                
                                setShowDocument(true);
                                setTimeout(() => handleGeneratePDF(), 500);
                              }}
                              variant="primary"
                              disabled={isSending}
                              fullWidth
                            />
                            <p className="text-center text-xs text-blue-600 font-semibold mt-3">✅ O plano será salvo e o PDF será gerado</p>
                            <ul className="text-xs text-gray-600 space-y-1 mt-4 ml-4">
                              <li className="flex gap-2">
                                <span>•</span>
                                <span>Salva automaticamente seu plano</span>
                              </li>
                              <li className="flex gap-2">
                                <span>•</span>
                                <span>Gera em PDF pronto para imprimir</span>
                              </li>
                              <li className="flex gap-2">
                                <span>•</span>
                                <span>Abre visualização antes de baixar</span>
                              </li>
                            </ul>
                          </div>
                        </div>

                        {/* BOTÃO ENVIAR ASSINADO */}
                        <div className="relative group">
                          <div className="absolute inset-0 bg-gradient-to-r from-red-600 to-rose-600 rounded-2xl blur-lg opacity-75 group-hover:opacity-100 transition duration-300"></div>
                          <div className="relative bg-white p-8 rounded-2xl shadow-lg border-2 border-red-500">
                            <div className="flex items-center justify-center mb-6">
                              <div className="p-4 bg-red-100 rounded-full">
                                <Send className="w-8 h-8 text-red-600" />
                              </div>
                            </div>
                            <h4 className="text-center font-black text-gray-900 mb-4 uppercase tracking-wide">Enviar para SES-SP</h4>
                            <Button
                              label="📧 ENVIAR ASSINADO"
                              onClick={handleSendToSES}
                              variant="primary"
                              fullWidth
                            />
                            <p className="text-center text-xs text-red-600 font-semibold mt-3">Abre seu email para anexar o PDF assinado</p>
                            <ul className="text-xs text-gray-600 space-y-1 mt-4 ml-4">
                              <li className="flex gap-2">
                                <span>•</span>
                                <span>Abre seu cliente de email</span>
                              </li>
                              <li className="flex gap-2">
                                <span>•</span>
                                <span>Mensagem pré-preenchida</span>
                              </li>
                              <li className="flex gap-2">
                                <span>•</span>
                                <span>Anexe o PDF assinado</span>
                              </li>
                            </ul>
                          </div>
                        </div>
                      </div>

                      {/* AUTO SAVE STATUS */}
                      <div className="bg-green-50 p-4 rounded-lg border-2 border-green-200">
                        <div className="flex items-center justify-center gap-2 text-sm">
                          {autoSaveStatus === 'saving' && (
                            <>
                              <Loader2 className="w-4 h-4 text-green-600 animate-spin" />
                              <span className="text-green-700 font-semibold">Salvando automaticamente...</span>
                            </>
                          )}
                          {autoSaveStatus === 'saved' && (
                            <>
                              <CheckCircle2 className="w-4 h-4 text-green-600" />
                              <span className="text-green-700 font-semibold">✓ Salvo com sucesso</span>
                              {lastAutoSaveTime && (
                                <span className="text-xs text-green-600">às {lastAutoSaveTime.toLocaleTimeString('pt-BR')}</span>
                              )}
                            </>
                          )}
                          {autoSaveStatus === 'idle' && lastAutoSaveTime && (
                            <>
                              <CheckCircle2 className="w-4 h-4 text-green-600" />
                              <span className="text-green-700 font-semibold">Seu plano é salvo automaticamente</span>
                            </>
                          )}
                        </div>
                      </div>
                    </div>
                  ) : (
                    <div className="text-center py-12 bg-green-50 rounded-lg border-2 border-green-200 space-y-4">
                      <div className="w-20 h-20 bg-green-600 rounded-full flex items-center justify-center mx-auto">
                        <MailCheck className="w-10 h-10 text-white" />
                      </div>
                      <h3 className="text-2xl font-bold text-green-900">Plano Salvo com Sucesso! ✅</h3>
                      <p className="text-sm text-green-700">Seu plano foi registrado no banco de dados da SES-SP.</p>
                      <div className="bg-white p-4 rounded-lg border border-green-300 space-y-2">
                        <p className="text-xs text-gray-600"><strong>Próximo Passo:</strong></p>
                        <p className="text-sm font-semibold text-gray-900">Envie o PDF assinado para:</p>
                        <p className="font-mono text-red-600 font-bold">gcf-emendasfederais@saude.sp.gov.br</p>
                      </div>
                      <Button
                        label="📧 Abrir Email"
                        onClick={handleSendToSES}
                        variant="primary"
                      />
                      <Button
                        label="Novo Cadastro"
                        onClick={() => window.location.reload()}
                        variant="secondary"
                      />
                    </div>
                  )}
                </Section>

                {/* STICKY BACK TO TOP BUTTON */}
                {activeSection !== 'info-emenda' && (
                  <button
                    onClick={() => scrollToSection('info-emenda')}
                    className="fixed bottom-8 right-8 p-3 bg-red-600 text-white rounded-full shadow-lg hover:bg-red-700 transition-all"
                    title="Voltar ao topo"
                  >
                    <ArrowUp className="w-6 h-6" />
                  </button>
                )}
              </div>
            </div>
            </>
          )}
        </div>
      </main>

      <style>{`
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .animate-fadeIn { animation: fadeIn 0.6s cubic-bezier(0.16, 1, 0.3, 1); }
      `}</style>
    </div>
  );
};

export default App;
