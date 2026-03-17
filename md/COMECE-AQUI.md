# 🚀 COMECE AQUI - Usuários Intermediários

## ⚡ Em 3 Passos Simples

### PASSO 1: Executar Script SQL
1. Abra o arquivo: `ADICIONAR-USUARIOS-INTERMEDIARIOS.sql`
2. Copie **TODO** o conteúdo
3. Acesse: https://app.supabase.com
4. Vá para: **SQL Editor** → **New Query**
5. Clique em: **Cole aqui** e cole o conteúdo
6. Clique em: **Run** (ou Ctrl+Enter)
7. Espere aparecer ✅ (verde)

### PASSO 2: Atualizar Navegador
1. Volte para seu app
2. Pressione: **Ctrl+F5** (ou Cmd+Shift+R se Mac)
3. Aguarde carregar completamente

### PASSO 3: Usar!
1. Abra **Gerenciamento de Usuários**
2. Leia as opções:
   - "Usuário Padrão" → Cria/edita/deleta seus próprios planos
   - "Usuário Intermediário" → Vê TODOS, mas não edita nada
   - "Administrador" → Total controle

---

## 👁️ O Que É Intermediário?

```
✅ Vê todos os planos do sistema
❌ Não cria planos
❌ Não edita planos  
❌ Não apaga planos
✅ Apenas leitura/visualização
```

**Ideal para:** Supervisores, auditores, consultores que precisam monitorar

---

## 🎯 Como Criar Usuário Intermediário?

1. Clique em: **Gerenciamento de Usuários**
2. Clique em: **Registrar Novo Usuário**
3. Preencha os dados:
   - Email
   - Nome
   - CNES (se tiver)
   - Senha
4. No campo "Perfil do Usuário" → Selecione: **Usuário Intermediário**
5. Clique em: **Registrar**

Pronto! ✅

---

## 🔄 Como Converter Usuário Existente?

1. Abra: **Gerenciamento de Usuários**
2. Encontre o usuário na lista
3. Use o dropdown: **"Padrão / Intermediário / Admin"**
4. Selecione: **Intermediário**
5. Confirme no popup
6. Pronto! ✅

---

## ✅ Como Testar?

### Teste Rápido:
1. Crie novo usuário como **Intermediário**
2. **Logout** da conta atual
3. **Login** com o novo usuário
4. Vá para: **Meus Planos**
5. Compare com o que você vê:
   - ✅ DEVE ver planos de TODOS
   - ❌ NÃO DEVE ter botão "Editar"
   - ❌ NÃO DEVE ter botão "Deletar"
   - ❌ NÃO DEVE ver botão "Dashboard"

Se tudo aparecer assim → **Sucesso!** ✅

---

## 📚 Documentação Completa

Se precisar de mais detalhes:
- `USUARIOS-INTERMEDIARIOS-GUIA.md` - Guia completo
- `CHECKPOINT-IMPLEMENTACAO.md` - Checklist técnico
- `RESUMO-USUARIOS-INTERMEDIARIOS.md` - Resumo rápido

---

## 🆘 Algo Não Funcionou?

### Problema: Não vê opção "Intermediário"
**Solução:** 
1. Recarregue a página (Ctrl+F5)
2. Limpe cache (Ctrl+Shift+Delete)
3. Logout e login novamente

### Problema: Usuário intermediário vê botões de Editar/Deletar
**Solução:**
1. Faça logout e login novamente
2. Se continuar, limpe cache (Ctrl+Shift+Delete)

### Problema: Erro ao executar SQL
**Solução:**
1. Verifique se colou o arquivo INTEIRO
2. Verifique se não tem linhas vazias extras
3. Execute de novo (Ctrl+Enter)

---

## 🎉 Pronto!

Agora você tem 3 tipos de usuários:
- 👑 **Admin** - Total controle
- 👁️ **Intermediário** - Visualização total
- 👤 **Padrão** - Controle apenas dos seus planos

**Dúvidas?** Leia `USUARIOS-INTERMEDIARIOS-GUIA.md`
