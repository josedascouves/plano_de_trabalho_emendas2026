/**
 * Máscaras e Validações para Campos
 * Formato brasileiro com validação real
 */

// CPF: 000.000.000-00
export const maskCPF = (value: string): string => {
  return value
    .replace(/\D/g, '')
    .slice(0, 11)
    .replace(/(\d{3})(\d)/, '$1.$2')
    .replace(/(\d{3})(\d)/, '$1.$2')
    .replace(/(\d{3})(\d{1,2})$/, '$1-$2');
};

export const validateCPF = (cpf: string): boolean => {
  const cleaned = cpf.replace(/\D/g, '');
  if (cleaned.length !== 11 || /^(\d)\1{10}$/.test(cleaned)) return false;
  
  let sum = 0;
  let remainder: number;
  
  for (let i = 1; i <= 9; i++) {
    sum += parseInt(cleaned.substring(i - 1, i)) * (11 - i);
  }
  
  remainder = (sum * 10) % 11;
  if (remainder === 10 || remainder === 11) remainder = 0;
  if (remainder !== parseInt(cleaned.substring(9, 10))) return false;
  
  sum = 0;
  for (let i = 1; i <= 10; i++) {
    sum += parseInt(cleaned.substring(i - 1, i)) * (12 - i);
  }
  
  remainder = (sum * 10) % 11;
  if (remainder === 10 || remainder === 11) remainder = 0;
  if (remainder !== parseInt(cleaned.substring(10, 11))) return false;
  
  return true;
};

// CNPJ: 00.000.000/0000-00
export const maskCNPJ = (value: string): string => {
  return value
    .replace(/\D/g, '')
    .slice(0, 14)
    .replace(/(\d{2})(\d)/, '$1.$2')
    .replace(/(\d{3})(\d)/, '$1.$2')
    .replace(/(\d{3})(\d)/, '$1/$2')
    .replace(/(\d{4})(\d)/, '$1-$2');
};

export const validateCNPJ = (cnpj: string): boolean => {
  const cleaned = cnpj.replace(/\D/g, '');
  if (cleaned.length !== 14 || /^(\d)\1{13}$/.test(cleaned)) return false;
  
  let size = cleaned.length - 2;
  let numbers = cleaned.substring(0, size);
  const digits = cleaned.substring(size);
  let sum = 0;
  let pos = size - 7;
  
  for (let i = size; i >= 1; i--) {
    sum += numbers.charAt(size - i) * pos--;
    if (pos < 2) pos = 9;
  }
  
  let result = sum % 11 < 2 ? 0 : 11 - (sum % 11);
  if (result !== parseInt(digits.charAt(0))) return false;
  
  size = size - 1;
  numbers = cleaned.substring(0, size);
  sum = 0;
  pos = size - 7;
  
  for (let i = size; i >= 1; i--) {
    sum += numbers.charAt(size - i) * pos--;
    if (pos < 2) pos = 9;
  }
  
  result = sum % 11 < 2 ? 0 : 11 - (sum % 11);
  if (result !== parseInt(digits.charAt(1))) return false;
  
  return true;
};

// Valor Monetário: R$ 1.234,56
export const maskCurrency = (value: string): string => {
  const cleaned = value.replace(/\D/g, '');
  const num = (Number(cleaned) / 100).toFixed(2);
  return num.replace('.', ',').replace(/\B(?=(\d{3})+(?!\d))/g, '.');
};

export const unmaskCurrency = (value: string): number => {
  const cleaned = value.replace(/\D/g, '');
  return Number(cleaned) / 100;
};

// Email validation
export const validateEmail = (email: string): boolean => {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
};

// Telefone: (11) 98765-4321
export const maskPhone = (value: string): string => {
  return value
    .replace(/\D/g, '')
    .slice(0, 11)
    .replace(/(\d{2})(\d)/, '($1) $2')
    .replace(/(\d{5})(\d)/, '$1-$2');
};

// CNES: apenas números, máximo 7 dígitos
export const maskCNES = (value: string): string => {
  return value.replace(/\D/g, '').slice(0, 7);
};

// Apenas números com separador de milhar
export const maskNumber = (value: string): string => {
  const cleaned = value.replace(/\D/g, '');
  return cleaned.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
};

// Porcentagem: 0 a 100 (mantém apenas números no state, sem % ou vírgula)
export const maskPercentage = (value: string): string => {
  // Remove TODOS os caracteres que não são número, incluindo %, , etc
  let cleaned = value.replace(/\D/g, '');
  
  // Se vazio, retorna vazio
  if (!cleaned) return '';
  
  // Limita a máximo 3 dígitos (para permitir até 100)
  cleaned = cleaned.slice(0, 3);
  
  // Converte para número
  let numValue = parseInt(cleaned, 10);
  
  // Se passou de 100, limita para 100
  if (numValue > 100) {
    numValue = 100;
  }
  
  // Retorna apenas como número string (sem formatação visual)
  // A formatação com % será adicionada apenas na exibição
  return String(numValue);
};

export const formatPercentageDisplay = (value: string): string => {
  // Para exibição: adiciona a formatação visual com vírgula e %
  if (!value) return '0,00%';
  const num = parseInt(value, 10);
  return num.toFixed(2).replace('.', ',') + '%';
};

export const unmaskPercentage = (value: string): number => {
  const cleaned = value.replace(/\D/g, '');
  return parseInt(cleaned, 10) || 0;
};

export default {
  maskCPF,
  validateCPF,
  maskCNPJ,
  validateCNPJ,
  maskCurrency,
  unmaskCurrency,
  validateEmail,
  maskPhone,
  maskCNES,
  maskNumber,
  maskPercentage,
  unmaskPercentage,
};
