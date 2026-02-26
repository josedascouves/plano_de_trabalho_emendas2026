# 👁️ USUÁRIOS INTERMEDIÁRIOS - GUIA DE IMPLEMENTAÇÃO

## 📋 O Que Foi Implementado

Novo papel de usuário chamado **"Intermediário"** que permite:
- ✅ **Visualizar TODOS os planos** do sistema
- ❌ **Não pode criar** novos planos
- ❌ **Não pode editar** planos
- ❌ **Não pode apagar** planos
- ✅ **Apenas leitura/visualização**

---

## 🎯 Casos de Uso Ideais

- **Supervisores** que precisam monitorar todos os planos
- **Auditors** que precisam acompanhar e revisar documentação
- **Consultores** que assessoram múltiplas unidades
- **Gestores regionais** que supervisionam vários CNES

---

## 🚀 Como Usar

### Opção 1: Executar Script SQL (Recomendado)

1. Abra o arquivo: `ADICIONAR-USUARIOS-INTERMEDIARIOS.sql`
2. Acesse: https://app.supabase.com
3. Vá para: **SQL Editor** → **New Query**
4. Copie e cole TODO o conteúdo do arquivo
5. Clique em **Run** (Ctrl+Enter)

### Opção 2: Usar Interface Web

1. Acesse a seção **Gerenciamento de Usuários** do app
2. Ao criar novo usuário:
   - Selecione "Usuário Intermediário" no campo "Perfil do Usuário"
3. Ao editar usuário existente:
   - Use o dropdown "Alternar Papel" para mudar para "Intermediário"

---

## 📊 Estrutura de Papéis Implementada

### 👑 ADMIN (Administrador)
```
✅ Visualizar TODOS os planos
✅ Criar novos planos
✅ Editar qualquer plano
✅ Apagar qualquer plano
✅ Gerenciar usuários
✅ Acessar Dashboard
```

### 👤 USUÁRIO PADRÃO
```
✅ Visualizar SEUS planos
✅ Criar novos planos
✅ Editar SEUS planos
✅ Apagar SEUS planos
❌ Visualizar planos de outros
❌ Acesso ao Dashboard
❌ Gerenciar usuários
```

### 👁️ USUÁRIO INTERMEDIÁRIO (NOVO!)
```
✅ Visualizar TODOS os planos
❌ Criar novos planos
❌ Editar planos
❌ Apagar planos
❌ Acesso ao Dashboard
❌ Gerenciar usuários
✅ Apenas leitura/visualização
```

---

## 🔧 Alterações Técnicas Realizadas

### Backend (SQL)
- ✅ Atualizada `constraint` da tabela `user_roles` para aceitar `'intermediate'` como valor válido
- ✅ Contadores de user_roles agora incluem contagem de intermediários

### Frontend (React/TypeScript)
- ✅ Atualizada função `canViewPlan()`: intermediários agora veem TODOS os planos
- ✅ Atualizada função `canEditPlan()`: intermediários NÃO podem editar
- ✅ Adicionada função `handleChangeUserRole()`: permite alteração de papel de forma genérica
- ✅ UI de criação de usuários agora mostra opção "Usuário Intermediário"
- ✅ Dropdown de alteração de papel agora oferece 3 opções: Padrão, Intermediário, Admin
- ✅ Badge de papel atualizado para mostrar "Intermediário" com cor roxa

### Lógica de Acesso
```
Interface de Planos:
- Botão "Editar" → Desaparece para intermediários
- Botão "Deletar" → Desaparece para intermediários
- Visualização → Todos os planos disponíveis

Dashboard:
- Acesso bloqueado para não-admins (inclui intermediários)
```

---

## ✅ Checklist de Implementação

- [x] SQL atualizado para aceitar novo role
- [x] Funções de controle de acesso atualizadas
- [x] Interface de criação de usuários atualizada
- [x] Dropdown de alteração de papel implementado
- [x] Botões de Editar/Deletar ocultados para intermediários
- [x] Badge de papel atualizado para mostrar novo tipo
- [x] Documentação completa

---

## 🧪 Como Testar

### Teste 1: Criar Usuário Intermediário
1. Abra "Gerenciamento de Usuários"
2. Clique em "Registrar Novo Usuário"
3. Preencha os dados
4. Selecione "Usuário Intermediário" no perfil
5. Clique "Registrar"
6. Verifique se o usuário aparece com badge "Intermediário"

### Teste 2: Verificar Acesso de Visualização
1. Faça login como usuário intermediário
2. Vá para "Meus Planos"
3. Verifique se TODOS os planos aparecem na lista
4. Clique em um plano de outro usuário
5. Verifique se consegue visualizar o conteúdo
6. Verifique se o botão "Editar" NÃO aparece
7. Verifique se o botão "Deletar" NÃO aparece

### Teste 3: Alterar Papel de Usuário
1. Abra "Gerenciamento de Usuários"
2. Encontre um usuário "Padrão"
3. Use o dropdown "Alternar Papel"
4. Selecione "Intermediário"
5. Confirme no popup
6. Verifique se o badge mudou para "Intermediário"

---

## 📁 Arquivos Modificados

1. **scripts/CONFIGURAR-USER-ROLES.sql**
   - Atualizada constraint CHECK para incluir 'intermediate'
   - Adicionado contador de intermediários

2. **ADICIONAR-USUARIOS-INTERMEDIARIOS.sql** (NOVO)
   - Script completo para implementar a mudança
   - Exemplos e documentação

3. **App.tsx**
   - Função `canEditPlan()`: Intermediários não podem editar
   - Função `canViewPlan()`: Intermediários veem todos os planos
   - Função `handleChangeUserRole()`: Nova função genérica
   - UI de usuários: Novo select para alteração de papel
   - UI de criação: Nova opção "Usuário Intermediário"

---

## 🛡️ Segurança

- Intermediários têm acesso apenas **leitura**
- Não podem executar operações que modifiquem dados
- Não têm acesso ao Dashboard (que contém estatísticas sensíveis)
- Não podem gerenciar outros usuários
- Não podem deletar contas

---

## 📞 Suporte

Se encontrar problemas:

1. Verifique se o script SQL foi executado corretamente
2. Limpe o cache do navegador (Ctrl+Shift+Delete)
3. Faça logout e login novamente
4. Verifique a página do usuário em Supabase (Tabela: user_roles)

---

## 🔄 Reversão (Se Necessário)

Se precisar remover o novo papel:

```sql
-- Converter todos os intermediários para usuários padrão
UPDATE public.user_roles 
SET role = 'user'
WHERE role = 'intermediate';

-- Atualizar constraint
ALTER TABLE public.user_roles DROP CONSTRAINT user_roles_role_check;
ALTER TABLE public.user_roles ADD CONSTRAINT user_roles_role_check 
  CHECK (role IN ('admin', 'user'));
```

---

**Implementação Concluída ✅**

Data: 26 de Fevereiro de 2026
