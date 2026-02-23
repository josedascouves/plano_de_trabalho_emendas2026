/**
 * Módulo de Segurança
 * Desabilita console e detecta tentativas de acesso ao DevTools
 */

export const initializeSecurity = () => {
  // 1️⃣ DESABILITAR TODOS OS MÉTODOS DO CONSOLE
  const noop = () => {};
  
  // @ts-ignore
  window.console.log = noop;
  // @ts-ignore
  window.console.warn = noop;
  // @ts-ignore
  window.console.error = noop;
  // @ts-ignore
  window.console.info = noop;
  // @ts-ignore
  window.console.debug = noop;
  // @ts-ignore
  window.console.trace = noop;
  // @ts-ignore
  window.console.table = noop;
  // @ts-ignore
  window.console.time = noop;
  // @ts-ignore
  window.console.timeEnd = noop;
  // @ts-ignore
  window.console.group = noop;
  // @ts-ignore
  window.console.groupEnd = noop;

  // 2️⃣ BLOQUEAR ATALHOS DO DEVTOOLS
  document.addEventListener('keydown', (e: KeyboardEvent) => {
    // F12 - DevTools
    if (e.key === 'F12') {
      e.preventDefault();
      return false;
    }
    // Ctrl+Shift+I - Inspecionar elemento
    if (e.ctrlKey && e.shiftKey && e.key === 'I') {
      e.preventDefault();
      return false;
    }
    // Ctrl+Shift+J - Console
    if (e.ctrlKey && e.shiftKey && e.key === 'J') {
      e.preventDefault();
      return false;
    }
    // Ctrl+Shift+C - Inspecionar elemento
    if (e.ctrlKey && e.shiftKey && e.key === 'C') {
      e.preventDefault();
      return false;
    }
  });

  // 3️⃣ DETECTAR DEVTOOLS ABERTO (método heurístico)
  const checkDevTools = () => {
    const threshold = 160;
    if (window.outerHeight - window.innerHeight > threshold) {
      // DevTools aberto na parte inferior
      handleDevToolsDetected();
    }
    if (window.outerWidth - window.innerWidth > threshold) {
      // DevTools aberto na parte lateral
      handleDevToolsDetected();
    }
  };

  // Verificar DevTools periodicamente
  setInterval(checkDevTools, 500);

  // 4️⃣ BLOQUEAR CLIQUE DIREITO (opcional)
  document.addEventListener('contextmenu', (e: MouseEvent) => {
    e.preventDefault();
    return false;
  });

  // 5️⃣ LIMPAR STORAGE DE DEBUG (localStorage/sessionStorage)
  try {
    localStorage.clear();
    sessionStorage.clear();
  } catch (e) {
    // Ignorar erros de storage
  }
};

/**
 * Handler para quando DevTools é detectado
 */
const handleDevToolsDetected = () => {
  // Opção 1: Apenas alertar
  // alert('⚠️ Ferramentas de desenvolvedor não são permitidas!');

  // Opção 2: Redirecionar para logout
  // window.location.href = '/logout';

  // Opção 3: Fazer nada (apenas monitorar)
  // console.clear(); // Isso não funcionará pois console foi desabilitado
};

/**
 * Integração com React: chamar no useEffect
 * 
 * Exemplo em App.tsx:
 * 
 * useEffect(() => {
 *   initializeSecurity();
 * }, []);
 */
