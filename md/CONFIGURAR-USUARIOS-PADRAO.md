# ✅ Configurar Todos os Usuários como Padrão

## 🎯 O Problema

Você criou 26 usuários, mas quando tenta fazer login, recebe erro:
```
❌ Erro ao buscar role: [406 Not Acceptable]
```

## ✅ Solução

Falta configurar a tabela `user_roles` que mapeia cada usuário para seu role (admin/user).

---

## 🚀 Como Resolver (1 Passo)

### Execute o Script SQL:

1. Acesse: https://app.supabase.com
2. Vá para: **SQL Editor** → **New Query**
3. Copie TODO o conteúdo de: `scripts/CONFIGURAR-USER-ROLES.sql`
4. Cole e clique: **Run** (Ctrl+Enter)
5. Aguarde: `✅ CONFIGURAÇÃO CONCLUÍDA!`

---

## 📋 O Que Este Script Faz

✅ Cria tabela `user_roles` (se não existir)  
✅ Configura políticas de RLS  
✅ **Adiciona TODOS os 26 usuários como role='user'** (padrão)  
✅ Marca todos como `disabled=false` (ativos)  
✅ Sincroniza com a tabela `profiles`  

---

## 📊 Resultado Esperado

```
✅ CONFIGURAÇÃO CONCLUÍDA!

total_users | admin_count | user_count | active_count
     26     |      0      |     26     |      26
```

Todos os usuários com:
- ✅ role = 'user'
- ✅ disabled = false
- ✅ 26 usuários ativos

---

## 🔐 Depois de Configurar

### Testar Login:

1. Vá para sua aplicação (http://localhost:3000)
2. Email: **secretaria.msi@famaesp.org.br**
3. Senha: **2790580** (do CSV)
4. ✅ Deve fazer login com sucesso!

### Verificar no Dashboard:

```sql
-- Ver todos os usuários configurados
SELECT 
  p.email,
  p.full_name,
  p.cnes,
  ur.role,
  ur.disabled
FROM public.user_roles ur
LEFT JOIN public.profiles p ON ur.user_id = p.id
ORDER BY p.email;
```

---

## 👨‍💼 Se Quiser Promover um Usuário para Admin:

```sql
UPDATE public.user_roles 
SET role = 'admin' 
WHERE user_id = (
  SELECT id FROM auth.users 
  WHERE email = 'seu-email@exemplo.com'
);
```

---

## 📝 Lista de Usuários Criados

| # | Email | Senha | CNES |
|---|-------|-------|------|
| 1 | institutobezerra.adm@gmail.com | 2084384 | 2084384 |
| 2 | convenios@therezaperlatti.com.br | 2790653 | 2790653 |
| 3 | administracao.irmadulce@alsf.org.br | 2790998 | 2790998 |
| 4 | halena.n@huhsp.org.br | 2077485 | 2077485 |
| 5 | rosane@santamarcelina.org | 2077477 | 2077477 |
| 6 | vivianeandrade@casaandreluiz.org.br | 2082276 | 2082276 |
| 7 | luci.rosa@boldrini.org.br | 2081482 | 2081482 |
| 8 | planejamento@consaude.org.br | 2077434 | 2077434 |
| 9 | dds.anapaula@amaralcarvalho.org.br | 2083086 | 2083086 |
| 10 | camilamarques@bairral.com.br | 2085143 | 2085143 |
| 11 | diretoria@hospitalaldebase.com.br | 2077396 | 2077396 |
| 12 | alexander.ferreira@hemocentro.fmrp.usp.br | 2047438 | 2047438 |
| 13 | gerente.adm@hrcpp.org.br | 7400926 | 7400926 |
| 14 | gacc@gacc.com.br | 5869412 | 5869412 |
| 15 | m.orlandino@hc.fm.usp.br | 2071568 | 2071568 |
| 16 | vmelias@famesp.org.br | 2748223 | 2748223 |
| 17 | secretaria.msi@famaesp.org.br | 2790580 | 2790580 |
| 18 | financas-hrs@saude.sp.gov.br | 2091313 | 2091313 |
| 19 | mariana.leonardo@redesc.org.br | 3028399 | 3028399 |
| 20 | controleinterno@santacasacaconde.com.br | 2080222 | 2080222 |
| 21 | projetos@santacasafernandopolis.com.br | 2093324 | 2093324 |
| 22 | eder.barboza@santacasasp.org.br | 2688689 | 2688689 |
| 23 | edilea@sobrapar.org.br | 2084252 | 2084252 |
| 24 | convenios.hcmf@hospitalmatao.com.br | 2090961 | 2090961 |
| 25 | contabilidade11@santacasavotuporanga.com.br | 2081377 | 2081377 |
| 26 | klesio@unicamp.br | 2079798 | 2079798 |

---

## ✨ Próximos Passos

1. ✅ Execute o script SQL (`CONFIGURAR-USER-ROLES.sql`)
2. ✅ Teste fazer login com um dos usuários
3. ✅ Se der certo, está pronto! 🎉
4. (Opcional) Promova alguns usuários para admin conforme necessário

---

## 🆘 Troubleshooting

**Erro: "Table user_roles not found"**
→ Execute o script SQL novamente

**Erro: "Permission denied"**
→ Verifique se você está logado como admin no Supabase

**Erro: "Invalid credentials"**
→ Verifique se a senha está correta (coluna 4 do CSV)

---

**Tudo pronto! Execute o script e teste o login! 🚀**
