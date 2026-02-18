# ❓ FAQ - Perguntas Frequentes

## 🎯 Perguntas sobre Implementação

### P: Por onde começar?
**R:** Execute os 3 passos do README_RBAC_RAPIDO.md:
1. Executar `setup-rbac-completo.sql`
2. Criar primeiro admin
3. Integrar `UserManagement.tsx` no App.tsx

### P: Quanto tempo leva para implementar?
**R:** 
- SQL: 5 minutos (copiar e colar)
- Frontend: 10 minutos (importar componente)
- Testes: 15 minutos
- **Total: ~30 minutos**

### P: Preciso de bibliotecas adicionais?
**R:** Não! Usa o que já tá instalado:
- ✓ @supabase/supabase-js
- ✓ react
- ✓ lucide-react (já instalado)
- ✓ tailwindcss

### P: Funciona com banco existente?
**R:** Sim! O script:
- Cria tabelas se não existirem
- Adiciona colunas se faltarem
- Não deleta dados existentes
- É seguro executar múltiplas vezes

---

## 🔐 Perguntas sobre Segurança

### P: Como protege o último admin?
**R:** Sistema valida em 3 pontos:
1. **demote_admin_to_user()**: `COUNT(*) WHERE role='admin' AND disabled=false`
2. **toggle_user_status()**: Mesma validação
3. **delete_user_admin()**: Mesma validação

Se `count ≤ 1`, retorna erro.

### P: Preciso de HTTPS?
**R:** Sim! Recomendações:
- ✓ Produção: SEMPRE HTTPS
- ✓ URL Supabase: HTTPS (automático)
- ✓ Dados transmitidos: Criptografados

### P: Senhas são armazenadas com segurança?
**R:** Sim! Supabase usa:
- ✓ bcrypt com gen_salt('bf')
- ✓ Não armazenadas em texto plano
- ✓ Função `crypt()` do PostgreSQL

### P: O que acontece se admin esquecer senha?
**R:** Opcoes:
1. Outro admin faz reset
2. Use recuperação de email do Supabase
3. SQL direto (emergência)

### P: Como rastrear ações suspeitas?
**R:** Consulte `audit_logs`:
```sql
SELECT * FROM audit_logs
WHERE created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;
```

---

## 🎨 Perguntas sobre Interface

### P: Como personalizar cores?
**R:** Edite em `UserManagement.tsx`:
- Procure por `bg-blue-600`, `bg-red-600`, etc
- Mude para suas cores Tailwind
- Ex: `bg-purple-600 hover:bg-purple-700`

### P: Componente funciona mobile?
**R:** Parcialmente:
- ✓ Listagem: OK
- ✓ Modais: OK
- ✓ Busca/Filtros: OK
- ⚠️ Cards: Pode melhorar para mobile

Para mobile, adicione responsividade:
```tsx
<div className="block md:grid md:grid-cols-5">
  {/* Conteúdo */}
</div>
```

### P: Como adicionar nova coluna de usuário?
**R:** 3 passos:
1. Adicione coluna em SQL: `ALTER TABLE profiles ADD COLUMN ...`
2. Atualize type em `types.ts`: `UserProfile` interface
3. Adicione campo em `UserManagement.tsx`

### P: Posso traduzir para outro idioma?
**R:** Sim! Substitua strings:
- Procure por português ("Administrador", "Padrão")
- Mude para seu idioma
- Ex: "Administrador" → "Administrator"

---

## 🐛 Perguntas sobre Troubleshooting

### P: "Policy missing for public.profiles"
**R:** Solução:
1. Acesse Supabase > Database > Policies
2. Verifique se RLS está ON
3. Re-execute o script SQL
4. Limpe cache do navegador

### P: "Only admins can..."
**R:** Usuário não é admin:
```sql
-- Verificar
SELECT role FROM profiles WHERE id = 'seu-uuid';

-- Corrigir
UPDATE profiles SET role = 'admin' WHERE id = 'seu-uuid';
```

### P: Perfil não aparece na listagem
**R:** 
- [ ] Verifique se admin está logado
- [ ] Atualize página
- [ ] Abra Console do navegador (F12)
- [ ] Procure por erros

### P: Logs vazios
**R:**
- [ ] Você é admin? Cheque `SELECT role FROM profiles WHERE id = auth.uid()`
- [ ] Fez alguma ação? Só aparece após operações
- [ ] RLS pode estar bloqueando

### P: Senha não muda
**R:** Verifique:
```sql
-- Confirmar função existe
SELECT COUNT(*) FROM information_schema.routines 
WHERE routine_name = 'change_user_password_admin';

-- Deve retornar 1
```

---

## 📊 Perguntas sobre Performance

### P: Quantos usuários suporta?
**R:**
- ✓ Até 100K: Sem problemas
- ✓ 100K - 1M: Com índices OK
- ✓ 1M+: Considere archive

### P: Auditoria deixa slow?
**R:** Não, porque:
- ✓ Índices em `created_at`, `affected_user_id`
- ✓ Apenas últimos 50 carregados
- ✓ SELECT é simples

### P: Como limpar logs antigos?
**R:** 
```sql
-- Deletar logs com >6 meses
DELETE FROM audit_logs 
WHERE created_at < NOW() - INTERVAL '6 months';

-- Ou arquivar em tabela separada
INSERT INTO audit_logs_archive SELECT * FROM audit_logs WHERE ...;
DELETE FROM audit_logs WHERE ...;
```

### P: Posso melhorar velocidade?
**R:** Sim:
- [x] Índices já existem
- [ ] Adicione paginação ao histórico
- [ ] Cache no frontend
- [ ] Archive logs antigos

---

## 🔄 Perguntas sobre Workflows

### P: Fluxo: Novo usuário
**R:**
1. Admin clica [+ Novo Usuário]
2. Form abre
3. Admin preenche dados
4. Sistema envia email com senha
5. Usuário faz login
6. Deve mudar senha **(implementar)**

### P: Fluxo: Deletar usuário
**R:**
1. Admin clica [Deletar]
2. Modal 1: Confirmar
3. Admin clica [Próximo]
4. Modal 2: Confirmação final
5. Admin clica [Deletar Permanentemente]
6. Usuário deletado de `auth.users` (cascade)
7. Log registrado EM MEMÓRIA antes de deletar

### P: Fluxo: Admin esqueceu senha
**R:**
1. Outro admin faz reset
2. Senha temporária gerada
3. Compartilhada pessoalmente
4. Usuário faz login
5. Sistema força mudança de senha

### P: Fluxo: Promover para Admin
**R:**
1. Admin clica [Alterar Perfil]
2. Modal abre com select
3. Escolhe "Administrador"
4. Clica [Sim, alterar perfil]
5. Função `promote_user_to_admin()` executa
6. Log registrado
7. Usuário agora tem acesso admin

---

## 📱 Perguntas sobre Integração

### P: Como integrar com meu App.tsx?
**R:** Ver EXEMPLO_INTEGRACAO.md com 3 opções

### P: Posso usar com Next.js?
**R:** Sim! Mesma integração:
```tsx
// Em pages/admin/usuarios.tsx
import UserManagement from '@/components/UserManagement';
export default UserManagement;
```

### P: Funciona com Vue.js?
**R:** Não (componente é React). Precisa reescrever em Vue.

### P: Preciso proteger a rota?
**R:** Sim! Exemplo:
```tsx
<Route 
  path="/admin/usuarios" 
  element={
    currentUser?.role === 'admin' ? (
      <UserManagement />
    ) : (
      <Navigate to="/dashboard" />
    )
  }
/>
```

---

## 💰 Perguntas sobre Custos

### P: Supabase cobra por logs?
**R:** Não! Incluso no plano.

### P: Tem limite de queries?
**R:** Depende do plano:
- Free: 50K queries/mês
- Pro: Unlimited (com custo por query extra)

### P: Vale a pena implementar?
**R:** Absolutamente! Economiza:
- ✓ Desenvolvimento futuro
- ✓ Segurança incorporada
- ✓ Auditoria pronta
- ✓ Sem retrabalho

---

## 🎓 Perguntas sobre Aprendizado

### P: Como entender o código SQL?
**R:** Leia assim:
1. Procure por `CREATE TABLE` (estrutura)
2. Procure por `CREATE POLICY` (segurança)
3. Procure por `CREATE FUNCTION` (lógica)

Comente qualquer `setup-rbac-completo.sql` com `--`

### P: O que é DEFINER?
**R:** Function executa com privilégios elevados:
```sql
CREATE FUNCTION minha_func() ... SECURITY DEFINER ...
-- Executa como criador (postgres) ao invés do chamador
-- Mas com validações próprias
```

### P: O que é RLS?
**R:** Row Level Security - Banco valida QUEM pode ver QUÊ:
```sql
CREATE POLICY "Users see own" ON profiles
USING (auth.uid() = id);
-- Usuário apenas vê linhas onde id = seu uid
```

### P: Por que múltiplas validações?
**R:** Defense in depth (defesa em profundidade):
1. Frontend: UX
2. Backend: Função valida
3. RLS: Banco garante

Se 1 falha, outros protegem!

---

## 🚀 Perguntas sobre Produção

### P: Posso usar em produção agora?
**R:** Sim! Mas:
- ✓ Teste com `TESTES_RBAC.sql`
- ✓ Backup antes de deploy
- ✓ Monitore logs
- ✓ Documente senhas de emergência

### P: Como fazer backup?
**R:**
```bash
# PostgreSQL
pg_dump -h db.xxxx.supabase.co -U postgres -d postgres > backup.sql

# Supabase automático
# Dashboard > Backups
```

### P: Preciso monitorar?
**R:** Recomendado verificar:
- ✓ Logs de auditoria diariamente
- ✓ Falhas de login
- ✓ Alterações de perfil
- ✓ Deletions

### P: Posso fazer rollback?
**R:** Depende:
- ✓ Tabelas: Restaure do backup
- ✓ Políticas: Re-execute script
- ✓ Dados: Recupere de audit_logs

### P: E se der problema em produção?
**R:** Plano de ação:
1. Desligue acesso (desative todos exceto você)
2. Investigue logs
3. Faça backup
4. Aplique fix
5. Teste
6. Reative acesso

---

## 📞 Como Contatar Suporte

Se tiver problema NÃO resoluto por aqui:

1. **Revise documentação:**
   - README_RBAC_RAPIDO.md
   - RBAC_IMPLEMENTACAO.md
   - EXEMPLO_INTEGRACAO.md

2. **Procure nos logs:**
   ```sql
   SELECT * FROM audit_logs WHERE created_at > NOW() - '1 day'::interval;
   ```

3. **Teste a função:**
   ```sql
   SELECT promote_user_to_admin('seu-uuid');
   ```

4. **Verifique RLS:**
   - Supabase Dashboard > Database > Policies
   - Confirme linhas em branco

---

## ✅ Quick Reference

### Comandos Úteis

```sql
-- Ver todos os usuários
SELECT id, full_name, email, role, disabled FROM profiles;

-- Ver últimos eventos
SELECT action, affected_user_id, created_at FROM audit_logs
ORDER BY created_at DESC LIMIT 20;

-- Contar admins
SELECT COUNT(*) FROM profiles WHERE role = 'admin' AND disabled = false;

-- Resetar schema (dangerous!)
-- DROP TABLE IF EXISTS audit_logs CASCADE;
-- DROP TABLE IF EXISTS profiles CASCADE;
```

### Funções Rápidas

```sql
promote_user_to_admin(uuid)          -- Promover
demote_admin_to_user(uuid)           -- Rebaixar
reset_user_password(uuid)            -- Reset
change_user_password_admin(id, pwd)  -- Mudar
toggle_user_status(uuid, bool)       -- Ativar/Desativar
delete_user_admin(uuid)              -- Deletar
```

---

**Versão**: 1.0  
**Última Atualização**: 12 de Fevereiro de 2026

Se sua pergunta não está aqui, revise os arquivos de documentação! 📖
