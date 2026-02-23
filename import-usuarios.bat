@echo off
REM ==============================================================================
REM Script para importar usuários no Supabase (Windows)
REM ==============================================================================
REM
REM Uso: execute este arquivo
REM
REM ==============================================================================

setlocal enabledelayedexpansion

cls
echo.
echo ============================================
echo   Importador de Usuários - Supabase
echo ============================================
echo.

REM Verificar se foi passado caminho do CSV como argumento
if "%~1"=="" (
    echo ❌ Erro: Nenhum arquivo CSV foi fornecido.
    echo.
    echo Uso: drag-and-drop o arquivo CSV neste arquivo
    echo  ou: import-usuarios.bat usuarios.csv
    echo.
    pause
    exit /b 1
)

set CSV_FILE=%~1
if not exist "!CSV_FILE!" (
    echo ❌ Erro: Arquivo não encontrado: !CSV_FILE!
    echo.
    pause
    exit /b 1
)

echo 📁 Arquivo CSV: !CSV_FILE!
echo.

REM Verificar Python
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Erro: Python não foi encontrado
    echo.
    echo Instale Python em: https://www.python.org/downloads/
    echo ☑ Marque "Add Python to PATH" durante a instalação
    echo.
    pause
    exit /b 1
)

echo ✅ Python encontrado
python --version
echo.

REM Verificar requests
python -c "import requests" >nul 2>nul
if %errorlevel% neq 0 (
    echo 📦 Instalando biblioteca 'requests'...
    pip install requests
    if %errorlevel% neq 0 (
        echo ❌ Erro ao instalar requests
        echo.
        pause
        exit /b 1
    )
)

echo ✅ Biblioteca 'requests' pronta
echo.

REM Solicitar chave de serviço
set "SERVICE_KEY="
for /f "tokens=2 delims==" %%A in ('findstr /L "SUPABASE_SERVICE_ROLE_KEY" "%USERPROFILE%\.env" 2^>nul') do (
    set "SERVICE_KEY=%%A"
)

if "!SERVICE_KEY!"=="" (
    echo.
    echo 🔐 Chave de Serviço Supabase Necessária
    echo.
    echo Onde obter:
    echo   1. Acesse: https://app.supabase.com
    echo   2. Selecione seu projeto
    echo   3. Vá para: Settings ^> API
    echo   4. Copie "service_role key"
    echo.
    set /p SERVICE_KEY="Cole a chave (começa com 'sb_'): "
)

if "!SERVICE_KEY!"=="" (
    echo ❌ Chave não fornecida
    echo.
    pause
    exit /b 1
)

echo ✅ Chave recebida
echo.

REM Executar script Python
echo 🚀 Iniciando importação...
echo.

set SUPABASE_SERVICE_ROLE_KEY=!SERVICE_KEY!
python scripts/import_users.py "!CSV_FILE!"

if %errorlevel% equ 0 (
    echo.
    echo ✅ Importação concluída com sucesso!
) else (
    echo.
    echo ⚠️  Importação concluída com erros
)

echo.
pause
