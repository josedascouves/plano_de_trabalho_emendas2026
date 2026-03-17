# 🚀 GUIA VISUAL - Criar 6 Usuários (Passo a Passo com Print)

## 📱 Tela 1: Abrir Supabase

```
┌──────────────────────────────────────────────────┐
│ 🌐 https://app.supabase.com                      │
│                                                   │
│ ┌────────────────────────────────────────────┐   │
│ │ Login com sua conta                        │   │
│ │ E-mail: ___________                        │   │
│ │ Senha: ***                                 │   │
│ │ [Login]                                    │   │
│ └────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────┘
```

**Ação**: Acesse app.supabase.com e faça login

---

## 📱 Tela 2: Selecionar Projeto

```
┌──────────────────────────────────────────────────┐
│ 📊 Dashboard                                      │
│                                                   │
│ Seus Projetos:                                   │
│ ┌────────────────────────────────────────┐      │
│ │ plano-de-trabalho-ses-sp-2026 ✅       │      │
│ │ (Clique aqui)                          │      │
│ └────────────────────────────────────────┘      │
│                                                   │
│ Outros projetos...                              │
└──────────────────────────────────────────────────┘
```

**Ação**: Clique no seu projeto

---

## 📱 Tela 3: Ir para SQL Editor

```
┌──────────────────────────────────────────┐
│ Menu Esquerdo:                           │
│                                          │
│ ▶️ Dashboard                           │
│ ▶️ Editor                              │
│ ▶️ SQL Editor ← CLIQUE AQUI             │
│ ▶️ Authentication                      │
│ ▶️ Database                            │
│ ▶️ Storage                             │
│ ▶️ Realtime                            │
│                                          │
└──────────────────────────────────────────┘
```

**Ação**: Clique em "SQL Editor"

---

## 📱 Tela 4: Nova Query

```
┌──────────────────────────────────────────┐
│ SQL Editor                               │
│                                          │
│ [+ New Query] ← CLIQUE AQUI              │
│                                          │
│ ┌──────────────────────────────────────┐│
│ │ Queries recentes:                    ││
│ │ - Query 1                            ││
│ │ - Query 2                            ││
│ └──────────────────────────────────────┘│
└──────────────────────────────────────────┘
```

**Ação**: Clique em "+ New Query"

---

## 📱 Tela 5: PRIMEIRA EXECUÇÃO - RPC

```
┌──────────────────────────────────────────────────┐
│ SQL Editor - New Query                           │
│                                                   │
│ [Run] [Save] [Share] ...                        │
│                                                   │
│ ┌─ COLE AQUI: ─────────────────────────────┐   │
│ │ -- ============================================ │
│ │ -- CRIAR FUNÇÃO RPC...                    │   │
│ │ BEGIN;                                     │   │
│ │ ALTER TABLE profiles DISABLE ROW...       │   │
│ │ CREATE OR REPLACE FUNCTION...             │   │
│ │ ...                                        │   │
│ │ (TODO o conteúdo de: CRIAR-RPC-SIN...)  │   │
│ │                                            │   │
│ └────────────────────────────────────────────┘   │
│                                                   │
│ [Run] ← CLIQUE AQUI (OU Ctrl+Enter)            │
│                                                   │
└──────────────────────────────────────────────────┘
```

**Ações**:
1. Abrir arquivo: `CRIAR-RPC-SINCRONIZAR.sql`
2. Copiar TODO o conteúdo
3. Colar no editor
4. Clique em "[Run]"

**Resultado Esperado**:
```
✅ Funções RPC criadas com sucesso!
```

---

## 📱 Tela 6: SEGUNDA EXECUÇÃO - Criar 6 Usuários

```
┌──────────────────────────────────────────────────┐
│ SQL Editor - Limpar anterior                     │
│                                                   │
│ ┌─ LIMPAR E COLAR AQUI: ───────────────────┐   │
│ │ -- ====================================  │   │
│ │ -- CRIAR 6 NOVOS USUÁRIOS...              │   │
│ │ BEGIN;                                    │   │
│ │ ALTER TABLE profiles DISABLE...           │   │
│ │ INSERT INTO auth.users (...) VALUES (...) │   │
│ │ INSERT INTO auth.users (...) VALUES (...) │   │
│ │ ...x6 (6 INSERT statements)               │   │
│ │ SELECT '✅ RESULTADO FINAL'...            │   │
│ │                                           │   │
│ │ (TODO o conteúdo de: CRIAR-6-USUARIOS..) │   │
│ │                                           │   │
│ └─────────────────────────────────────────┘   │
│                                                   │
│ [Run] ← CLIQUE AQUI (OU Ctrl+Enter)            │
│                                                   │
└──────────────────────────────────────────────────┘
```

**Ações**:
1. Clique em "+ New Query" novamente
2. Abrir arquivo: `CRIAR-6-USUARIOS-COMPLETO.sql`
3. Copiar TODO o conteúdo
4. Colar no novo editor
5. Clique em "[Run]"

**Resultado Esperado**:
```
✅ PASSO 1: Os 6 usuários foram criados em auth.users
✅ PASSO 2: Profiles criados
✅ PASSO 3: User_roles criados com role = intermediate

📊 RESULTADO FINAL
(Tabela com 6 linhas mostrando os 6 usuários)
```

---

## 📱 Tela 7: Verificação Final

```
┌──────────────────────────────────────────────────┐
│ SQL Editor - Verificar Resultado                 │
│                                                   │
│ ┌─ EXECUTAR: ───────────────────────────────┐   │
│ │ SELECT                                     │   │
│ │   p.id, p.email, p.full_name, p.cnes,     │   │
│ │   ur.role, ur.disabled                     │   │
│ │ FROM public.profiles p                     │   │
│ │ LEFT JOIN public.user_roles ur...          │   │
│ │ WHERE p.email IN ('mvvas...', 'janete..') │   │
│ │                                            │   │
│ └────────────────────────────────────────────┘   │
│                                                   │
│ Resultado:                                       │
│ ┌────────────────────┐                          │
│ │ mvvasconcelos@...  │ cnes: 0052124           │
│ │ janete.sgueglia... │ role: intermediate      │
│ │ lhribeiro@...      │ disabled: false         │
│ │ gtcosta@...        │ ✅ 6 linhas              │
│ │ casouza@...        │                         │
│ │ rcloscher@...      │                         │
│ └────────────────────┘                          │
│                                                   │
│ ✅ SUCESSO! 6 usuários criados                  │
└──────────────────────────────────────────────────┘
```

**Ação**: Execute a query de verificação

---

## 📋 Checklist Final

```
☐ Passo 1: Abrir Supabase
☐ Passo 2: Selecionar projeto
☐ Passo 3: Ir parar SQL Editor
☐ Passo 4: Clique em "+ New Query"
☐ Passo 5: Executar CRIAR-RPC-SINCRONIZAR.sql
  └─ Aguardar: "✅ Funções RPC criadas..."
☐ Passo 6: Clique em "+ New Query" (nova)
☐ Passo 7: Executar CRIAR-6-USUARIOS-COMPLETO.sql
  └─ Aguardar: "✅ PASSO 1, 2, 3"
  └─ Aguardar: "📊 RESULTADO FINAL" (6 linhas)
☐ Passo 8: Executar query de verificação
  └─ Deve mostrar 6 usuários

✅ PRONTO! Sistema está 100% configurado!
```

---

## 🎯 Próximo Passo (Opcional)

### Testar Criar Usuário via UI

```
1. Abrir sua aplicação
2. Ir para "Criar Novo Usuário"
3. Preencher:
   - Nome: Um dos 6 nomes
   - E-mail: Um dos 6 e-mails
   - CNES: 0052124
   - Perfil: Intermediário
   - Senha: Qualquer uma

4. Clicar "[Criar Usuário]"

5. Resultado:
   ❌ Se der erro antigo = não executou passo 5 ou 7
   ✅ Se disser "✅ Usuário sincronizado" = PERFEITO!
```

---

## 📱 Arquivos Necessários

Você vai precisar abrir estes arquivos (estão na pasta do projeto):

```
1️⃣ CRIAR-RPC-SINCRONIZAR.sql
   ↓ Copiar TODO o conteúdo
   ↓ Colar no SQL Editor
   ↓ Executar

2️⃣ CRIAR-6-USUARIOS-COMPLETO.sql
   ↓ Copiar TODO o conteúdo
   ↓ Colar no SQL Editor
   ↓ Executar

3️⃣ TESTES-RAPIDOS-VALIDACAO.sql (opcional, para testar)
```

---

## ⏱️ Tempo Total

- **Passo 1-4**: 1 minuto
- **Passo 5**: 2 minutos (executar RPC)
- **Passo 6-7**: 3 minutos (executar usuários)
- **Passo 8**: 1 minuto (verificar)

**Total: ~7-10 minutos** ⏰

---

## 🆘 Se Algo Der Errado

### Erro 1: "Token expirado"
```
❌ Erro: "Invalid JWT..."
✅ Solução: Fazer login novamente no Supabase
```

### Erro 2: "Sintaxe SQL"
```
❌ Erro: "syntax error..."
✅ Solução: Certifique-se de copiar TODO o arquivo
           (não deixar nada de fora)
```

### Erro 3: "RPC não funciona"
```
❌ Erro: "Function not found..."
✅ Solução: Execute CRIAR-RPC-SINCRONIZAR.sql PRIMEIRO!
           (na sequeência correta)
```

### Erro 4: "Duplicação"
```
❌ Erro: "ON CONFLICT..."
✅ Solução: É NORMAL! Significa que o usuário já existe.
           Ignore este erro (é por segurança)
```

---

**✅ Pronto! Seu sistema está 100% operacional!**
