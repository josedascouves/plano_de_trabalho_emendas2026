# 🔧 CORRIGINDO: Intermediário Não Vê Dashboard/Planos

## ✅ Alteração Implementada

Removi o bloqueio de "Acesso exclusivo para admins" do Dashboard. Agora intermediários podem acessar.

---

## 🎯 Passos Para Resolver

### 1️⃣ Diagnosticar o Problema

**Execute este script SQL:**
- Arquivo: `DIAGNOSTICO-INTERMEDIARIO-COMPLETO.sql`
- Supabase → SQL Editor → New Query → Cole e Execute

**Este script vai mostrar:**
- ✅ ou ❌ Role do intermediário está como `'intermediate'`?
- ✅ ou ❌ Usuário está `disabled = false`?
- ✅ ou ❌ Existem planos no banco?

---

### 2️⃣ Interpretar os Resultados

#### ✅ Se role = 'intermediate' e disabled = false:

1. Na app browser: **Ctrl+F5** (limpa cache)
2. **Logout** (clique em sair)
3. **Login** novamente
4. Agora deve aparecer:
   - ✅ Dashboard na barra de menu
   - ✅ Planos na lista
   - ✅ Estatísticas no Dashboard

---

#### ❌ Se role = 'user' (deveria ser 'intermediate'):

O intermediário foi criado com `role = 'user'` quando deveria ser `'intermediate'`.

**CORRIGIR:**

```sql
UPDATE public.user_roles 
SET role = 'intermediate'
WHERE user_id = 'ID_QUE_APARECEU_NO_DIAGNOSTICO';

UPDATE public.profiles
SET role = 'intermediate'
WHERE id = 'ID_QUE_APARECEU_NO_DIAGNOSTICO';
```

Depois:
1. Ctrl+F5 na app
2. Logout e login novamente

---

#### ❌ Se role = NULL:

O usuário não tem entrada em `user_roles`.

**CORRIGIR:**

```sql
INSERT INTO public.user_roles (user_id, role, disabled)
VALUES ('ID_QUE_APARECEU_NO_DIAGNOSTICO', 'intermediate', false);

UPDATE public.profiles
SET role = 'intermediate'
WHERE id = 'ID_QUE_APARECEU_NO_DIAGNOSTICO';
```

Depois:
1. Ctrl+F5 na app
2. Logout e login novamente

---

#### ❌ Se existem planos mas nenhum aparece:

Pode ser que os planos foram criados por outro usuário. Isso é NORMAL.

**O intermediário vê TODOS os planos (de qualquer criador)**, não apenas os dele.

Se nem assim aparece:
- Execute a query de diagnóstico novamente
- Procure a seção "CRUZAMENTO USUÁRIOS vs PLANOS"
- Verifique se existem planos com `disabled = false`

---

## 🚀 Checklist Final

Depois de resolver, teste:

- [ ] Dashboard aparece na navegação (ao lado de "Meus Planos")
- [ ] Clico em Dashboard → vejo estatísticas e gráficos
- [ ] Clico em "Meus Planos" → vejo todos os planos do sistema
- [ ] Tento clicar em "Editar" em um plano → botão não funciona ou não existe
- [ ] Não existe botão de "👥 Gerenciamento de Usuários"

Se tudo passou ✅ = Intermediário está funcionando perfeitamente!

---

## 📝 Resumo Técnico

**O que mudou no código:**
- Dashboard agora aceita: `isAdmin() || currentUser?.role === 'intermediate'`
- Antes aceitava apenas: `isAdmin()`
- Função `checkSession` agora lê role de `user_roles` (não de `profiles`)

**Permissões do Intermediário:**
| Ação | Permitido? |
|------|-----------|
| Ver Dashboard | ✅ |
| Ver Todos Planos | ✅ |
| Editar Planos | ❌ |
| Deletar Planos | ❌ |
| Gerenciar Usuários | ❌ |

