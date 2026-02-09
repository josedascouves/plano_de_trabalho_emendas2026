import React, { useState } from 'react';
import { AlertCircle, CheckCircle2, ChevronDown, Loader2 } from 'lucide-react';

interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary' | 'danger' | 'success';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  loading?: boolean;
  icon?: React.ReactNode;
  fullWidth?: boolean;
  type?: 'button' | 'submit' | 'reset';
}

export const Button: React.FC<ButtonProps> = ({
  label,
  onClick,
  variant = 'primary',
  size = 'md',
  disabled = false,
  loading = false,
  icon,
  fullWidth = false,
  type = 'button',
}) => {
  const variantStyles = {
    primary: 'bg-red-600 text-white hover:bg-red-700 active:bg-red-800 disabled:bg-red-300 shadow-md hover:shadow-lg',
    secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300 active:bg-gray-400 disabled:bg-gray-100 shadow-sm',
    danger: 'bg-red-500 text-white hover:bg-red-600 active:bg-red-700 disabled:bg-red-300 shadow-md hover:shadow-lg',
    success: 'bg-green-600 text-white hover:bg-green-700 active:bg-green-800 disabled:bg-green-300 shadow-md hover:shadow-lg',
  };

  const sizeStyles = {
    sm: 'px-4 py-2 text-xs lg:text-sm font-bold uppercase tracking-wide rounded-lg',
    md: 'px-6 py-5 text-sm lg:text-base font-bold uppercase tracking-wider rounded-xl',
    lg: 'px-8 py-5 lg:py-6 text-base lg:text-lg font-bold uppercase tracking-wider rounded-xl',
  };

  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled || loading}
      className={`
        inline-flex items-center justify-center gap-3 
        transition-all duration-200 font-bold
        disabled:cursor-not-allowed disabled:opacity-50
        focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-600
        ${variantStyles[variant]}
        ${sizeStyles[size]}
        ${fullWidth ? 'w-full' : ''}
      `}
      aria-busy={loading}
    >
      {loading ? (
        <Loader2 className="w-4 h-4 lg:w-5 lg:h-5 animate-spin" />
      ) : (
        icon && icon
      )}
      {label}
    </button>
  );
};

interface SelectProps {
  label: string;
  name: string;
  value: string;
  onChange: (e: React.ChangeEvent<HTMLSelectElement>) => void;
  options: Array<{ value: string; label: string }>;
  required?: boolean;
  error?: string;
  help?: string;
  disabled?: boolean;
  hideBottomMargin?: boolean;
}

export const Select: React.FC<SelectProps> = ({
  label,
  name,
  value,
  onChange,
  options,
  required = false,
  error,
  help,
  disabled = false,
  hideBottomMargin = false,
}) => {
  const [isFocused, setIsFocused] = useState(false);

  return (
    <div className={hideBottomMargin ? '' : 'mb-6 lg:mb-8'}>
      <label
        htmlFor={name}
        className="block text-sm lg:text-base font-bold text-gray-900 mb-2 uppercase tracking-tight flex items-center gap-2"
      >
        {label}
        {required && (
          <span className="text-red-600 font-black text-base" aria-label="campo obrigatório">
            *
          </span>
        )}
        {value && !error && (
          <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0" />
        )}
      </label>

      <div className="relative">
        <select
          id={name}
          name={name}
          value={value}
          onChange={onChange}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          disabled={disabled}
          required={required}
          aria-label={label}
          aria-required={required}
          aria-invalid={!!error}
          aria-describedby={error ? `${name}-error` : help ? `${name}-help` : undefined}
          className={`
            w-full px-4 lg:px-6 py-5 rounded-lg lg:rounded-xl
            border-2 transition-all duration-200
            text-base font-medium appearance-none pr-10
            focus:outline-none focus:ring-2 focus:ring-offset-2
            ${
              error
                ? 'border-red-500 bg-red-50 focus:border-red-600 focus:ring-red-200'
                : isFocused
                  ? 'border-red-600 bg-white focus:border-red-700 focus:ring-red-200 shadow-md'
                  : 'border-gray-300 bg-white focus:border-red-600 focus:ring-red-100'
            }
            ${disabled ? 'bg-gray-100 text-gray-500 cursor-not-allowed border-gray-200' : ''}
          `}
        >
          <option value="">Selecione uma opção...</option>
          {options.map(option => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>

        {/* Ícone de chevron */}
        <ChevronDown className="absolute right-3 lg:right-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
      </div>

      {error && (
        <div
          id={`${name}-error`}
          className="mt-2 flex items-start gap-2 text-sm text-red-600 font-medium animate-slideDown"
          role="alert"
        >
          <AlertCircle className="w-4 h-4 flex-shrink-0 mt-0.5" />
          <span>{error}</span>
        </div>
      )}

      {help && !error && (
        <p id={`${name}-help`} className="mt-2 text-sm text-gray-500 font-medium">
          💡 {help}
        </p>
      )}
    </div>
  );
};

interface TextAreaProps {
  label: string;
  name: string;
  value: string;
  onChange: (e: React.ChangeEvent<HTMLTextAreaElement>) => void;
  placeholder?: string;
  required?: boolean;
  rows?: number;
  error?: string;
  help?: string;
  disabled?: boolean;
  maxLength?: number;
}

export const TextArea: React.FC<TextAreaProps> = ({
  label,
  name,
  value,
  onChange,
  placeholder,
  required = false,
  rows = 4,
  error,
  help,
  disabled = false,
  maxLength,
}) => {
  const [isFocused, setIsFocused] = useState(false);

  return (
    <div className="mb-6 lg:mb-8">
      <label
        htmlFor={name}
        className="block text-sm lg:text-base font-bold text-gray-900 mb-2 uppercase tracking-tight flex items-center gap-2"
      >
        {label}
        {required && (
          <span className="text-red-600 font-black text-base" aria-label="campo obrigatório">
            *
          </span>
        )}
        {value.length > 0 && !error && (
          <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0" />
        )}
      </label>

      <textarea
        id={name}
        name={name}
        value={value}
        onChange={onChange}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
        placeholder={placeholder}
        disabled={disabled}
        rows={rows}
        maxLength={maxLength}
        required={required}
        aria-label={label}
        aria-required={required}
        aria-invalid={!!error}
        aria-describedby={error ? `${name}-error` : help ? `${name}-help` : undefined}
        className={`
          w-full px-4 lg:px-6 py-5 rounded-lg lg:rounded-xl
          border-2 transition-all duration-200
          text-base font-medium placeholder-gray-400 resize-vertical
          focus:outline-none focus:ring-2 focus:ring-offset-2
          ${
            error
              ? 'border-red-500 bg-red-50 focus:border-red-600 focus:ring-red-200'
              : isFocused
                ? 'border-red-600 bg-white focus:border-red-700 focus:ring-red-200 shadow-md'
                : 'border-gray-300 bg-white focus:border-red-600 focus:ring-red-100'
          }
          ${disabled ? 'bg-gray-100 text-gray-500 cursor-not-allowed border-gray-200' : ''}
        `}
      />

      <div className="flex justify-between items-start mt-2">
        <div>
          {error && (
            <div
              id={`${name}-error`}
              className="flex items-start gap-2 text-sm text-red-600 font-medium"
              role="alert"
            >
              <AlertCircle className="w-4 h-4 flex-shrink-0 mt-0.5" />
              <span>{error}</span>
            </div>
          )}

          {help && !error && (
            <p id={`${name}-help`} className="text-sm text-gray-500 font-medium">
              💡 {help}
            </p>
          )}
        </div>

        {maxLength && (
          <span className="text-xs text-gray-500 font-medium">
            {value.length} / {maxLength}
          </span>
        )}
      </div>
    </div>
  );
};

export default { Button, Select, TextArea };
