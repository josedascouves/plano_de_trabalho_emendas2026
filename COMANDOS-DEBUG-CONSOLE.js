// ════════════════════════════════════════════════════════════════════════
// COMANDO PARA EXECUTAR NO CONSOLE (F12) - DEBUG RÁPIDO
// ════════════════════════════════════════════════════════════════════════

// COPIE E COLE UM DESTES COMMANDS NO CONSOLE (F12):

// ─── OPÇÃO 1: Ver dados em tempo real do localStorage ───
console.log("=== DADOS NO STORAGE ===");
console.log("currentUser:", JSON.parse(localStorage.getItem('supabase.auth.json') || '{}'));
console.log("usersList:", JSON.parse(localStorage.getItem('usersList') || '{}'));


// ─── OPÇÃO 2: Limpar tudo e recarregar ───
localStorage.clear(); 
sessionStorage.clear();
location.reload();


// ─── OPÇÃO 3: Ver todos os logs de 👥 ───
console.log("Procure por '👥' nos logs acima");


// ─── OPÇÃO 4: Ver se é admin agora ───
// Copie isto no console:
fetch('https://seu-projeto.supabase.co/rest/v1/user_roles', {
  headers: {
    'apikey': 'sua-anon-key-aqui',
    'Authorization': 'Bearer ' + localStorage.getItem('sb_access_token')
  }
}).then(r => r.json()).then(d => console.log("User roles:", d))


// ═══════════════════════════════════════════════════════════════════════
// MAIS RÁPIDO: ABRA DEVTOOLS, PASTE ISTO E PRESSIONE ENTER:
// ═══════════════════════════════════════════════════════════════════════

// Força recarregamento com limpeza
(() => {
  console.clear();
  localStorage.clear();
  sessionStorage.clear();
  console.log("✅ Storage limpo!");
  console.log("⏳ Recarregando página...");
  setTimeout(() => location.reload(), 500);
})();
