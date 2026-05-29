import React, { useMemo } from 'react';
import { Check } from 'lucide-react';

interface StepperProgressProps {
  steps: Array<{ id: string; label: string; title?: string }>;
  activeStep: string;
  onStepClick?: (stepId: string) => void;
  completedSteps?: string[];
}

/**
 * StepperProgress — design compacto (≤ 90px)
 * Inspirado em Azure Portal / Power BI Service / Microsoft Fluent
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

  const activeStepData = steps[activeStepIndex];

  return (
    <div
      className="sticky z-30 bg-[#F3F4F6] border-b border-[#E5E7EB]"
      style={{ top: 72, fontFamily: "Inter, 'Segoe UI', sans-serif" }}
    >
      <div className="max-w-screen-xl mx-auto px-4 sm:px-6 py-2.5">
        <div className="bg-white rounded-xl border border-[#E5E7EB] px-4 sm:px-5 py-3 flex items-center gap-4">

          {/* ── Esquerda: número da etapa + label ativo ── */}
          <div className="flex-shrink-0">
            <p className="text-[10px] font-medium text-gray-400 uppercase tracking-wider leading-none mb-1">
              Etapa {activeStepIndex + 1} de {steps.length}
            </p>
            <p
              className="text-[14px] font-semibold text-gray-900 leading-tight whitespace-nowrap"
              title={activeStepData?.title}
            >
              {activeStepData?.label || ''}
            </p>
          </div>

          {/* ── Divisor vertical ── */}
          <div className="hidden sm:block w-px h-8 bg-gray-200 flex-shrink-0" />

          {/* ── Centro: bolinha + linha de progresso ── */}
          <div className="flex-1 flex items-center min-w-0">
            {steps.map((step, index) => {
              const isActive = step.id === activeStep;
              const isCompleted = completedSteps.includes(step.id) || index < activeStepIndex;

              return (
                <React.Fragment key={step.id}>
                  {/* Bolinha */}
                  <button
                    onClick={() => onStepClick?.(step.id)}
                    disabled={!onStepClick}
                    title={`${index + 1}. ${step.label}${step.title ? ` — ${step.title}` : ''}`}
                    aria-label={`Etapa ${index + 1}: ${step.label}`}
                    className={[
                      'flex-shrink-0 w-7 h-7 rounded-full flex items-center justify-center',
                      'text-[11px] font-bold transition-all duration-200 focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-1',
                      onStepClick ? 'cursor-pointer' : 'cursor-default',
                      isCompleted
                        ? 'bg-[#16A34A] text-white shadow-sm'
                        : isActive
                          ? 'bg-[#E53935] text-white shadow-md ring-4 ring-[#E53935]/20'
                          : 'bg-[#D1D5DB] text-gray-600',
                    ].join(' ')}
                  >
                    {isCompleted
                      ? <Check size={13} strokeWidth={3} />
                      : <span>{index + 1}</span>}
                  </button>

                  {/* Linha conectora entre bolinhas */}
                  {index < steps.length - 1 && (
                    <div
                      className="flex-1 mx-1 rounded-full overflow-hidden min-w-[6px]"
                      style={{ height: 4, backgroundColor: '#D1D5DB' }}
                    >
                      <div
                        className="h-full rounded-full transition-all duration-500"
                        style={{
                          width: isCompleted ? '100%' : '0%',
                          backgroundColor: '#16A34A',
                        }}
                      />
                    </div>
                  )}
                </React.Fragment>
              );
            })}
          </div>

          {/* ── Direita: contador de concluídas ── */}
          <div className="hidden sm:flex flex-col items-end flex-shrink-0">
            <p className="text-[13px] font-bold text-[#16A34A] leading-none">
              {completedSteps.length}/{steps.length}
            </p>
            <p className="text-[10px] text-gray-400 leading-none mt-0.5 uppercase tracking-wider">
              concluídas
            </p>
          </div>

        </div>
      </div>
    </div>
  );
};

export default StepperProgress;
