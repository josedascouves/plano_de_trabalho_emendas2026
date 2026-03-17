# 🔐 RBAC - Gestão de Usuários - Guia de Implementação

## 📋 Visão Geral

Sistema completo de Controle de Acesso Baseado em Papéis (RBAC) com suporte a:
- ✅ Dois perfis: Administrador e Usuário Padrão
- ✅ Auditoria completa de ações
- ✅ Proteção do último administrador
- ✅ Políticas de Segurança em Nível de Linhas (RLS)
- ✅ Interface moderna e intuitiva

## 🚀 Passo 1: Executar Scripts SQL

### 1.1 Executar no Supabase SQL Editor

1. Abra [supabase.com](https://supabase.com)
2. Acesse seu projeto
3. Vá para **SQL Editor** > **New Query**
4. Copie todo o conteúdo de `setup-rbac-completo.sql`
5. Execute o script

**O script criará:**
- Tabela `profiles` com campos de RBAC
- Tabela `audit_logs` para auditoria
- Políticas RLS de segurança
- Funções de gerenciamento de usuários
- Triggers e visualizações

### 1.2 Criar o Primeiro Admin

Execute no SQL Editor:

```sql
-- Substitua com o UUID real do seu usuário
INSERT INTO profiles (id, role, full_name, email, created_at)
VALUES ('UUID_DO_USUARIO', 'admin', 'Nome Admin', 'email@example.com', now())
ON CONFLICT (id) DO UPDATE SET role = 'admin';
```

## 🎯 Passo 2: Atualizar a Aplicação TypeScript

### 2.1 Types Atualizados

Os tipos foram atualizados em `types.ts`:

```typescript
interface User {
  id: string;
  role: 'admin' | 'user';
  full_name: string;
  email: string;
  disabled?: boolean;
  // ... outros campos
}

interface AuditLog {
  id: number;
  affected_user_id: string;
  action: string;
  performed_by_id: string;
  details: Record<string, any>;
  created_at: string;
}

interface UserStats {
  active_admins: number;
  active_users: number;
  total_active_users: number;
  total_users: number;
  disabled_users: number;
}
```

### 2.2 Integrar o Componente

Em `App.tsx`, adicione uma rota para gestão de usuários:

```typescript
import UserManagement from './components/UserManagement';

function App() {
  return (
    <Routes>
      {/* Outras rotas... */}
      <Route path="/admin/usuarios" element={<UserManagement />} />
    </Routes>
  );
}
```

## 🔐 Funções SQL Disponíveis

### Promover Usuário para Admin

```sql
SELECT promote_user_to_admin('user-id-uuid');
```

**Requisitos:**
- Usuário logado deve ser admin
- Não pode promover a si mesmo
- Retorna erro se falhar

### Rebaixar Admin para Usuário

```sql
SELECT demote_admin_to_user('user-id-uuid');
```

**Proteção:**
- Não permite rebaixar se for o único admin ativo
- Não permite rebaixar a si mesmo
- Registra no log de auditoria

### Alterar Senha (Admin)

```sql
SELECT change_user_password_admin('user-id', 'nova-senha');
```

**Segurança:**
- Apenas admin pode executar
- Não pode alterar sua própria senha (usar `change_own_password`)
- Registra na auditoria

### Alterar Própria Senha

```sql
SELECT change_own_password('senha-atual', 'nova-senha');
```

**Validação:**
- Verifica senha atual
- Atualiza apenas para usuário logado
- Retorna erro se senha atual estiver incorreta

### Reset de Senha

```sql
SELECT reset_user_password('user-id');
```

**Retorna:**
- Senha temporária gerada
- Deve ser compartilhada com o usuário
- Admin deve comunicar ao usuário pessoalmente

### Ativar/Desativar Usuário

```sql
SELECT toggle_user_status('user-id', true);  -- desativar
SELECT toggle_user_status('user-id', false); -- ativar
```

**Proteção:**
- Não permite desativar o último admin
- Não permite desativar a si mesmo
- Registra na auditoria

### Deletar Usuário

```sql
SELECT delete_user_admin('user-id');
```

**Proteção:**
- Apenas admin pode deletar
- Não pode deletar a si mesmo
- Não pode deletar o último admin
- Registra na auditoria ANTES de deletar

## 📊 Políticas RLS (Row Level Security)

### Tabela: profiles

| Operação | Condição | Detalhes |
|----------|----------|----------|
| SELECT | Admin | Pode ver todos |
| SELECT | User | Pode ver apenas seu próprio perfil |
| INSERT | Admin | Apenas admin pode criar |
| UPDATE | Admin | Pode alterar qualquer usuário |
| UPDATE | User | Pode alterar apenas seus dados (não pode mudar role) |
| DELETE | Admin | Apenas admin pode deletar (não a si mesmo) |

### Tabela: audit_logs

| Operação | Acesso |
|----------|--------|
| SELECT | Admin ou quem realizou a ação |
| INSERT | Sistema (DEFINER) |

## 🔍 Auditoria

Todas as ações geram logs na tabela `audit_logs`:

| Ação | Descrição |
|------|-----------|
| CREATE_USER | Novo usuário criado |
| DELETE_USER | Usuário deletado |
| PROMOTE_TO_ADMIN | Promovido para admin |
| DEMOTE_TO_USER | Rebaixado para usuário padrão |
| CHANGE_PASSWORD_ADMIN | Admin alterou senha de outro |
| CHANGE_OWN_PASSWORD | Usuário alterou sua própria senha |
| RESET_PASSWORD | Senha resetada com código temporário |
| ENABLE_USER | Usuário reativado |
| DISABLE_USER | Usuário desativado |

## 🎨 Interface UserManagement

### Funcionalidades:

✅ **Listagem de Usuários**
- Busca por nome ou email
- Filtro por perfil (Admin/Padrão)
- Filtro por status (Ativo/Inativo)
- Ordenação (Nome, Data Criação, Perfil)

✅ **Estatísticas**
- Total de usuários
- Usuários ativos/inativos
- Conta de admins
- Conta de usuários padrão

✅ **Ações por Usuário**
- Alterar Perfil (com confirmação)
- Alterar Senha (modal seguro)
- Reset de Senha (gera temporária)
- Ativar/Desativar
- Deletar (dupla confirmação)

✅ **Histórico de Auditoria**
- Últimos 50 eventos
- Filtrado por permissões

## 🛡️ Segurança

### Proteções Implementadas:

1. **RLS (Row Level Security)**
   - Cada usuário só pode ver/editar seus dados
   - Admin tem acesso total
   - Políticas executadas no servidor

2. **Rate Limiting**
   - Implementar no seu backend
   - Proteger contra força bruta

3. **Dupla Confirmação**
   - Exclusão de usuários exige 2 confirmações
   - Mudança de perfil exibe aviso

4. **Proteção do Último Admin**
   - Sistema verifica antes de rebaixar/desativar/deletar
   - Retorna erro se for o último

5. **Funções com SECURITY DEFINER**
   - Executadas com permissões elevadas
   - Mas com validações rigorosas

## 🐛 Troubleshooting

### Erro: "Only admins can..."

**Causa:** Usuário novo não é admin

**Solução:**
1. Execute no SQL Editor:
```sql
UPDATE profiles SET role = 'admin' WHERE id = 'seu-uuid';
```

### Erro: "Cannot demote the last admin"

**Causa:** É o único admin ativo

**Solução:**
- Promova outro usuário primeiro
- Ou ative um admin desativado

### Erro: RLS Policy

**Causa:** Políticas não estão aplicadas corretamente

**Solução:**
1. Verifique em **Database** > **Policies** no Supabase
2. Certifique-se que `audit_logs` tem política de INSERT com `WITH CHECK (true)`
3. Re-execute o script SQL

### Usuário não consegue ver formulário

**Causa:** Role não é 'admin'

**Solução:**
1. Verifique o role na tabela profiles:
```sql
SELECT role, disabled FROM profiles WHERE id = 'uuid';
```
2. Se não for admin ou estiver disabled:
```sql
UPDATE profiles SET role = 'admin', disabled = false WHERE id = 'uuid';
```

## 📱 Exemplo de Uso no React

```tsx
import UserManagement from './components/UserManagement';

function AdminDashboard() {
  return (
    <div>
      <h1>Painel Administrativo</h1>
      <UserManagement />
    </div>
  );
}
```

## 🎓 Boas Práticas

1. **Nunca compartilhe senhas**
   - Use reset de senha
   - Comunique senhas por canal seguro

2. **Revise logs regularmente**
   - Auditar ações administrativas
   - Detectar atividades suspeitas

3. **Manter backup do último admin**
   - Sempre tenha email de recovery
   - Mantenha mais de um admin

4. **Desative em vez de deletar**
   - Melhor para auditoria
   - Preserva histórico

5. **Validar permissões no frontend**
   - Mas confiar na RLS do backend
   - Nunca confiar APENAS no frontend

## 📚 Arquivos Criados/Modificados

- ✅ `setup-rbac-completo.sql` - Script SQL completo
- ✅ `types.ts` - Tipos TypeScript atualizados
- ✅ `components/UserManagement.tsx` - Componente de gestão
- ✅ `RBAC_IMPLEMENTACAO.md` - Este arquivo

## 🤝 Suporte

Para dúvidas, consulte:
- Documentação Supabase: https://supabase.com/docs
- Docs PostgreSQL: https://www.postgresql.org/docs/
- Issues no projeto
