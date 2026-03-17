╔════════════════════════════════════════════════════════════════════════════╗
║              ✏️  GUIA - EDITAR E GERENCIAR USUÁRIOS                          ║
╚════════════════════════════════════════════════════════════════════════════╝

Agora que conseguiu ver os usuários, aqui está como editá-los e gerenciá-los.

═══════════════════════════════════════════════════════════════════════════════

📋 OPERAÇÕES DISPONÍVEIS PARA ADMIN:

1. VER DETALHES DO USUÁRIO
   └─ Automático ao abrir modal

2. PROMOVER A ADMIN
   └─ Botão: "👑 Promover a Admin"
   ├─ Clica no botão
   ├─ Sistema confirma

3. REBAIXAR PARA USUÁRIO
   └─ Botão: "⬇️ Rebaixar"
   ├─ Clica no botão
   ├─ Sistema confirma

4. DESATIVAR USUÁRIO (bloqueia acesso)
   └─ Botão: "🔒 Desativar"
   ├─ Usuário não consegue mais fazer login
   ├─ Dados dele continuam no sistema

5. ATIVAR USUÁRIO (desbloqueia acesso)
   └─ Botão: "✅ Ativar"
   ├─ Usuário consegue fazer login novamente

6. DELETAR USUÁRIO
   └─ Botão: "🗑️ Deletar"
   ├─ ⚠️ AÇÃO IRREVERSÍVEL
   ├─ Pede confirmação
   ├─ Remove do banco completamente

═══════════════════════════════════════════════════════════════════════════════

🔐 RESTRIÇÕES DO SISTEMA:

• Você poderá:
  ✅ Ver todos os usuários
  ✅ Promover qualquer um a admin
  ✅ Rebaixar qualquer um para usuário
  ✅ Desativar/Ativar usuários
  ✅ Deletar usuários
  ✅ Criar novos usuários

• CNES agora é OBRIGATÓRIO:
  ✅ Ao criar usuário, deve preencher CNES
  ✅ Máximo 8 dígitos
  ✅ Sistema valida automaticamente

═══════════════════════════════════════════════════════════════════════════════

📝 CRIAR NOVO USUÁRIO:

1. No modal de usuários, vá até a seção: "REGISTRAR NOVO USUÁRIO"
2. Preencha os campos:
   • Email: (obrigatório) ex: usuario@saude.sp.gov.br
   • Senha: (obrigatório) mínimo 6 caracteres
   • Nome: (obrigatório) mínimo 3 caracteres
   • CNES: (obrigatório) máximo 8 dígitos ← NOVO!
   • Perfil: Escolha "Admin" ou "Usuário Padrão"

3. Clique: "✅ Registrar Usuário"

4. Sistema vai:
   ├─ Criar conta no Auth Supabase
   ├─ Salvar perfil em profiles
   ├─ Atribuir role em user_roles
   ├─ Mostrar confirmação
   └─ Recarregar lista

═══════════════════════════════════════════════════════════════════════════════

⚠️ CUIDADOS IMPORTANTES:

🔴 NUNCA REMOVA O ÚLTIMO ADMIN
    ├─ Se remover o único admin (você), perderá acesso
    ├─ Sistema não bloqueia isto automaticamente
    ├─ Se acontecer, executa SQL manualmente:
    │  UPDATE public.user_roles SET role = 'admin' WHERE user_id = 'seu-id'
    └─ Contate um desenvolvedor

🔴 DELETAR USUÁRIO É PERMANENTE
    ├─ Não pode ser desfeito
    ├─ Dados do usuário são perdidos
    ├─ Melhor usar "Desativar" se precisar reverter

🟡 DESATIVAR NÃO DELETA
    ├─ Dados ficam no sistema
    ├─ Usuário pode ser ativado depois
    ├─ Use isto para "suspender" temporariamente

═══════════════════════════════════════════════════════════════════════════════

📊 VENDO QUEM ESTÁ FAZENDO O QUÊ:

Se quiser ver o histórico de ações (quem fez o quê):

1. Go to Supabase Console
2. SQL Editor
3. Run:

SELECT 
  id,
  affected_user_id,
  action,
  performed_by_id,
  details,
  created_at
FROM public.audit_logs
ORDER BY created_at DESC
LIMIT 50;

Vai mostrar:
• Quem fez a ação
• Qual ação (promote, demote, delete, etc)
• Quando foi feita
• Detalhes adicionais

═══════════════════════════════════════════════════════════════════════════════

✅ CHECKLIST APÓS CONFIGURAR TUDO:

[ ] Consigo ver a lista de 7 usuários
[ ] Consigo promover um usuário a admin
[ ] Consigo rebaixar um admin
[ ] Consigo desativar/ativar usuários
[ ] Consigo deletar um usuário (com cuidado!)
[ ] Consigo criar novo usuário com CNES obrigatório
[ ] O ícone mostra "Admin" em vermelho no header
[ ] Console não mostra erros ❌

Se todos os checkmarks estão ✅, SISTEMA COMPLETO E FUNCIONANDO! 🎉

═══════════════════════════════════════════════════════════════════════════════

🚀 RECURSOS ADICIONAIS:

Arquivo                             Descrição
────────────────────────────────────────────────────────────
DEBUG-USUARIOS-NAO-CARREGAM.md       Se usuários não aparecem
ACOES-RAPIDAS-USUARIOS.txt           Troubleshooting rápido
COMANDOS-DEBUG-CONSOLE.js            Comandos para console
COMO-CORRIGIR-ADMIN.md               Guia completo de correção
TESTE-RAPIDO-RLS.sql                 Testa se tudo funciona
CORRECAO-ADMIN-PLANOS.sql            Script principal de fix

═══════════════════════════════════════════════════════════════════════════════

💡 DICAS:

1. Sempre verifique Console (F12) para erros
2. Se algo quebrar, execute CORRECAO-ADMIN-PLANOS.sql
3. Limpar cache (Ctrl+Shift+Delete) resolve muitos problemas
4. Faça backup do Supabase periodicamente
5. Teste em ambiente de desenvolvimento primeiro

═══════════════════════════════════════════════════════════════════════════════

Sucesso! Seu sistema RBAC está funcionando completo! 🎊
