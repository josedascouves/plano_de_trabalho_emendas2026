🔧 GUIA DE CORREÇÃO - ADMIN NÃO VÊ USUÁRIOS E PLANOS
=====================================================

## 🚨 PROBLEMAS IDENTIFICADOS:
- Admin (afpereira) não consegue ver usuários
- Admin (afpereira) não consegue ver planos criados
- Possível problema com RLS policies em planos_trabalho
- Possível problema com role não sendo carregado corretamente

## ✅ PASSOS DE CORREÇÃO:

### PASSO 1: EXECUTAR SQL NO SUPABASE (CRÍTICO!)
================================================

1. Abra o Supabase Console → SQL Editor
2. Copie e execute TODO o conteúdo do arquivo:
   **CORRECAO-ADMIN-PLANOS.sql**
   
3. Este script vai:
   ✓ Garantir que afpereira é admin
   ✓ Remover RLS policies ruins em planos_trabalho
   ✓ Criar novas policies corretas
   ✓ Adicionar coluna CNES se não existir
   ✓ Mostrar verificação final

4. **IMPORTANTE**: Copie TUDO de uma vez e execute
   (não linha por linha)


### PASSO 2: FAZER LOGOUT
========================

1. Na aplicação, clique em "Logout" (ícone sair)
2. Limpe o cache do navegador:
   - Pressione: **Ctrl+Shift+Delete**
   - Marque todas as opções
   - Clique "Limpar dados"


### PASSO 3: FAZER LOGIN NOVAMENTE
==================================

1. Email: **afpereira@saude.sp.gov.br**
2. Senha: (sua senha)
3. Aperte Enter ou clique "Fazer Login"

4. **OBSERVAR O CONSOLE** (abra F12 → Console):
   - Procure por logs como:
     * 🔑 LOGIN - Usuário autenticado
     * ✅ Perfil carregado
     * ✅ Role carregado
     * 🎯 setCurrentUser
     * ✅ LOGIN CONCLUÍDO

   - Se tiver ❌ ou ⚠ vermelhos, há erro!


### PASSO 4: VERIFICAR SE FUNCIONOU
====================================

**Você deve ver:**

a) No Header (canto superior direito):
   ✓ Seu nome e foto
   ✓ Sua role como "admin" em VERMELHO
   ✓ Ícone de usuários (Users/Pessoas)

b) Quando clica no ícone de usuários:
   ✓ Modal abre
   ✓ Lista de 7 usuários aparece
   ✓ Nomes, emails, roles aparecem
   ✓ Botões de editar, promover, etc. funcionar

c) Na página de planos:
   ✓ Aparecem todos os planos (não apenas seus)
   ✓ Pode editar qualquer plano
   ✓ Pode deletar qualquer plano


## 🆘 SE NÃO FUNCIONAR:

### Problema: "Não consigo ver o ícone de usuários"
- Faça F12 → Console
- Procure por logs de login (ctrl+F, procure por "LOGIN")
- Se não aparecer:
  * Pode ser que você não realizou login
  * Ou não realizou o CORRECAO-ADMIN-PLANOS.sql

### Problema: "Ícone aparece mas lista de usuários não carrega"
- Abra DevTools (F12)
- Vá à aba "Console"
- Procure por ⚠ ou ❌ vermelhos
- Anote a mensagem de erro exato
- Execute novamente: **CORRECAO-ADMIN-PLANOS.sql**

### Problema: "Consigo ver usuários mas planos não carregam"
- Mesmo processo acima
- Os logs devem mostrar:
  * 📋 loadPlanos - Iniciando carregamento
  * isAdmin: true
  * ✅ Planos carregados: X

### Problema: "O banco ainda mostra erro ao tentar buscar dados"
- Execute este script para DIAGNOSTICAR:
  * Abra: **DIAGNOSTICO-COMPLETO.sql**
  * Execute no Supabase
  * Ele vai listar:
    - Quantos usuários existem
    - Quantos admins existem  
    - Estrutura de RLS policies
    - Todos os planos


## 📋 IMPORTÂNCIA DO CNES

Para criar usuários padrão (não admin), o CNES agora é obrigatório.

**Na criação de usuário:**
- Nome: (obrigatório)
- Email: (obrigatório)
- Senha: (obrigatório)
- Perfil: "Usuário Padrão"
- **CNES: (obrigatório) - máximo 8 dígitos**

O aplicativo vai validar e não deixar criar sem CNES.


## 📞 LOGS DE DEBUG

Todos os logs importantes aparecem no console (F12).

Procure por:
- 🔑 = LOGIN
- ✅ = Sucesso
- ❌ = Erro
- ⚠ = Aviso
- 📋 = Planos
- 👥 = Usuários
- 🔐 = Admin check


## 🎯 CHECKLIST FINAL

[  ] Executei CORRECAO-ADMIN-PLANOS.sql no Supabase
[  ] Fiz logout
[  ] Limpei cache (Ctrl+Shift+Delete)
[  ] Fiz login novamente
[  ] Vejo o ícone de usuários no header
[  ] Lista de usuários carrega
[  ] Consigo ver os planos
[  ] Posso editar/deletar planos
[  ] Posso promover/desativar usuários
[  ] CNES é obrigatório ao criar usuário

Se todas as caixas ✓, SISTEMA ESTÁ FUNCIONANDO! 🎉
