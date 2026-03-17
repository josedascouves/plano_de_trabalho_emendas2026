🔍 GUIA DE DEBUG - USUÁRIOS NÃO CARREGAM NO ADMIN
================================================

Se você está logado como admin mas NÃO consegue ver a lista de usuários:

┌─ PASSO 1: PREPARAR DEBUG ──────────────────────────────┐
│                                                           │
│ 1. Faça login como: afpereira@saude.sp.gov.br           │
│ 2. Pressione: F12 (abre DevTools)                        │
│ 3. Clique na aba: Console                                │
│ 4. Vá ao topo do console (Limpar antigos se quiser)     │
│ 5. Mantenha o console aberto lado a lado                 │
│                                                           │
└───────────────────────────────────────────────────────────┘

┌─ PASSO 2: VERIFICAR SE VOCÊ É ADMIN ──────────────────┐
│                                                           │
│ No console, procure por (use Ctrl+F):                    │
│ Procure: "🔐 isAdmin"                                    │
│                                                           │
│ VAI MOSTRAR ALGO COMO:                                   │
│ 🔐 isAdmin() check: {                                    │
│   currentUser: { id: "...", name: "...", role: "admin" }│
│   isAdmin: true                                          │
│ }                                                         │
│                                                           │
│ ❌ SE MOSTRAR: role: "user" ou isAdmin: false            │
│ → Você NÃO é admin no banco                             │
│ → Execute CORRECAO-ADMIN-PLANOS.sql no Supabase         │
│                                                           │
│ ✅ SE MOSTRAR: role: "admin" e isAdmin: true            │
│ → Continue no próximo passo                              │
│                                                           │
└───────────────────────────────────────────────────────────┘

┌─ PASSO 3: VERIFICAR SE MODAL ESTÁ ABRINDO ────────────┐
│                                                           │
│ 1. No console, procure por (Ctrl+F):                     │
│    Procure: "🔍 useEffect check"                         │
│                                                           │
│ 2. VA MOSTRAR ALGO COMO:                                 │
│ 🔍 useEffect check: {                                    │
│   isAuthenticated: true,                                 │
│   showUserManagement: true,                              │
│   currentUser_role: "admin",                             │
│   prevShowUserManagementRef: false,                       │
│   shouldFetch: true                                      │
│ }                                                         │
│                                                           │
│ IMPORTANTE:                                               │
│ • showUserManagement deve ser: true (modal aberto)       │
│ • currentUser_role deve ser: "admin"                     │
│ • shouldFetch deve ser: true                             │
│                                                           │
│ ❌ SE shouldFetch for false:                             │
│ → Pode ser que você não clicou no ícone de usuários     │
│ → Ou o ícone não aparece (porque não é admin)           │
│                                                           │
├─ COMO ABRIR O MODAL DE USUÁRIOS:                         │
│ 1. Procure no header no canto superior direito           │
│ 2. Deve aparecer um ícone de pessoas (USERS)             │
│ 3. Próximo ao ícone de sair                              │
│ 4. Clique NELE                                            │
│ → Deve abrir um pop-up com user management               │
│                                                           │
└───────────────────────────────────────────────────────────┘

┌─ PASSO 4: VER SE ESTÁ CARREGANDO DADOS ───────────────┐
│                                                           │
│ 1. Quando o modal abre, deve aparecer no console:       │
│    Procure por: "👥 fetchUsers()"                        │
│                                                           │
│ 2. DEVE APARECER ALGO COMO:                              │
│ 👥 fetchUsers() - Iniciando carregamento de usuários     │
│ ✅ Profiles carregados: 7 [...]                          │
│ ✅ User roles carregados: 7 [...]                        │
│ ✅ Lista de usuários atualizada: 7 [...]                 │
│   - User: teste@gmail.com => role: user, disabled: false │
│   - User: afpereira@saude.sp.gov.br => role: admin...    │
│                                                           │
│ ✅ SE MOSTRA ISSO:                                        │
│ → Os dados estão sendo carregados corretamente         │
│ → Vá ao próximo passo                                    │
│                                                           │
│ ❌ SE NÃO MOSTRA OU MOSTRA ❌:                           │
│ → Copie a mensagem de erro exato                         │
│ → Continue no passo "ERROS" abaixo                       │
│                                                           │
└───────────────────────────────────────────────────────────┘

┌─ PASSO 5: VERIFICAR SE ESTÁ RENDERIZANDO ─────────────┐
│                                                           │
│ Se passou pelos passos anteriores:                       │
│                                                           │
│ 1. Olhe para o modal de usuários na aplicação            │
│ 2. Deve aparecer um card para cada usuário               │
│ 3. Cada card mostra:                                      │
│    - Avatar com primeira letra do nome                   │
│    - Nome do usuário                                     │
│    - Email                                                │
│    - Status (Ativo/Inativo)                              │
│    - Role (Admin/Usuário)                                 │
│    - Botões (Editar, Promover, Deletar, etc)             │
│                                                           │
│ ✅ SE VÊ TUDO ISSO:                                       │
│ → SISTEMA ESTÁ FUNCIONANDO CORRETAMENTE! 🎉             │
│                                                           │
└───────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════

🆘 TROUBLESHOOTING - SE DEU ERRO

ERRO 1: "❌ Erro ao carregar profiles"
─────────────────────────────────────
Causa: RLS policy está impedindo leitura de profiles
Solução:
  1. Execute: CORRECAO-ADMIN-PLANOS.sql no Supabase
  2. Faça novo login

ERRO 2: "❌ Erro ao carregar user_roles"
──────────────────────────────────────
Causa: Tabela user_roles vazia ou sem dados
Solução:
  1. Execute no Supabase:
     SELECT COUNT(*) FROM public.user_roles;
  2. Se retornar 0, execute: MIGRACAO-USUARIOS-EXISTENTES.sql
  3. Depois faça novo login

ERRO 3: "shouldFetch: false" mas é admin
─────────────────────────────────────────
Causa: prevShowUserManagementRef não está sendo resetado
Solução:
  1. Recarregue a página: F5
  2. Faça novo login
  3. Tente abrir modal de usuários novamente

ERRO 4: "useEffect check" não aparece no console
────────────────────────────────────────────────
Causa: Não clicou no ícone de usuários ou ícone não existe
Solução:
  1. Procure no header (canto superior direito)
  2. Deve ter: Nome + Role + Ícone de pessoas + Ícone sair
  3. Se não vê ícone de pessoas:
     → Execute: console.log("isAdmin:", isAdmin())
     → Se retornar false, execute CORRECAO-ADMIN-PLANOS.sql

ERRO 5: "Nenhum usuário encontrado" na interface
──────────────────────────────────────────────────
Causa: usersList carregou como array vazio
Solução:
  1. Verifique no console se aparece:
     ✅ Profiles carregados: X
  2. Se X = 0, significa profiles vazia
  3. Execute no Supabase:
     SELECT COUNT(*) FROM public.profiles;
  4. Se retornar 0, use:
     MIGRACAO-USUARIOS-EXISTENTES.sql

═══════════════════════════════════════════════════════════════

📋 CHECKLIST DE DEBUG

[ ] 1. Logado como afpereira
[ ] 2. F12 aberto no Console
[ ] 3. Vejo "🔐 isAdmin" com role: "admin" e isAdmin: true
[ ] 4. Cliquei no ícone de pessoas (Users) no header
[ ] 5. Vejo "🔍 useEffect check" com shouldFetch: true
[ ] 6. Vejo "👥 fetchUsers()" no console
[ ] 7. Vejo "✅ Profiles carregados: X"
[ ] 8. Vejo "✅ User roles carregados: X"
[ ] 9. Vejo "✅ Lista de usuários atualizada: X"
[ ] 10. Vejo lista de usuários na interface

Se todos os checks passam, TUDO ESTÁ FUNCIONANDO! 🎉

═══════════════════════════════════════════════════════════════

💡 DICA: Se nada aparecer, experimente:
   1. F5 para recarregar a página
   2. Limpar cache: Ctrl+Shift+Delete
   3. Fazer logout e login novamente
   4. Executar CORRECAO-ADMIN-PLANOS.sql novamente
