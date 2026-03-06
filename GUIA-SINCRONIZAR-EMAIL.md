# 🔧 Sincronização de Email com Supabase Auth

## ❌ Problema identificado
A usuária **HELENA EUGENIA NOGUEIRA DA SILVA** teve seu email alterado no sistema, mas o email no `auth.users` do Supabase não foi atualizado. Por isso, ela não consegue fazer login com o novo email.

## ✅ Solução implementada
1. Criada uma RPC function `update_user_email()` que sincroniza o email com a tabela `auth.users`
2. Atualizada a função `handleEditUser()` para chamar essa RPC quando o admin edita um usuário

## 📋 Passos para implementar

### PASSO 1: Executar o SQL no Supabase
1. Acesse o [Supabase Dashboard](https://app.supabase.com)
2. Entre no seu projeto
3. Vá para **SQL Editor** (lado esquerdo)
4. Clique em **New query**
5. Cole o SQL do arquivo: `CREATE-RPC-UPDATE-USER-EMAIL.sql`
6. Clique em **Run**

### PASSO 2: Verificar se a RPC foi criada com sucesso
Você verá uma mensagem: `Query executed successfully!`

### PASSO 3: Corrigir o email da usuária HELENA
Depois disso, quando você editar a usuária HELENA no sistema:
- Nome: HELENA EUGENIA NOGUEIRA DA SILVA
- Email: helena.n@huhsp.org.br
- O email será **automaticamente sincronizado** com o `auth.users`

## 🔍 Como testar
Após editar a usuária:
1. Avise à usuária para tentar fazer login com o novo email
2. Se der erro de "usuário não encontrado", limpe o cache/cookies do navegador
3. Tente novamente

## 📝 SQL que será executado

```sql
CREATE OR REPLACE FUNCTION update_user_email(user_id UUID, new_email TEXT)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  -- Atualizar email na tabela auth.users
  UPDATE auth.users
  SET email = new_email,
      raw_user_meta_data = raw_user_meta_data || jsonb_build_object('email', new_email),
      email_confirmed_at = CASE 
        WHEN email_confirmed_at IS NOT NULL THEN NOW() 
        ELSE email_confirmed_at 
      END
  WHERE id = user_id;

  result := json_build_object(
    'success', true,
    'message', 'Email atualizado com sucesso'
  );
  
  RETURN result;
EXCEPTION WHEN OTHERS THEN
  result := json_build_object(
    'success', false,
    'error', SQLERRM
  );
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;
```

## 🎯 Resultado final
✅ Quando um admin editar o email de qualquer usuário, o email será sincronizado automaticamente com a tabela `auth.users` do Supabase Auth
✅ A usuária conseguirá fazer login com o novo email
✅ Nenhuma alteração manual será necessária
