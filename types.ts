
export interface Meta {
  id: string;
  descricao: string;
}

export interface Objetivo {
  id: string;
  titulo: string;
  metas: Meta[];
}

export interface Diretriz {
  id: string;
  numero: number;
  titulo: string;
  objetivos: Objetivo[];
}

export interface AcaoServico {
  categoria: string;
  itens: string[];
}

export interface NaturezaDespesa {
  codigo: string;
  descricao: string;
}

export interface User {
  id: string;
  username?: string;
  password?: string;
  role: 'admin' | 'user';
  name: string;
  cnes?: string;
  email?: string;
  full_name?: string;
  disabled?: boolean;
  last_login_at?: string;
  password_changed_at?: string;
  created_at?: string;
  updated_at?: string;
}

export interface AuditLog {
  id: number;
  affected_user_id: string;
  action: string;
  performed_by_id: string;
  details: Record<string, any>;
  ip_address?: string;
  user_agent?: string;
  created_at: string;
}

export interface UserProfile {
  id: string;
  role: 'admin' | 'user';
  full_name: string;
  email: string;
  disabled: boolean;
  last_login_at?: string;
  password_changed_at?: string;
  created_at: string;
  updated_at: string;
}

export interface UserStats {
  active_admins: number;
  active_users: number;
  total_active_users: number;
  total_users: number;
  disabled_users: number;
}

export interface FormState {
  emenda: {
    parlamentar: string;
    numero: string;
    valor: string;
    valorExtenso: string;
    programa: string;
  };
  beneficiario: {
    nome: string;
    cnes: string;
    cnpj: string;
    email: string;
    telefone: string;
  };
  planejamento: {
    diretrizId: string;
    objetivoId: string;
    metaIds: string[];
  };
  acoesServicos: Array<{
    categoria: string;
    item: string;
    metasQuantitativas: string[];
    valor: string;
  }>;
  metasQualitativas: Array<{
    meta: string;
    valor: string;
  }>;
  naturezasDespesa: Array<{
    codigo: string;
    valor: string;
  }>;
  justificativa: string;
  responsavelAssinatura: string;
}
