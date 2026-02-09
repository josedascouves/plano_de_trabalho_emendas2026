## 🔧 Corrigindo Erro de RLS (Row-Level Security) no Supabase

### Problema
```
Erro no banco de dados: new row violates row-level security policy
```

Este erro significa que as políticas de segurança (RLS) estão bloqueando a inserção de dados nas tabelas relacionadas (`acoes_servicos`, `metas_qualitativas`, `naturezas_despesa_plano`).

---

## ✅ Solução em 3 Passos

### PASSO 1: Executar o Script de Correção RLS

1. Abra o **Supabase Dashboard** → SQL Editor
2. Crie uma **nova query** (clique em "+ New")
3. **Copie e cole** TODO o conteúdo do arquivo `setup-rls-fix.sql`
4. Clique em **"Run"** (botão verde com ▶️)
5. Aguarde a execução completar (deve dizer "Success")

**Arquivo:** `setup-rls-fix.sql` (já criado no projeto)

---

### PASSO 2: Verificar Storage (se não existir)

Se aparecer erro ao enviar PDF, crie o bucket:

1. Abra **Supabase Dashboard** → Storage
2. Clique em **"Create a new bucket"**
3. Nome: `planos-trabalho-pdfs`
4. Selecione **"Public"** (para uploads)
5. Clique em **"Create bucket"**

---

### PASSO 3: Testar no Aplicativo

1. Faça login no sistema
2. Preencha um plano de trabalho completo
3. Clique em **"Finalizar e Salvar"**
4. Deve funcionar sem erros ✅

---

## 📋 O que foi Corrigido?

**Antes:**
- Políticas RLS muito restritivas usando `ALL` (SELECT, INSERT, UPDATE, DELETE juntos)
- Sub-tabelas bloqueavam INSERTs automaticamente

**Depois:**
- Políticas separadas por operação (INSERT, SELECT, UPDATE, DELETE)
- INSERT permite usuários autenticados insertarem em suas próprias tabelas
- SELECT/UPDATE/DELETE mantêm segurança (apenas dono ou admin)

---

## 🚨 Se Ainda Não Funcionar

1. **Verifique autenticação:**
   - Está logado? Veja a barra de header

2. **Verifique permissões de usuário:**
   - Seu usuário está em `auth.users`?
   - Tem um perfil em `profiles` com `role = 'user'` ou `'admin'`?

3. **Limpe cache do navegador:**
   - Faça logout e login novamente
   - `Ctrl + Shift + Delete` → limpar dados de site

4. **Contato:**
   - Se persistir, o erro virá com detalhes no console do navegador
   - Abra DevTools (F12) → Console para ver mais informações

---

## 🔐 Segurança Implementada

✅ **Apenas usuários autenticados** podem criar planos
✅ **Cada usuário sees apenas seus planos** (ou todos se admin)
✅ **Admin pode editar/deletar** todos os planos
✅ **Dados de outros usuários** são completamente invisíveis

---

## 📝 Resumo da Mudança

| Operação | Antes | Depois |
|----------|-------|--------|
| INSERT | ❌ Bloqueado | ✅ Permitido (autenticados) |
| SELECT | ✅ Permitido | ✅ Permitido (dono/admin) |
| UPDATE | Coletado | ✅ Permitido (dono/admin) |
| DELETE | Bloqueado | ✅ Permitido (dono/admin) |

