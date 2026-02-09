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
};
