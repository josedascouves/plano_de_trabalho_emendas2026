# ⚡ Solução Rápida - Erro "Infinite Recursion" ao Fazer Login

## ❌ O Erro
```
infinite recursion detected in policy for relation "profiles"
Erro ao carregar perfil do usuário
```

## ✅ O Problema
As políticas RLS estavam consultando a tabela `profiles` recursivamente, causando erro.

## ✅ A Solução Implementada

Criei uma **tabela separada `user_roles`** (sem RLS) que armazena a role e status do usuário:
- Tabela `profiles`: Dados pessoais (nome, email, etc)
- Tabela `user_roles`: Role e status (admin/user, disabled/enabled)

Assim as políticas RLS não precisam consultar `profiles` recursivamente!

## ✅ Como Aplicar - 3 Passos

### **Passo 1: Execute o Script de Limpeza e Setup**

1. Abra o [Supabase Dashboard](https://app.supabase.com)
2. Vá até **SQL Editor**
3. Crie uma **nova query**
4. **Copie TODO o conteúdo** de [LIMPEZA-E-SETUP-COMPLETO.sql](LIMPEZA-E-SETUP-COMPLETO.sql)
5. **Cole** na query
6. **Clique em "Run"** ▶️

⏳ Espere até ver (leva ~5 segundos):
```
tables_created             | 2
rls_policies_count        | 9
functions_count           | 7
```

---

### **Passo 2: Criar o Primeiro Admin**

1. Vá para **Authentication > Users** no Supabase
2. **Crie um novo usuário** (ou use um existente)
3. **Copie o UUID** do usuário
4. Volte ao **SQL Editor** e execute **AMBAS** as queries:

```sql
-- Query 1: Criar profile (dados pessoais)
INSERT INTO public.profiles (id, full_name, email, created_at, updated_at)
VALUES (
  'COPIE-SEU-UUID-AQUI',
  'Seu Nome Completo',
  'seu.email@domain.com',
  now(),
  now()
);

-- Query 2: Criar user_role (permissão + status)
INSERT INTO public.user_roles (user_id, role, disabled)
VALUES (
  'COPIE-SEU-UUID-AQUI',
  'admin',
  false
);
```

✅ Resultado esperado: "Successfully inserted" em ambas

---

### **Passo 3: Teste no Navegador**

1. Abra sua aplicação
2. **Faça login** com o usuário admin que você criou
3. **Verifique**: Não deve haver erro
4. A interface deve carregar normalmente

---

## 📊 Nova Estrutura

| Tabela | Propósito | Tem RLS? |
|--------|-----------|----------|
| `profiles` | Nome, email, dados pessoais | ✅ Sim |
| `user_roles` | Role (admin/user), disabled | ❌ Não |
| `audit_logs` | Log de auditoria | ✅ Sim |

---

## ✨ Mudanças no Code

- ✅ `App.tsx` foi atualizado para buscar dados de ambas tabelas
- ✅ `LIMPEZA-E-SETUP-COMPLETO.sql` recria tudo com a nova estrutura
- ✅ Políticas RLS agora consultam `user_roles` (sem recursão)
- ✅ Todas as 7 funções SQL atualizadas para nova estrutura

---

**Pronto! O erro de recursão deve estar resolvido!** 🚀

Se ainda houver problemas, compartilhe a mensagem de erro completa.

