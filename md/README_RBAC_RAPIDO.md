# ⚡ Início Rápido - RBAC

## 🚀 3 Passos para Funcionar

### PASSO 1: Executar SQL
```sql
-- Copie TODO o conteúdo de: setup-rbac-completo.sql
-- Cole no Supabase > SQL Editor > New Query
-- Clique em "Run"
```

### PASSO 2: Criar Primeiro Admin
```sql
-- Substitua UUID_AQUI e dados reais
INSERT INTO profiles (id, role, full_name, email, created_at)
VALUES ('UUID_AQUI', 'admin', 'Seu Nome', 'seu@email.com', now())
ON CONFLICT (id) DO UPDATE SET role = 'admin';
```

### PASSO 3: Integrar no React
```tsx
// Em App.tsx
import UserManagement from './components/UserManagement';

// Copie o arquivo: components/UserManagement.tsx
```

## 📦 Arquivos Criados

1. **setup-rbac-completo.sql** - Script SQL completo (execute PRIMEIRO!)
2. **types.ts** - Tipos TypeScript (já atualizado)
3. **components/UserManagement.tsx** - Componente React
4. **SISTEMA_RBAC_COMPLETO.md** - Documentação completa
5. **RBAC_IMPLEMENTACAO.md** - Guia detalhado
6. **EXEMPLO_INTEGRACAO.md** - Exemplos de código
7. **TESTES_RBAC.sql** - Suite de testes
8. **README_RAPIDO.md** - Este arquivo

## ✅ O Que Foi Implementado

### Tabelas
- ✅ `profiles` - Usuários com RBAC
- ✅ `audit_logs` - Histórico de ações

### Funções SQL (7)
- ✅ `promote_user_to_admin()`
- ✅ `demote_admin_to_user()`
- ✅ `reset_user_password()`
- ✅ `change_user_password_admin()`
- ✅ `change_own_password()`
- ✅ `toggle_user_status()`
- ✅ `delete_user_admin()`

### Segurança
- ✅ Políticas RLS (Row Level Security)
- ✅ Proteção do último admin
- ✅ Dupla confirmação para deletar
- ✅ Auditoria completa
- ✅ DEFINER functions com validações

### Interface React
- ✅ Listagem com busca/filtro/ordenação
- ✅ Modais para operações
- ✅ Estatísticas em tempo real
- ✅ Histórico de auditoria
- ✅ Dashboard completo

## 🎯 Papéis

### 👨‍💼 Admin pode:
- Criar usuários
- Editar qualquer um
- Alterar senhas
- Promover/rebaixar
- Ativar/desativar
- Deletar usuários
- Ver histórico

### 👤 User padrão pode:
- Editar seus dados
- Mudar sua senha
- ❌ Tudo mais é bloqueado

## 🔒 Proteções

```
✓ Não pode rebaixar o único admin
✓ Não pode desativar o único admin ativo
✓ Não pode deletar a si mesmo
✓ Não pode alterar seu próprio role
✓ RLS bloqueia acesso não autorizado
✓ Todos os logs são auditados
```

## 📊 Tabela de Ações

| Ação | Admin | User |
|------|-------|------|
| Criar usuário | ✓ | ✗ |
| Editar qualquer um | ✓ | ✗ |
| Editar si mesmo | ✓ | ✓ |
| Alterar senha outro | ✓ | ✗ |
| Alterar própria senha | ✓ | ✓ |
| Reset senha | ✓ | ✗ |
| Promover | ✓ | ✗ |
| Rebaixar | ✓ | ✗ |
| Desativar | ✓ | ✗ |
| Deletar | ✓ | ✗ |
| Ver logs | ✓ (todos) | ✓ (seus) |

## 🧪 Testar

1. Execute `TESTES_RBAC.sql` no Supabase SQL Editor
2. Cada teste tem instruções
3. Todos devem passar ✓

## 📚 Documentação Completa

- [SISTEMA_RBAC_COMPLETO.md](SISTEMA_RBAC_COMPLETO.md) - Visão geral
- [RBAC_IMPLEMENTACAO.md](RBAC_IMPLEMENTACAO.md) - Guia técnico
- [EXEMPLO_INTEGRACAO.md](EXEMPLO_INTEGRACAO.md) - Como integrar

## 🚨 Se algo quebrar

### Erro: "Only admins can..."
```
→ Usuário não é admin
→ Execute: UPDATE profiles SET role='admin' WHERE id='uuid';
```

### Erro: "Cannot demote the last admin"
```
→ É o único admin
→ Solução: Promova outro primeiro
```

### Erro: RLS Policy
```
→ Políticas não aplicadas
→ Ações: Re-execute o script SQL
```

## ☑️ Checklist

- [ ] Executar setup-rbac-completo.sql
- [ ] Criar primeiro admin
- [ ] Copiar types.ts
- [ ] Copiar UserManagement.tsx
- [ ] Importar em App.tsx
- [ ] Testar login admin
- [ ] Testar criar usuário
- [ ] Testar alterar perfil
- [ ] Testar alterar senha
- [ ] Testar histórico
- [ ] Deploy ✓

## 🎓 Próximos Passos

1. Integrar com Email (enviar senhas temporárias)
2. Adicionar 2FA (autenticação dupla)
3. Rate limiting (proteção força bruta)
4. Backup automático
5. Dashboard de análise

## 📞 Suporte

Revise os arquivos de documentação se tiver dúvidas:
- SISTEMA_RBAC_COMPLETO.md
- RBAC_IMPLEMENTACAO.md
- EXEMPLO_INTEGRACAO.md

---

**Versão**: 1.0  
**Status**: ✅ Pronto para Deploy  
**Data**: 2026-02-12  

Para documentação completa, veja SISTEMA_RBAC_COMPLETO.md
