#!/bin/bash

# Script para fazer deploy no Cloudflare Pages
# Uso: ./deploy-cloudflare.sh

set -e

echo "🚀 Deploy Cloudflare Pages - Plano de Trabalho SES-SP"
echo "=================================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar se wrangler está instalado
if ! command -v wrangler &> /dev/null; then
    echo -e "${RED}❌ Wrangler não está instalado!${NC}"
    echo "Instale com: npm install -g wrangler"
    exit 1
fi

# Verificar se está em um repositório git
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Este não é um repositório git!${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Etapa 1: Instalando dependências...${NC}"
npm install

echo -e "${YELLOW}🔨 Etapa 2: Fazendo build...${NC}"
npm run build

if [ ! -d "dist" ]; then
    echo -e "${RED}❌ Erro: Pasta dist/ não foi criada!${NC}"
    exit 1
fi

echo -e "${YELLOW}✅ Build concluído com sucesso!${NC}"
echo ""

echo -e "${YELLOW}🌍 Etapa 3: Fazendo deploy no Cloudflare Pages...${NC}"

# Fazer deploy
wrangler pages deploy dist/ \
    --project-name=plano-ses-sp \
    --branch=main

echo ""
echo -e "${GREEN}✅ Deploy concluído com sucesso!${NC}"
echo ""
echo -e "${GREEN}🎉 Seu site está disponível em:${NC}"
echo "   https://plano-ses-sp.pages.dev"
echo ""
echo -e "${YELLOW}📊 Para acompanhar:${NC}"
echo "   1. Acesse: https://dash.cloudflare.com/"
echo "   2. Clique em Pages → plano-ses-sp"
echo "   3. Veja os deployments e analytics"
echo ""
