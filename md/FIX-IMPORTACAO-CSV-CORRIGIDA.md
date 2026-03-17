# ✅ FIX: Importar Usuários em Lote via CSV - VERSÃO CORRIGIDA

## 🔧 Problema Anterior
O erro `Could not find the function` ocorria porque:
- ❌ A RPC esperava parâmetros em ordem específica
- ❌ Supabase teve problemas ao mapear os parâmetros

## ✅ Solução Implementada
- ✅ Nova RPC que recebe um objetos JSON com todos os dados
- ✅ Muito mais simples e confiável
- ✅ Sem problemas de ordem de parâmetros

## 📋 Passos para Corrigir

### ✅ PASSO 1: Limpar as RPC antigas no Supabase

1. Abra: https://app.supabase.com
2. Vá para **SQL Editor** → **New query**
3. Execute este comando:

```sql
DROP FUNCTION IF EXISTS public.criar_usuario_individual(TEXT, TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.criar_usuarios_em_lote(JSONB) CASCADE;
SELECT 'Funções antigas removidas!' as resultado;
```

4. Clique **"Run"** e aguarde conclusão

### ✅ PASSO 2: Executar a RPC Corrigida

1. Abra o arquivo: **`CREATE-RPC-CRIAR-USUARIO-INDIVIDUAL-CORRIGIDO.sql`**
2. Copie **TODO** o conteúdo
3. Vá para **SQL Editor** → **"New query"** (no Supabase)
4. Cole o SQL
5. Clique **"Run"** (botão verde)
6. Aguarde: `RPC Function criar_usuario_individual (versão JSON) criada com sucesso!`

### ✅ PASSO 3: Teste a Importação

No seu sistema:
1. Vá para **Gerenciamento de Usuários**
2. Clique em **"Carregar CSV"**
3. Selecione **`Pasta3.csv`**
4. Confirme
5. Aguarde ✅

## 🎯 O que mudou

### Antes (❌ Não funcionava):
```javascript
await supabase.rpc('criar_usuario_individual', {
  p_email: usuario.email,      // Parâmetros
  p_senha: usuario.senha,      // em ordem
  p_nome: usuario.nome,        // incorreta
  p_cnes: usuario.cnes
});
```

### Agora (✅ Funciona):
```javascript
await supabase.rpc('criar_usuario_individual', {
  p_usuario: usuario  // Tudo em um objeto JSON
});
```

### SQL (✅ Nova abordagem):
```sql
CREATE OR REPLACE FUNCTION criar_usuario_individual(p_usuario JSON)
RETURNS JSON AS $$
  v_email := p_usuario ->> 'email';
  v_senha := p_usuario ->> 'senha';
  v_nome := p_usuario ->> 'nome';
  v_cnes := p_usuario ->> 'cnes';
  -- ... resto do código
```

## ✨ Resultado Esperado

```
✅ Importação concluída!

Total processado: 13
Criados: 13
Erros: 0
```

## 🆘 Se ainda der erro

### ❌ "Could not find the function"
**Solução:** Você não executou o PASSO 2. Execute o arquivo `CREATE-RPC-CRIAR-USUARIO-INDIVIDUAL-CORRIGIDO.sql`

### ❌ "Usuario com este email já existe"
**Solução:** Um dos emails já foi criado em um teste anterior. Limpe o CSV e use emails novos.

### ✅ Tudo OK?
Se os 13 usuários foram criados com sucesso:
- ✅ Vá para "Gerenciamento de Usuários"
- ✅ Os 13 novos usuários devem aparecer na lista
- ✅ Eles conseguem fazer login com email + CNES (que foi a senha)

---

**Resumo:**
1. Execute o SQL `CREATE-RPC-CRIAR-USUARIO-INDIVIDUAL-CORRIGIDO.sql` no Supabase
2. Clique "Carregar CSV" e selecione `Pasta3.csv`
3. Pronto! ✅

