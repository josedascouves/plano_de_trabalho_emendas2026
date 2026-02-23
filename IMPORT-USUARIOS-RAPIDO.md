# ⚡ Guia Rápido: Importar Usuários no Supabase

## 📋 Você tem 3 opções:

### Opção 1: Python (Mais Fácil) ⭐
```bash
# 1. Defina a chave de serviço
set SUPABASE_SERVICE_ROLE_KEY=sb_xxxxxxxxxxxxxx

# 2. Instale requests
pip install requests

# 3. Execute o script
python scripts/import_users.py usuarios.csv
```

### Opção 2: Node.js (Se preferir)
```bash
# 1. Defina a chave de serviço
set SUPABASE_SERVICE_ROLE_KEY=sb_xxxxxxxxxxxxxx

# 2. Execute o script
node scripts/import-users.js usuarios.csv
```

### Opção 3: SQL Direto (Rápido mas Manual)
```bash
# 1. Acesse: https://app.supabase.com
# 2. Vá para: SQL Editor
# 3. Cole o conteúdo de: scripts/create-users.sql
# 4. Execute
# 5. Crie usuários manualmente no Dashboard Authentication → Users
```

---

## 🔐 Onde Obter a Chave de Serviço?

1. Acesse [https://app.supabase.com](https://app.supabase.com)
2. Selecione seu projeto
3. Vá para **Settings** → **API**
4. Copie a **service_role key** (aquela com "sb_" no começo)
5. Use no comando acima

---

## 📊 Arquivos Gerados

```
scripts/
├── import-users.js        # Script Node.js
├── import_users.py        # Script Python
└── create-users.sql       # Script SQL

IMPORT-USUARIOS-GUIA.md    # Guia detalhado
IMPORT-USUARIOS-RAPIDO.md  # Este arquivo
```

---

## ✅ Verificar Resultado

Após importar, execute no SQL Editor do Supabase:

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

---

## ⚠️ Erros Comuns

| Erro | Solução |
|------|---------|
| "SUPABASE_SERVICE_ROLE_KEY não definido" | Defina a variável de ambiente |
| "User already exists" | O usuário já foi criado, delete primeiro |
| "401 Unauthorized" | A chave está incorreta |
| "Encoding error" | O CSV não está em UTF-8, tente Latin-1 |

---

## 🚀 Próximos Passos

1. ✅ Importar usuários
2. 📧 Solicitar mudança de senha no primeiro login
3. 🔐 Configurar 2FA (opcional)
4. 👥 Definir roles/permissões
5. 🛡️ Testar políticas de RLS

---

## 📞 Suporte

Para mais detalhes, veja [IMPORT-USUARIOS-GUIA.md](./IMPORT-USUARIOS-GUIA.md)
