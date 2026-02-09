# 📧 Setup SendGrid - Grátis Permanentemente

## ✨ Por que SendGrid (não Brevo)?

| Critério | Brevo | SendGrid |
|----------|-------|----------|
| **Grátis por quanto?** | 30 dias | SEMPRE (100 emails/dia) |
| **Precisa cartão?** | Sim (após trial) | Não |
| **Burocracia?** | Alta | Nenhuma |
| **Gmail funciona?** | ❌ Bloqueia | ✅ Funciona |
| **PDF funciona?** | Problemático | ✅ 100% |
| **Setup rápido?** | Médio | Muito rápido |

**SendGrid é a escolha certa para você!**

---

## 🚀 Passo 1: Criar Conta SendGrid (2 minutos)

1. Acesse: https://signup.sendgrid.com/
2. Preencha:
   - **Email**: seu@email.com
   - **Password**: qualquer senha segura
   - **First Name**: seu nome
   - **Last Name**: sobrenome
3. **NÃO precisa de cartão de crédito**
4. Clique em **Create Account**
5. Confirme seu email (procure na caixa de entrada)
6. Pronto!

---

## 🔑 Passo 2: Gerar API Key (2 minutos)

### Via Dashboard

1. Faça login em: https://app.sendgrid.com/
2. Vá para **Settings** → **API Keys** (ou direto em: https://app.sendgrid.com/settings/api_keys)
3. Clique em **Create API Key** (botão azul)
4. Preencha:
   - **API Key Name**: `Supabase` (ou qualquer nome)
   - **API Key Permissions**: Selecione **Full Access** (a mais fácil)
5. Clique em **Create & Save**
6. **COPIE a chave** (começará com `SG.`)
   - Algo como: `SG.abcdef1234567890abcdef1234567890...`
7. **GUARDE EM SEGURANÇA** (você não conseguirá ver novamente)

Pronto! Você tem sua API Key.

---

## 🔐 Passo 3: Configurar no Supabase

### Opção A: Via PowerShell (Recomendado)

```powershell
# Abra PowerShell como Administrador
# Navegue até seu projeto
cd "C:\Users\afpereira\Downloads\plano-de-trabalho-ses-sp-2026"

# Certifique-se de estar logado no Supabase
npx supabase@latest login
# Será aberta uma janela do navegador para você se autenticar

# Agora adicione a secret (substitua SG.xxxxx pela sua chave)
npx supabase@latest secrets set SENDGRID_API_KEY SG.abcdef1234567890abcdef1234567890...

# Aguarde a confirmação
# ✓ Secret SENDGRID_API_KEY set successfully
```

### Opção B: Via Dashboard Supabase

1. Acesse https://app.supabase.com (seu projeto)
2. Vá para **Settings** → **Secrets**
3. Clique em **New secret**
4. Preencha:
   - **Name**: `SENDGRID_API_KEY`
   - **Value**: `SG.abcdef1234567890...` (sua chave)
5. Clique em **Save**

**Pronto!** A chave está segura.

---

## 📤 Passo 4: Deploy da Edge Function

```powershell
# No terminal, execute:
cd "C:\Users\afpereira\Downloads\plano-de-trabalho-ses-sp-2026"

# Deploy
npx supabase@latest functions deploy send-email
```

Você verá:
```
✓ Function send-email deployed successfully
```

**Pronto!** A função está na nuvem.

---

## ✅ Passo 5: Testar o Sistema

1. Abra o navegador com seu formulário
2. Preencha com dados de teste:
   ```
   Parlamentar: Deputado João Silva
   Nº Emenda: 12340001
   Programa: CUSTEIO MAC – 2E90
   Valor: 100000,00
   Beneficiário: Hospital Estadual
   CNPJ: 12.345.678/0001-90
   Email: SEU_EMAIL@gmail.com (IMPORTANTE: seu email real)
   ```
3. Clique em **Finalizar e Salvar**
4. Aguarde 1-2 segundos
5. Abra **F12** (Developer Tools) → aba **Console**
6. Procure por:
   ```
   ✅ Email enviado com SUCESSO!
   ✅ Emails enviados para: seu-email@gmail.com
   ```
7. Verifique seu email em pouquíssimos segundos!

---

## 🎯 O que Você vai Receber

**Email que chega:**

```
From: noreply@sessp.gov.br
Subject: Plano de Trabalho 2026 - Emenda 12340001

---

✅ Plano de Trabalho Salvo com Sucesso!

Seu plano de trabalho foi registrado no sistema da Secretaria 
de Estado da Saúde de São Paulo.

┌─────────────────────────────────────┐
│ Parlamentar: Deputado João Silva    │
│ Nº Emenda: 12340001                 │
│ Programa: CUSTEIO MAC – 2E90        │
│ Valor: R$ 100.000,00                │
└─────────────────────────────────────┘

📎 Arquivo em Anexo: plano.pdf

Secretaria de Estado da Saúde de São Paulo
Emendas Parlamentares 2026
06/02/2026
```

---

## 🐛 Troubleshooting

### ❌ Console mostra: "SENDGRID_API_KEY não configurada"

**Solução:** Você esqueceu de executar o comando `secrets set`

```powershell
# Execute no PowerShell:
npx supabase@latest secrets set SENDGRID_API_KEY SG.sua-chave-aqui
```

---

### ❌ Console mostra: "SendGrid error (401)"

**Solução:** Sua API Key está errada ou expirada

1. Acesse https://app.sendgrid.com/settings/api_keys
2. Verifique se a chave não expirou
3. Se expirou, gere uma nova
4. Execute novamente o comando `secrets set` com a chave nova

---

### ❌ Email nunca chega

**Passo 1: Verifique logs do SendGrid**
1. Acesse: https://app.sendgrid.com/email_activity
2. Procure por seu email nos últimos 5 minutos
3. Veja o status:
   - **Delivered** ✅ Chegou (procure em Spam)
   - **Dropped** ❌ Rejeitado (erro de email)
   - **Bounced** ❌ Email não existe

**Passo 2: Verifique pasta de SPAM**
- Procure por `noreply@sessp.gov.br`
- Marque como "Não é spam"
- Espere o próximo email

**Passo 3: Tente com email diferente**
- Tente com Outlook, Yahoo, etc
- Alguns provedores bloqueiam mais

---

### ⚠️ Erro: "Email com formatação inválida"

**Solução:** Verifique:
- Sem espaços: `usuario@email.com` ❌ `usuario@email.com ` (espaço)
- Formato válido: `usuario@dominio.com` ✅

---

## 📊 Monitorar Seus Envios

**Dashboard SendGrid:**
1. Acesse: https://app.sendgrid.com/email_activity
2. Veja em tempo real:
   - Cada email enviado
   - Se foi entregue
   - Se foi aberto
   - Se teve cliques

---

## 💰 Planos SendGrid

| Limite | Preço |
|--------|-------|
| 100 emails/dia (3k/mês) | **$0** (Grátis) |
| 5.000 emails/mês | ~$9.95 |
| 50.000 emails/mês | ~$79.95 |
| 100.000+ | Negociar preço |

Você começa grátis e só paga quando exceder 100 emails/dia!

---

## 🎓 Avançado: Usar Seu Próprio Domínio

Se quiser que emails saiam de `noreply@sessp.gov.br` (não de sandbox):

**Requer Plano Pago:** ~$25/mês

1. Plano pago SendGrid
2. Adicionar domínio em **Sender Authentication**
3. Seguir instruções de DNS
4. Verificar domínio

**Por enquanto, use o sandbox** - funciona perfeitamente!

---

## ✅ Checklist Final

- [ ] Conta SendGrid criada
- [ ] API Key gerada (começa com `SG.`)
- [ ] Secret configurado no Supabase
- [ ] Edge Function deployed
- [ ] Email de teste recebido
- [ ] Tudo funcionando! 🎉

---

## 📞 Suporte

- **SendGrid Help**: https://support.sendgrid.com
- **Comunidade**: https://www.sendgrid.com/solutions/community
- **Documentação**: https://docs.sendgrid.com

**Parabéns! Seu sistema de emails está 100% funcional e grátis!** 🚀
