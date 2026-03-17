# 🚀 GUIA DE IMPLEMENTAÇÃO - HISTÓRICO DE DOWNLOADS DE PDF

## 📋 RESUMO

Você solicitou a implementação do salvamento de informações quando o usuário clica em **"Visualizar e Baixar PDF"**. 

**Arquivos criados/modificados:**
1. ✅ `add-pdf-download-history.sql` - Script para criar tabela no banco
2. ✅ `App.tsx` - Modificado com função `recordPdfViewEvent()`
3. ✅ `HISTORICO-PDF-DOWNLOADS.md` - Documentação completa

---

## 🔧 PASSO A PASSO DE IMPLEMENTAÇÃO

### PASSO 1: Executar o Script SQL no Supabase ⚙️

**Acesse:** https://supabase.com/dashboard/project/SEU_PROJETO/sql/new

1. Abra o arquivo `add-pdf-download-history.sql`
2. Copie TODO o conteúdo
3. Cole no **SQL Editor** do Supabase
4. Clique em **"Run"** (ou Ctrl+Enter)
5. Verifique que todas as mensagens dizem "✅"

**Resultado esperado:**
```
✅ Tabela pdf_download_history criada com sucesso!
✅ Índices criados!
✅ RLS habilitado!
✅ View de estatísticas criada!
```

---

### PASSO 2: Verificar se a Tabela foi Criada ✓

No Supabase SQL Editor, execute:

```sql
SELECT * FROM public.pdf_download_history LIMIT 1;
```

**Esperado:** Sem erros, você verá a estrutura da tabela (mesmo que vazia)

---

### PASSO 3: Testar a Funcionalidade 🧪

1. **Abra a aplicação** em seu navegador
2. **Faça login** com um usuário
3. **Abra um plano de trabalho** ou **crie um novo**
4. **Clique em "Visualizar e Baixar PDF"**
5. **Verifique o console** (F12 → Console) para ver a mensagem:
   ```
   ✅ Evento de visualização de PDF registrado com sucesso!
   ```

---

### PASSO 4: Consultar os Dados Registrados 📊

No Supabase SQL Editor, execute:

```sql
SELECT 
  numero_emenda,
  parlamentar,
  user_email,
  downloaded_at,
  action_type
FROM public.pdf_download_history
ORDER BY downloaded_at DESC
LIMIT 10;
```

**Você deve ver** seus registros de downloads com data/hora!

---

## ✅ O QUE FOI IMPLEMENTADO

### Na Aplicação (App.tsx)

**Nova função criada:**
```typescript
const recordPdfViewEvent = async (planoId: string) => {
  // 1. Obtém usuário autenticado
  // 2. Busca dados do plano (emenda, parlamentar, valor)
  // 3. Insere registro em pdf_download_history
  // 4. Registra sucesso ou erro no console
}
```

**Função modificada:**
```typescript
const handleGeneratePDF = async () => {
  // ... validações e salva plano ...
  
  // NOVA LINHA:
  await recordPdfViewEvent(currentPlanoId);
  
  // ... abre diálogo de impressão ...
}
```

---

## 📊 DADOS CAPTURADOS

Cada vez que alguém clica em "Visualizar PDF", o sistema registra:

| Campo | Exemplo |
|-------|---------|
| plano_id | `550e8400-e29b-41d4-a716-446655440000` |
| user_id | `662312a1-1234-5678-abcd-ef1234567890` |
| downloaded_at | `2026-02-27 14:35:22.123456+00` |
| action_type | `view_pdf` |
| user_email | `afpereira@example.com` |
| user_name | `AFP Pereira` |
| numero_emenda | `123/2026` |
| parlamentar | `João da Silva` |
| valor_total | `50000.00` |

---

## 🔍 CONSULTAS ÚTEIS

### Ver seus próprios downloads:
```sql
SELECT numero_emenda, parlamentar, downloaded_at
FROM public.pdf_download_history
WHERE user_email = 'seu.email@gov.br'
ORDER BY downloaded_at DESC;
```

### Ver downloads hoje:
```sql
SELECT numero_emenda, user_email, COUNT(*) as acessos
FROM public.pdf_download_history
WHERE DATE(downloaded_at) = CURRENT_DATE
GROUP BY numero_emenda, user_email;
```

### Ver estatísticas por plano:
```sql
SELECT * FROM public.pdf_download_stats
ORDER BY total_downloads DESC;
```

---

## ⚠️ TROUBLESHOOTING

### ❌ "Não vejo nada no histórico"

**Solução:**
```sql
-- Verificar se a tabela existe
SELECT COUNT(*) FROM public.pdf_download_history;

-- Ver todas as colunas
\d public.pdf_download_history;

-- Ver últimos registros
SELECT * FROM public.pdf_download_history ORDER BY downloaded_at DESC LIMIT 10;
```

---

### ❌ "Erro ao registrar evento"

**Verificar no console do navegador (F12):**
- Deve aparecer uma mensagem de erro específica
- Comum: RLS bloqueando inserção
- **Solução:** Executar novamente o script SQL

---

### ❌ "RLS policy error"

**Solução rápida:**
```sql
-- Verificar políticas
SELECT * FROM information_schema.role_routine_grants 
WHERE routine_schema = 'public' AND routine_name = 'pdf_download_history';

-- Deletar e recriar tabela
DROP TABLE IF EXISTS public.pdf_download_history CASCADE;
-- Executar o script completo novamente
```

---

## 🎯 PRÓXIMOS PASSOS (OPCIONAL)

### 1. Criar um Dashboard de Downloads
```typescript
// Componente que mostra histórico de downloads
const DownloadHistoryDashboard = () => {
  const [history, setHistory] = useState([]);
  
  useEffect(() => {
    supabase
      .from('pdf_download_history')
      .select('*')
      .eq('user_id', currentUser.id)
      .order('downloaded_at', { ascending: false })
      .then(({ data }) => setHistory(data));
  }, []);
  
  return (
    <table>
      <thead>
        <tr>
          <th>Emenda</th>
          <th>Data</th>
          <th>Hora</th>
        </tr>
      </thead>
      <tbody>
        {history.map(h => (
          <tr key={h.id}>
            <td>{h.numero_emenda}</td>
            <td>{new Date(h.downloaded_at).toLocaleDateString('pt-BR')}</td>
            <td>{new Date(h.downloaded_at).toLocaleTimeString('pt-BR')}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};
```

### 2. Enviar Notificação de Download
```typescript
// Registrar que admin foi notificado sobre um download importante
const notifyAdminOnDownload = async (planoId: string) => {
  // Enviar email ou criar notificação
};
```

### 3. Gerar Relatório de Acessos
```typescript
// Relatório de quem acessou qual plano
const generateAccessReport = async () => {
  const { data } = await supabase
    .from('pdf_download_stats')
    .select('*')
    .order('total_downloads', { ascending: false });
  
  // Exportar para CSV ou PDF
};
```

---

## 📝 CHECKLIST DE IMPLEMENTAÇÃO

- [ ] Executei o script SQL no Supabase
- [ ] Verifiquei que a tabela foi criada
- [ ] Testei clicando em "Visualizar PDF"
- [ ] Consigo ver o registro no banco
- [ ] Ativei o arquivo App.tsx modificado
- [ ] Fiz reload da aplicação
- [ ] Testei novamente com um usuário diferente
- [ ] Verifiquei que cada click registra um novo histórico

---

## 🎉 CONCLUSÃO

✨ **Implementação completa!**

Seu sistema agora:
- ✅ Registra quando usuários clicam em "Visualizar PDF"
- ✅ Armazena data, hora e dados do plano
- ✅ Permite auditoria e rastreamento de uso
- ✅ Protege dados com RLS (Row Level Security)
- ✅ Não afeta performance da aplicação

**Dúvidas?** Consulte `HISTORICO-PDF-DOWNLOADS.md` para mais exemplos de consultas.

