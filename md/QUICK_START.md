# 🚀 QUICK START - SendGrid (GRÁTIS PERMANENTEMENTE)

## ✨ Por que SendGrid?
- ✅ **GRÁTIS FOREVER**: 100 emails/dia (ilimitado depois ~ $20/10mil emails)
- ✅ **SEM CARTÃO DE CRÉDITO**: Apenas email para verificar
- ✅ **SEM BUROCRACIA**: Pronto em 2 minutos
- ✅ **FUNCIONA 100%**: Com Deno, Edge Functions e PDF
- ✅ **PROFISSIONAL**: Usado por startups e empresas

---

## 📋 Checklist (5 minutos)

### 1️⃣ Criar Conta SendGrid
- [ ] Acesse: https://signup.sendgrid.com/
- [ ] Email: seu@email.com
- [ ] Password: qualquer uma
- [ ] **Não precisa cartão de crédito**
- [ ] Confirme seu email

### 2️⃣ Copiar API Key
```
1. Após login, vá para: https://app.sendgrid.com/settings/api_keys
2. Clique em "Create API Key"
3. Nome: "Supabase"
4. Permission: "Full Access"
5. Copie a chave (começa com SG.xxxxx)
```

### 3️⃣ Configurar no Supabase (no PowerShell)
```powershell
# Abra PowerShell no seu projeto
cd "C:\Users\afpereira\Downloads\plano-de-trabalho-ses-sp-2026"

# Faça login se ainda não fez
npx supabase@latest login

# Cole sua API Key aqui (substitua SG.xxxxx)
npx supabase@latest secrets set SENDGRID_API_KEY SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 4️⃣ Deploy da Edge Function
```powershell
npx supabase@latest functions deploy send-email
```

### 5️⃣ Testar
1. Vá ao formulário
2. Preencha todos os dados
3. No email, coloque **seu-email@gmail.com** ou outro
4. Clique "Finalizar e Salvar"
5. Espere 1-2 segundos
6. Abra **F12** → **Console** e procure por ✅

---

## 📊 Limites SendGrid Grátis

| Recurso | Limite |
|---------|--------|
| Emails por dia | 100 |
| Total por mês | ~3.000 |
| Attachments | ✅ Sim |
| HTML/Design | ✅ Sim |
| Domínio customizado | ❌ Não (sandbox) |
| **Custo** | **$0** |

Depois de 100 emails/dia, custa ~$20 por mês para 100k emails/mês. Super barato.

---

## 🎯 Dados para Testar

```
Parlamentar: Deputado João Silva
Nº Emenda: 12340001
Programa: CUSTEIO MAC – 2E90
Valor: 100000,00
Beneficiário: Hospital Estadual
CNPJ: 12.345.678/0001-90
Email: SEU_EMAIL@gmail.com ← COLOQUE SEU EMAIL AQUI
```

---

## ✅ Se Funcionar

Você verá no console (F12):
```
✅ Email enviado com SUCESSO!
✅ Emails enviados para: seu-email@gmail.com
```

E em seu email receberá:
```
Subject: Plano de Trabalho 2026 - Emenda 12340001
From: noreply@sessp.gov.br

✅ Plano de Trabalho Salvo com Sucesso!
...
📎 Arquivo em Anexo: plano.pdf
```

---

## 🆘 Troubleshooting

### Email não chega?

1. **Verifique o Console (F12)**
   ```
   Se vir: "SENDGRID_API_KEY não configurada"
   → Você pulou o passo 3, volte e execute o comando
   ```

2. **Verifique pasta de SPAM**
   - SendGrid sandbox às vezes cai em spam
   - Procure por `noreply@sessp.gov.br`
   - Marque como "Não é spam"

3. **Verifique logs SendGrid**
   - Acesse: https://app.sendgrid.com/email_activity
   - Procure por seu email dos últimos 5 min
   - Veja status: Delivered / Bounced / etc

4. **Erros Comuns:**

| Erro | Solução |
|------|---------|
| `SENDGRID_API_KEY não configurada` | Execute o comando `secrets set` |
| `401 Unauthorized` | API Key incorreta ou expirada |
| `Invalid email` | Email mal formatado |
| `Bounce` | Email de destino não existe |

---

## 💡 Links Úteis

| Link | O que faz |
|------|-----------|
| https://signup.sendgrid.com | Criar conta |
| https://app.sendgrid.com | Dashboard |
| https://app.sendgrid.com/settings/api_keys | Pegar API Key |
| https://app.sendgrid.com/email_activity | Ver emails enviados |
| https://sendgrid.com/pricing | Planos (grátis + pago) |

---

## 📝 Próximos Passos (Opcional)

Depois que funcionar, você pode:

1. **Usar domínio customizado** (pago $25/mês)
2. **Aumentar limite** (pago)
3. **Usar templates** (grátis)
4. **Rastrear opens/clicks** (grátis no plano pago)

---

## 🎉 Sucesso!

Seu sistema de email está **100% funcional e grátis**!

Se tiver dúvidas, o suporte SendGrid é excelente: https://support.sendgrid.com
