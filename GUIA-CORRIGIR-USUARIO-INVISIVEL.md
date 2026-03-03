# 🔧 Guia de Solução - Usuário Não Aparece na Lista

## Problema
- ✗ Usuário **Gabriela Dias** foi criado mas não aparece na lista de usuários
- ✗ Provavelmente não consegue fazer login
- ✗ Sistema diz "já foi criado" ao tentar criar novamente

## Causa Provável
O usuário foi criado em `auth.users` mas falta entrada em:
- `profiles` (dados pessoais)
- `user_roles` (papel/permissão)

Ou está com `disabled = true`

---

## ✅ SOLUÇÃO RÁPIDA (5 minutos)

### Passo 1: Executar Diagnóstico
1. Abra o **Supabase Dashboard** → **SQL Editor**
2. Copie TODO o conteúdo do arquivo: `DIAGNOSTICO-USUARIO-GABRIELA.sql`
3. Cole no SQL Editor
4. Clique em **Run** (ou Ctrl+Enter)

**Resultado esperado:** Você verá quantas vezes o usuário aparece em cada tabela

### Passo 2: Corrigir o Usuário
1. Abra o **Supabase Dashboard** → **SQL Editor** (novo)
2. Copie TODO o conteúdo do arquivo: `CORRIGIR-USUARIO-GABRIELA.sql`
3. Cole no SQL Editor
4. **IMPORTANTE:** Comente a seção "ALTERNATIVA: SE ACIMA NÃO FUNCIONAR..." (não execute ainda)
5. Clique em **Run** (execute só até o PASSO 4)

**Esperado:** Você verá 4 selects mostrando:
- Status final do usuário
- Lista de usuários visíveis (agora com Gabriela)
- Lista de usuários desativados
- Lista de usuários órfãos

### Passo 3: Testar no App
1. Volte para o App
2. **Recarregue a página** (Ctrl+R ou F5)
3. Abra o modal de **Gerenciar Usuários**
4. Procure por **"Gabriela"** na lista

Agora deve aparecer!

### Passo 4: Teste de Login
1. **Faça logout** (se estiver logado) ou abra em **janela anônima** (Ctrl+Shift+N)
2. Tente fazer login com:
   - **Email:** gabriela.dias@hc.fm.usp.br
   - **Senha:** 2071568

---

## ❌ SE NÃO FUNCIONAR (Solução Nuclear)

Se mesmo após executar o script acima o usuário ainda não aparece:

### Passo 1: Deletar Tudo
1. No **Supabase Dashboard** → **SQL Editor**
2. Role até a seção **"ALTERNATIVA: SE ACIMA NÃO FUNCIONAR..."**
3. Descomente e execute APENAS essas linhas:
```sql
DELETE FROM user_roles 
WHERE user_id IN (
  SELECT id FROM profiles 
  WHERE email = 'gabriela.dias@hc.fm.usp.br'
);

DELETE FROM profiles 
WHERE email = 'gabriela.dias@hc.fm.usp.br';
```

### Passo 2: Deletar do Auth
1. Vá para **Supabase Dashboard** → **Authentication** → **Users**
2. Procure por: **gabriela.dias@hc.fm.usp.br**
3. Clique nos **3 pontinhos** (⋮) à direita
4. Selecione **"Delete user"**
5. Confirme

### Passo 3: Recriar o Usuário
1. Volte ao App
2. Vá para **Gerenciar Usuários**
3. Preencha o formulário:
   - **Email:** gabriela.dias@hc.fm.usp.br
   - **Senha:** 2071568 (ou outra de 6+ caracteres)
   - **Nome:** Gabriela Dias Propheta Caneiro
   - **CNES:** 2071568
   - **Perfil:** Usuário Padrão
4. Clique em **Criar Usuário**

---

## 🔍 VERIFICAÇÃO FINAL

Para garantir que TODOS os usuários estão OK, execute este script:

```sql
-- Mostrar usuários visíveis
SELECT 
  p.full_name,
  p.email,
  ur.role,
  ur.disabled,
  'VISÍVEL ✅' as status
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
WHERE ur.disabled = false
ORDER BY p.full_name;

-- Mostrar usuários desativados
SELECT 
  p.full_name,
  p.email,
  ur.role,
  'DESATIVADO ❌' as status
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
WHERE ur.disabled = true
ORDER BY p.full_name;
```

**Resultado esperado:** 
- Gabriela deve aparecer em "VISÍVEL ✅"
- Nenhum deve estar em "DESATIVADO ❌" (a não ser que seja intencional)

---

## 💡 DICAS

### Para Verificar um Usuário Específico
```sql
SELECT 
  p.full_name,
  p.email,
  p.cnes,
  ur.role,
  ur.disabled,
  a.created_at,
  a.confirmed_at
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
LEFT JOIN auth.users a ON p.id = a.id
WHERE p.email = 'gabriela.dias@hc.fm.usp.br';
```

### Para Desativar um Usuário (sem deletar)
```sql
UPDATE user_roles
SET disabled = true
WHERE user_id IN (
  SELECT id FROM profiles 
  WHERE email = 'gabriela.dias@hc.fm.usp.br'
);
```

### Para Reativar um Usuário
```sql
UPDATE user_roles
SET disabled = false
WHERE user_id IN (
  SELECT id FROM profiles 
  WHERE email = 'gabriela.dias@hc.fm.usp.br'
);
```

---

## 🆘 Ainda com Problemas?

Se nada funcionar:
1. Verifique se a **Supabase Edgebase** tem **RLS habilitada** (pode estar bloqueando)
2. Confirme se o **email foi confirmado** no auth.users
3. Verifique se há **duplicate constraints** (dois usuários com mesmo email)

Compartilhe a saída do script de diagnóstico comigo para investigação mais profunda.
