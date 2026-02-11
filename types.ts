
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
  username: string;
  password?: string;
  role: 'admin' | 'user';
  name: string;
  cnes?: string;
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
