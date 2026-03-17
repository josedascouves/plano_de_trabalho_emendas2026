# 🚀 Guia - Migrar Usuários Existentes (7 usuários)

## Situação
Você já tem **7 usuários** criados no Supabase Auth:
- ✅ **afpereira@saude.sp.gov.br** → Será ADMIN
- ✅ 6 outros usuários → Serão USERS

## Objetivo
Migrar esses usuários para as tabelas `profiles` e `user_roles` com estrutura corrigida.

---

## ⏱️ Tempo Estimado: 2 minutos

---

## 🎯 Execução em 2 Passos

### **PASSO 1: Executar Script de Limpeza e Setup**

⏰ **Tempo: 1 minuto**

**Arquivo:** `LIMPEZA-E-SETUP-COMPLETO.sql`

```
Supabase Dashboard
    ↓
SQL Editor > New Query
    ↓
Colar TODO o conteúdo de LIMPEZA-E-SETUP-COMPLETO.sql
    ↓
Clique em RUN ▶️
    ↓
Esperar que termine (aparece ✅ verde)
```

**Resultado esperado:**
```
✅ tables_created = 2
✅ rls_policies_count = 9
✅ functions_count = 7
```

---

### **PASSO 2: Executar Script de Migração**

⏰ **Tempo: 1 minuto**

**Arquivo:** `MIGRACAO-USUARIOS-EXISTENTES.sql`

```
SQL Editor > New Query
    ↓
Colar TODO o conteúdo de MIGRACAO-USUARIOS-EXISTENTES.sql
    ↓
Clique em RUN ▶️
    ↓
Esperar terminar
```

**Resultado esperado:**
```
✅ profiles_criados = 7
✅ user_roles_criados = 7
✅ total_admins = 1 (afpereira)
✅ total_users = 6
```

**Tabela de verificação:**
```
┌────────────────────┬──────────────────────┬────────────┬─────────┬──────────┐
│ id                 │ full_name            │ email      │ role    │ disabled │
├────────────────────┼──────────────────────┼────────────┼─────────┼──────────┤
│ 57a4936e...        │ Afpereira            │ afpereira  │ admin   │ false    │
│ 3ad7cc2b...        │ Camila Pereira...    │ ...        │ user    │ false    │
│ ca1e9bf9...        │ Mateus Ribeiro...    │ ...        │ user    │ false    │
│ 12876b40...        │ Teste                │ sessp.css  │ user    │ false    │
│ 01a6e716...        │ Maria                │ sessp.css1 │ user    │ false    │
│ 1008ec03...        │ Dick                 │ sessp.css2 │ user    │ false    │
│ 5a673cab...        │ Thais Cristina...    │ tcnbarboa  │ user    │ false    │
└────────────────────┴──────────────────────┴────────────┴─────────┴──────────┘
```

---

## ✅ Verificação Completa

Após PASSO 2, todos os usuários estarão prontos!

```sql
-- Teste 1: Ver estrutura
SELECT * FROM public.profiles LIMIT 1;

-- Teste 2: Ver roles
SELECT * FROM public.user_roles LIMIT 1;

-- Teste 3: Ver admin
SELECT * FROM public.user_roles WHERE role = 'admin';
-- Deve retornar: afpereira com role = admin
```

---

## 🌐 Teste no Navegador

```
1. Abra http://localhost:3000 (ou seu URL)
2. Tente fazer LOGIN com: afpereira@saude.sp.gov.br
3. Resultado esperado:
   ✅ Login funciona
   ✅ Dashboard aparece
   ✅ Sem erro 500
   ✅ Vê a opção de gerenciar usuários (porque é admin)
```

---

## 📊 Estrutura Após Migração

```
auth.users (Supabase - já existem)
    │ 7 usuários
    ├── afpereira@saude.sp.gov.br
    ├── Camila Pereira dos Santos
    ├── Mateus Ribeiro da Silva
    ├── Teste
    ├── Maria
    ├── Dick
    └── Thais Cristina Nascimento

    ↓ (via FK)

public.profiles (dados pessoais)
    │ 7 linhas
    ├── id, full_name, email, created_at, updated_at
    └─ SEM role (movido para user_roles)

public.user_roles (roles + status - SEM RLS)
    │ 7 linhas
    ├── afpereira → admin, disabled=false
    ├── camila → user, disabled=false
    ├── mateus → user, disabled=false
    ├── teste → user, disabled=false
    ├── maria → user, disabled=false
    ├── dick → user, disabled=false
    └── thais → user, disabled=false
```

---

## 🎯 O que cada script faz

### LIMPEZA-E-SETUP-COMPLETO.sql
- ✅ Deleta estrutura antiga (se existe)
- ✅ Cria `profiles` (com RLS)
- ✅ Cria `user_roles` (SEM RLS)
- ✅ Cria `audit_logs` (com RLS)
- ✅ Cria 9 políticas RLS
- ✅ Cria 7 funções SQL
- ✅ Cria triggers e views

### MIGRACAO-USUARIOS-EXISTENTES.sql
- ✅ Insere 7 usuários em `profiles`
- ✅ Insere 7 usuários em `user_roles`
- ✅ Define afpereira como ADMIN
- ✅ Define os outros como USER
- ✅ Verifica se tudo funcionou

---

## ❓ Dúvidas Comuns

### P: E se der erro no PASSO 1?
R: Verifique se tem pgcrypto:
```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```
Depois tente novamente.

### P: E se der erro no PASSO 2?
R: Pode ser que um usuário já exista. O script tem `ON CONFLICT DO UPDATE` então é seguro executar múltiplas vezes.

### P: Posso adicionar mais usuários depois?
R: Sim! Crie no Supabase Auth, depois execute:
```sql
INSERT INTO public.profiles (id, full_name, email, created_at, updated_at)
VALUES ('novo-uuid', 'Novo Nome', 'email@domain.com', now(), now());

INSERT INTO public.user_roles (user_id, role, disabled)
VALUES ('novo-uuid', 'user', false);
```

### P: Como fazer outro admin?
R: Execute:
```sql
UPDATE public.user_roles SET role = 'admin' WHERE user_id = 'uuid-do-usuario';
```

### P: Posso remover um usuário?
R: Sim, vai em Supabase Auth > Users > Delete
Ou execute:
```sql
DELETE FROM auth.users WHERE id = 'uuid-do-usuario';
-- Cascata deleta automaticamente profiles e user_roles
```

---

## ✨ Depois da Migração

Uma vez que tudo funcionar:

1. **Teste cada usuário fazendo login**
   - afpereira deve ver opção "Gerenciar Usuários"
   - Outros usuários não devem ver essa opção

2. **Teste as funções de admin**
   - Promote/Demote usuários
   - Resetar senhas
   - Desabilitar/habilitar usuários

3. **Verifique auditoria**
   - `audit_logs` deve ter registros de cada ação

---

## 📝 Checklist Final

- [ ] Executei LIMPEZA-E-SETUP-COMPLETO.sql
- [ ] Vi ✅ "Successfully executed"
- [ ] Executei MIGRACAO-USUARIOS-EXISTENTES.sql
- [ ] Vi ✅ "Successfully executed"
- [ ] Verifiquei que temos 7 profiles
- [ ] Verifiquei que temos 7 user_roles
- [ ] Verifiquei que afpereira é admin
- [ ] Testei login com afpereira
- [ ] Dashboard apareceu sem erro
- [ ] ✨ Sistema completo e pronto!

---

**Pronto!** Sistema com todos os 7 usuários migrados e funcionando! 🚀
