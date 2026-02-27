-- ============================================================================
-- CONSULTAS SQL PRONTAS - HISTÓRICO DE DOWNLOADS DE PDF
-- ============================================================================
-- Copie e cole essas consultas no Supabase SQL Editor para analisar dados

-- ============================================================================
-- 1️⃣ VER ÚLTIMOS 20 DOWNLOADS (TODO MUNDO SE FOR ADMIN)
-- ============================================================================
SELECT 
  numero_emenda,
  parlamentar,
  user_email,
  user_name,
  downloaded_at AT TIME ZONE 'America/Sao_Paulo' as data_hora,
  valor_total
FROM public.pdf_download_history
ORDER BY downloaded_at DESC
LIMIT 20;

-- ============================================================================
-- 2️⃣ VER SEUS PRÓPRIOS DOWNLOADS
-- ============================================================================
-- Substitua 'seu.email@gov.br' pelo seu email
SELECT 
  numero_emenda,
  parlamentar,
  downloaded_at AT TIME ZONE 'America/Sao_Paulo' as data_hora,
  valor_total,
  action_type
FROM public.pdf_download_history
WHERE user_email = 'seu.email@gov.br'
ORDER BY downloaded_at DESC;

-- ============================================================================
-- 3️⃣ DOWNLOADS POR DIA (HOJE)
-- ============================================================================
SELECT 
  DATE(downloaded_at AT TIME ZONE 'America/Sao_Paulo') as data,
  numero_emenda,
  parlamentar,
  COUNT(*) as total_acessos
FROM public.pdf_download_history
WHERE DATE(downloaded_at AT TIME ZONE 'America/Sao_Paulo') = CURRENT_DATE
GROUP BY DATE(downloaded_at AT TIME ZONE 'America/Sao_Paulo'), numero_emenda, parlamentar
ORDER BY total_acessos DESC;

-- ============================================================================
-- 4️⃣ DOWNLOADS POR SEMANA
-- ============================================================================
SELECT 
  DATE_TRUNC('week', downloaded_at AT TIME ZONE 'America/Sao_Paulo')::DATE as semana,
  COUNT(*) as total_downloads,
  COUNT(DISTINCT user_id) as usuarios_unicos
FROM public.pdf_download_history
GROUP BY DATE_TRUNC('week', downloaded_at AT TIME ZONE 'America/Sao_Paulo')
ORDER BY semana DESC;

-- ============================================================================
-- 5️⃣ TOP 10 PLANOS MAIS ACESSADOS
-- ============================================================================
SELECT 
  numero_emenda,
  parlamentar,
  COUNT(*) as total_downloads,
  COUNT(DISTINCT user_id) as usuarios_unicos,
  MAX(downloaded_at AT TIME ZONE 'America/Sao_Paulo') as ultimo_acesso
FROM public.pdf_download_history
GROUP BY numero_emenda, parlamentar
ORDER BY total_downloads DESC
LIMIT 10;

-- ============================================================================
-- 6️⃣ TOP 10 USUÁRIOS COM MAIS DOWNLOADS
-- ============================================================================
SELECT 
  user_email,
  user_name,
  COUNT(*) as total_downloads,
  COUNT(DISTINCT plano_id) as planos_unicos,
  MAX(downloaded_at AT TIME ZONE 'America/Sao_Paulo') as ultimo_download
FROM public.pdf_download_history
GROUP BY user_email, user_name
ORDER BY total_downloads DESC
LIMIT 10;

-- ============================================================================
-- 7️⃣ PLANOS NUNCA ACESSADOS (PARA VISUALIZAR PDF)
-- ============================================================================
SELECT 
  pt.id,
  pt.numero_emenda,
  pt.parlamentar,
  pt.valor_total,
  pt.created_at AT TIME ZONE 'America/Sao_Paulo' as criado_em,
  (SELECT full_name FROM public.profiles WHERE id = pt.created_by) as criado_por
FROM public.planos_trabalho pt
LEFT JOIN public.pdf_download_history pdh ON pt.id = pdh.plano_id
WHERE pdh.id IS NULL
ORDER BY pt.created_at DESC;

-- ============================================================================
-- 8️⃣ HISTÓRICO COMPLETO DE UM PLANO ESPECÍFICO
-- ============================================================================
-- Substitua 'NUMERO_EMENDA' pelo número que quer consultar
SELECT 
  plano_id,
  user_email,
  user_name,
  downloaded_at AT TIME ZONE 'America/Sao_Paulo' as data_hora,
  action_type
FROM public.pdf_download_history
WHERE numero_emenda = '123/2026'
ORDER BY downloaded_at DESC;

-- ============================================================================
-- 9️⃣ DOWNLOADS POR USUÁRIO E PLANO
-- ============================================================================
SELECT 
  user_email,
  numero_emenda,
  COUNT(*) as total_acessos,
  MIN(downloaded_at) as primeiro_acesso,
  MAX(downloaded_at) as ultimo_acesso
FROM public.pdf_download_history
GROUP BY user_email, numero_emenda
ORDER BY user_email, total_acessos DESC;

-- ============================================================================
-- 🔟 USUÁRIOS QUE ACESSARAM MAIS NO MÊS
-- ============================================================================
SELECT 
  user_email,
  user_name,
  DATE_TRUNC('month', downloaded_at)::DATE as mes,
  COUNT(*) as downloads_mes,
  COUNT(DISTINCT DATE(downloaded_at)) as dias_com_acesso
FROM public.pdf_download_history
WHERE DATE_TRUNC('month', downloaded_at)::DATE = DATE_TRUNC('month', CURRENT_DATE)::DATE
GROUP BY user_email, user_name, DATE_TRUNC('month', downloaded_at)
ORDER BY downloads_mes DESC;

-- ============================================================================
-- 1️⃣1️⃣ ESTATÍSTICAS GERAIS DE DOWNLOADS
-- ============================================================================
SELECT 
  COUNT(*) as total_downloads,
  COUNT(DISTINCT plano_id) as planos_diferentes,
  COUNT(DISTINCT user_id) as usuarios_unicos,
  MIN(downloaded_at AT TIME ZONE 'America/Sao_Paulo') as primeiro_registro,
  MAX(downloaded_at AT TIME ZONE 'America/Sao_Paulo') as ultimo_registro,
  ROUND(AVG(valor_total), 2) as valor_medio_acessado
FROM public.pdf_download_history;

-- ============================================================================
-- 1️⃣2️⃣ PLANOS COM VALOR TOTAL ALTO E POUCOS ACESSOS
-- ============================================================================
SELECT 
  pt.numero_emenda,
  pt.parlamentar,
  pt.valor_total,
  COUNT(pdh.id) as total_acessos,
  pt.created_at AT TIME ZONE 'America/Sao_Paulo' as criado_em
FROM public.planos_trabalho pt
LEFT JOIN public.pdf_download_history pdh ON pt.id = pdh.plano_id
GROUP BY pt.id, pt.numero_emenda, pt.parlamentar, pt.valor_total, pt.created_at
HAVING pt.valor_total > 100000 AND COUNT(pdh.id) < 2
ORDER BY pt.valor_total DESC;

-- ============================================================================
-- 1️⃣3️⃣ DOWNLOADS ÚLTIMAS 24 HORAS
-- ============================================================================
SELECT 
  numero_emenda,
  parlamentar,
  user_email,
  downloaded_at AT TIME ZONE 'America/Sao_Paulo' as data_hora,
  valor_total
FROM public.pdf_download_history
WHERE downloaded_at >= NOW() - INTERVAL '24 hours'
ORDER BY downloaded_at DESC;

-- ============================================================================
-- 1️⃣4️⃣ DOWNLOADS ÚLTIMOS 30 DIAS
-- ============================================================================
SELECT 
  DATE(downloaded_at AT TIME ZONE 'America/Sao_Paulo') as data,
  COUNT(*) as downloads_dia,
  COUNT(DISTINCT user_id) as usuarios_dia,
  SUM(valor_total) as valor_total_acessado
FROM public.pdf_download_history
WHERE downloaded_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(downloaded_at AT TIME ZONE 'America/Sao_Paulo')
ORDER BY data DESC;

-- ============================================================================
-- 1️⃣5️⃣ VIEW: USAR A VIEW DE ESTATÍSTICAS JÁ CRIADA
-- ============================================================================
-- Essa view fue criada automaticamente - mostra resumo por plano
SELECT 
  numero_emenda,
  parlamentar,
  total_downloads,
  usuarios_unicos,
  ultimo_download AT TIME ZONE 'America/Sao_Paulo' as ultimo_acesso,
  plano_criado_em AT TIME ZONE 'America/Sao_Paulo' as criado_em
FROM public.pdf_download_stats
ORDER BY total_downloads DESC;

-- ============================================================================
-- 1️⃣6️⃣ DELETAR HISTÓRICO DE TESTES (CUIDADO!)
-- ============================================================================
-- Use isso apenas para limpar dados de testes
-- DELETE FROM public.pdf_download_history
-- WHERE user_email = 'teste@example.com';

-- ============================================================================
-- 1️⃣7️⃣ EXPORTAR PARA CSV - ÚLTIMOS 100 DOWNLOADS
-- ============================================================================
-- Execute isso e clique em "Copy" para copiar para Excel
COPY (
  SELECT 
    numero_emenda,
    parlamentar,
    user_email,
    user_name,
    downloaded_at::TEXT,
    valor_total::TEXT
  FROM public.pdf_download_history
  ORDER BY downloaded_at DESC
  LIMIT 100
) TO STDOUT WITH CSV HEADER;

-- ============================================================================
-- NOTAS:
-- ============================================================================
-- - Sempre use 'downloaded_at AT TIME ZONE 'America/Sao_Paulo'' para horário de SP
-- - As consultas respeitam automaticamente a segurança RLS
-- - Você só vê seus dados, a menos que seja admin
-- - Substitua 'seu.email@gov.br' pelo seu email onde indicado
-- - Substitua 'NUMERO_EMENDA' pela emenda que quer consultar
-- - Em caso de dúvida, copie a consulta exatamente como está

