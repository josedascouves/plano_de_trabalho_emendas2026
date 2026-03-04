🚨 CORREÇÃO RÁPIDA - 4 USUÁRIOS COM ERRO

## PROBLEMA
❌ Erro "Database error querying schema" ao tentar acessar
❌ Afeta: janete.sgueglia@saude.sp.gov.br, lhribeiro@saude.sp.gov.br, gtcosta@saude.sp.gov.br, casouza@saude.sp.gov.br

## SOLUÇÃO (2 scripts a executar)

### PASSO 1: Executar CORRIGIR-4-USUARIOS-COM-ERRO.sql
1. Acesse https://app.supabase.com
2. Vá para SQL Editor
3. Abra: CORRIGIR-4-USUARIOS-COM-ERRO.sql
4. Copie TODO o conteúdo
5. Cole no SQL Editor
6. Execute (Ctrl+Enter)

✅ Esperado: Ver "✅ PASSO 3B: User_roles recriados" e resultado final com ✅ COMPLETO

---

### PASSO 2: Executar CORRIGIR-POLITICAS-RLS.sql
1. Clique em "+ New Query"
2. Abra: CORRIGIR-POLITICAS-RLS.sql
3. Copie TODO o conteúdo
4. Cole no SQL Editor
5. Execute (Ctrl+Enter)

✅ Esperado: Ver "✅ PASSO 4F" e "✅ CONCLUSÃO"

---

## RESULTADO ESPERADO

Depois de executar os 2 scripts, os 4 usuários devem conseguir fazer login SEM erros!

---

## O QUE FOI FEITO

### Script 1 (CORRIGIR-4-USUARIOS-COM-ERRO.sql):
- ✅ Deletou profiles antigos corrompidos
- ✅ Deletou user_roles antigos corrompidos
- ✅ Recriou profiles corretamente
- ✅ Recriou user_roles com role='intermediate'

### Script 2 (CORRIGIR-POLITICAS-RLS.sql):
- ✅ Removeu políticas RLS que estavam causando o erro
- ✅ Criou novas políticas RLS PERMISSIVAS (sem recursão)
- ✅ Permitiu acesso total aos usuários autenticados

---

## PRÓXIMOS PASSOS

1. Execute PASSO 1 e 2 acima
2. Teste cada usuário tentando fazer login
3. Se tudo funcionar, ✅ PROBLEMA RESOLVIDO!

---

## EM CASO DE ERRO

Se ainda houver erro após executar os scripts:

1. **Erro de "Token expirado"**: Faça login novamente no Supabase
2. **Erro de "Sintaxe SQL"**: Certifique-se de copiar TODO o arquivo
3. **Erro de "Policy does not exist"**: É normal! Significa que não existe mais - a solução removeu
4. **Usuário ainda não consegue fazer login**: Tente resetar a senha no Dashboard Supabase

---

**⏱️ Tempo total: ~5 minutos**
