# 🔧 SINCRONIZAR TODOS OS USUÁRIOS ÓRFÃOS

## ⚡ Quick Fix

**Arquivo:** `SINCRONIZAR-USUARIOS-ORFAOS.sql`

### Passos:

1. **Supabase → SQL Editor → New Query**
2. **Cole o arquivo completo**
3. **Execute** (Ctrl+Enter)
4. **Pronto!** ✅

---

## 🎯 O Que Este Script Faz

### Automaticamente:

✅ **Passo 1:** Cria `profiles` para todos os usuários em `auth.users` que não têm
✅ **Passo 2:** Cria `user_roles` para todos os usuários faltantes
✅ **Passo 3:** Sincroniza roles entre `profiles` e `user_roles`
✅ **Passo 4:** Mostra diagnóstico (quantos sincronizados)
✅ **Passo 5:** Lista todos os usuários finais
✅ **Passo 6:** Confirma sucesso

---

## 📊 Resultado Esperado

Ao executar, você verá:

```
✅ Passo 1: Profiles sincronizados
✅ Passo 2: User roles sincronizados  
✅ Passo 3: Roles atualizados para corresponder com profiles
=== RESULTADO DA SINCRONIZAÇÃO ===
total_usuarios | com_profile | sem_profile | com_role | sem_role
    10         |     10      |      0      |    10    |    0
```

---

## 🚀 Depois de Executar

1. **Ctrl+F5** na app (limpar cache)
2. **Logout/Login** de todos os usuários
3. Agora todos vão funcionar normalmente! ✅

---

## 🔍 Se Encontrar Problemas

Se algum usuário precisa de role diferente (ex: admin, intermediate):

```sql
UPDATE public.user_roles 
SET role = 'admin'
WHERE user_id = 'ID_DO_USUARIO';

UPDATE public.profiles
SET role = 'admin'
WHERE id = 'ID_DO_USUARIO';
```

---

## ✨ Benefícios

- ✅ Sem perda de dados
- ✅ Recupera usuários "desaparecidos"
- ✅ Sincroniza todas as 3 tabelas
- ✅ Idempotente (seguro executar múltiplas vezes)
- ✅ Mostra relatório completo ao final

