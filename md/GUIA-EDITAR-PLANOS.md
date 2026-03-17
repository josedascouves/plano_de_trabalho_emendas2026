# 🔧 CORRIGIR EDIÇÃO DE PLANOS - GUIA COMPLETO

## ❌ Problema
Ao editar um plano, os campos não carregam completamente:
- ❌ Diretrizes vazio
- ❌ Objetivos vazio  
- ❌ Metas vazias
- ❌ Outros campos não aparecem

## ✅ Causa
As colunas foram criadas no código mas **não existem no banco de dados** Supabase:
- `diretriz_id` - armazena qual diretriz foi selecionada
- `objetivo_id` - armazena qual objetivo foi selecionado
- `metas_ids` - armazena array de metas selecionadas
- `edit_count` - conta quantas vezes foi editado
- `last_edited_at` - data da última edição

---

## 🔧 SOLUÇÃO - 3 PASSOS

### Passo 1: Abrir Supabase SQL Editor
1. Acesse: https://app.supabase.com
2. Clique em **SQL Editor** no menu lateral
3. Clique em **New Query**

### Passo 2: Executar o Script
1. Abra o arquivo: **ADD-COLUNAS-ALINHAMENTO.sql**
2. Copie TODO o conteúdo
3. Cole no editor SQL do Supabase
4. Clique em **Run** (ou Ctrl+Enter)

```sql
-- Exemplo do que será executado:
ALTER TABLE public.planos_trabalho
ADD COLUMN IF NOT EXISTS diretriz_id TEXT;

ALTER TABLE public.planos_trabalho
ADD COLUMN IF NOT EXISTS objetivo_id TEXT;

-- ... etc
```

### Passo 3: Recarregar o App
1. Volte ao app
2. Pressione **F5** para recarregar
3. Clique em editar um plano
4. ✅ Agora todos os campos devem carregar!

---

## 📋 Checklist de Verificação

Após executar o script, rode esta query no Supabase para verificar:

```sql
SELECT 
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'planos_trabalho'
AND column_name IN ('diretriz_id', 'objetivo_id', 'metas_ids', 'edit_count', 'last_edited_at')
ORDER BY column_name;
```

Deve retornar **5 colunas**:
- ✅ diretriz_id (text)
- ✅ edit_count (integer)
- ✅ last_edited_at (timestamp)
- ✅ metas_ids (ARRAY)
- ✅ objetivo_id (text)

---

## 🧪 Teste Agora

1. **Crie um novo plano** com todos os dados
2. **Salve o plano** com sucesso
3. **Volte para a lista** de planos
4. **Clique em "Editar"** em um plano
5. ✅ **Todos os campos devem aparecer preenchidos**

---

## ⚠️ Se Ainda não Funcionar

Execute no console do navegador (F12) para ver os logs:

```javascript
// Abra DevTools > Console
// Procure por logs como:
// ✅ Plano carregado: { diretriz_id: "..." }
```

Se ainda vir `diretriz_id: undefined`, significa que:
1. O script SQL não foi executado
2. Ou houve erro na execução do script

Neste caso:
- Abra o arquivo **ADD-COLUNAS-ALINHAMENTO.sql**
- Execute apenas a seção "1. ADICIONAR COLUNAS DE ALINHAMENTO ESTRATÉGICO"
- Ignores as demais seções por enquanto

---

## 📞 Próximos Passos

Após corrigir, você terá:
- ✅ Edição completa de planos
- ✅ Carregamento de todas as diretrizes
- ✅ Carregamento de todos os objetivos
- ✅ Carregamento de todas as metas
- ✅ Histórico de edições (edit_count)
- ✅ Rastreamento de última edição (last_edited_at)

---

**Dúvidas ou erros? Veja os logs de:**
- 📂 Arquivo: ADD-COLUNAS-ALINHAMENTO.sql (tem comentários explicativos)
- 🔍 Console do navegador (F12 > Console)
- 🗄️ Supabase SQL Editor (veja mensagens de erro)
