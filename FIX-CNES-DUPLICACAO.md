# 🔧 FIX PARA CNES E DUPLICAÇÃO DE PLANOS

## ✅ Correções Implementadas no Código

1. **CNES agora é salvo** - Adicionado `cnes: formData.beneficiario.cnes || null` em todos os INSERTs/UPDATEs
2. **Duplicação eliminada** - Implementado check `if (planoSalvoId)` para UPDATE (não INSERT) quando plano já existe
3. **Validação de Despesas** - Funciona em `handleFinalSend()` E `handleGeneratePDF()`
4. **Proteção contra duplo clique** - Flag `isSending` previne múltiplos cliques simultâneos

## ⚠️ REQUERIDO: Adicionar coluna CNES ao Supabase

A coluna `cnes` ainda não existe na tabela `planos_trabalho`. Você precisa:

### Opção 1: Via Supabase SQL Editor (Recomendado)

1. Abra: https://supabase.com/dashboard/project/tlpmspfnswaxwqzmwski/sql/new
2. Copie o conteúdo de `MIGRATION-ADD-CNES.sql`
3. Execute (Ctrl + Enter ou clique em "Run")
4. Pronto! A coluna será criada

### Opção 2: Copie apenas este SQL

```sql
ALTER TABLE public.planos_trabalho 
ADD COLUMN IF NOT EXISTS cnes TEXT;

ALTER TABLE public.planos_trabalho 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
```

## 🧪 Como Testar

1. **Novo Plano**
   - Insira CNES no formulário (ex: 1234567)
   - Salve o plano
   - Vá para "Meus Planos" e veja se CNES aparece (não será mais "—")

2. **Editar Plano**
   - Clique em "EDITAR" em um plano existente
   - Modifique algo (ex: PARLAMENTAR)
   - Clique em salvar
   - Deve aparecer mensagem de sucesso
   - Na listagem, só há 1 cópia do plano (não duplicado)

3. **Validação de Despesa**
   - Adicione Metas Quantitativas (ex: R$ 100)
   - Tente adicionar Natureza de Despesa > R$ 100
   - Deve receber alerta: "O total de Naturezas de Despesa ultrapassa..."
   - Não deve permitir salvar/gerar PDF

## 📋 Status dos Problemas

| Problema | Status | Detalhes |
|----------|--------|----------|
| CNES vazio | ✅ Corrigido (pendente coluna SQL) | Código salva CNES. Precisa criar coluna no banco |
| Duplicação | ✅ Corrigido | Agora faz UPDATE para planos existentes |
| Validação Despesa | ✅ Corrigido | Funciona em Salvar e Gerar PDF |

## 🔍 Logs para Debug

Abra o Console do Navegador (F12) e procure por:
- `✅ Plano ${id} carregado para edição` → Indica plano carregado
- `📌 Plano ${id} salvo. lastSavedFormData atualizado` → Indica salvamento
- `⚠️ Plano ${id} já existe. Atualizando dados...` → Indica UPDATE (não INSERT)

Se ver múltiplos logs de salvamento = ainda há duplicação.
