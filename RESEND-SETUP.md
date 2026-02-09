## 📧 Como Implementar Envio Real de Emails com Resend

### ✅ Estado Atual
O sistema está **pronto para salvar dados** e **enviar emails por Resend**, mas o envio está **comentado** (sendo simulado).

---

## 🚀 Passo a Passo para Ativar:

### 1️⃣ **Criar Conta no Resend**
1. Acesse: https://resend.com
2. Crie uma conta gratuita
3. Vá em: **Settings** → **API Keys**
4. Copie a chave que começa com `re_`

### 2️⃣ **Encontrar o Código no App.tsx**
Na função `handleSendEmail` (por volta da linha 360), procure por:
```typescript
// TODO: Implementar com Resend
// Para usar Resend:
```

### 3️⃣ **Descomentar o Código**
Remova os `/*` e `*/` que envolvem o código da requisição:

**ANTES:**
```typescript
/*
const RESEND_API_KEY = 're_xxxxx';
const response = await fetch(...)
*/
```

**DEPOIS:**
```typescript
const RESEND_API_KEY = 're_xxxxx';
const response = await fetch(...)
```

### 4️⃣ **Adicionar sua API Key**
Troque `'re_xxxxx'` pela sua chave real do Resend.

**⚠️ IMPORTANTE: Proteja sua chave!**
- Nunca faça commit da chave no GitHub
- Use variáveis de ambiente (vite.config.ts) para produção

### 5️⃣ **Configurar Domínio (Opcional)**
- No Resend, configure um domínio próprio ou use `noreply@resend.dev`
- Atualize `from: "SES-SP Planos <noreply@seu-dominio.com>"` se necessário

### 6️⃣ **Testar**
1. **F5** no navegador
2. Preencha formulário completo
3. Clique **"Finalizar e Salvar"**
4. Modal de emails aparece
5. Insira um email real (ou seu email para testar)
6. Clique **"Enviar"**
7. Procure por um email com assunto: **"Plano de Trabalho 2026"**

---

## 🔒 Forma Segura (Recomendada)

Para **produção**, use variáveis de ambiente:

### 1. Adicione ao arquivo `.env.local`:
```
VITE_RESEND_API_KEY=re_sua_chave_aqui
```

### 2. Atualize o App.tsx:
```typescript
const RESEND_API_KEY = import.meta.env.VITE_RESEND_API_KEY;
```

### 3. No `.gitignore`, certifique-se que tem:
```
.env.local
```

---

## 📋 Estrutura do Email que Será Enviado:

```
De: SES-SP Planos <noreply@seu-dominio.com>
Para: emails que o usuário inserir
Assunto: Plano de Trabalho 2026 - [NÚMERO DA EMENDA]

Corpo:
- Informações do plano
- Parlamentar, Programa, Valor
- PDF como attachment

Anexo: PDF assinado (enviado pelo usuário)
```

---

## ❓ Dúvidas Comuns

**P: Posso usar outro serviço (SendGrid, Mailgun)?**
R: Sim! O código é similar. Consulte a documentação desses serviços.

**P: Quanto custa o Resend?**
R: Gratuito até 100 emails/dia. Depois sai por email enviado.

**P: Preciso de um domínio?**
R: Não obrigatório no começo. Use `resend.dev` ou seu domínio.

**P: O PDF é enviado como attachment?**
R: Sim! Convertemos em Base64 dentro da função.

---

## 🎯 Código Pronto para Copiar-Colar

Se preferir, aqui está o código completo descomentado:

```typescript
const RESEND_API_KEY = import.meta.env.VITE_RESEND_API_KEY;

const response = await fetch('https://api.resend.com/emails', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${RESEND_API_KEY}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    from: "SES-SP Planos <noreply@resend.dev>",
    to: emailList,
    subject: `Plano de Trabalho 2026 - ${formData.emenda.numero}`,
    html: `
      <h2>Seu Plano de Trabalho foi salvo com sucesso!</h2>
      <p><strong>Parlamentar:</strong> ${formData.emenda.parlamentar}</p>
      <p><strong>Programa:</strong> ${formData.emenda.programa}</p>
      <p><strong>Valor:</strong> R$ ${formData.emenda.valor}</p>
      <p>Em anexo encontra-se o PDF assinado.</p>
      <hr/>
      <p><small>Secretaria de Estado da Saúde de São Paulo</small></p>
    `,
    attachments: [
      {
        filename: formData.pdfAssinado.name,
        content: pdfBase64
      }
    ]
  })
});

if (!response.ok) {
  const error = await response.json();
  throw new Error(error.message || 'Erro ao enviar email');
}
```

---

## ✅ Próximas Etapas

1. Criar conta Resend
2. Copiar API Key
3. Descomentar código em `App.tsx`  
4. Testar com um email real
5. Configurar domínio (opcional)

Avisa quando conseguir! 🚀
