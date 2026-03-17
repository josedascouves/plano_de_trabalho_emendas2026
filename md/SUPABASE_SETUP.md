# ⚙️ Configuração Necessária do Supabase

## 🔴 Erros Atuais e Soluções

### Erro 1: `duplicate key value violates unique constraint "profiles_pkey"`
**Causa:** A tabela `profiles` criou automaticamente um registo quando o usuário foi criado em `auth.users`.
**Solução:** ✅ RESOLVIDO - Agora usando `upsert` em vez de `insert`.

---

### Erro 2: `Failed to load resource: 409 (Conflict)` em /profiles
**Causa:** Problema de RLS (Row Level Security) - permissões insuficientes para ler profiles
**Solução:** Siga os passos abaixo

---

## 📋 Passos para Configurar RLS (Row Level Security)

### 1️⃣ Habilitar RLS na Tabela `profiles`

```sql
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
```

### 2️⃣ Criar Política para Leitura (SELECT)

Vá para **SQL Editor** no Supabase e execute:

```sql
-- Permitir que admins leiam todos os profiles
CREATE POLICY "Admins can read all profiles"
ON profiles
FOR SELECT
TO authenticated
USING (
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
);

-- Permitir que usuários leiam seu próprio profile
CREATE POLICY "Users can read own profile"
ON profiles
FOR SELECT
TO authenticated
USING (id = auth.uid());
```

### 3️⃣ Criar Política para Escrita (UPDATE)

```sql
-- Permitir que admins atualizem qualquer profile
CREATE POLICY "Admins can update profiles"
ON profiles
FOR UPDATE
TO authenticated
USING (
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
);

-- Permitir que usuários atualizem seu próprio profile
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid());
```

### 4️⃣ Criar Política para Criação (INSERT)

```sql
-- Permitir que qualquer usuário autenticado seja criado (Supabase cria automaticamente)
CREATE POLICY "Enable insert for authenticated users"
ON profiles
FOR INSERT
TO authenticated
WITH CHECK (true);
```

### 5️⃣ Criar Política para Deleção (DELETE)

```sql
-- Permitir que admins deletem profiles
CREATE POLICY "Admins can delete profiles"
ON profiles
FOR DELETE
TO authenticated
USING (
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
);
```

---

## 🔐 Configuração de Autenticação

### Desabilitar Verificação de Email (Optional)

1. Vá para **Authentication → Providers → Email**
2. **Marque**: `Auto Confirm` ✅
3. **Desmarque**: `Confirm email` ❌

Isso fará com que novos usuários não precisem confirmar o email para fazer login.

---

## 🧪 Testando a Configuração

1. Abra o modal de **Gestão de Usuários**
2. Tente **criar um novo usuário**
3. Verifique no console se não há erros 409 ou 400
4. A lista de usuários deve carregar corretamente

---

## 📊 Estrutura Esperada da Tabela `profiles`

```
Column       | Type              | Modifiers
-------------|-------------------|----------
id           | uuid              | PRIMARY KEY
email        | text              | 
full_name    | text              | 
role         | text              | DEFAULT 'user'
disabled     | boolean           | DEFAULT false
created_at   | timestamp         | 
updated_at   | timestamp         |
```

Se `profiles` não existir, crie com:

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  role TEXT DEFAULT 'user',
  disabled BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

---

## ✅ Verificação Final

Após seguir estes passos:
- ✓ Usuários admins conseguem: Criar, listar, editar e deletar usuários
- ✓ Usuários padrão podem: Ver e editar seu próprio perfil
- ✓ Novos registros aparecem na lista em tempo real
- ✓ Nenhum erro 409 Conflict
- ✓ Nenhum erro 400 Bad Request em profiles

Se ainda houver problemas, verifique os logs no **Supabase → Logs** para detalhes.
