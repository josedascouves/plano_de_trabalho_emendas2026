# ✅ CHECKLIST DE IMPLEMENTAÇÃO - HISTÓRICO DE PDF

## 📋 ANTES DE COMEÇAR

- [ ] Você tem acesso ao Supabase SQL Editor
- [ ] A aplicação começa a rodar sem erros
- [ ] Você consegue fazer login e criar planos
- [ ] Você sabe alterar entre abas no Supabase

---

## 🔧 ETAPA 1: CRIAR TABELA NO BANCO

### Procurar arquivos
- [ ] Abri o arquivo `add-pdf-download-history.sql`
- [ ] Vi a declaração "CREATE TABLE"

### Executar Script
- [ ] Copiei TODO o conteúdo do arquivo SQL
- [ ] Entrei em: https://supabase.com/dashboard/project/[SEU_PROJETO]/sql/new
- [ ] Virei no SQL Editor um novo espaço
- [ ] Colei o conteúdo
- [ ] Cliquei em "Run" ou pressionei Ctrl+Enter

### Verificar Resultado
- [ ] Apareceu mensagem: "✅ Tabela pdf_download_history criada com sucesso!"
- [ ] Apareceu mensagem: "✅ Índices criados!"
- [ ] Apareceu mensagem: "✅ RLS habilitado!"
- [ ] Apareceu mensagem: "✅ View de estatísticas criada!"

---

## ✓ ETAPA 2: VERIFICAR TABELA FOI CRIADA

### No Supabase
- [ ] Vou na aba "SQL Editor" novamente
- [ ] Crio um novo Query
- [ ] Digito: `SELECT * FROM public.pdf_download_history LIMIT 1;`
- [ ] Clico em Run

### Resultado Esperado
- [ ] Vejo as colunas: id, plano_id, user_id, downloaded_at, etc.
- [ ] Sem mensagem de erro "table does not exist"
- [ ] A tabela está VAZIA (esperado, ninguém acessou ainda)

**Se deu erro:**
- [ ] Voltar para ETAPA 1 e executar o script novamente

---

## 🧪 ETAPA 3: O CÓDIGO REACT JÁ ESTÁ PRONTO

### Verificar Arquivo App.tsx
- [ ] Abri o arquivo `App.tsx`
- [ ] Procurei por: `recordPdfViewEvent`
- [ ] Vi a função nova criada (procure por "Registra evento")
- [ ] Vi que `handleGeneratePDF` chama `recordPdfViewEvent`

**Resultado:** ✅ O código já está implementado, nada para fazer aqui!

---

## 🧬 ETAPA 4: TESTAR A FUNCIONALIDADE

### Preparar
- [ ] A aplicação está rodando no localhost
- [ ] Faço login com um usuário
- [ ] Navego até um plano (crio um novo ou abro um existente)

### Teste 1: Abrir Console do Navegador
- [ ] Pressionei F12
- [ ] Vou na aba "Console"
- [ ] Deixei a aba console aberta

### Teste 2: Clicar em "Visualizar e Baixar PDF"
- [ ] Procuro pelo botão "Visualizar e Baixar PDF" (ou similar)
- [ ] Clico nele
- [ ] Espero alguns segundos

### Teste 3: Verificar Console
- [ ] Procuro por mensagens no console
- [ ] Vejo a mensagem: `✅ Evento de visualização de PDF registrado com sucesso!`
- [ ] Ou vejo: `downloaded_at`

**Se NÃO vejo mensagem:**
- [ ] Procuro por erro (mensag com "❌")
- [ ] Anoto o erro
- [ ] Volto para Etapa 1

**Se vejo erro de RLS:**
- [ ] Significa que as políticas estão bloqueando
- [ ] Solução: Executar script SQL novamente (Etapa 1)

---

## 📊 ETAPA 5: CONSULTAR DADOS NO BANCO

### Primeira Consulta Simples
```sql
SELECT * FROM public.pdf_download_history;
```

- [ ] Vou na aba SQL do Supabase
- [ ] Crio um novo Query
- [ ] Digito ou colo a consulta acima
- [ ] Clico em Run

### Resultado Esperado
- [ ] Vejo uma linha com meu download
- [ ] Colunas: id, plano_id, user_id, downloaded_at, etc.
- [ ] O numero_emenda aparece
- [ ] O user_email aparece

**Se estiver vazio:**
- [ ] Voltar para Etapa 4
- [ ] Testar clicando no botão de um plano diferente

### Segunda Consulta: Filtrar por Meu Email
- [ ] Copiei uma consulta de `CONSULTAS-PDF-DOWNLOADS.sql`
- [ ] Substitui 'seu.email@gov.br' pelo meu email real
- [ ] Executei
- [ ] Vi meus registros de download

- [ ] ✅ Tudo funcionando!

---

## 👥 ETAPA 6: TESTAR COM OUTRO USUÁRIO (OPCIONAL)

### Criar Segundo Usuário
- [ ] Tenho acesso a outro usuário ou crio um
- [ ] Desloquei do primeiro usuário
- [ ] Fiz login com o segundo usuário

### Testar Download
- [ ] Cliquei em "Visualizar e Baixar PDF" com o segundo usuário
- [ ] Voltei ao SQL e consultei

### Resultado Esperado
- [ ] Vejo TWO usuários diferentes no histórico
- [ ] Cada um vê apenas seus próprios downloads
- [ ] (A menos que seja admin)

- [ ] ✅ RLS está funcionando corretamente

---

## 📈 ETAPA 7: VER AS ESTATÍSTICAS

### Consultar View de Estatísticas
```sql
SELECT * FROM public.pdf_download_stats;
```

- [ ] Colei essa consulta no SQL Editor
- [ ] Cliquei em Run

### Resultado Esperado
- [ ] Vejo: numero_emenda, parlamentar, total_downloads, usuarios_unicos, etc.
- [ ] Os números combinam com o que vi antes

- [ ] ✅ Estatísticas funcionando

---

## 🎯 ETAPA 8: USAR AS CONSULTAS PRONTAS

### Abrir Arquivo de Consultas
- [ ] Abri: `CONSULTAS-PDF-DOWNLOADS.sql`
- [ ] Copiei uma das 17 consultas

### Testar 5 Consultas
- [ ] `1️⃣ VER ÚLTIMOS 20 DOWNLOADS` - funcionou
- [ ] `3️⃣ DOWNLOADS POR DIA` - funcionou
- [ ] `5️⃣ TOP 10 PLANOS` - funcionou
- [ ] `6️⃣ TOP 10 USUÁRIOS` - funcionou
- [ ] `11️⃣ ESTATÍSTICAS GERAIS` - funcionou

- [ ] ✅ Todas as consultas funcionam

---

## 🚀 CONCLUSÃO

- [ ] Executei o script SQL com sucesso
- [ ] Verifiquei que a tabela foi criada
- [ ] Testei o clique em "Visualizar PDF"
- [ ] Vi o registro aparecer no banco
- [ ] Testei as consultas de análise
- [ ] Tudo funcionando perfeitamente!

**Status: ✅ IMPLEMENTAÇÃO CONCLUÍDA**

---

## 📝 PRÓXIMAS AÇÕES

Agora você pode:

1. **Usar no dia a dia**
   - Cada clique em "Visualizar PDF" registra automaticamente

2. **Consultar histórico**
   - Use as consultas em `CONSULTAS-PDF-DOWNLOADS.sql`

3. **Gerar relatórios**
   - Copie dados para Excel
   - Analise padrões de uso

4. **Criar dashboard** (opcional)
   - Mostre histórico dentro da app
   - Crie gráficos de uso

---

## ⚠️ TROUBLESHOOTING RÁPIDO

| Problema | Solução |
|----------|---------|
| "table does not exist" | Execute o script SQL novamente |
| "RLS policy error" | Verifique se as políticas foram criadas (script) |
| "Sem mensagens no console" | Verifique se clicou no botão correto |
| "Registros vazios" | Clique no botão novamente e aguarde |
| "Erro no navegador" | Abra console (F12) e veja o erro específico |

---

## 📚 REFERÊNCIA RÁPIDA

- **Documentação Completa:** `HISTORICO-PDF-DOWNLOADS.md`
- **Guia Passo-a-Passo:** `IMPLEMENTACAO-HISTORICO-PDF.md`
- **Consultas SQL:** `CONSULTAS-PDF-DOWNLOADS.sql`
- **Resumo Executivo:** `RESUMO-IMPLEMENTACAO.md`
- **Script SQL:** `add-pdf-download-history.sql`

---

## ✨ Pronto!

Sua implementação de histórico de downloads está **100% funcional**.

Aproveite! 🎉
