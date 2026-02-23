@echo off
REM Script para fazer deploy no Cloudflare Pages (Windows)
REM Uso: deploy-cloudflare.bat

echo.
echo 🚀 Deploy Cloudflare Pages - Plano de Trabalho SES-SP
echo ==================================================
echo.

REM Verificar se wrangler está instalado
where wrangler >nul 2>nul
if errorlevel 1 (
    echo ❌ Wrangler não está instalado!
    echo Instale com: npm install -g wrangler
    exit /b 1
)

echo 📦 Etapa 1: Instalando dependências...
call npm install

echo.
echo 🔨 Etapa 2: Fazendo build...
call npm run build

if not exist "dist" (
    echo ❌ Erro: Pasta dist/ não foi criada!
    exit /b 1
)

echo.
echo ✅ Build concluído com sucesso!
echo.

echo 🌍 Etapa 3: Fazendo deploy no Cloudflare Pages...
echo.

REM Fazer deploy
call wrangler pages deploy dist/ --project-name=plano-ses-sp --branch=main

echo.
echo ✅ Deploy concluído com sucesso!
echo.
echo 🎉 Seu site está disponível em:
echo    https://plano-ses-sp.pages.dev
echo.
echo 📊 Para acompanhar:
echo    1. Acesse: https://dash.cloudflare.com/
echo    2. Clique em Pages ^> plano-ses-sp
echo    3. Veja os deployments e analytics
echo.

pause
