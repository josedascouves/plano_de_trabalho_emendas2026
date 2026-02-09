import React, { useState } from 'react';
import { AlertCircle, CheckCircle2 } from 'lucide-react';

interface InputFieldProps {
  label: string;
  name: string;
  type?: string;
  value: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  placeholder?: string;
  required?: boolean;
  mask?: (value: string) => string;
  error?: string;
  help?: string;
  disabled?: boolean;
  maxLength?: number;
  success?: boolean;
  hideBottomMargin?: boolean;
}

export const InputField: React.FC<InputFieldProps> = ({
  label,
  name,
  type = 'text',
  value,
  onChange,
  placeholder,
  required = false,
  mask,
  error,
  help,
  disabled = false,
  maxLength,
  success = false,
  hideBottomMargin = false,
}) => {
  const [isFocused, setIsFocused] = useState(false);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    let newValue = e.target.value;
    if (mask) {
      newValue = mask(newValue);
    }
    e.target.value = newValue;
    onChange(e);
  };

  const isValid = success && value.length > 0;

  return (
    <div className={hideBottomMargin ? '' : 'mb-12 lg:mb-14'}>
      {/* Label com indicadores */}
      <label
        htmlFor={name}
        className="block label-field mb-2 flex items-center gap-2"
      >
        {label}
        {required && (
          <span className="text-red-600 font-black text-base" aria-label="campo obrigatório">
            *
          </span>
        )}
        {isValid && !error && (
          <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0" />
        )}
      </label>

      {/* Campo de input com estados */}
      <div className="relative group">
        <input
          id={name}
          name={name}
          type={type}
          value={value}
          onChange={handleChange}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          placeholder={placeholder}
          disabled={disabled}
          maxLength={maxLength}
          aria-label={label}
          aria-required={required}
          aria-invalid={!!error}
          aria-describedby={error ? `${name}-error` : help ? `${name}-help` : undefined}
          className={`
            w-full px-4 lg:px-6 py-5 rounded-lg lg:rounded-xl
            border-2 transition-all duration-200
            text-base lg:text-base font-medium placeholder-gray-400
            focus:outline-none focus:ring-2 focus:ring-offset-2
            ${
              error
                ? 'border-red-500 bg-red-50 focus:border-red-600 focus:ring-red-200'
                : isValid
                  ? 'border-green-500 bg-green-50 focus:border-green-600 focus:ring-green-200'
                  : isFocused
                    ? 'border-red-600 bg-white focus:border-red-700 focus:ring-red-200 shadow-md'
                    : 'border-gray-300 bg-white focus:border-red-600 focus:ring-red-100'
            }
            ${disabled ? 'bg-gray-100 text-gray-500 cursor-not-allowed border-gray-200' : ''}
          `}
        />

        {/* Indicador visual de preenchimento */}
        {isFocused && !error && (
          <div className="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-400">
            <div className="w-1 h-6 bg-red-600 rounded-full" />
          </div>
        )}
      </div>

      {/* Mensagens de erro ou ajuda */}
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

      {/* Indicador de caracteres (se maxLength) */}
      {maxLength && (
        <p className="mt-2 text-xs text-gray-500 font-medium">
          {value.length} / {maxLength} caracteres
        </p>
      )}
    </div>
  );
};

export default InputField;
