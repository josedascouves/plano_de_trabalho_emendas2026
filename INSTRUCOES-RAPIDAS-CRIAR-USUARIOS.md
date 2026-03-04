️# ⚡ RESOLUÇÃO RÁPIDA: CRIAR 6 NOVOS USUÁRIOS NO SISTEMA

## 🎯 Objetivo
Registre os 6 novos usuários intermediários direto do sistema sem erros de autenticação.

## 👥 Usuários a Registrar
1. **MÁRCIA VITORINO DE VASCONCELOS** - mvvasconcelos@saude.sp.gov.br - CNES: 0052124
2. **JANETE LOURENÇO SGUEGLIA** - janete.sgueglia@saude.sp.gov.br - CNES: 0052124
3. **Lúcia Henrique Ribeiro** - lhribeiro@saude.sp.gov.br - CNES: 0052124
4. **Geisel Guimarães Torres Costa** - gtcosta@saude.sp.gov.br - CNES: 0052124
5. **Cristiane Aparecida Barreto de Souza** - casouza@saude.sp.gov.br - CNES: 0052124
6. **ROBERTO CLÁUDIO LOSCHER** - rcloscher@saude.sp.gov.br - CNES: 0052124

---

## 📋 PASSO 1: Preparar o Banco de Dados (OBRIGATÓRIO)

1. Acesse **https://app.supabase.com**
2. Selecione seu projeto
3. Clique em **"SQL Editor"** (lado esquerdo)
4. Clique em **"+ New Query"**
5. Abra o arquivo **`CRIAR-RPC-SINCRONIZAR.sql`** (na pasta do projeto)
6. **Copie TODO o conteúdo** e cole no SQL Editor
7. Clique em **"Run"** (ou Ctrl+Enter)
8. Aguarde: "Query executed successfully" (em verde)

**✅ O banco agora tem uma função RPC que sincroniza automaticamente usuários!**

---

## 📋 PASSO 2: Criar os 6 Usuários em auth.users (OBRIGATÓRIO)

1. Clique em **"+ New Query"** novamente
2. Abra o arquivo **`CRIAR-6-USUARIOS-COMPLETO.sql`** (na pasta do projeto)
3. **Copie TODO o conteúdo** e cole no SQL Editor
4. Clique em **"Run"** (ou Ctrl+Enter)
5. Aguarde: "Query executed successfully" e veja o resultado final com os 6 usuários

**✅ Os 6 usuários foram criados em auth.users, profiles e user_roles!**

---

## 📋 PASSO 3: Testar no Sistema (OPCIONAL - Pode não precisar)

Se você quiser testar criando um usuário via UI do sistema:

1. Abra seu aplicativo
2. Vá para "Gerenciamento de Usuários" ou "Criar Novo Usuário"
3. Preencha:
   - **Nome**: Um dos nomes acima
   - **E-mail**: Um dos e-mails acima (de preferência um que já foi criado no SQL)
   - **CNES**: 0052124
   - **Perfil**: Intermediário
   - **Senha**: Qualquer senha

4. Clique em **"Criar Usuário"**

**O que vai acontecer:**
- ✅ Se o e-mail **já existe** em auth.users (porque criamos no SQL): O sistema vai sincronizar AUTOMATICAMENTE usando a função RPC que criamos.
- ✅ Se o e-mail **NÃO existe**: O sistema cria novo normalmente.
- ✅ **Sem erros!**

---

## 🔍 VERIFICAÇÃO FINAL

Para garantir que tudo funcionou, no SQL Editor faça:

```sql
SELECT 
  p.id,
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled,
  (a.email_confirmed_at IS NOT NULL) as email_confirmado
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
LEFT JOIN auth.users a ON p.id = a.id
WHERE p.email IN (
  'mvvasconcelos@saude.sp.gov.br',
  'janete.sgueglia@saude.sp.gov.br',
  'lhribeiro@saude.sp.gov.br',
  'gtcosta@saude.sp.gov.br',
  'casouza@saude.sp.gov.br',
  'rcloscher@saude.sp.gov.br'
)
ORDER BY p.email;
```

Você deve ver **6 linhas** com:
- ✅ Email correto
- ✅ Full name preenchido
- ✅ CNES = 0052124
- ✅ Role = intermediate
- ✅ Disabled = false (ou NULL)

---

## 🚀 COMO OS USUÁRIOS FAZEM LOGIN?

Cada usuário pode fazer login com:
- **E-mail**: Um dos e-mails acima
- **Senha**: `SenhaTemporaria123!` (a senha que definimos no SQL)

**IMPORTANTE**: Você pode ressetar a senha desses usuários para qualquer outra pelo Supabase ou pela UI do sistema.

---

## ❓ PERGUNTAS COMUNS

### P: O erro "Este e-mail já foi registrado" ainda aparece?
**R**: Não! Agora temos a função RPC que sincroniza automaticamente. O sistema vai:
1. Tentar criar normalmente
2. Se disser "already registered", chama a RPC automaticamente
3. RPC insere os dados faltantes em profiles e user_roles
4. Usuário fica completo e pronto para usar

### P: Como ressetar a senha de um usuário?
**R**: No Supabase, vá em "Authentication" > "Users" > clique no usuário > "Reset password"

### P: Posso usar senhas diferentes para cada usuário?
**R**: Sim! Edite o arquivo `CRIAR-6-USUARIOS-COMPLETO.sql` e troque `SenhaTemporaria123!` por outras senhas antes de executar.

### P: E se eu quiser criar mais usuários no futuro?
**R**: Você pode:
- ✅ Criá-los direto no formulário do sistema (vai usar a RPC automaticamente)
- ✅ Ou criar um novo script SQL baseado em `CRIAR-6-USUARIOS-COMPLETO.sql`

---

## 📞 SUPORTE

Se algo não funcionar:

1. **Erro no SQL**: Verifique se copiou TODO o arquivo (não deixou nada de fora)
2. **Usuário não aparece**: Execute a query de verificação acima
3. **RPC não funciona**: Certifique-se de executar `CRIAR-RPC-SINCRONIZAR.sql` primeiro

---

**✅ Pronto! Seus usuários estão prontos para usar o sistema!**
