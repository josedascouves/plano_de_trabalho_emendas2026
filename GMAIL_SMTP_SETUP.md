# 📧 Setup Email com Gmail - SEM CADASTRO

## ✨ Por que Gmail?

| Aspecto | Gmail |
|--------|-------|
| **Cadastro?** | ❌ NÃO precisa (você já tem!) |
| **Grátis?** | ✅ SIM, para sempre |
| **Limite?** | ✅ Sem limite (uso normal) |
| **Config** | ✅ Super simples (2 passos) |
| **PDF Funciona?** | ✅ 100% |

**A solução mais simples possível!**

---

## 🚀 Passo 1: Gerar Senha de Aplicativo (3 minutos)

### Se você TEM 2FA ativado (recomendado):

1. Abra: https://myaccount.google.com/security
2. Clique em **App passwords** (procure à esquerda ou use busca)
3. Selecione:
   - **Select the app:** `Mail`
   - **Select the device:** `Windows Computer`
4. Clique em **Generate**
5. Google gera uma senha com 16 letras:
   ```
   abcd efgh ijkl mnop
   ```
6. **COPIE** (sem espaços):
   ```
   abcdefghijklmnop
   ```

### Se você NÃO tem 2FA:

Você pode pular e usar sua **senha normal do Gmail**.

---

## 🔐 Passo 2: Configurar no Supabase (2 minutos)

### Via PowerShell:

```powershell
# Abra PowerShell como Administrador
# Navegue até o projeto
cd "C:\Users\afpereira\Downloads\plano-de-trabalho-ses-sp-2026"

# Faça login no Supabase
npx supabase@latest login
# Vai abrir navegador para autenticar

# Agora configure seu Gmail
# Substitua:
#   SEU_EMAIL@gmail.com → seu email real
#   SUA_SENHA ou SUA_SENHA_APP → senha (16 letras) ou senha normal
npx supabase@latest secrets set GMAIL_USERNAME SEU_EMAIL@gmail.com
npx supabase@latest secrets set GMAIL_APP_PASSWORD SUA_SENHA_OU_SUA_SENHA_APP

# Aguarde a confirmação:
# ✓ Secret GMAIL_USERNAME set successfully
# ✓ Secret GMAIL_APP_PASSWORD set successfully
```

### Exemplos:

Se seu email é `joao.silva@gmail.com` e sua senha de app é `abcd efgh ijkl mnop`:

```powershell
npx supabase@latest secrets set GMAIL_USERNAME joao.silva@gmail.com
npx supabase@latest secrets set GMAIL_APP_PASSWORD abcdefghijklmnop
```

---

## 📤 Passo 3: Deploy (1 minuto)

```powershell
# No PowerShell:
npx supabase@latest functions deploy send-email

# Você verá:
# ✓ Function send-email deployed successfully
```

---

## ✅ Passo 4: Testar (2 minutos)

1. Abra seu navegador com o formulário
2. Preencha:
   ```
   Parlamentar: Deputado João Silva
   Nº Emenda: 12340001
   Programa: CUSTEIO MAC – 2E90
   Valor: 100000,00
   Beneficiário: Hospital Estadual
   CNPJ: 12.345.678/0001-90
   Email: SEU_EMAIL@gmail.com (seu email real!)
   ```
3. Clique em **Finalizar e Salvar**
4. Abra **F12** → aba **Console**
5. Procure por:
   ```
   ✅ Conectado ao Gmail SMTP com sucesso
   ✅ Email enviado com SUCESSO!
   ✅ Emails enviados para: seu-email@gmail.com
   ```
6. Verifique seu email em segundos!

---

## 🎯 O que Vai Chegar

```
From: seu_email@gmail.com
Subject: Plano de Trabalho 2026 - Emenda 12340001

---

✅ Plano de Trabalho Salvo com Sucesso!

Seu plano de trabalho foi registrado no sistema...

[Detalhes em tabela]

📎 Arquivo em Anexo: plano.pdf
```

---

## 🐛 Troubleshooting

### ❌ Erro: "GMAIL_USERNAME não configurada"

Você esqueceu de rodar `secrets set`.

```powershell
npx supabase@latest secrets set GMAIL_USERNAME seu_email@gmail.com
```

---

### ❌ Erro: "Connection refused" ou "auth failed"

Suas credenciais estão erradas.

**Solução:**
1. Verifique se copiou a senha corretamente (sem espaços)
2. Se usou app password, certifique-se que tem 16 caracteres
3. Rodar novamente:
   ```powershell
   npx supabase@latest secrets set GMAIL_APP_PASSWORD CORRIGE_AQUI
   ```

---

### ❌ Erro: "Gmail says you need to use an App password"

Significa você tem 2FA ativado e precisa usar **App Password** (não a senha normal).

**Solução:**
1. Acesse: https://myaccount.google.com/apppasswords
2. Gere uma nova App Password
3. Configure com `secrets set`

---

### ❌ Email não chega na caixa de entrada

**Passo 1: Procure em SPAM**
- Gmail às vezes marca emails como spam
- Procure por `seu_email@gmail.com`
- Se encontrou, marque como "Não é spam"

**Passo 2: Verifique o Gmail que enviou**
- Se você está recebendo em `joao@hotmail.com` mas enviou de `joao@gmail.com`, pode ter ido para spam
- Tente enviar para o mesmo email do remetente
- Depois testa com outros

**Passo 3: Ative "Acesso de apps menos seguros"**
Se tiverem problemas, acesse:
https://myaccount.google.com/u/0/lesssecureapps

(Mas isso só existe se não tiver 2FA; com 2FA + App Password funciona direto)

---

## 📊 Monitorar Envios

### No Gmail:

1. Acesse: https://mail.google.com
2. Procure por emails que você enviou com a função
3. Veja a hora exata que foi enviado

### No Console:

Ao testar, você verá logs detalhados:
```
📨 Função send-email chamada
✅ Body recebido
🔍 Validando dados...
✅ Dados validados com sucesso
📧 Conectando ao Gmail SMTP...
🔐 Autenticando no Gmail...
✅ Conectado ao Gmail SMTP com sucesso
📤 Enviando para 1 destinatário(s)...
  ├─ Enviando para: seu_email@gmail.com
  ✅ Enviado para: seu_email@gmail.com
✅ Email enviado com SUCESSO!
```

---

## ✅ Checklist Final

- [ ] Gerei App Password no Google (ou anotei minha senha)
- [ ] Configurei GMAIL_USERNAME com `secrets set`
- [ ] Configurei GMAIL_APP_PASSWORD com `secrets set`
- [ ] Fiz deploy da função
- [ ] Testei e recebi email
- [ ] Tudo funcionando! 🎉

---

## 🎓 Avançado: Usar Outro Provedor SMTP

Se preferir usar Outlook, Yahoo, etc, a estrutura é a mesma, só muda:

```
Outlook: smtp.office365.com (porta 587)
Yahoo: smtp.mail.yahoo.com (porta 465)
Seu servidor corporativo: seu.dominio.com (porta 25, 465 ou 587)
```

Mas **Gmail é o mais simples!**

---

## 📞 Suporte

- **Gmail Help**: https://support.google.com/accounts
- **Documentação deno-smtp**: https://deno.land/x/smtp

**Pronto! Seu sistema de emails está funcionando SEM cadastro!** 🚀
