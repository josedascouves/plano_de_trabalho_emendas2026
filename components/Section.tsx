import React from 'react';
import { HelpCircle } from 'lucide-react';

interface SectionProps {
  id: string;
  title: string;
  description?: string;
  icon?: React.ReactNode;
  children: React.ReactNode;
  isComplete?: boolean;
  step?: number;
  totalSteps?: number;
  onHelpClick?: () => void;
}

/**
 * Section.tsx - Card com design institucion al moderno
 * Padding generoso, tipografia clara, sem decoração excessiva
 */
export const Section: React.FC<SectionProps> = ({
  id,
  title,
  description,
  icon,
  children,
  isComplete = false,
  step,
  totalSteps,
  onHelpClick,
}) => {
  return (
    <section
      id={id}
      className="scroll-mt-32"
      aria-labelledby={`${id}-title`}
    >
      {/* Card com padding espaçoso */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-8 lg:p-10">
        {/* Título e subtítulo */}
        <div className="mb-8">
          <div className="flex items-center justify-between gap-4 mb-2">
            <h2
              id={`${id}-title`}
              className="text-2xl font-bold text-gray-900"
            >
              {title}
            </h2>
            {onHelpClick && (
              <button
                onClick={onHelpClick}
                className="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-all duration-200"
                title="Clique para obter ajuda sobre como preencher esta seção"
                aria-label={`Ajuda para ${title}`}
              >
                <HelpCircle className="w-6 h-6" />
              </button>
            )}
          </div>
          
          {description && (
            <p className="text-base text-gray-600 font-medium">
              {description}
            </p>
          )}
        </div>

        {/* Conteúdo - Grid responsivo */}
        <div>
          {children}
        </div>
      </div>
    </section>
  );
};

export default Section;
