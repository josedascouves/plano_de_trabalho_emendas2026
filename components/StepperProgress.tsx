import React, { useMemo } from 'react';
import { 
  FileText,
  Building2,
  Target,
  CheckCircle2,
  BarChart3,
  DollarSign,
  FileCheck,
  Check
} from 'lucide-react';

interface StepperProgressProps {
  steps: Array<{ id: string; label: string; title?: string }>;
  activeStep: string;
  onStepClick?: (stepId: string) => void;
  completedSteps?: string[];
}

/**
 * StepperProgress - ELEGANTE COM ÍCONES
 * Design moderno com ícones, labels descritivos e animações suaves
 */
export const StepperProgress: React.FC<StepperProgressProps> = ({
  steps,
  activeStep,
  onStepClick,
  completedSteps = [],
}) => {
  const activeStepIndex = useMemo(
    () => steps.findIndex(s => s.id === activeStep),
    [steps, activeStep]
  );

  const progressPercent = useMemo(
    () => ((activeStepIndex + 1) / steps.length) * 100,
    [activeStepIndex, steps.length]
  );

  // Ícones para cada etapa
  const stepIcons = [
    FileText,
    Building2,
    Target,
    CheckCircle2,
    BarChart3,
    DollarSign,
    FileCheck
  ];

  return (
    <div className="sticky top-24 z-30 bg-white border-b-2 border-gray-100 shadow-sm">
      <div style={{ maxWidth: '1280px', margin: '0 auto', padding: '1.5rem 2rem' }}>
        {/* Barra de progresso superior */}
        <div className="mb-4 h-1.5 bg-gray-100 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-red-600 to-red-500 transition-all duration-500 rounded-full"
            style={{ width: `${progressPercent}%` }}
          />
        </div>

        {/* Stepper com ícones e labels */}
        <div className="flex items-center justify-between gap-2">
          {steps.map((step, index) => {
            const isActive = activeStep === step.id;
            const isCompleted = completedSteps.includes(step.id) || index < activeStepIndex;
            const IconComponent = stepIcons[index] || FileText;

            return (
              <button
                key={step.id}
                onClick={() => onStepClick?.(step.id)}
                className={`flex flex-col items-center gap-2 px-2 py-2 rounded-lg transition-all duration-200 flex-1 ${
                  isActive
                    ? 'bg-red-50'
                    : isCompleted
                      ? 'bg-green-50'
                      : 'hover:bg-gray-50'
                }`}
                title={step.title}
                disabled={!onStepClick}
              >
                {/* Círculo com ícone */}
                <div
                  className={`flex items-center justify-center w-10 h-10 rounded-full transition-all duration-200 flex-shrink-0 ${
                    isCompleted
                      ? 'bg-green-500 text-white'
                      : isActive
                        ? 'bg-red-600 text-white ring-4 ring-red-200'
                        : 'bg-gray-200 text-gray-600'
                  }`}
                >
                  {isCompleted ? (
                    <Check className="w-5 h-5" strokeWidth={3} />
                  ) : (
                    <IconComponent className="w-5 h-5" />
                  )}
                </div>

                {/* Label descritivo */}
                <div className="text-center min-w-0">
                  <p className={`text-xs font-bold uppercase tracking-widest transition-colors ${
                    isActive
                      ? 'text-red-600'
                      : isCompleted
                        ? 'text-green-600'
                        : 'text-gray-500'
                  }`}>
                    {step.label}
                  </p>
                  <p className={`text-[10px] transition-colors truncate ${
                    isActive
                      ? 'text-gray-700 font-medium'
                      : 'text-gray-400'
                  }`}>
                    {step.title ? step.title.split(' ')[0] : ''}
                  </p>
                </div>
              </button>
            );
          })}
        </div>

        {/* Estatísticas de progresso */}
        <div className="mt-3 flex items-center justify-between">
          <span className="text-xs text-gray-500 font-medium">
            Etapa {activeStepIndex + 1} de {steps.length}
          </span>
          <span className="text-xs text-green-600 font-medium">
            {completedSteps.length} concluído(s)
          </span>
        </div>
      </div>
    </div>
  );
};

export default StepperProgress;
