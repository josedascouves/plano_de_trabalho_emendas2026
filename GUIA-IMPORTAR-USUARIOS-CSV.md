# 📋 Importar Usuários em Lote via CSV

## ✅ O que foi feito

Criei uma RPC function no Supabase que permite criar múltiplos usuários de uma vez através de um arquivo CSV.

## 📥 Formato do arquivo CSV

O arquivo deve conter as seguintes colunas (nesta ordem):

```
NOME RESPONSAVEL PLANO DE TRABALHO;EMAIL RESPONSAVEL PLANO DE TRABALHO;CNES;SENHA
JANINE DANEZI DA SILVA;janine.danezi@irssl.org.br;6992560;6992560
FLAVIA ALESSANDRA GUERINO MARQUES DA SILVA;administracao.hsd@alsf.org.br;2093502;2093502
```

**Colunas aceitas:**
- **NOME**: Aceita variações como "nome", "name", "fullname", "nomeCompleto", "responsavel"
- **EMAIL**: Aceita variações como "email", "mail", "emailResponsavel"
- **CNES**: Aceita variações como "cnes", "codigoCNES"
- **SENHA**: Aceita variações como "senha", "password", "pass" (opcional - usa CNES como padrão)

**Separadores aceitos:**
- ✅ Ponto-e-vírgula (;) - Recomendado
- ✅ Vírgula (,)

## ⚙️ Passos para ativar

### PASSO 1: Abra o Supabase
1. Acesse [Supabase Dashboard](https://app.supabase.com)
2. Entre no seu projeto
3. Vá para **SQL Editor** (lado esquerdo da tela)
4. Clique em **"New query"**

### PASSO 2: Execute o SQL
1. Abra o arquivo: `CREATE-RPC-CRIAR-USUARIOS-EM-LOTE.sql`
2. Copie **TODO** o conteúdo
3. Cole no **SQL Editor** do Supabase
4. Clique em **"Run"** (botão verde no canto inferior direito)
5. Aguarde a mensagem: `RPC Function criar_usuarios_em_lote criada com sucesso!`

### PASSO 3: Teste no Sistema
1. Vá para **Gerenciamento de Usuários**
2. Procure por um botão **"Carregar CSV"** ou **"Importar Usuários"**
3. Selecione seu arquivo CSV
4. Sistema mostrará uma prévia dos usuários a criar
5. Confirme para criar

## ✨ Recursos da Importação

✅ **Validação automática** - Verifica se os dados estão corretos
✅ **Detecção de separador** - Funciona com ; ou ,
✅ **Mapeamento flexível** - Reconhece variações nos nomes das colunas
✅ **Relatório detalhado** - Mostra quantos foram criados e se houve erros
✅ **Tratamento de erros** - Continua criando mesmo se um usuário falhar

## 📊 Relatório de Importação

Após a importação, você recebe:
- **Total**: Quantidade de linhas processadas
- **Criados**: Quantos usuários foram criados com sucesso
- **Erros**: Quantos falharam e por quê

## 🆘 Solução de Problemas

### ❌ "Erro ao importar: Could not find the function"
**Solução:** Você não executou o SQL no Supabase ainda. Siga os **PASSOS** acima.

### ❌ "Coluna 'email' não encontrada"
**Solução:** Verifique se o cabeçalho do seu CSV contém uma coluna com "email" (pode ser "EMAIL RESPONSAVEL PLANO DE TRABALHO", que será reconhecido).

### ❌ "Usuário já existe"
**Solução:** Se o email já está registrado, o sistema tentará atualizar. Se der erro, será listado no relatório.

### ✅ Tudo funcionando?
Após criar os usuários, eles aparecerão na lista de **Gerenciamento de Usuários** e poderão fazer login com o email e senha definidos.

## 📌 Seu arquivo CSV está pronto!

Use o arquivo **Pasta3.csv** que você compartilhou:
- ✅ Tem o formato correto
- ✅ Contém 13 usuários
- ✅ Pronto para importar após executar o SQL

---

**Próximo passo:** Execute o SQL do arquivo `CREATE-RPC-CRIAR-USUARIOS-EM-LOTE.sql` no Supabase, depois use o botão de importação CSV no sistema!
