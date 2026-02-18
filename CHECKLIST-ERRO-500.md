# 📋 Checklist - Corrigir Erro 500 no Login

## Status Atual
- ❌ Erro 500 ao fazer login
- ❌ Tabela `profiles` não existe

---

## Resolução em 5 Minutos

### ✅ Fase 1: Preparação

- [ ] Abra [Supabase Dashboard](https://app.supabase.com)
- [ ] Vá até **SQL Editor** (lado esquerdo)
- [ ] Clique em **New Query**

---

### ✅ Fase 2: Executar Limpeza e Setup

**Arquivo a executar:** [LIMPEZA-E-SETUP-COMPLETO.sql](LIMPEZA-E-SETUP-COMPLETO.sql)

**Ações:**
- [ ] Abra o arquivo `LIMPEZA-E-SETUP-COMPLETO.sql`
- [ ] Copie **TODO** o conteúdo (Ctrl+A > Ctrl+C)
- [ ] Cole no SQL Editor do Supabase (Ctrl+V)
- [ ] Clique em **"Run"** ▶️
- [ ] Espere aparecer **"Successfully executed"**

**Resultado esperado:**
```
tables_created             | 2
rls_policies_count        | 9
functions_count           | 7
```

> ✅ Se viu esses números, você está no caminho certo!

---

### ✅ Fase 3: Criar Admin

**Passo 1: Obter UUID do usuário**
- [ ] Vá para **Authentication > Users**
- [ ] Abra um usuário existente (ou crie novo)
- [ ] **Copie o UUID** (coluna ID)

**Passo 2: Criar Admin no banco**
- [ ] Volte ao **SQL Editor**
- [ ] Crie uma **nova query**
- [ ] Cole ambos os comandos:

```sql
-- Comando 1: Criar profile (dados pessoais)
INSERT INTO public.profiles (id, full_name, email, created_at, updated_at)
VALUES (
  'COPIE-UUID-AQUI',
  'Seu Nome Completo',
  'seu.email@domain.com',
  now(),
  now()
);

-- Comando 2: Criar user_role (role + status)
INSERT INTO public.user_roles (user_id, role, disabled)
VALUES (
  'COPIE-UUID-AQUI',
  'admin',
  false
);
```

- [ ] Execute ambos
- [ ] Veja **"Successfully inserted"** em ambas as queries

---

### ✅ Fase 4: Teste

**Ações:**
- [ ] Abra sua aplicação no navegador
- [ ] Pressione **Ctrl+R** (recarregar)
- [ ] Limpe o cache: **Ctrl+Shift+Delete > Cookies/Cache**
- [ ] **Faça login** com suas credenciais

**Resultado esperado:**
- ✅ Sem erro 500
- ✅ Dashboard carrega normalmente
- ✅ Pode navegar tranquilamente

---

## 🚨 Erros Comuns e Soluções

### ❌ Erro: `extension "pgcrypto" not found`

**Solução:**
```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

Depois execute novamente `LIMPEZA-E-SETUP-COMPLETO.sql`

---

### ❌ Erro: `relation "auth.users" does not exist`

**Solução:** Você possivelmente está em um banco de dados errado.
- Verifique no Supabase que está no **projeto correto**
- Recarregue a página
- Tente novamente

---

### ❌ Ainda dá erro 500?

**Próximo passo:**
- Abra o navegador (F12 > Console)
- Copie a mensagem de erro COMPLETA
- Compartilhe para diagnóstico detalhado

---

## 📊 Verificação Rápida

Execute no SQL Editor para confirmar que tudo está certo:

```sql
-- Tabelas criadas?
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name IN ('profiles', 'user_roles', 'audit_logs');

-- Deve retornar: 3

-- Admin existe?
SELECT p.id, p.full_name, ur.role, ur.disabled 
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE ur.role = 'admin';

-- Deve retornar: Seu admin com role = 'admin' e disabled = false
```

---

## 💡 Resumo do que foi feito

| O quê | Por quê |
|------|--------|
| Deletou tabelas antigas | Estavam com RLS incorreto |
| Recriou tabelas | Com estrutura corrigida |
| Recriou políticas RLS | Com sintaxe corrigida (usando EXISTS) |
| Recriou funções | Para retornar JSONB (mais seguro) |
| Recriou triggers | Para atualizar timestamps automaticamente |

---

## ✨ Próximas Melhorias (Opcional)

- [ ] Configurar email de recuperação de senha
- [ ] Ativar 2FA (autenticação de dois fatores)
- [ ] Configurar políticas de senha forte
- [ ] Criar backups automáticos

---

**Status:** 🔄 Em Progresso → 🎉 Completo

Atualize este checklist conforme avança! ✅
