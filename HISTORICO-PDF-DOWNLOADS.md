# 📋 HISTÓRICO DE DOWNLOADS DE PDF - PLANO DE TRABALHO

## ✅ Implementação Completa

A funcionalidade de salvamento do histórico de downloads foi implementada com sucesso. Agora cada vez que um usuário clica em **"Visualizar e Baixar PDF"**, o sistema registra:

- **Data e hora** do download
- **Usuário** que fez o download (email e nome)
- **Plano** que foi acessado (emenda, parlamentar, valor)
- **Tipo de ação** (view_pdf)

---

## 🗄️ Estrutura do Banco de Dados

### Tabela Principal
**`pdf_download_history`**
```
- id (SERIAL PRIMARY KEY)
- plano_id (UUID - referência ao plano)
- user_id (UUID - referência ao usuário)
- downloaded_at (TIMESTAMP com timezone)
- action_type (TEXT: 'view_pdf' ou 'download_pdf')
- user_email (TEXT)
- user_name (TEXT)
- numero_emenda (TEXT)
- parlamentar (TEXT)
- valor_total (NUMERIC)
```

### View para Estatísticas
**`pdf_download_stats`**
- Mostra estatísticas agregadas de downloads por plano
- Útil para análises e relatórios

---

## 🔍 CONSULTAS SQL PARA VISUALIZAR OS DADOS

### 1️⃣ VER TODOS OS DOWNLOADS DO SEU USUÁRIO
```sql
SELECT 
  numero_emenda,
  parlamentar,
  user_email,
  downloaded_at,
  valor_total
FROM public.pdf_download_history
WHERE user_email = 'seu.email@gov.br'
ORDER BY downloaded_at DESC;
```

### 2️⃣ VER DOWNLOADS DE UM PLANO ESPECÍFICO
```sql
SELECT 
  user_email,
  user_name,
  downloaded_at,
  action_type
FROM public.pdf_download_history
WHERE numero_emenda = '123/2026'
ORDER BY downloaded_at DESC;
```

### 3️⃣ VER ESTATÍSTICAS POR PLANO (TODOS OS DOWNLOADS)
```sql
SELECT 
  numero_emenda,
  parlamentar,
  total_downloads,
  usuarios_unicos,
  ultimo_download,
  plano_criado_em
FROM public.pdf_download_stats
ORDER BY total_downloads DESC;
```

### 4️⃣ VER DOWNLOADS DO DIA
```sql
SELECT 
  numero_emenda,
  parlamentar,
  user_email,
  user_name,
  downloaded_at::DATE as data,
  COUNT(*) as total_acessos
FROM public.pdf_download_history
WHERE DATE(downloaded_at) = CURRENT_DATE
GROUP BY numero_emenda, parlamentar, user_email, user_name, downloaded_at::DATE
ORDER BY downloaded_at DESC;
```

### 5️⃣ VER USUÁRIOS ADMINISTRATIVOS - HISTÓRICO COMPLETO
```sql
-- Se você é admin, pode ver TODOS os downloads do sistema
SELECT 
  numero_emenda,
  parlamentar,
  user_email,
  user_name,
  downloaded_at,
  valor_total,
  COUNT(*) OVER (PARTITION BY plano_id) as total_downloads_plano
FROM public.pdf_download_history
ORDER BY downloaded_at DESC
LIMIT 100;
```

### 6️⃣ VER USUÁRIOS COM MAIS DOWNLOADS
```sql
SELECT 
  user_email,
  user_name,
  COUNT(*) as total_downloads,
  COUNT(DISTINCT plano_id) as planos_unicos
FROM public.pdf_download_history
GROUP BY user_email, user_name
ORDER BY total_downloads DESC;
```

### 7️⃣ VER PLANOS NUNCA ACESSADOS
```sql
SELECT 
  pt.id,
  pt.numero_emenda,
  pt.parlamentar,
  pt.created_at,
  pt.valor_total
FROM public.planos_trabalho pt
LEFT JOIN public.pdf_download_history pdh ON pt.id = pdh.plano_id
WHERE pdh.id IS NULL
ORDER BY pt.created_at DESC;
```

---

## 🔐 SEGURANÇA (RLS)

✅ **Políticas de Segurança Implementadas:**

1. **Usuários veem apenas seus próprios downloads**
   - Cada usuário só pode consultar seu próprio histórico

2. **Admins podem ver tudo**
   - Administradores têm visibilidade de todos os downloads

3. **Apenas o usuário autenticado pode inserir**
   - O sistema automaticamente registra o user_id atual

---

## 📊 USAR AS ESTATÍSTICAS NO CÓDIGO REACT

Você pode criar um dashboard para visualizar estatísticas de downloads:

```typescript
// Exemplo de função para buscar estatísticas
const getDownloadStats = async () => {
  const { data, error } = await supabase
    .from('pdf_download_stats')
    .select('*')
    .order('total_downloads', { ascending: false });
    
  if (error) {
    console.error('Erro ao buscar estatísticas:', error);
  } else {
    console.log('Estatísticas de downloads:', data);
  }
};

// Exemplo de função para buscar histórico do usuário
const getUserDownloadHistory = async () => {
  const { data: { user } } = await supabase.auth.getUser();
  
  const { data, error } = await supabase
    .from('pdf_download_history')
    .select('*')
    .eq('user_id', user?.id)
    .order('downloaded_at', { ascending: false });
    
  if (error) {
    console.error('Erro ao buscar histórico:', error);
  } else {
    console.log('Seu histórico de downloads:', data);
  }
};
```

---

## ✅ PRÓXIMOS PASSOS

1. **Executar o script SQL** (`add-pdf-download-history.sql`) no Supabase
2. **Testar a funcionalidade:**
   - Abra um plano
   - Clique em "Visualizar e Baixar PDF"
   - Veja se aparece no histórico
3. **Criar um painel de estatísticas** (opcional)
4. **Gerar relatórios** baseados no histórico de downloads

---

## 🐛 TROUBLESHOOTING

**Problema:** Os downloads não estão sendo registrados
- ✓ Verificar se a tabela foi criada: `SELECT * FROM public.pdf_download_history LIMIT 1;`
- ✓ Verificar console do navegador para erros
- ✓ Confirmar que RLS está habilitado e as políticas estão OK

**Problema:** Erro de permissão ao inserir
- ✓ Verificar se o usuário está autenticado
- ✓ Testar a política RLS diretamente no Supabase

---

## 📝 NOTAS

- Os registros são **permanentes** no banco
- Ideal para **auditoria** e **análise de uso**
- View `pdf_download_stats` atualiza automaticamente
- Não afeta o **desempenho** da aplicação

