-- Script para corrigir tabela profiles e habilitar User Management
-- Execute este script no Supabase SQL Editor

-- 1. Adicionar coluna 'disabled' se não existir
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS disabled BOOLEAN DEFAULT FALSE;

-- 2. Garantir que o email está na tabela profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS email TEXT UNIQUE;

-- 3. Atualizar a coluna email com valores do auth.users se estiver vazia
UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.id = u.id AND p.email IS NULL;

-- 4. Habilitar RLS na tabela profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 5. Criar política para usuários verem seu próprio perfil
CREATE POLICY "Usuários podem ver seu próprio perfil"
ON public.profiles FOR SELECT
USING (auth.uid() = id);

-- 6. Criar política para admin ver todos os perfis
CREATE POLICY "Admin pode ver todos os perfis"
ON public.profiles FOR SELECT
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- 7. Criar política para admin atualizar perfis
CREATE POLICY "Admin pode atualizar perfis"
ON public.profiles FOR UPDATE
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- 8. Criar política para admin deletar perfis
CREATE POLICY "Admin pode deletar perfis"
ON public.profiles FOR DELETE
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- 9. Criar política para admin inserir perfis
CREATE POLICY "Admin pode criar perfis"
ON public.profiles FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- Verificar se as políticas foram criadas
SELECT * FROM pg_policies WHERE tablename = 'profiles';
