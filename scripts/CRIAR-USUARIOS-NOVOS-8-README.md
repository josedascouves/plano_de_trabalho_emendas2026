# Como Criar os 8 Novos Usuários no Supabase

## 📋 Usuários a Criar

| # | Nome | Email | CNES | Senha |
|---|------|-------|------|-------|
| 1 | GABRIEL LAMBERT BORGES | gabriel.borges@fajsaude.com.br | 2088495 | 2088495 |
| 2 | EVELYN FERNANDA DOS SANTOS | convenios2@ciprianoayla.com.br | 2089335 | 2089335 |
| 3 | ORIVAL ANDRIES JUNIOR | diretoriaoss@funcamp.unicamp.br | 2083981 | 2083981 |
| 4 | FERDINANDO BORRELLI JUNIOR | ferdinando.borrelli@oss.santamarcelina.org | 2078562 | 2078562 |
| 5 | MARIA DE LOURDES LACERDA FRANCO | lourdes.franco@hgp.spdm.org.br | 2079828 | 2079828 |
| 6 | KELLER RAFAELA CANUTO CASTRO | keller.castro@santacasajales.com.br | 2079895 | 2079895 |
| 7 | FERNANDA EUGENIO FERREIRA | dec@caism.unicamp.br | 2079798 | 2079798 |
| 8 | GABRIELA MORANDI DE ARAUJO | convenios@caism.unicamp.br | 2079798 | 2079798 |

---

## 🚀 OPÇÃO 1: Usar Python Script (RECOMENDADO - Mais Fácil)

### Passo 1: Copiar a Service Role Key

1. Acesse: **https://app.supabase.com**
2. Selecione seu projeto
3. Vá para: **Project Settings → API → Service Role**
4. Clique em "Copy" para copiar a chave

### Passo 2: Executar o Script

**Windows PowerShell:**

```powershell
# Opção A: Definir a chave como variável de ambiente
$env:SUPABASE_SERVICE_ROLE_KEY = "cole_a_chave_aqui"
python scripts/criar-usuarios-novos-8.py

# Opção B: Passar direto no comando (sem espaços!)
python scripts/criar-usuarios-novos-8.py --key "cole_a_chave_aqui"
```

**Mac/Linux Terminal:**

```bash
# Opção A: Definir a chave como variável
export SUPABASE_SERVICE_ROLE_KEY="cole_a_chave_aqui"
python3 scripts/criar-usuarios-novos-8.py

# Opção B: Passar direto
python3 scripts/criar-usuarios-novos-8.py --key "cole_a_chave_aqui"
```

### Resultado Esperado

```
================================================================================
🚀 CRIANDO 8 NOVOS USUÁRIOS NO SUPABASE
================================================================================

[1/8] Criando: GABRIEL LAMBERT BORGES (gabriel.borges@fajsaude.com.br)... ✅ OK
[2/8] Criando: EVELYN FERNANDA DOS SANTOS (convenios2@ciprianoayla.com.br)... ✅ OK
...
================================================================================
📊 RESUMO DA OPERAÇÃO
================================================================================

✅ Sucesso: 8/8
❌ Erros: 0/8
```

---

## 🔧 OPÇÃO 2: Criar Manualmente via Dashboard

Se preferir criar manualmente:

1. Acesse: **https://app.supabase.com**
2. Selecione seu projeto
3. Vá para: **Authentication → Users**
4. Clique em: **"Add user"**
5. Preencha para cada usuário:
   - Email: (do quadro acima)
   - Password: (do quadro acima)
6. Clique em: **"Create user"**
7. Repita para os 8 usuários

---

## ⚙️ PASSO 3: Sincronizar Dados (Importante!)

Depois que os usuários forem criados (seja via Python ou Dashboard):

1. Acesse: **https://app.supabase.com**
2. Selecione seu projeto
3. Vá para: **SQL Editor**
4. Clique em: **"New Query"**
5. Abra o arquivo: `CRIAR-USUARIOS-NOVOS-8.sql`
6. Cole TODO o conteúdo no editor
7. Clique em: **"Run"** (Ctrl+Enter)

Este script sincroniza:
- ✅ Full Name (Nome completo)
- ✅ CNES (Código da instituição)
- ✅ Role (Perfil: user)

---

## ✅ Verificar Sucesso

### Via Dashboard

1. Vá para: **Authentication → Users**
2. Procure pelos emails criados
3. Verifique se estão listados com status "Confirmed"

### Via SQL

Execute esta query no SQL Editor:

```sql
SELECT email, full_name, cnes, role, created_at
FROM public.profiles
WHERE email IN (
  'gabriel.borges@fajsaude.com.br',
  'convenios2@ciprianoayla.com.br',
  'diretoriaoss@funcamp.unicamp.br',
  'ferdinando.borrelli@oss.santamarcelina.org',
  'lourdes.franco@hgp.spdm.org.br',
  'keller.castro@santacasajales.com.br',
  'dec@caism.unicamp.br',
  'convenios@caism.unicamp.br'
)
ORDER BY created_at DESC;
```

---

## 🆘 Troubleshooting

### ❌ "Erro: Usuário já existe"
- O usuário foi criado anteriormente
- Nenhuma ação necessária, pode ignorar

### ❌ "SUPABASE_SERVICE_ROLE_KEY não definido"
- Você não passou a chave corretamente
- Copie novamente de: **Project Settings → API → Service Role**

### ❌ "Erro 401: Unauthorized"
- A chave está incorreta ou expirou
- Tente copiar novamente do Dashboard

### ❌ "Timeout ao conectar"
- Problema de rede
- Tente novamente em alguns segundos

### ❌ "Erro 500: Database error"
- Pode ser um problema com trigger na tabela profiles
- Execute o arquivo CREATE-USERS-COMPLETO.sql primeiro

---

## 📧 Próximas Ações

Após criar os usuários:

1. ✅ Usuários podem fazer login na plataforma
2. ✅ Verificar dados em: Dashboard → Authentication → Users
3. ✅ Atualizar planilha de rastreamento
4. ✅ Comunicar aos usuários suas credenciais (email já foi cadastrado, podem redefinir senha)

---

## 📞 Suporte

Arquivo de dados: `usuarios-novos-8.csv`
- Contém os mesmos 8 usuários em formato CSV
- Use se precisar importar em outro sistema

---

**Versão:** 1.0 | **Data:** Março 2026 | **Status:** Operacional ✅
