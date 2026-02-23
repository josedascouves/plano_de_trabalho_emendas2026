#!/bin/bash
# ==============================================================================
# Script para importar usuários no Supabase (Linux/Mac)
# ==============================================================================
#
# Uso: ./import-usuarios.sh usuarios.csv
#
# ==============================================================================

set -e

clear

echo ""
echo "============================================"
echo "   Importador de Usuários - Supabase"
echo "============================================"
echo ""

# Verificar argumentos
if [ $# -eq 0 ]; then
    echo "❌ Erro: Nenhum arquivo CSV foi fornecido."
    echo ""
    echo "Uso: ./import-usuarios.sh usuarios.csv"
    echo ""
    exit 1
fi

CSV_FILE="$1"

if [ ! -f "$CSV_FILE" ]; then
    echo "❌ Erro: Arquivo não encontrado: $CSV_FILE"
    echo ""
    exit 1
fi

echo "📁 Arquivo CSV: $CSV_FILE"
echo ""

# Verificar Python
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo "❌ Erro: Python não foi encontrado"
    echo ""
    echo "Instale Python:"
    echo "  Ubuntu/Debian: sudo apt-get install python3 python3-pip"
    echo "  macOS: brew install python3"
    echo ""
    exit 1
fi

# Usar python3 se disponível, senão python
PYTHON=python3
if ! command -v python3 &> /dev/null; then
    PYTHON=python
fi

echo "✅ Python encontrado"
$PYTHON --version
echo ""

# Verificar requests
if ! $PYTHON -c "import requests" 2>/dev/null; then
    echo "📦 Instalando biblioteca 'requests'..."
    $PYTHON -m pip install requests || {
        echo "❌ Erro ao instalar requests"
        echo ""
        exit 1
    }
fi

echo "✅ Biblioteca 'requests' pronta"
echo ""

# Solicitar chave de serviço
SERVICE_KEY=""

if [ -f "$HOME/.env" ]; then
    SERVICE_KEY=$(grep -oP 'SUPABASE_SERVICE_ROLE_KEY=\K[^[:space:]]+' "$HOME/.env" 2>/dev/null || true)
fi

if [ -z "$SERVICE_KEY" ]; then
    echo ""
    echo "🔐 Chave de Serviço Supabase Necessária"
    echo ""
    echo "Onde obter:"
    echo "  1. Acesse: https://app.supabase.com"
    echo "  2. Selecione seu projeto"
    echo "  3. Vá para: Settings > API"
    echo "  4. Copie 'service_role key'"
    echo ""
    echo -n "Cole a chave (começa com 'sb_'): "
    read -r SERVICE_KEY
fi

if [ -z "$SERVICE_KEY" ]; then
    echo "❌ Chave não fornecida"
    echo ""
    exit 1
fi

echo "✅ Chave recebida"
echo ""

# Executar script Python
echo "🚀 Iniciando importação..."
echo ""

export SUPABASE_SERVICE_ROLE_KEY="$SERVICE_KEY"
$PYTHON scripts/import_users.py "$CSV_FILE"

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Importação concluída com sucesso!"
else
    echo "⚠️  Importação concluída com erros"
fi

echo ""
