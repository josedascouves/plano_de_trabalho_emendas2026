# 🚀 Guia de Importação - Passo a Passo

## ❌ Problema Identificado

O trigger automático em `profiles` está falhando, impedindo a criação de usuários. Solução é simples!

---

## ✅ Solução em 3 Passos

### **Passo 1: Desabilitar o Trigger** (2 min)

1. Acesse: https://app.supabase.com
2. Vá para: **SQL Editor**
3. Clique em **New Query**
4. Copie e cole o conteúdo de:
   ```
   scripts/PREPARAR-ANTES-DE-IMPORTAR.sql
   ```
5. Clique em **Run** (Ctrl+Enter)
6. Aguarde a mensagem "Query executed successfully"

**O que faz:** Remove o trigger que estava causando erro

---

### **Passo 2: Importar Usuários** (3-5 min)

Execute no PowerShell ou Terminal:

```powershell
$env:SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRscG1zcGZuc3dheHdxem13c2tpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDMwMDk1OCwiZXhwIjoyMDg1ODc2OTU4fQ.enjDo9Ob3SwsINnUenmXos81XYf1WE-Bpm_NsG4G-ys"

cd "c:\Users\afpereira\Downloads\Plano de trabalho Emendas\plano-de-trabalho-ses-sp-2026"

python scripts/import_users_simple.py "c:\Users\afpereira\Downloads\usuarios.csv" --auto
```

**O que faz:** Cria todos os 26 usuários válidos (3 com emails inválidos serão pulados)

---

### **Passo 3: Sincronizar Profiles e Reabilitar Trigger** (2 min)

1. No SQL Editor do Supabase
2. Vá até a parte do script que diz:
   ```sql
   -- ==============================================================================
   -- RECRIAR TRIGGER (após usuários serem criados)
   -- ==============================================================================
   ```
3. Selecione TODO O CÓDIGO a partir desse ponto até o final
4. Clique em **Run**

**O que faz:** 
- Sincroniza os dados em `profiles`
- Reabilita o trigger para novos usuários

---

## 📊 Resultado Esperado

```
📊 Resultado Final:
   ✅ Criados: 26
   ❌ Erros: 0
🎉 Importação concluída com sucesso!
```

---

## ✔️ Verificar Se Funcionou

No SQL Editor, execute:

```sql
SELECT COUNT(*) as total_users FROM auth.users;
SELECT COUNT(*) as total_profiles FROM public.profiles;

SELECT 
  email,
  user_metadata ->> 'full_name' as full_name,
  user_metadata ->> 'cnes' as cnes,
  created_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 10;
```

---

## 🔥 Resumo Dos Usuários

- ✅ **26 usuários** serão criados com sucesso
- ⚠️ **3 usuários** com emails inválidos (múltiplos emails):
  - DORION DENARDI E EBENÉZER NUNES MARQUES (linha 15)
  - DORION DENARDI / EBENÉZER NUNES MARQUES (linha 16)  
  - RAQUEL DOS SANTOS FIALHO RIBEIRO (linha 28)

> **Dica:** Se precisar desses 3 usuários, edite o CSV deixando apenas um email por linha

---

## 💾 Segurança

⚠️ **Apague a chave após terminar:**

```powershell
$env:SUPABASE_SERVICE_ROLE_KEY = ""
```

Ou melhor ainda, **gere uma nova chave** no Supabase para invalidar essa.

---

## 📞 Suporte

Se encontrar erro:
1. Verifique o arquivo de erro no terminal
2. Execute novamente o **Passo 1** para resetar
3. Tente o **Passo 2** novamente

**Erro comum:**
```
Database error creating new user
```
→ Execute novamente o **Passo 1**
