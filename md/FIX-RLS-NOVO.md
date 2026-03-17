## 🔧 Corrigindo Erro de RLS - VERSÃO CORRIGIDA

### ❌ Problema
```
Erro no banco de dados: new row violates row-level security policy
```

O erro persiste porque as políticas RLS antigas ainda estão ativas.

---

## ✅ Solução (SE JÁ EXECUTOU O SCRIPT ANTERIOR)

### **PASSO 1: Executar Script SQL NOVO no Supabase**

1. Abra: **https://supabase.com/dashboard**
2. Selecione seu projeto
3. Clique em: **SQL Editor** (menu lateral esquerdo)
4. Clique em: **"+ New Query"** (botão verde)
5. **Abra o arquivo:** `setup-rls-completo.sql` ← NOVO (não o anterior)
6. **Copie TODO o conteúdo**
7. **Cole na query do Supabase**
8. Clique em: **"RUN"** (botão verde ▶️)
9. Aguarde mensagem: ✅ **Success**

⚠️ **IMPORTANTE:** Use `setup-rls-completo.sql` - este remove TODAS as políticas antigas

---

### **PASSO 2: Verificar Storage** ✅

Você JÁ criou corretamente: `planos-trabalho-pdfs` (PUBLIC)

---

### **PASSO 3: Limpar Cache do Navegador**

1. **Logout** do sistema (se logado)
2. Pressione: **Ctrl + Shift + Delete** (Windows)
3. Selecione: **"Todos os tempos"**
4. Clique: **"Limpar dados"**
5. Feche a aba do browser
6. Volte para: **localhost:3004**
7. Faça **login novamente**

---

### **PASSO 4: Testar**

1. Preencha o formulário completo (todos os 7 passos)
2. Clique: **"Finalizar e Salvar"**
3. Deve salvar ✅

---

## 🔴 Se ainda der erro:

1. Abra **DevTools** (F12 no navegador)
2. Vá para aba: **Console**
3. Tente salvar novamente
4. Copie o erro exato que aparecer
5. Procure pelo padrão da mensagem de erro

---

## 📋 Arquivos Importantes

| Arquivo | Descrição |
|---------|-----------|
| `setup-rls-completo.sql` | ✅ NOVO - Script completo que remove tudo e reconstrói |
| `setup-rls-fix.sql` | ❌ Antigo - Pode não funcionar completamente |

Use apenas: **`setup-rls-completo.sql`**

