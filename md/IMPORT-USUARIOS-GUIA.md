# Como Importar Usuários para o Supabase

## Opção 1: Script Node.js (Recomendado)

### Pré-requisitos:
- Node.js 14+
- Chave de Serviço (Service Role Key) do Supabase

### Passo a passo:

1. **Obtenha a Chave de Serviço:**
   - Acesse https://app.supabase.com
   - Selecione seu projeto
   - Vá para Settings → API
   - Copie a `service_role key` (a chave com acesso total)

2. **Configure a variável de ambiente:**

   **No Windows (PowerShell):**
   ```powershell
   $env:SUPABASE_SERVICE_ROLE_KEY = "sua_chave_aqui"
   ```

   **No Windows (CMD):**
   ```cmd
   set SUPABASE_SERVICE_ROLE_KEY=sua_chave_aqui
   ```

   **No Linux/Mac:**
   ```bash
   export SUPABASE_SERVICE_ROLE_KEY="sua_chave_aqui"
   ```

   **Ou crie um arquivo `.env.local`:**
   ```
   SUPABASE_SERVICE_ROLE_KEY=sua_chave_aqui
   ```

3. **Execute o script:**

   ```bash
   node scripts/import-users.js usuarios.csv
   ```

## Opção 2: Script SQL (Alternativa)

Se você quiser criar os usuários diretamente usando SQL, execute no console do Supabase:

```sql
-- Substituir pelos dados reais
SELECT auth.uid() as admin_id;

-- Criar usuários via função RPC
SELECT 
  email,
  full_name,
  cnes
FROM (
  VALUES
    ('institutobezerra.adm@gmail.com', 'CÉLIA LUZIA HONORATO CAVALHERI', '2084384'),
    ('convenios@therezaperlatti.com.br', 'MARCELO HENRIQUE BARBIERI', '2790653'),
    -- ... adicionar todos os usuários
) as users(email, full_name, cnes);
```

## Opção 3: Dashboard Supabase

1. Acesse https://app.supabase.com
2. Selecione seu projeto
3. Vá para Authentication → Users
4. Clique em "Add user"
5. Preencha Email e Password
6. Após criar, edite o usuário para adicionar User Metadata (CNES, nome completo, etc.)

## Estrutura do CSV Esperada

O arquivo deve ter o seguinte formato:

```
Nome completo;E-mail;CNES;Senha inicial
CÉLIA LUZIA HONORATO CAVALHERI;institutobezerra.adm@gmail.com;2084384;2084384
MARCELO HENRIQUE BARBIERI;convenios@therezaperlatti.com.br;2790653;2790653
```

**Campos obrigatórios:**
- Nome completo
- E-mail (deve ser válido)
- CNES (pode estar vazio, será armazenado em metadados)
- Senha inicial (será usada como senha padrão)

## Dados Armazenados no Supabase

Os seguintes dados serão armazenados:

- **auth.users** (tabela de autenticação):
  - email
  - password (criptografada)
  - user_metadata: { full_name, cnes }

- **public.profiles** (se existir):
  - id (uid do usuário)
  - email
  - full_name
  - cnes
  - role (padrão: 'user')
  - created_at

## Troubleshooting

### "SUPABASE_SERVICE_ROLE_KEY não está definido"
- Verifique se definiu a variável de ambiente corretamente
- Use `echo $SUPABASE_SERVICE_ROLE_KEY` para confirmar

### "Email inválido"
- Verifique o formato do email no CSV
- O email deve conter @ e um domínio válido

### "Erro ao criar usuário: User already exists"
- O usuário já foi criado anteriormente
- Delete o usuário no dashboard ou use outro email

### "401 Unauthorized"
- A chave de serviço está incorreta ou expirou
- Gere uma nova chave no dashboard

## Segurança

⚠️ **IMPORTANTE:**
- Nunca compartilhe sua `service_role key`
- Ella tem acesso completo ao banco de dados
- Use apenas em scripts confiáveis
- Não commite a chave no Git (use `.env.local` ou variáveis de ambiente)

## Verificar Resultado

Após a importação, verifique no Supabase:

```sql
-- Contar usuários criados
SELECT COUNT(*) as total_users FROM auth.users;

-- Listar usuários criados
SELECT 
  id,
  email,
  user_metadata ->> 'full_name' as full_name,
  user_metadata ->> 'cnes' as cnes,
  created_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 30;
```

## Próximos Passos

1. Solicite aos usuários que troquem sua senha no primeiro login
2. Configure o 2FA (autenticação de dois fatores) se necessário
3. Defina os roles/permissões de cada usuário
4.  Configure a política de RLS (Row Level Security) para acesso aos dados
