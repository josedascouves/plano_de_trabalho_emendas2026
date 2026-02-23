# 📦 Importador de Usuários - Supabase

Script completo para importar usuários do CSV para o Supabase em 3 cliques!

## 🚀 Quick Start (Windows)

```bash
# 1. Obtenha a chave do Supabase (https://app.supabase.com → Settings → API)

# 2. Clique 2x em:
#    import-usuarios.bat

# 3. Cole o arquivo CSV ou o caminho
```

## 📋 Opções Disponíveis

### Windows
```bash
# Via GUI (recomendado)
import-usuarios.bat usuarios.csv

# Via Command Prompt
set SUPABASE_SERVICE_ROLE_KEY=sb_xxxxx
python scripts/import_users.py usuarios.csv
```

### Linux/Mac
```bash
chmod +x import-usuarios.sh
./import-usuarios.sh usuarios.csv
```

### Node.js (Novo)
```bash
set SUPABASE_SERVICE_ROLE_KEY=sb_xxxxx
node scripts/import-users.js usuarios.csv
```

## 📁 Arquivos Criados

```
projeto/
├── import-usuarios.bat              # ⭐ Importador para Windows
├── import-usuarios.sh               # ⭐ Importador para Linux/Mac
│
├── scripts/
│   ├── import-users.js              # Script Node.js
│   ├── import_users.py              # Script Python
│   └── create-users.sql             # Script SQL
│
├── IMPORT-USUARIOS-RAPIDO.md        # Guia rápido
├── IMPORT-USUARIOS-GUIA.md          # Guia detalhado
└── README-USUARIOS.md               # Este arquivo
```

## 🔐 Como Obter a Chave de Serviço?

1. Acesse [https://app.supabase.com](https://app.supabase.com)
2. Selecione seu projeto
3. Vá para **Settings** → **API**
4. Copie a **service_role key** (começa com `sb_`)
5. Use no script

⚠️ **IMPORTANTE**: Nunca compartilhe essa chave! Ela tem acesso total ao banco.

## 📊 Formato do CSV Esperado

```
Nome completo;E-mail;CNES;Senha inicial
JOÃO SILVA;joao@exemplo.com.br;2077485;2077485
MARIA SANTOS;maria@exemplo.com.br;2084384;2084384
```

**Campos:**
- `Nome completo` - Nome do usuário (obrigatório)
- `E-mail` - Email válido (obrigatório)
- `CNES` - Código CNES (opcional)
- `Senha inicial` - Senha padrão (usará CNES se vazio)

## ✅ O Que Será Criado

- ✅ Usuário no Auth (com email e senha)
- ✅ User metadata com nome completo e CNES
- ✅ Perfil de usuário (tabela profiles se existir)
- ✅ Timestamp de criação

## 🔍 Verificar Resultado

### Via Dashboard
1. Acesse: https://app.supabase.com
2. Vá para: Authentication → Users
3. Veja os novos usuários criados

### Via SQL
```sql
SELECT 
  email,
  user_metadata ->> 'full_name' as nome,
  user_metadata ->> 'cnes' as cnes,
  created_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 30;
```

## ⚠️ Erros Comuns e Soluções

| Erro | Solução |
|------|---------|
| `Python não encontrado` | Instale em https://www.python.org/downloads/ |
| `requests not found` | Execute: `pip install requests` |
| `SUPABASE_SERVICE_ROLE_KEY não definido` | Defina a variável de ambiente |
| `401 Unauthorized` | Chave incorreta, gere uma nova no dashboard |
| `User already exists` | Usuário já foi criado, delete ou use outro email |
| `Encoding error` | CSV não está em UTF-8, salve como UTF-8 |

## 🛠️ Troubleshooting

### Script não funciona no Windows?
```powershell
# Abra PowerShell como Admin e execute:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Precisa atualizar Python?
```bash
python -m pip install --upgrade pip requests
```

### Verificar se Python está instalado
```bash
python --version
```

## 📚 Arquivos de Documentação

- [IMPORT-USUARIOS-RAPIDO.md](./IMPORT-USUARIOS-RAPIDO.md) - Guia resumido
- [IMPORT-USUARIOS-GUIA.md](./IMPORT-USUARIOS-GUIA.md) - Guia completo com detalhes
- [scripts/create-users.sql](./scripts/create-users.sql) - Operações SQL complementares

## 🔄 Próximos Passos (Pós Importação)

1. **Solicitar Mudança de Senha**
   - Envie email aos usuários solicitando mudança na primeira login

2. **Configurar 2FA** (Opcional)
   - Ative autenticação de dois fatores para mais segurança

3. **Definir Permissões**
   - Configure roles (admin/user) para cada usuário
   - Implemente políticas de RLS (Row Level Security)

4. **Testar Acesso**
   - Verifique se os usuários conseguem fazer login
   - Teste as permissões de cada role

## 🎯 Dicas Úteis

### Importar dados de um banco antigo
```bash
# Exporte para CSV
SELECT CONCAT(full_name, ';', email, ';', cnes, ';', initial_password)
FROM old_users

# Depois use este script
python scripts/import_users.py exported_data.csv
```

### Fazer backup dos usuários criados
```bash
# Exporte do Supabase
SELECT email, user_metadata, created_at
FROM auth.users
ORDER BY created_at DESC
```

### Deletar usuários criados por engano
⚠️ **Cuidado!** Isso é irreversível!
```sql
DELETE FROM auth.users 
WHERE created_at > now() - interval '1 hour'
```

## 📞 Suporte

Para problemas ou dúvidas:
1. Verifique o arquivo [IMPORT-USUARIOS-GUIA.md](./IMPORT-USUARIOS-GUIA.md)
2. Consulte a documentação do Supabase: https://supabase.com/docs
3. Verifique os logs no dashboard do Supabase

## 📝 Licença

Livre para usar e modificar. Use por sua conta e risco.

---

**Última atualização:** Fevereiro 2026
**Versão:** 1.0
