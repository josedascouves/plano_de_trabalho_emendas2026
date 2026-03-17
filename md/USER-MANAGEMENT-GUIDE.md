# Guia de Correção - Sistema de Login e Gestão de Usuários

## 🔧 Problemas Corrigidos

### 1. **Usuários Criados Não Conseguiam Fazer Login**
**Causa:** O sistema criava usuários no Supabase Auth mas não inseriam o perfil na tabela `profiles`, causando falha no login.

**Solução:** Agora quando um novo usuário é criado:
- ✅ É criado na Supabase Auth
- ✅ Um perfil é inserido automaticamente na tabela `profiles`
- ✅ O usuário pode fazer login normalmente

### 2. **Gestão de Usuários Implementada**
O administrador agora pode:

#### a) **Desativar/Ativar Usuários**
- Clique em "✕ Desativ" para desativar um usuário
- Usuários desativados são marcados com status visual
- Usuários desativados NÃO conseguem fazer login mesmo com senha correta

#### b) **Alterar Senha de Qualquer Usuário**
- Clique em "Senha" para definir uma nova senha
- Um prompt pedirá a senha (mínimo 6 caracteres)
- Clique OK para salvar

#### c) **Excluir Usuários**
- Clique em "Deletar" para remover um usuário permanentemente
- O usuário é removido do Auth e do banco de dados
- Esta ação NÃO pode ser desfeita

## 📋 Passos Para Usar

### Para Criar um Novo Usuário:

1. Faça login como **Administrador**
2. Clique no ícone **⚙️ Gerenciar Usuários** no canto superior direito
3. Preencha os campos:
   - **Nome Completo**: Nome do usuário
   - **E-mail**: Email único (será usado para login)
   - **Senha Inicial**: Senha temporária (mínimo 6 caracteres)
   - **Tipo**: Usuário Padrão ou Administrador SES
4. Clique em **"Registrar no Supabase"**
5. Confirme a mensagem de sucesso
6. **Compartilhe as credenciais com o usuário**

### Para o Novo Usuário Fazer o Primeiro Login:

1. Acesse a aplicação
2. Digite:
   - **E-mail**: O email informado no cadastro
   - **Senha**: A senha inicial recebida
3. Clique em **"Entrar"**
4. ✅ Login bem-sucedido!

### Para Gerenciar Usuários (Admin):

1. Clique em **"Gerenciar Usuários"** (ícone ⚙️)
2. Na seção "Perfis em Banco de Dados" você verá todos os usuários
3. Para cada usuário há 3 botões:
   - **✓ Ativar / ✕ Desativ**: Ativa ou desativa o usuário
   - **Senha**: Altera a senha do usuário
   - **Deletar**: Remove o usuário permanentemente

## 🗄️ Configuração do Banco de Dados

Execute o script SQL fornecido no Supabase:

1. Abra o **Supabase Dashboard**
2. Vá para **SQL Editor**
3. Clique em **"New Query"**
4. Cole o conteúdo do arquivo `fix-user-management.sql`
5. Clique em **"Run"**
6. Verifique se não houve erros

Este script:
- ✅ Adiciona coluna `disabled` à tabela profiles
- ✅ Adiciona coluna `email` à tabela profiles
- ✅ Sincroniza emails do Auth para o banco de dados
- ✅ Habilita RLS (Row Level Security)
- ✅ Cria políticas de segurança

## ⚠️ Importante

- **Senhas mínimas:** 6 caracteres
- **Emails únicos:** Cada usuário deve ter um email diferente
- **Administradores:** Podem gerenciar todos os usuários
- **Usuários desativados:** Veem erro "Este usuário foi desativado" ao tentar login

## 🆘 Se Algo Não Funcionou

- Verifique se o script SQL foi executado com sucesso
- Verifique se a coluna `disabled` foi adicionada: SELECT * FROM profiles LIMIT 1;
- Tente recarregar a página (F5) após executar o script
- Verifique se seus usuários Admin tem `role = 'admin'` no banco de dados
