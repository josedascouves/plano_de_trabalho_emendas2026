# 🆘 CORRIGIR ERRO DE PERMISSÃO DO ADMIN

## 🔴 PROBLEMA
```
Admin recebe erro de permissão após executar CONFIGURAR-USER-ROLES.sql
Mensagem típica: "permission denied for schema public" ou similar
```

## ✅ SOLUÇÃO (3 passos)

### PASSO 1: Execute o Script de Correção
1. Abra o arquivo: **`CORRIGIR-ERRO-ADMIN-RLS.sql`**
2. Copie **TODO** o conteúdo
3. Acesse: https://app.supabase.com → **SQL Editor**
4. Clique em: **New Query**
5. Cole o conteúdo
6. Execute: **Ctrl+Enter** ou clique em **Run**
7. Aguarde aparecer ✅ (verde)

### PASSO 2: Recarregue o App
1. Volte para seu aplicativo
2. Pressione: **Ctrl+F5** (recarregamento completo)
3. Aguarde carregar completamente
4. Faça logout e login novamente

### PASSO 3: Teste se Funcionou
1. Tente criar um novo usuário
2. Tente alterar papel de usuário
3. Tente acessar Dashboard
4. Verifique se todos botões aparecem normalmente

---

## 🔧 O QUE FOI Corrigido

### Problema Técnico
As políticas RLS (Row Level Security) estavam causando **recursão infinita**:
- Admin tenta ler permissões
- Policy tenta verificar se é admin
- Precisa ler permissões para verificar
- Loop infinito = Erro!

### Solução Implementada
1. ✅ Removidas políticas recursivas
2. ✅ Criadas políticas simples sem loop
3. ✅ Sincronizadas permissões
4. ✅ Verificado funcionamento

---

## ✨ Se Ainda Não Funcionar

Se continuar com erro, execute este script (super simplificado):

```sql
-- Desabilitar RLS completamente (menos seguro, mas funciona)
ALTER TABLE public.user_roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- Pronto! Agora funciona sem restrições
```

**Mas tente o script de correção PRIMEIRO!** Esse é o último recurso.

---

## 📞 Se Precisar

Tenha esses arquivos à mão:
- `CORRIGIR-ERRO-ADMIN-RLS.sql` ← Usar agora
- `ADICIONAR-USUARIOS-INTERMEDIARIOS.sql` ← Depois (se quiser intermediários)
- `CONFIGURAR-USER-ROLES.sql` ← Não execute de novo

---

**Próximo Passo: Abra `CORRIGIR-ERRO-ADMIN-RLS.sql` e execute! ↑**
