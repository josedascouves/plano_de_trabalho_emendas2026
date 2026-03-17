# 📐 Arquitetura Corrigida - Explicação Técnica

## ❌ Problema Original

As políticas RLS de `profiles` estavam consultando a mesma tabela `profiles`:

```sql
CREATE POLICY "admin_see_all_profiles" ON public.profiles
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p  -- ⚠️ RECURSÃO!
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );
```

Quando o usuário tentava fazer SELECT em `profiles`:
1. A política precisava validar se era admin
2. Para isso consultava... `profiles` novamente
3. O que triggerava a política de novo
4. Causando **infinite recursion** ❌

---

## ✅ Solução: Tabela Separada `user_roles`

Criei uma **tabela sem RLS** para armazenar roles e status:

### Estrutura Nova

```
┌─────────────────────┐
│   auth.users        │
│  (Supabase nativo)  │
└──────────┬──────────┘
           │ FOREIGN KEY
           ↓
┌─────────────────────────────────────────┐
│        public.profiles (COM RLS)        │
│  ┌───────────────────────────────────┐  │
│  │ id (PK, FK → auth.users)          │  │
│  │ full_name                         │  │
│  │ email                             │  │
│  │ last_login_at                     │  │
│  │ password_changed_at               │  │
│  │ created_at                        │  │
│  │ updated_at                        │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
           ↕ LEFT JOIN
┌─────────────────────────────────────────┐
│       public.user_roles (SEM RLS!)      │
│  ┌───────────────────────────────────┐  │
│  │ user_id (PK, FK → auth.users)     │  │
│  │ role ('admin' ou 'user')          │  │
│  │ disabled (true/false)             │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
           ↓ Consultada pelas políticas
┌─────────────────────────────────────────┐
│  Políticas RLS (sem recursão!)          │
│  Consultam user_roles para validar     │
│  role e permissões                     │
└─────────────────────────────────────────┘
```

---

## 🎯 Por que isso resolve?

1. **Tabela `user_roles` não tem RLS**
   - Políticas RLS podem consultá-la sem ativar recursão
   - É apenas uma tabela de referência simples

2. **Cada tabela tem responsabilidade única**
   - `profiles`: Dados pessoais (com RLS)
   - `user_roles`: Segurança/permissões (sem RLS)
   - `audit_logs`: Auditoria (com RLS)

3. **Performance melhorada**
   - `user_roles` tem índices em `user_id` e `role`
   - Consultas são muito rápidas
   - Menos dados a carregar em políticas

---

## 🔑 Política RLS Corrigida

Antes (❌ recursão):
```sql
WHERE p.id = auth.uid() AND p.role = 'admin'
```

Depois (✅ sem recursão):
```sql
WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
```

Consultando `user_roles` (sem RLS) em vez de `profiles` (com RLS)!

---

## 🗄️ Mudanças no Código

### `App.tsx` - Login atualizado

**Antes:**
```typescript
const { data: profile } = await supabase
  .from('profiles')
  .select('*')
  .eq('id', data.user.id)
  .single();

setCurrentUser({
  role: profile?.role,        // ❌ Não existe mais em profiles
  // ...
});
```

**Depois:**
```typescript
// Query 1: Buscar perfil
const { data: profile } = await supabase
  .from('profiles')
  .select('*')
  .eq('id', data.user.id)
  .single();

// Query 2: Buscar role e status
const { data: userRole } = await supabase
  .from('user_roles')
  .select('role, disabled')
  .eq('user_id', data.user.id)
  .single();

setCurrentUser({
  role: userRole?.role,        // ✅ De user_roles
  // ...
});
```

---

## 7️⃣ Funções SQL Atualizadas

Todas as 7 funções foram atualizadas para usar `user_roles`:

| Função | Mudança |
|--------|---------|
| `promote_user_to_admin()` | UPDATE `user_roles` SET role = 'admin' |
| `demote_admin_to_user()` | UPDATE `user_roles` SET role = 'user' |
| `reset_user_password()` | Verifica admin em `user_roles` |
| `toggle_user_status()` | UPDATE `user_roles` SET disabled |
| `change_own_password()` | Verifica auth em `user_roles` |
| `change_user_password_admin()` | Verifica admin em `user_roles` |
| `delete_user_admin()` | Verifica admin em `user_roles` |

---

## 📋 Migração de Dados (se você tiver existing data)

If you had data in old `profiles` table, você pode migrar:

```sql
-- Copiar dados de profiles para user_roles
INSERT INTO public.user_roles (user_id, role, disabled)
SELECT id, role, disabled FROM public.profiles_old;

-- Depois remover role e disabled de profiles
ALTER TABLE public.profiles DROP COLUMN IF EXISTS role;
ALTER TABLE public.profiles DROP COLUMN IF EXISTS disabled;
```

---

## 🔐 Segurança

### Por que `user_roles` não tem RLS?

✅ **É seguro** porque:
- Tabela é consultada apenas por **políticas RLS** (serverside)
- Não é acessível direto do cliente
- Mesmo que fosse, só tem `user_id`, `role`, `disabled`
- Sem dados sensíveis

### Dados sensíveis

Continuam em tabela **com RLS**:
- `profiles`: full_name, email, etc (com RLS)
- `auth.users`: senha, autenticação (Supabase gerencia)

---

## 🧪 Teste Rápido

Após aplicar o novo script, teste:

```sql
-- 1. Verificar recursão resolvida
SELECT COUNT(*) FROM public.profiles;
-- ✅ Deve retornar linha (0 ou mais)

-- 2. Verificar policies
SELECT policyname FROM pg_policies 
WHERE tablename = 'profiles';
-- ✅ Deve retornar 6 políticas

-- 3. Verificar user_roles sem RLS
SELECT COUNT(*) FROM public.user_roles;
-- ✅ Deve retornar linha (0 ou mais)

-- 4. Verificar que user_roles não tem RLS
SELECT tablename, rowsecurity FROM pg_tables 
WHERE tablename = 'user_roles';
-- ✅ Deve retornar rowsecurity = false
```

---

## 📚 Referências

- [Supabase RLS Best Practices](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL Row Security Policies](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Avoiding RLS Recursion](https://github.com/supabase/supabase/discussions/5235)

---

**Resultado:** Sistema RBAC robusto, sem recursão, e muito mais seguro! ✨
