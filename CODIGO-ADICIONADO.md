# 📝 CÓDIGO ADICIONADO - FUNÇÃO recordPdfViewEvent

Este documento mostra exatamente o código que foi adicionado ao arquivo `App.tsx`.

---

## 🎯 LOCALIZAÇÃO

**Arquivo:** `App.tsx`  
**Função adicionada ANTES de:** `handleGeneratePDF`  
**Aproximadamente na linha:** 2234

---

## 📦 CÓDIGO COMPLETO DA NOVA FUNÇÃO

```typescript
// Registra evento de visualização/download de PDF no banco de dados
const recordPdfViewEvent = async (planoId: string) => {
  try {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      console.warn("⚠️ Não foi possível registrar evento PDF: usuário não autenticado");
      return;
    }

    // Buscar dados do plano para registrar no histórico
    const { data: plano, error: fetchError } = await supabase
      .from('planos_trabalho')
      .select('numero_emenda, parlamentar, valor_total')
      .eq('id', planoId)
      .single();

    if (fetchError) {
      console.error("❌ Erro ao buscar dados do plano:", fetchError);
      return;
    }

    // Registrar no histórico
    const { error: insertError } = await supabase
      .from('pdf_download_history')
      .insert({
        plano_id: planoId,
        user_id: user.id,
        user_email: user.email,
        user_name: currentUser?.name || 'Usuário',
        numero_emenda: plano.numero_emenda,
        parlamentar: plano.parlamentar,
        valor_total: plano.valor_total,
        action_type: 'view_pdf'
      });

    if (insertError) {
      console.error("❌ Erro ao registrar evento PDF:", insertError);
    } else {
      console.log("✅ Evento de visualização de PDF registrado com sucesso!");
    }
  } catch (error: any) {
    console.error("❌ Erro ao registrar evento de PDF:", error);
    // Não interrompe o fluxo se falhar ao registrar
  }
};
```

---

## 📝 MODIFICAÇÃO NA FUNÇÃO handleGeneratePDF

A função `handleGeneratePDF` foi modificada para chamar a nova função.

### ANTES (linhas 2290-2291):
```typescript
      // 2. Abrir diálogo de impressão (navegador respeitará quebras naturalmente)
      console.log("Abrindo diálogo de impressão...");
```

### DEPOIS (linhas 2290-2295):
```typescript
      // 2. Registrar evento de visualização/download no banco de dados
      console.log("📝 Registrando evento de visualização de PDF...");
      await recordPdfViewEvent(currentPlanoId);

      // 3. Abrir diálogo de impressão (navegador respeitará quebras naturalmente)
      console.log("Abrindo diálogo de impressão...");
```

---

## 🔍 EXPLICAÇÃO DO CÓDIGO

### 1. Obter Usuário Autenticado
```typescript
const { data: { user } } = await supabase.auth.getUser();
if (!user) {
  console.warn("⚠️ Não foi possível registrar evento PDF: usuário não autenticado");
  return;
}
```
- Verifica se o usuário está logado
- Se não estiver, retorna sem erro (não interrompe o fluxo)

### 2. Buscar Dados do Plano
```typescript
const { data: plano, error: fetchError } = await supabase
  .from('planos_trabalho')
  .select('numero_emenda, parlamentar, valor_total')
  .eq('id', planoId)
  .single();
```
- Busca dados do plano no banco
- Seleciona apenas as colunas necessárias para melhor performance
- Se houver erro, registra no console

### 3. Inserir Registro de Download
```typescript
const { error: insertError } = await supabase
  .from('pdf_download_history')
  .insert({
    plano_id: planoId,
    user_id: user.id,
    user_email: user.email,
    user_name: currentUser?.name || 'Usuário',
    numero_emenda: plano.numero_emenda,
    parlamentar: plano.parlamentar,
    valor_total: plano.valor_total,
    action_type: 'view_pdf'
  });
```

**Campos inseridos:**
- `plano_id` → ID do plano
- `user_id` → ID do usuário (automático)
- `user_email` → Email do usuário
- `user_name` → Nome do usuário (de `currentUser?.name`)
- `numero_emenda` → Número da emenda
- `parlamentar` → Nome do parlamentar
- `valor_total` → Valor total da emenda
- `action_type` → Tipo de ação ('view_pdf')

### 4. Verificação de Sucesso
```typescript
if (insertError) {
  console.error("❌ Erro ao registrar evento PDF:", insertError);
} else {
  console.log("✅ Evento de visualização de PDF registrado com sucesso!");
}
```
- Se houve erro, registra no console
- Se foi sucesso, confirma no console

### 5. Tratamento de Erros
```typescript
} catch (error: any) {
  console.error("❌ Erro ao registrar evento de PDF:", error);
  // Não interrompe o fluxo se falhar ao registrar
}
```
- Captura qualquer erro inesperado
- **Importante:** Não interrompe o fluxo principal
- O PDF ainda é gerado mesmo se falhar o registro

---

## 🔗 INTEGRAÇÃO NA handleGeneratePDF

```typescript
const handleGeneratePDF = async () => {
  // ... validações ...
  
  // 1. Primeira vez: Salvar plano se ainda não foi salvo
  let currentPlanoId = planoSalvoId;
  if (!currentPlanoId) {
    console.log("Salvando plano antes de gerar PDF...");
    currentPlanoId = await handleFinalSend();
    if (!currentPlanoId) throw new Error("Falha ao salvar plano");
  }

  // 2. NOVA LINHA: Registrar evento de visualização/download
  console.log("📝 Registrando evento de visualização de PDF...");
  await recordPdfViewEvent(currentPlanoId);

  // 3. Abrir diálogo de impressão
  console.log("Abrindo diálogo de impressão...");
  setTimeout(() => {
    window.print();
  }, 500);

  alert('✅ Plano salvo com sucesso!\n\nAgora você pode salvar como PDF...');
};
```

---

## ✅ VERIFICAÇÃO

Para verificar que o código foi implementado corretamente:

1. Procure no App.tsx por: `recordPdfViewEvent`
2. Deve aparecer uma função com esse nome
3. A função estará sendo chamada em `handleGeneratePDF`
4. Procure por: `await recordPdfViewEvent(currentPlanoId);`

Se tudo está certo, você verá:
- Função definida
- Sendo chamada com `currentPlanoId`
- Antes de `window.print()`

---

## 🧪 TESTE

### Console do Navegador (F12 → Console)
Quando você clica em "Visualizar PDF", deve ver:

```
📝 Registrando evento de visualização de PDF...
✅ Evento de visualização de PDF registrado com sucesso!
```

Ou em caso de erro:
```
❌ Erro ao registrar evento PDF: ...mensagem de erro...
```

---

## 📊 DADOS INSERIDOS NO BANCO

Cada execução insere um registro assim:

```sql
INSERT INTO public.pdf_download_history (
  plano_id, 
  user_id, 
  downloaded_at,  -- automático
  action_type,    -- 'view_pdf'
  user_email, 
  user_name,
  numero_emenda,
  parlamentar,
  valor_total
) VALUES (
  '550e8400-e29b-41d4-a716-446655440000',
  '662312a1-1234-5678-abcd-ef1234567890',
  '2026-02-27 14:35:22.123456+00',
  'view_pdf',
  'afpereira@example.com',
  'AFP Pereira',
  '123/2026',
  'João da Silva',
  50000.00
);
```

---

## 🎯 FLUXO COMPLETO

```
1. Usuário clica em "Visualizar e Baixar PDF"
   ↓
2. handleGeneratePDF() é chamada
   ↓
3. Valida campos obrigatórios
   ↓
4. Salva plano se não foi salvo
   ↓
5. 🆕 Chama recordPdfViewEvent(currentPlanoId)
   ↓
6. recordPdfViewEvent():
   - Obtém usuário autenticado
   - Busca dados do plano
   - Insere em pdf_download_history
   - Retorna com sucesso ou erro registrado
   ↓
7. window.print() abre diálogo de impressão
   ↓
8. Usuário pode salvar como PDF
```

---

## 💡 NOTA IMPORTANTE

A função `recordPdfViewEvent` é chamada com `await`, mas **não interrompe o fluxo se falhar**:

- ✅ Se funcionar: registra no banco
- ✅ Se não logado: apenas avisa no console
- ✅ Se erro no banco: registra erro mas PDF continua
- ✅ Se erro de rede: não impede de abrir print

Assim o usuário nunca fica impedido de gerar o PDF por falha do registro.

---

## 📚 REFERÊNCIA RÁPIDA

| O que | Onde | Função |
|------|------|--------|
| Nova Função | App.tsx, antes de `handleGeneratePDF` | `recordPdfViewEvent` |
| Chamada | Dentro de `handleGeneratePDF` | `await recordPdfViewEvent(...)` |
| Tabela | Supabase → `pdf_download_history` | Armazena registros |
| Console | F12 → Console | Mostra sucesso/erro |

