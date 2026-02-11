# ⚠️ INSTRUÇÃO CRÍTICA: Executar Scripts SQL no Supabase

Você precisa executar os seguintes scripts SQL no Supabase para ativar as funcionalidades de edição e versionamento.

## 📋 Scripts Necessários

### 1️⃣ Adicionar Colunas de Versionamento
Execute este script no console Supabase:
- Abra: https://app.supabase.com → Seu Projeto → SQL Editor
- Crie uma nova query
- Cole o conteúdo do arquivo: `add-versioning-columns.sql`
- Clique em "RUN"

```sql
-- Adicionar coluna de contagem de edições
ALTER TABLE planos_trabalho 
ADD COLUMN IF NOT EXISTS edit_count INTEGER DEFAULT 0;

-- Adicionar coluna de data última edição
ALTER TABLE planos_trabalho 
ADD COLUMN IF NOT EXISTS last_edited_at TIMESTAMP WITH TIME ZONE;

-- Adicionar coluna de usuário última edição
ALTER TABLE planos_trabalho 
ADD COLUMN IF NOT EXISTS last_edited_by UUID;

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_planos_work_edit_count ON planos_trabalho(edit_count DESC);
CREATE INDEX IF NOT EXISTS idx_planos_work_last_edited_at ON planos_trabalho(last_edited_at DESC);
```

### 2️⃣ Adicionar Colunas de Planejamento Estratégico
Execute este script no console Supabase:

```sql
-- Adicionar colunas de planejamento estratégico à tabela planos_trabalho
ALTER TABLE planos_trabalho 
ADD COLUMN IF NOT EXISTS diretriz_id TEXT,
ADD COLUMN IF NOT EXISTS objetivo_id TEXT,
ADD COLUMN IF NOT EXISTS metas_ids TEXT[] DEFAULT '{}';
```

## ✅ Verificação

Após executar os scripts, verifique se as colunas foram criadas:
- Vá em: Supabase → Seu Projeto → Database → Tables → planos_trabalho
- Confirme que as colunas aparecem listadas

## 🔄 Funcionalidades Ativadas

Após executar os scripts corretamente:
- ✅ Contador de edições será registrado automaticamente
- ✅ Data/hora da última edição será exibida
- ✅ Diretrizes e objetivos estratégicos serão salvos com o plano
- ✅ Dashboard mostrará histórico de edições (máx 10 últimas)
- ✅ Lista de planos mostrará badge com número de edições

## 📍 Status: PENDENTE EXECUÇÃO DOS SCRIPTS SQL

