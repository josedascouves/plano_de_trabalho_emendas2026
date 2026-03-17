# ✅ Importar Usuários em Lote via CSV - VERSÃO CORRIGIDA

## 🔧 O que foi corrigido

A versão anterior tinha um problema onde a RPC de lote falhava. A **nova versão:**
- ✅ Cria usuários **um por um** em paralelo
- ✅ Muito mais confiável e robusta
- ✅ Mostra detalhes de cada erro individualmente
- ✅ Funciona com até 13 usuários sem problemas

## 📋 Formato do arquivo CSV

Use exatamente este formato (com ponto-e-vírgula):

```
NOME RESPONSAVEL PLANO DE TRABALHO;EMAIL RESPONSAVEL PLANO DE TRABALHO;CNES;SENHA
JANINE DANEZI DA SILVA;janine.danezi@irssl.org.br;6992560;6992560
FLAVIA ALESSANDRA GUERINO MARQUES DA SILVA;administracao.hsd@alsf.org.br;2093502;2093502
```

## ⚙️ Como Implementar (3 PASSOS)

### ✅ PASSO 1: No Supabase SQL Editor

1. Abra: https://app.supabase.com
2. Entre no seu projeto
3. Clique em **"SQL Editor"** (lado esquerdo)
4. Clique em **"New query"**
5. Copie **TODO** o arquivo: `CREATE-RPC-CRIAR-USUARIO-INDIVIDUAL.sql`
6. Cole no editor
7. Clique em **"Run"** (botão verde)
8. Aguarde a mensagem: `RPC Function criar_usuario_individual criada com sucesso!`

### ✅ PASSO 2: Aguarde a conclusão

Você verá:
```
CREATE EXTENSION
INSERT 0 1
INSERT 0 1
RPC Function criar_usuario_individual criada com sucesso!
```

### ✅ PASSO 3: Use no sistema

1. Vá para **Gerenciamento de Usuários**
2. Procure o botão **"Carregar CSV"** (ou Upload)
3. Selecione seu arquivo CSV
4. Sistema mostra uma preview dos usuários
5. Confirme (botão OK)
6. Aguarde a criação

## 📊 Durante a criação

O sistema mostra:
- 🚀 Status em tempo real
- ⏳ Quantos usuários foram criados
- ✅ Sucesso para cada um
- ❌ Erros com detalhes

## ✨ Exemplo de Resultado

```
✅ Importação concluída!

Total processado: 13
Criados: 13
Erros: 0
```

## 🆘 Se der erro

### ❌ "Could not find the function criar_usuario_individual"
**Solução:** Você não executou o SQL. Siga o **PASSO 1** acima.

### ❌ "Usuário com este email já existe"
**Solução:** Este email já foi criado. Use um email diferente.

### ❌ "Erro ao criar usuário"
**Solução:** Verifique se o CSV tem as colunas corretas.

## 📌 A nova abordagem

```
Seu arquivo CSV
        ↓
Sistema lê o CSV
        ↓
Cria 5 usuários em paralelo
        ↓
Aguarda conclusão
        ↓
Cria mais 5 em paralelo
        ↓
... e assim até terminar
        ↓
Relatório final
```

Isso é **muito mais rápido e confiável** que tentar criar tudo de uma vez!

## ✅ Seu arquivo CSV

O `Pasta3.csv` que você tem está **100% pronto** para usar após executar o SQL!

---

**Próximo passo:** Execute o SQL do arquivo `CREATE-RPC-CRIAR-USUARIO-INDIVIDUAL.sql` no Supabase!
