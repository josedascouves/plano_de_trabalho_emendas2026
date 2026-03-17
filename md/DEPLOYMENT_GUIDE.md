# 🚀 Guia de Deploy - Plano de Trabalho SES-SP 2026

## Status Atual ✅
- ✅ Frontend (React 19) - Completo
- ✅ Banco de Dados (Supabase) - Completo
- ✅ Email Modal - Completo
- ✅ PDF Generation - Completo
- ⏳ **Edge Function - Criada, aguardando DEPLOY**
- ⏳ **Resend API Key - Aguardando configuração no Supabase**

---

## 📋 Próximos Passos

### 1️⃣ Deploy da Edge Function no Supabase

#### Opção A: Via Supabase CLI (Recomendado)

```bash
# 1. Instalar Supabase CLI se ainda não tiver
npm install -g supabase

# 2. Login no Supabase
supabase login

# 3. Entrar no diretório do projeto
cd c:\Users\afpereira\Downloads\plano-de-trabalho-ses-sp-2026

# 4. Deploy da função
supabase functions deploy send-email
```

#### Opção B: Via Dashboard Supabase (Manual)

1. Acesse: https://app.supabase.com
2. Selecione seu projeto `tlpmspfnswaxwqzmwski`
3. Vá em **Functions** → **Create a new function** → **send-email**
4. Copie o conteúdo de `supabase/functions/send-email/index.ts`
5. Cole no editor
6. Clique **Deploy**

---

### 2️⃣ Configurar API Key do Resend como Secret

1. Acesse: https://app.supabase.com/project/tlpmspfnswaxwqzmwski/settings/secrets
2. Clique **New Secret**
3. Preencha:
   - **Name**: `RESEND_API_KEY`
   - **Value**: `re_AM61AKGL_K4npjaZUczPba8sDhPjeVjMW`
4. Clique **Add secret**

---

### 3️⃣ Verificar URL da Edge Function

No painel do Supabase, vá em **Functions** e procure por `send-email`. Copie a URL completa.

**Formato esperado**:
```
https://tlpmspfnswaxwqzmwski.supabase.co/functions/v1/send-email
```

✅ **Já está configurada no App.tsx!**

---

## 🧪 Testando o Fluxo Completo

1. **Login** na aplicação
2. **Preencharr o formulário** (7 etapas)
3. **Clicar "Salvar Plan"** 
   - ✅ Dados salvos no banco
   - ✅ Modal aparece pedindo emails
4. **Digitar emails** (separados por vírgula):
   ```
   seu-email@gmail.com, outro-email@empresa.com
   ```
5. **Clicar "Enviar"**
   - 📡 Requisição vai para Edge Function
   - 📤 Edge Function chama API do Resend
   - 📧 PDF é enviado por email
   - ✅ Mensagem de sucesso aparece

---

## 🔍 Troubleshooting

### Erro: "403 Forbidden" ou "Unauthorized"
**Causa**: API Key do Resend incorreta ou não configurada  
**Solução**: Verificar se `RESEND_API_KEY` está em **Settings → Secrets** do Supabase

### Erro: "Edge Function not found"
**Causa**: Função não foi deployada  
**Solução**: Executar `supabase functions deploy send-email`

### Erro: "CORS error"
**Causa**: Origem não autorizada  
**Solução**: Edge Function já tem CORS headers configurados ✅

### Erro: "Invalid email format"
**Causa**: Email inválido na lista  
**Solução**: Validar formato de emails antes de enviar

---

## 📊 Fluxo de Dados

```
Frontend (React)
    ↓ (email + PDF base64)
Edge Function (Supabase)
    ↓ (recebe + valida)
Resend API
    ↓ (envia com token)
Servidor de Email
    ↓ (processa)
Gmail / Outlook / etc
```

---

## 🎯 Checklist Final

- [ ] Edge Function deployada via CLI ou Dashboard
- [ ] `RESEND_API_KEY` configurada em Secrets do Supabase
- [ ] Frontend rodando em localhost:3004
- [ ] Banco de dados acessível
- [ ] Teste: Preencher formulário → Salvar → Enviar email
- [ ] Email recebido com PDF em anexo

---

## 📞 Informações Úteis

**URL Supabase Project**: https://app.supabase.com/project/tlpmspfnswaxwqzmwski  
**URL Resend Dashboard**: https://app.resend.com  
**URL Aplicação Local**: http://localhost:3004

---

**Status**: 🟡 Aguardando deploy da Edge Function e teste de envio
