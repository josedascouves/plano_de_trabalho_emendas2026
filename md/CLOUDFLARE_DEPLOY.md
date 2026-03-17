# 🚀 Guia de Deploy - Cloudflare Pages

## ✅ Opção 1: Deploy via Git (RECOMENDADO - Automático)

### Pré-requisitos
- Conta no [Cloudflare](https://dash.cloudflare.com/)
- Repositório no GitHub/GitLab com este projeto
- Git configurado

### Passo a Passo

#### **1. Conectar Repositório ao Cloudflare Pages**
1. Acesse https://dash.cloudflare.com/
2. Clique em **"Pages"** no menu lateral esquerdo
3. Clique em **"Create a project"** → **"Connect to Git"**
4. Selecione seu provider (GitHub/GitLab)
5. Autorize o Cloudflare a acessar seus repositórios
6. Selecione o repositório: `plano-de-trabalho-ses-sp-2026`
7. Clique em **"Begin setup"**

#### **2. Configurar Build e Deploy**
Na tela de configuração:

- **Project name:** `plano-ses-sp` (ou outro nome)
- **Production branch:** `main`
- **Build command:** `npm run build`
- **Build output directory:** `dist`
- **Root directory:** `/` (deixar em branco)

#### **3. Adicionar Variáveis de Ambiente**
Clique em **"Build settings"** e adicione as variáveis:

```
SUPABASE_URL=https://tlpmspfnswaxwqzmwski.supabase.co
SUPABASE_ANON_KEY=sb_publishable_a_t5QoKSL53wf1uT6GjqYg_wk2ENe-9
VITE_SUPABASE_URL=https://tlpmspfnswaxwqzmwski.supabase.co
VITE_SUPABASE_ANON_KEY=sb_publishable_a_t5QoKSL53wf1uT6GjqYg_wk2ENe-9
```

#### **4. Deploy Automático**
- Clique em **"Save and Deploy"**
- Aguarde o build completar (~2-3 minutos)
- Você receberá uma URL como: `https://plano-ses-sp.pages.dev`

#### **5. Próximas Atualizações**
Sempre que fizer push no branch `main`, o Cloudflare faz deploy automático! 🎉

---

## ⚡ Opção 2: Deploy via Wrangler CLI (Manual)

### Pré-requisitos
```bash
npm install -g wrangler
```

### Passo a Passo

#### **1. Fazer Login no Cloudflare**
```bash
wrangler login
```
Isso abrirá o navegador para você autorizar.

#### **2. Fazer Build Localmente**
```bash
npm run build
```
Isso criará a pasta `dist/` com os arquivos prontos.

#### **3. Fazer Deploy**
```bash
wrangler pages deploy dist/
```

#### **4. URL do Site**
Após o deploy, você receberá uma URL como:
```
✅ Deployment successful!
URL: https://plano-ses-sp.pages.dev
```

---

## 📋 Pré-requisitos Verificação

Antes de fazer deploy, verifique:

- [x] Arquivo `wrangler.toml` existe
- [x] `npm run build` funciona localmente
- [x] Pasta `dist/` é gerada corretamente
- [x] Variáveis de ambiente Supabase estão corretas
- [x] `.env.local` não está commitado (está em `.gitignore`)

---

## 🔍 Verificar Build Localmente

```bash
# Build do projeto
npm run build

# Verificar se dist/ foi criado
ls dist/

# Testare previamente
npm run preview
```

---

## 🌐 Domínio Customizado (Opcional)

### Conectar Domínio Próprio
1. Em Cloudflare Pages → Project Settings
2. Clique em **"Custom domains"**
3. Clique em **"Set up a custom domain"**
4. Digite seu domínio: `plano.saude.sp.gov.br`
5. Siga as instruções para validar (DNS)

### Registradores de Domínio Comuns
- GoDaddy, Registro.br, HostGator, etc.
- Atualize os DNS para apontar para Cloudflare

---

## 🔒 CORS e Segurança

### Habilitar CORS para Supabase
No arquivo `wrangler.toml`, adicione:

```toml
[env.production]
routes = [
  {pattern = "plano-ses-sp.pages.dev"}
]

[[env.production.r2_buckets]]
binding = "BUCKET"
bucket_name = "plano-de-trabalho"
```

### Headers de Segurança
Crie arquivo `_headers` na pasta `public/`:

```
/*
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  X-XSS-Protection: 1; mode=block
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: geolocation=()
```

---

## 🐛 Troubleshooting

### Build falha com erro
```bash
# Limpar cache
rm -rf node_modules package-lock.json
npm install
npm run build
```

### CORS error ao acessar Supabase
- Verifique se as variáveis de ambiente estão corretas
- Confirme que Supabase não está bloqueando a origem

### 404 em rotas React
Crie arquivo `_redirects` na pasta `public/`:

```
/* /index.html 200
```

---

## 📊 Monitoramento

### Acessar Analytics
1. Cloudflare Pages → Project → Analytics
2. Veja views, requisições, tempo de resposta

### Ver Logs de Deploy
1. Cloudflare Pages → Deployments
2. Clique no deploy para ver logs

---

## 🚨 Rollback para Versão Anterior

```bash
# Ver histórico de deployments
wrangler pages deployments list

# Fazer rollback
wrangler pages rollback --project-name=plano-ses-sp
```

---

## ✅ Checklist Final

- [x] Repositório está em Git
- [x] `wrangler.toml` criado
- [x] Build funciona: `npm run build`
- [x] Variáveis de ambiente configuradas
- [x] Supabase URL e chaves corretas
- [x] Domínio customizado (opcional)
- [x] CORS habilitado
- [x] Headers de segurança configurados

---

## 📈 Próximas Etapas

1. **Monitoramento:** Configure alertas em Cloudflare Analytics
2. **SSL/TLS:** Cloudflare fornece automaticamente (Flexible)
3. **Caching:** Configure regras de cache em Page Rules
4. **Analytics:** Ative Google Analytics se desejado

---

## 🆘 Suporte

- Documentação Cloudflare Pages: https://developers.cloudflare.com/pages/
- Comunidade: https://community.cloudflare.com/
- Status: https://www.cloudflarestatus.com/

---

**Data:** Fevereiro 2026  
**Status:** ✅ Pronto para Deploy  
**Versão:** 1.0
