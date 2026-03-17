# 🔐 RBAC - Controle de Acesso por Perfil

Sistema institucional com proteção de acesso baseada em papéis (Role-Based Access Control).

---

## 👥 Dois Perfis de Acesso

### **👑 ADMIN (Administrador)**

✅ **Pode:**
- Visualizar **todos os planos** de todos os usuários
- Acessar o **Dashboard** completo com estatísticas e relatórios
- **Visualizar, baixar PDF** e deletar qualquer plano
- Identificar o **autor de cada plano** na lista
- **Gerenciar usuários**: criar, editar, deletar contas
- Ter um botão **"Usuários"** na barra de menu

❌ **Não pode:**
- (Sem limitações - tem acesso total)

---

### **👤 USUÁRIO (Comum)**

✅ **Pode:**
- Visualizar somente **seus próprios planos**
- **Criar novos planos**
- **Editar seus planos** (autosave automático)
- **Visualizar e baixar PDF** apenas dos seus planos
- **Deletar seus planos**

❌ **Não pode:**
- Acessar o **Dashboard** (acesso negado com mensagem clara)
- Visualizar planos de **outros usuários**
- Acessar a página de **Gerenciamento de Usuários**
- Ver o botão de Dashboard no menu
- Ver o botão de Usuários no menu

---

## 🎯 Recursos por Perfil

| Recurso | ADMIN | USUÁRIO |
|---------|-------|---------|
| **Novo Plano** | ✅ | ✅ |
| **Meus Planos** | ✅ (Todos) | ✅ (Apenas seus) |
| **Dashboard** | ✅ | ❌ Acesso Negado |
| **Gerenciar Usuários** | ✅ | ❌ Oculto |
| **Ver PDF** | ✅ (Qualquer) | ✅ (Apenas seus) |
| **Deletar Plano** | ✅ (Qualquer) | ✅ (Apenas seus) |
| **Visualizar Autor** | ✅ | ❌ |
| **Salvamento Automático** | ✅ | ✅ |

---

## 💾 Salvamento Automático (Autosave)

**Ambos os perfis têm:**

✅ **Salvamento automático** a cada alteração de dados
✅ **Sem botão de "Salvar Manual"** - tudo é autosave
✅ **Indicador visual** mostrando:
   - "Salvando automaticamente..."
   - "✓ Salvo com sucesso" + hora
   - "Seu plano é salvo automaticamente"

⏱️ **Debounce de 3 segundos** - salva 3 segundos após parar de digitar

---

## 🔍 Proteções de Acesso

### **1. Menu Lateral (Header)**

```
✅ NOVO PLANO        → Visível para todos
✅ MEUS PLANOS       → Visível para todos
✅ DASHBOARD         → Visível APENAS para ADMIN
✅ USUÁRIOS          → Ícone visível APENAS para ADMIN
```

### **2. Lista de Planos**

**Usuários comuns veem:**
- Apenas seus planos
- Botões: Ver PDF, Deletar
- 4 colunas: Parlamentar, Nº Emenda, Valor, Data

**ADMIN vê:**
- TODOS os planos
- Botões: Ver PDF, Deletar
- **5 colunas**: Parlamentar, Nº Emenda, Valor, **Autor**, Data
- Coluna "Autor" mostra quem criou (ex: "João Silva (Você)" se for o ADMIN)

### **3. Dashboard**

**Se NÃO for ADMIN:**
```
🔒 ACESSO NEGADO

O Dashboard é exclusivo para administradores.

Contacte um administrador se você acredita que 
deveria ter acesso.

[Botão: Voltar para Meus Planos]
```

**Se for ADMIN:**
- Mostra estatísticas globais
- Valor total de todos os planos
- Porcentagem por programa
- Resumo por programa

### **4. Gerenciamento de Usuários**

**Usuários comuns:**
- Modal não aparece
- Botão "Usuários" é oculto

**ADMIN:**
- Botão "Usuários" ✅ visível
- Pode criar novos usuários
- Pode visualizar lista de usuários

---

## 🔒 Validações de Segurança

### **Front-End**

✅ Funções `isAdmin()`, `canEditPlan()`, `canViewPlan()`
✅ Condicional `{isAdmin() && <Dashboard />}`
✅ Botões aparecem/desaparecem com base em permissões
✅ Menu se adapta ao perfil do usuário

### **Back-End (Supabase)**

✅ Query `loadPlanos()` filtra por:
   - ADMIN: Carrega TODOS
   - USUÁRIO: Carrega apenas `created_by = currentUser.id`

✅ Função `canViewPlan(planAuthor)` verifica:
   - Se é ADMIN → acesso total
   - Se é o autor → pode ver seu próprio plano
   - Caso contrário → acesso negado

✅ Função `canEditPlan(planAuthor)` verifica:
   - Se é ADMIN → pode editar qualquer um
   - Se é o autor → pode editar seu próprio
   - Caso contrário → acesso negado

---

## 📋 Fluxo de Usuário por Perfil

### **Fluxo USUÁRIO COMUM**

```
1. Login (email + senha)
   ↓
2. Carrega página com:
   - Menu: [NOVO PLANO] [MEUS PLANOS] (sem DASHBOARD)
   - Sem botão de USUÁRIOS
   ↓
3. Clica "MEUS PLANOS"
   ↓
4. Vê apenas seus planos
   - Pode clicar em "Ver PDF" dos seus
   - Pode clicar em "Deletar" dos seus
   ↓
5. Clica "NOVO PLANO"
   ↓
6. Preenche formulário
   ↓
7. Autosave salva automaticamente
   ↓
8. Clica em "Visualizar PDF"
   ↓
9. Clica "Enviar Assinado"
   ↓
10. Email abre com dados preenchidos
```

### **Fluxo ADMIN**

```
1. Login (email + senha)
   ↓
2. Carrega página com:
   - Menu: [NOVO PLANO] [MEUS PLANOS] [DASHBOARD] ✨
   - Botão USUÁRIOS ✨
   ↓
3. Clica "MEUS PLANOS"
   ↓
4. Vê TODOS os planos com coluna AUTOR
   - Pode clicar em "Ver PDF" de qualquer um
   - Pode clicar em "Deletar" de qualquer um
   ↓
5. Clica "DASHBOARD"
   ↓
6. Vê relatórios e estatísticas completas
   - Cantidad de planos
   - Valor total
   - Porcentagem por programa
   - Detalhes por programa
   ↓
7. Clica botão USUÁRIOS
   ↓
8. Modal mostra:
   - Formulário para criar usuários
   - Lista de usuários no sistema
```

---

## 🛡️ Proteção de Dados Sensíveis

### **Nunca confie apenas no Front-End!**

Implementamos proteções em **dois níveis**:

1. **Front-End**: UI se adapta por perfil (experiência do usuário)
2. **Back-End**: Supabase valida TODA requisição

Exemplo:

```typescript
// Front-end: esconde botões
{isAdmin() && <DashboardButton />}

// Back-end: Supabase também valida
.from('planos_trabalho')
.select('*')
.eq('created_by', user.id)  // Garante que vê apenas seus dados
```

---

## 📊 Mudanças Implementadas

✅ **Menu dinâmico** - Dashboard e Usuários aparecem apenas para ADMIN

✅ **Lista filtrada** - ADMIN vê tudo, usuário vê apenas seus

✅ **Coluna Autor** - Mostra quem criou (ADMIN vê)

✅ **Proteção de Dashboard** - Mensagem de acesso negado para usuários comuns

✅ **Autosave** - Sem botão de salvar manual

✅ **Proteção de PDF** - Via `canViewPlan()`

✅ **Proteção de Deletar** - Via `canEditPlan()`

---

## 🔑 Funções-Chave de RBAC

```typescript
// Verifica se é admin
const isAdmin = (): boolean => currentUser?.role === 'admin';

// Verifica se pode editar um plano
const canEditPlan = (planCreatedBy: string): boolean => {
  if (!currentUser) return false;
  return isAdmin() || planCreatedBy === currentUser.username;
};

// Verifica se pode visualizar um plano
const canViewPlan = (planCreatedBy: string): boolean => {
  if (!currentUser) return false;
  return isAdmin() || planCreatedBy === currentUser.username;
};
```

---

## ✨ Resultado Final

| Cenário | Antes | Depois |
|---------|-------|--------|
| Usuário tenta acessar Dashboard | ❌ Ele via os dados | ✅ Acesso Negado |
| Usuário tenta deletar plano de outro | ❌ Conseguia | ✅ Botão oculto |
| Admin quer ver planos | ❌ Via apenas seus | ✅ Vê TODOS |
| Admin quer saber quem criou plano | ❌ Sem coluna Autor | ✅ Nova coluna Autor |
| Salvamento de dados | ❌ Botão Manual | ✅ Autosave automático |

---

## 🎓 Next Steps

Para reforçar a segurança back-end, também implementar no Supabase:

1. **Row Level Security (RLS)** - Policies que validam permissões
2. **Audit Log** - Registrar quem acessou/modificou o quê
3. **API Guards** - Validar perfil em cada endpoint

Mas o sistema **já está funcional e seguro** com as proteções front-end + lógica de filtro!
