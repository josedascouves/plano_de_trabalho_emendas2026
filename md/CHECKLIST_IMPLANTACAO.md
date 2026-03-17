# ✅ CHECKLIST DE IMPLANTAÇÃO - RBAC v1.0

## 🎯 Pre-Implantação

### Preparação
- [ ] Leia `README_RBAC_RAPIDO.md`
- [ ] Tenha acesso ao Supabase Dashboard
- [ ] Tenha VS Code aberto com o projeto
- [ ] Tenha backup do banco (recomendado)
- [ ] Acesso à tabela `auth.users`

### Validação de Ambiente
- [ ] npm packages instalados (`npm ls`)
- [ ] Supabase conectado (`supabase.ts` presente)
- [ ] TypeScript compilando sem erros
- [ ] Tailwind CSS funcionando
- [ ] React Router (se usando)

---

## 📊 FASE 1: Backend (SQL) - ~5 minutos

### 1.1 Executar Script SQL
- [ ] Abra [Supabase Dashboard](https://supabase.com)
- [ ] Vá a: **SQL Editor** → **New Query**
- [ ] Copie TODO o conteúdo de: `setup-rbac-completo.sql`
- [ ] Cole na query
- [ ] Clique **Run** (ícone ▶️ ou `Ctrl+Enter`)
- [ ] Aguarde conclusão (deve dizer "Done")

### 1.2 Validar Tabelas Criadas
- [ ] Vá a: **Database** → **Tables**
- [ ] Procure por:
  - [ ] `profiles` (deve existir)
  - [ ] `audit_logs` (deve existir)
- [ ] Clique em cada uma para ver estrutura
- [ ] Verifique total de colunas:
  - [ ] `profiles`: 8+ colunas
  - [ ] `audit_logs`: 7+ colunas

### 1.3 Validar Políticas RLS
- [ ] Vá a: **Database** → **Policies**
- [ ] Procure por políticas em:
  - [ ] `profiles` (deve ter 4+ policies)
  - [ ] `audit_logs` (deve ter 2+ policies)
- [ ] Verifique que RLS está **ON** em ambas tabelas

### 1.4 Validar Funções Criadas
- [ ] Vá a: **Database** → **Functions** (se disponível)
- [ ] OU execute no SQL Editor:
  ```sql
  SELECT routine_name FROM information_schema.routines
  WHERE routine_schema = 'public'
  AND (routine_name LIKE '%admin%' 
       OR routine_name LIKE '%password%'
       OR routine_name LIKE '%toggle%');
  ```
- [ ] Verifique que encontra as 7 funções:
  - [ ] `promote_user_to_admin`
  - [ ] `demote_admin_to_user`
  - [ ] `reset_user_password`
  - [ ] `change_user_password_admin`
  - [ ] `change_own_password`
  - [ ] `toggle_user_status`
  - [ ] `delete_user_admin`

### 1.5 Criar Primeiro Administrador
- [ ] No SQL Editor, execute:
  ```sql
  -- Substitua com valores reais!
  INSERT INTO profiles (id, role, full_name, email, created_at)
  VALUES ('SEU_UUID_AQUI', 'admin', 'Seu Nome', 'seu@email.com', now())
  ON CONFLICT (id) DO UPDATE SET role = 'admin';
  ```
- [ ] Substitua:
  - [ ] `'SEU_UUID_AQUI'` → UUID real do seu usuário
  - [ ] `'Seu Nome'` → Seu nome completo
  - [ ] `'seu@email.com'` → Seu email
- [ ] Execute
- [ ] Verifique resultado:
  ```sql
  SELECT id, role, full_name FROM profiles WHERE role = 'admin';
  ```
  - [ ] Deve retornar sua linha com `role = 'admin'`

---

## 💻 FASE 2: Frontend (React) - ~10 minutos

### 2.1 Atualizar types.ts
- [ ] Abra arquivo: `types.ts`
- [ ] Verifique que foi atualizado com:
  - [ ] Nova interface `User` (com mais campos)
  - [ ] Nova interface `AuditLog`
  - [ ] Nova interface `UserProfile`
  - [ ] Nova interface `UserStats`
- [ ] Se não estiver, copie do arquivo fornecido

### 2.2 Adicionar Componente UserManagement
- [ ] Verifique arquivo: `components/UserManagement.tsx`
- [ ] Se não existir, crie-o:
  - [ ] Copie conteúdo fornecido
  - [ ] Salve em: `components/UserManagement.tsx`
- [ ] Se existir, verifique tamanho (~12KB)

### 2.3 Adicionar Importação em App.tsx
- [ ] Abra: `App.tsx`
- [ ] Adicione import no topo:
  ```tsx
  import UserManagement from './components/UserManagement';
  ```
- [ ] Verifique que compila sem erros

### 2.4 Integrar Rota/Botão
- [ ] Escolha uma opção:

**Opção A: Botão no Dashboard**
```tsx
<button onClick={() => setShowUserManagement(true)}>
  Gerenciar Usuários
</button>

{showUserManagement && (
  <>
    <UserManagement />
    <button onClick={() => setShowUserManagement(false)}>Fechar</button>
  </>
)}
```

**Opção B: Rota Separada** (se usando React Router)
```tsx
<Route path="/admin/usuarios" element={<UserManagement />} />
```

**Opção C: Menu Dropdown**
```tsx
{currentUser?.role === 'admin' && (
  <button onClick={() => navigate('/admin/usuarios')}>
    👥 Gerenciar Usuários
  </button>
)}
```

- [ ] Escolha uma E implemente
- [ ] Compile: `npm run build` (sem erros?)

### 2.5 Verificar Componente
- [ ] Iniciar dev server: `npm run dev`
- [ ] Abra http://localhost:5173
- [ ] Faça login com seu admin
- [ ] Clique em "Gerenciar Usuários"
- [ ] Verifique que aparece a interface
- [ ] Procure por:
  - [ ] Título "Gestão de Usuários"
  - [ ] Cards de estatísticas
  - [ ] Barra de busca e filtros
  - [ ] Lista de usuários

---

## 🧪 FASE 3: Testes - ~15 minutos

### 3.1 Executar Testes SQL
- [ ] Abra SQL Editor
- [ ] Copie seções de `TESTES_RBAC.sql`
- [ ] Execute cada teste, um por um

**Teste 1: Tabelas**
```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('profiles', 'audit_logs');
```
- [ ] Deve retornar 2 linhas

**Teste 2: RLS Habilitado**
```sql
SELECT tablename, rowsecurity FROM pg_tables
WHERE tablename IN ('profiles', 'audit_logs');
```
- [ ] Ambas devem ter `rowsecurity = true`

**Teste 3: Funções Existem**
```sql
SELECT COUNT(*) as count FROM information_schema.routines
WHERE routine_schema = 'public' AND routine_name LIKE '%user%password%admin%toggle%';
```
- [ ] Deve retornar ~7

**Teste 4: RLS Funciona**
- [ ] Faça login como usuário padrão (não admin)
- [ ] No console do navegador: `fetch()`
- [ ] Tente: `SELECT * FROM profiles;`
- [ ] Deve retornar somente seu próprio profile

### 3.2 Testes na Interface
- [ ] Como admin, criado na FASE 1:
  - [ ] Acesse página de gestão
  - [ ] Veja sua conta na lista
  - [ ] Verifique estatísticas (deve mostrar 1 admin)

- [ ] Teste de **Prompt > Rebaixar**:
  - [ ] Clique em seu card
  - [ ] Tente "Alterar Perfil" para User
  - [ ] Deve retornar erro ou aviso (último admin)

- [ ] Teste de **Busca**:
  - [ ] Digite seu nome
  - [ ] Deve filtrar resultado

- [ ] Teste de **Filtros**:
  - [ ] Filtro por "Admin" 
  - [ ] Deve mostrar você (1 resultado)

### 3.3 Testes de Segurança
- [ ] RLS: Como usuário padrão
  - [ ] Tente acessar URL de admin
  - [ ] Deve ver mensagem de erro

- [ ] Proteção: Tentar deletar último admin
  - [ ] Como você é único, dê 2x confirmar
  - [ ] Deve aparecer erro "Cannot delete last admin"

- [ ] Auditoria: Checar logs
  - [ ] Clique em "Ver Histórico"
  - [ ] Deve mostrar suas ações

---

## 🚀 FASE 4: Deploy - ~10 minutos

### 4.1 Build
- [ ] Terminal: `npm run build`
- [ ] Verifique:
  - [ ] ✓ Sem erros de compilação
  - [ ] ✓ Arquivo em `dist/` foi criado
  - [ ] ✓ Tamanho razoável (~50-100KB)

### 4.2 Teste de Build
- [ ] Terminal: `npm run preview`
- [ ] Abra http://localhost:4173
- [ ] Teste layout completo:
  - [ ] Página carrega?
  - [ ] Login funciona?
  - [ ] Gestão de usuários abre?

### 4.3 Deploy no Netlify (se aplicável)
- [ ] Acesse Netlify
- [ ] Conecte repositório Git
- [ ] Configure:
  - [ ] Build command: `npm run build`
  - [ ] Publish directory: `dist`
- [ ] Deploy
- [ ] Acesse live URL
- [ ] Teste tudo novamente

### 4.4 Deploy Alternativo (Vercel, GitHub Pages, etc)
- [ ] Siga instruções específicas da plataforma
- [ ] Certifique variáveis de ambiente:
  - [ ] `VITE_SUPABASE_URL`
  - [ ] `VITE_SUPABASE_ANON_KEY`

---

## 📋 FASE 5: Pós-Implantação - Contínuo

### Segurança
- [ ] Revisar `audit_logs` diariamente
- [ ] Procurar por atividades suspeitas
- [ ] Monitorar `DISABLE_USER`, `DELETE_USER`, etc

### Manutenção
- [ ] Backup do banco diariamente
- [ ] Verificar espaço em disco
- [ ] Atualizar pacotes npm mensalmente
- [ ] Rever senhas temporárias (resetar)

### Escalabilidade
- [ ] Avaliar performance com >100 usuários
- [ ] Se lento, adicionar índices extras
- [ ] Archive logs >6 meses
- [ ] Considerar paginação se histórico enormeː

### Melhorias
- [ ] Implementar envio de email
- [ ] Adicionar 2FA
- [ ] Rate limiting
- [ ] Webhooks para eventos

---

## 🐛 ROLLBACK - Se Algo Quebrou

### Opção 1: Remover Tudo (Nuclear)
```sql
-- DELETAR TUDO (irreversível!)
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP FUNCTION IF EXISTS promote_user_to_admin CASCADE;
DROP FUNCTION IF EXISTS demote_admin_to_user CASCADE;
DROP FUNCTION IF EXISTS reset_user_password CASCADE;
DROP FUNCTION IF EXISTS change_user_password_admin CASCADE;
DROP FUNCTION IF EXISTS change_own_password CASCADE;
DROP FUNCTION IF EXISTS toggle_user_status CASCADE;
DROP FUNCTION IF EXISTS delete_user_admin CASCADE;
DROP VIEW IF EXISTS user_statistics CASCADE;
```

Depois:
1. Restaure do backup
2. OU re-execute `setup-rbac-completo.sql`

### Opção 2: Desabilitar Apenas Funções
```sql
-- Desabilitar execução
DROP FUNCTION promote_user_to_admin CASCADE;
DROP FUNCTION demote_admin_to_user CASCADE;
-- ... etc
```

Depois, re-crie do script.

### Opção 3: Restaurar do Backup
1. Supabase Dashboard > Backups
2. Selecione backup anterior
3. Clique "Restore"
4. Aguarde ~5 minutos

---

## 📞 Resolução de Problemas

| Problema | Solução |
|----------|---------|
| "Policy missing" | Re-execute setup-rbac.sql |
| "Function not found" | Verifique funções criadas |
| "401 Unauthorized" | Verifique token Supabase |
| "Cannot see users" | Você é admin? |
| "Interface vazia" | Console F12 procura erros |
| "Componente não compila" | npm install, limpe node_modules |

---

## ✅ Final Checklist

### Antes de Considerar Completo

- [ ] SQL executado com sucesso
- [ ] Primeiro admin criado
- [ ] types.ts atualizado
- [ ] UserManagement.tsx copiado
- [ ] App.tsx integrado
- [ ] Testes SQL passando
- [ ] Interface carrega
- [ ] Pode criar novo usuário
- [ ] Pode alterar perfil
- [ ] Pode alterar senha
- [ ] Pode ver histórico
- [ ] Proteção último admin funciona
- [ ] Dupla confirmação funciona
- [ ] Build sem erros
- [ ] Deploy realizado
- [ ] Tudo funciona em produção ✓

---

## 🎉 SUCESSO!

Se tudo passou, parabéns! 🎊

Seu sistema RBAC está **100% funcional** e **pronto para usar**.

### Próximos Passos
1. Criar mais admins (se necessário)
2. Integrar email para senhas
3. Documentar processo para sua equipe
4. Monitorar logs
5. Planejar melhorias futuras

---

**Versão**: 1.0  
**Data**: 12 de Fevereiro de 2026  
**Tempo Total**: ~40 minutos  

Boa sorte! 🚀

---

### Legenda
- [ ] = Tarefa a fazer (não feita)
- [x] = Tarefa completa
- ⚠️ = Cuidado/Atenção
- ✅ = Sucesso
- ❌ = Erro/Problema
