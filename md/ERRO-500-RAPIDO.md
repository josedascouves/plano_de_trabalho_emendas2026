# 🚨 ERRO 500: SOLUÇÃO RÁPIDA EM 5 MINUTOS

## ❌ Você está vendo:
```
Failed to load resource: the server responded with a status of 500 ()
Erro ao buscar perfil: Object
```

## ✅ SOLUÇÃO PASSO-A-PASSO

### 1️⃣ Ir ao Supabase
- Abra https://supabase.com
- Acesse seu projeto

### 2️⃣ Limpar Tudo (Importante!)
- Clique em: **SQL Editor** > **New Query**
- Copie-cole TUDO isto:

```sql
-- LIMPEZA
ALTER TABLE IF EXISTS public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.audit_logs DISABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "admin_see_all_profiles" ON public.profiles;
DROP POLICY IF EXISTS "user_see_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_update_all_profiles" ON public.profiles;
DROP POLICY IF EXISTS "user_update_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_create_profiles" ON public.profiles;
DROP POLICY IF EXISTS "admin_delete_profiles" ON public.profiles;
DROP POLICY IF EXISTS "admin_view_all_audit_logs" ON public.audit_logs;
DROP POLICY IF EXISTS "user_view_own_audit_logs" ON public.audit_logs;
DROP POLICY IF EXISTS "system_insert_audit_logs" ON public.audit_logs;
DROP VIEW IF EXISTS public.user_statistics;
DROP TRIGGER IF EXISTS profiles_update_timestamp ON public.profiles;
DROP FUNCTION IF EXISTS public.update_profiles_timestamp();
DROP FUNCTION IF EXISTS public.promote_user_to_admin(UUID);
DROP FUNCTION IF EXISTS public.demote_admin_to_user(UUID);
DROP FUNCTION IF EXISTS public.reset_user_password(UUID);
DROP FUNCTION IF EXISTS public.toggle_user_status(UUID, BOOLEAN);
DROP FUNCTION IF EXISTS public.change_own_password(VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS public.change_user_password_admin(UUID, VARCHAR);
DROP FUNCTION IF EXISTS public.delete_user_admin(UUID);
DROP TABLE IF EXISTS public.audit_logs CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
```

- Clique em **Run** (ou `Ctrl+Enter`)

### 3️⃣ Re-executar Setup
- **Nova Query**
- Copie TUDO de: `setup-rbac-completo.sql` (arquivo que foi atualizado)
- Clique em **Run**

### 4️⃣ Criar Admin
- Vá em: **Authentication** > **Users**
- Procure por seu email
- **Copie** o ID (é o UUID, um código longo)
- **Nova Query** com:

```sql
INSERT INTO public.profiles (id, role, full_name, email, created_at, updated_at)
VALUES (
  'COLE-O-UUID-AQUI',
  'admin',
  'Seu Nome',
  'seu@email.com',
  now(),
  now()
);
```

- Clique em **Run**

### 5️⃣ Testar
- Volte ao navegador
- Recarregue a página (F5)
- Faça login

---

## 🎉 Se deu certo
Você verá o dashboard sem erro 500!

## ❌ Se ainda tiver erro
Abra o navegador:
- Pressione **F12** (abrir console)
- Procure por erro vermelho
- Compartilhe a mensagem

---

**Tempo**: 5 minutos  
**Dificuldade**: ⭐ Fácil

Boa sorte! 🚀
