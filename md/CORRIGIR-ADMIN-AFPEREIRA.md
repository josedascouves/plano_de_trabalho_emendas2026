# 🔧 Corrigir Admin - Afpereira Não Vê Permissões

## Problema
- ❌ Logou como afpereira
- ❌ Mas não vê opção de "Gerenciar Usuários"
- ❌ Não consegue alterar usuários
- ❌ `role` está como 'user' em vez de 'admin'

## Solução em 3 Passos (2 minutos)

---

### **PASSO 1: Executar Diagnóstico SQL**

**Arquivo:** `DIAGNOSTICO-ADMIN.sql`

1. Supabase Dashboard → SQL Editor
2. Copiar TODO o conteúdo de `DIAGNOSTICO-ADMIN.sql`
3. Colar + **Run** ▶️

**O que vai fazer:**
- ✅ Diagnosticar quantos admins existem
- ✅ Verificar se afpereira está em user_roles
- ✅ **Automaticamente corrigir** afpereira para admin
- ✅ Verificar resultado final

**Resultado esperado:**
```
total_usuarios = 7
total_admins_after = 1  (ou mais)
afpereira deve ter role = 'admin' e disabled = false
```

---

### **PASSO 2: Recarregar Página + Fazer Login Novamente**

1. **Feche completamente o navegador** (pressione Alt+F4)
2. Abra uma **aba nova incógnita** (Ctrl+Shift+N)
3. Acesse: `http://localhost:3000` (ou sua URL)
4. **FAÇA LOGIN NOVAMENTE** com:
   - Email: `afpereira@saude.sp.gov.br`
   - Senha: (a que você usa)

---

### **PASSO 3: Verificar Se Funcionou**

Depois de fazer login, você deve ver:

✅ Dashboard aparece  
✅ **Botão "Gerenciar Usuários"** está VISÍVEL  
✅ Consegue clicar (não está desabilitado)  
✅ Lista de usuários aparece  
✅ Consegue alterar/promover/demover usuários  

---

## ❓ Por Que Isso Aconteceu?

O problema foi um de desses:

1. **Migração incompleta**
   - Usuários foram criados em `profiles`
   - Mas não foram criados em `user_roles`
   - Resultado: Nenhum role definido

2. **Erro na query de busca**
   - App buscava do `profiles` (que não tinha role)
   - Agora busca de `user_roles` corretamente
   - Precisa fazer login de novo

3. **Role não salvo corretamente**
   - Afpereira foi setado como 'user' em vez de 'admin'
   - Script corrige isso

---

## ✨ Próximas Funcionalidades Que Agora Funcionam

Uma vez que estiver como ADMIN, você pode:

- ✅ **Gerenciar Usuários** - Ver todos os usuários
- ✅ **Promover/Rebaixar** - Fazer admins
- ✅ **Resetar Senhas** - Do próprio dashboard
- ✅ **Desabilitar Usuários** - Sem deletar
- ✅ **Ver Auditoria** - Logs de todas as ações
- ✅ **Visibilidade Total** - Ver todos os planos

---

## 📝 Checklist

- [ ] Criei script `DIAGNOSTICO-ADMIN.sql`
- [ ] Executei SQL no Supabase
- [ ] Vi resultados do diagnóstico
- [ ] Fechei navegador completamente
- [ ] Abri aba nova incógnita
- [ ] Fiz login novamente com afpereira
- [ ] Dashboard carregou
- [ ] Botão "Gerenciar Usuários" está VISÍVEL
- [ ] Consegui clicar e ver usuários
- [ ] ✨ Sistema funcionando como admin!

---

## 🎯 Se Ainda Não Funcionar

Se depois disso ainda não funcionar:

### Verificação 1: Ver qual é o role depois do login
Abra F12 > Console e cole:
```javascript
// Isso vai mostrar o currentUser setado
console.log(window.currentUser);
```
Se mostrar `role: "admin"`, está correto. Senão, o login não pegou.

### Verificação 2: Ver o que o banco retorna
Abra F12 > Network e procure por requests que começam com "user_roles"
Clique no request e veja se a resposta tem `role: "admin"`

### Verificação 3: Forçar reset no App
```tsx
// No console do navegador:
localStorage.clear();
sessionStorage.clear();
location.reload();
```

---

**Pronto! Agora é só executar o script SQL e recarregar! 🚀**
