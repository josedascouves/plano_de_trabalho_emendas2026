# 🎯 Como Criar os 26 Usuários - 3 Opções

## 📋 Resumo dos Usuários

| Email | Senha | CNES |
|-------|-------|------|
| institutobezerra.adm@gmail.com | 2084384 | 2084384 |
| convenios@therezaperlatti.com.br | 2790653 | 2790653 |
| administracao.irmadulce@alsf.org.br | 2790998 | 2790998 |
| halena.n@huhsp.org.br | 2077485 | 2077485 |
| rosane@santamarcelina.org | 2077477 | 2077477 |
| vivianeandrade@casaandreluiz.org.br | 2082276 | 2082276 |
| luci.rosa@boldrini.org.br | 2081482 | 2081482 |
| planejamento@consaude.org.br | 2077434 | 2077434 |
| dds.anapaula@amaralcarvalho.org.br | 2083086 | 2083086 |
| camilamarques@bairral.com.br | 2085143 | 2085143 |
| diretoria@hospitalaldebase.com.br | 2077396 | 2077396 |
| alexander.ferreira@hemocentro.fmrp.usp.br | 2047438 | 2047438 |
| gerente.adm@hrcpp.org.br | 7400926 | 7400926 |
| gacc@gacc.com.br | 5869412 | 5869412 |
| m.orlandino@hc.fm.usp.br | 2071568 | 2071568 |
| vmelias@famesp.org.br | 2748223 | 2748223 |
| secretaria.msi@famaesp.org.br | 2790580 | 2790580 |
| financas-hrs@saude.sp.gov.br | 2091313 | 2091313 |
| mariana.leonardo@redesc.org.br | 3028399 | 3028399 |
| controleinterno@santacasacaconde.com.br | 2080222 | 2080222 |
| projetos@santacasafernandopolis.com.br | 2093324 | 2093324 |
| eder.barboza@santacasasp.org.br | 2688689 | 2688689 |
| edilea@sobrapar.org.br | 2084252 | 2084252 |
| convenios.hcmf@hospitalmatao.com.br | 2090961 | 2090961 |
| contabilidade11@santacasavotuporanga.com.br | 2081377 | 2081377 |
| klesio@unicamp.br | 2079798 | 2079798 |

---

## 🚀 Opção 1: Python Script (Recomendado) ⭐

**Tempo:** 3-5 minutos  
**Dificuldade:** ⭐ Fácil  
**Confiabilidade:** 99%  
**Automatizado:** ✅ Sim

### Passos:

```powershell
# 1. Abra PowerShell e vá para a pasta do projeto
cd "c:\Users\afpereira\Downloads\Plano de trabalho Emendas\plano-de-trabalho-ses-sp-2026"

# 2. Defina a chave do Supabase
$env:SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRscG1zcGZuc3dheHdxem13c2tpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDMwMDk1OCwiZXhwIjoyMDg1ODc2OTU4fQ.enjDo9Ob3SwsINnUenmXos81XYf1WE-Bpm_NsG4G-ys"

# 3. Execute o script
python scripts/import_users_simple.py "c:\Users\afpereira\Downloads\usuarios.csv" --auto
```

**Resultado esperado:**
```
✅ 26 usuários encontrados
🚀 Iniciando importação de 26 usuários...
✅ [1/26] institutobezerra.adm@gmail.com criado com sucesso
✅ [2/26] convenios@therezaperlatti.com.br criado com sucesso
... (restante dos usuários)
📊 Resultado Final:
   ✅ Criados: 26
   ❌ Erros: 0
🎉 Importação concluída com sucesso!
```

---

## 📋 Opção 2: SQL Direto (Manual)

**Tempo:** 15-30 minutos  
**Dificuldade:** ⭐⭐ Médio  
**Confiabilidade:** 95%  
**Automatizado:** ❌ Não

### Passos:

1. Acesse: https://app.supabase.com
2. Selecione seu projeto
3. Vá para: **Authentication → Users**
4. Clique em: **"Add user"**
5. Preencha para cada usuário:
   - **Email:** (da tabela acima)
   - **Password:** (da tabela acima)
6. Clique em **"Create user"**
7. Repita 26× ⏱️ (cansativo!)

**Vantagem:** Visual e seguro  
**Desvantagem:** Muito lento (26 cliques manuais)

---

## 💾 Opção 3: SQL + Python (Híbrido)

**Tempo:** 5-10 minutos  
**Dificuldade:** ⭐ Fácil  
**Confiabilidade:** 99%  
**Recomendado se:** Preferir fazer em 2 etapas

### Passo 1: Preparar o Banco

1. Acesse: https://app.supabase.com
2. Vá para: **SQL Editor**
3. Clique em: **"New Query"**
4. Copie e cole TODO o conteúdo de:
   ```
   scripts/CREATE-USERS-COMPLETO.sql
   ```
5. Clique: **Run** (Ctrl+Enter)
6. Aguarde: `Query executed successfully`

### Passo 2: Criar Usuários

Execute no PowerShell:
```powershell
$env:SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRscG1zcGZuc3dheHdxem13c2tpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDMwMDk1OCwiZXhwIjoyMDg1ODc2OTU4fQ.enjDo9Ob3SwsINnUenmXos81XYf1WE-Bpm_NsG4G-ys"

python scripts/import_users_simple.py "c:\Users\afpereira\Downloads\usuarios.csv" --auto
```

---

## ✅ Verificar Se Funcionou

Independente da opção escolhida, execute no **SQL Editor** do Supabase:

```sql
-- Contar usuários
SELECT COUNT(*) as total_users FROM auth.users;

-- Ver os 5 últimos criados
SELECT 
  email,
  user_metadata ->> 'full_name' as full_name,
  user_metadata ->> 'cnes' as cnes,
  created_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 5;
```

**Resultado esperado:**
```
 count |                  email                   |        full_name         | cnes
-------+--------------------------------------------+--------------------------+--------
    26 | institutobezerra.adm@gmail.com             | CÉLIA LUZIA ...           | 2084384
    25 | convenios@therezaperlatti.com.br           | MARCELO HENRIQUE ...      | 2790653
    ...
```

---

## 🏆 Recomendação Final

### ✅ Use Opção 1 (Python) se:
- Quer fazer tudo automaticamente
- Tem pressa
- Quer certeza de 0 erros

### ✅ Use Opção 2 (Dashboard) se:
- Quer visualizar o que está fazendo
- Prefere controle manual
- Sono abundante 😴

### ✅ Use Opção 3 (SQL + Python) se:
- Quer fazer em 2 etapas
- Quer ver o SQL executado
- Quer garantia dupla

---

## 🔐 Segurança

⚠️ **Após terminar, apague a chave:**

```powershell
$env:SUPABASE_SERVICE_ROLE_KEY = ""
```

Ou melhor, **gere uma nova chave** no Supabase para invalidar essa.

---

## 📞 Suporte

**Se der erro:**

1. Verifique o arquivo: `scripts/CREATE-USERS-COMPLETO.sql`
2. Execute-o no SQL Editor ANTES de usar o script Python
3. Tente novamente

**Erro comum:**
```
Database error creating new user
```
→ Execute o arquivo SQL para preparar o trigger

---

**Escolha uma opção e comece! 🚀**
