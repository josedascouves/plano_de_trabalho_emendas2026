# 🔧 GUIA DE CORREÇÃO - Erro 500 ao Buscar Perfil

## 📍 Problema
```
Failed to load resource: the server responded with a status of 500 ()
Erro ao buscar perfil: Object
```

## 🎯 Causa Provável
A tabela `profiles` não foi criada corretamente ou há conflito nas políticas RLS.

## ✅ Solução Passo-a-Passo

### Passo 1: Limpeza Completa
1. Abra Supabase Dashboard
2. Vá para: **SQL Editor** > **New Query**
3. **COPIE** todo o conteúdo de: `FIX-RBAC-ERRO-500.sql`
4. **COLE** na query
5. **SELECIONE** somente o PASSO 2 (a seção de limpeza)
6. Clique **Run** (ícone ▶️)
7. Aguarde conclusão

### Passo 2: Re-executar Setup Completo
1. **Nova Query** no SQL Editor
2. **COPIE** todo o conteúdo de: `setup-rbac-completo.sql` (O ARQUIVO CORRIGIDO)
3. **COLE** na query
4. Clique **Run**
5. Aguarde "Done"

### Passo 3: Criar Admin Inicial
1. No Supabase Dashboard, vá a: **Authentication** > **Users**
2. Procure por seu email/usuário
3. **Copie o ID** (UUID)
4. Nova Query com:
```sql
INSERT INTO public.profiles (id, role, full_name, email, created_at, updated_at)
VALUES (
  'COLE-UM-AQUI',  -- ← Copie do passo anterior
  'admin',
  'Seu Nome Completo',
  'seu@email.com',
  now(),
  now()
);
```
5. Clique **Run**

### Passo 4: Testar no Navegador
1. Recarregue http://localhost:3000 (ou seu URL)
2. F12 para abrir Console
3. Fazendo login, não deve mais aparecer erro 500

---

## 🐛 Se Ainda Não Funcionar

### Verificação 1: Tabela existe?
```sql
SELECT tablename FROM pg_tables 
WHERE schemaname = 'public' AND tablename IN ('profiles', 'audit_logs');
```
**Esperado**: 2 linhas

### Verificação 2: RLS habilitado?
```sql
SELECT tablename, rowsecurity FROM pg_tables 
WHERE schemaname = 'public' AND tablename IN ('profiles', 'audit_logs');
```
**Esperado**: `rowsecurity = true` para ambas

### Verificação 3: Políticas RLS?
```sql
SELECT policyname, tablename FROM pg_policies WHERE tablename = 'profiles';
```
**Esperado**: 6+ políticas

### Verificação 4: Seu admin existe?
```sql
SELECT id, role, full_name FROM public.profiles WHERE role = 'admin';
```
**Esperado**: Sua linha com role = 'admin'

---

## 🔄 Reset Nuclear (Última Opção)

Se nada funcionar:

1. Execute `FIX-RBAC-ERRO-500.sql` - **PASSO 2** (Limpeza Completa)
2. Aguarde conclusão
3. Execute `setup-rbac-completo.sql` novamente completamente
4. Crie admin manualmente (Passo 3 acima)
5. Recarregue página

---

## 📞 Debug Checklist

- [ ] Tabelas criadas (profiles e audit_logs)
- [ ] RLS habilitado em ambas
- [ ] 6+ políticas RLS em profiles
- [ ] 7 funções criadas (promote, demote, reset, etc)
- [ ] Admin criado em profiles
- [ ] Email do admin está na tabela
- [ ] UUID do admin é válido (não é NULL)
- [ ] Sem erros no SQL Editor (tudo com "Done")

---

## 📝 Logs da Página

Se tiver erro no console, compartilhe a mensagem COMPLETA:

```
Incluir em um relatório:
1. URL que estava tentando acessar
2. Erro completo do console (F12)
3. Response do erro 500 (F12 > Network)
4. Resultado de SELECT * FROM profiles LIMIT 1;
```

---

**Versão**: 1.0  
**Data**: 12/02/2026  

Se ainda tiver problema após estas etapas, o issue está em outro lugar do código (não no RBAC).
