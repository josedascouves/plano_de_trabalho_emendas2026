-- ============================================================
-- LIMPEZA E SETUP COMPLETO - EM UM ÚNICO SCRIPT
-- Executa limpeza + recriação completa do RBAC
-- ============================================================

-- ============================================================
-- PARTE 1: LIMPEZA COMPLETA
-- ============================================================

-- Desabilitar RLS temporariamente para poder deletar
ALTER TABLE IF EXISTS public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.audit_logs DISABLE ROW LEVEL SECURITY;

-- Deletar todas as políticas RLS
DROP POLICY IF EXISTS "admin_see_all_profiles" ON public.profiles;
DROP POLICY IF EXISTS "user_see_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_update_all_profiles" ON public.profiles;
DROP POLICY IF EXISTS "user_update_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_create_profiles" ON public.profiles;
DROP POLICY IF EXISTS "admin_delete_profiles" ON public.profiles;
DROP POLICY IF EXISTS "admin_view_all_audit_logs" ON public.audit_logs;
DROP POLICY IF EXISTS "user_view_own_audit_logs" ON public.audit_logs;
DROP POLICY IF EXISTS "system_insert_audit_logs" ON public.audit_logs;

-- Políticas antigas (compatibilidade)
DROP POLICY IF EXISTS "Admins can view all users" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Admins can update any user" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Admins can create users" ON profiles;
DROP POLICY IF EXISTS "Admins can delete users" ON profiles;
DROP POLICY IF EXISTS "Users can view own audit" ON audit_logs;
DROP POLICY IF EXISTS "System can insert audit logs" ON audit_logs;

-- Deletar views
DROP VIEW IF EXISTS public.user_statistics;

-- Deletar triggers e funções do trigger
DROP TRIGGER IF EXISTS profiles_update_timestamp ON public.profiles;
DROP FUNCTION IF EXISTS public.update_profiles_timestamp();

-- Deletar todas as funções do RBAC
DROP FUNCTION IF EXISTS public.promote_user_to_admin(UUID);
DROP FUNCTION IF EXISTS public.demote_admin_to_user(UUID);
DROP FUNCTION IF EXISTS public.reset_user_password(UUID);
DROP FUNCTION IF EXISTS public.toggle_user_status(UUID, BOOLEAN);
DROP FUNCTION IF EXISTS public.change_own_password(VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS public.change_user_password_admin(UUID, VARCHAR);
DROP FUNCTION IF EXISTS public.delete_user_admin(UUID);

-- Deletar tabelas
DROP TABLE IF EXISTS public.audit_logs CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.user_roles CASCADE;

-- ============================================================
-- PARTE 2: SETUP COMPLETO
-- ============================================================

-- ============================================================
-- 0. TABELA DE USER_ROLES (SEM RLS) - Para evitar recursão
-- ============================================================

CREATE TABLE public.user_roles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user')),
  disabled BOOLEAN DEFAULT FALSE
);

-- NÃO HABILITAR RLS NESTA TABELA - Ela é usada pelas políticas!
CREATE INDEX idx_user_roles_role ON public.user_roles(role);

-- ============================================================
-- 1. TABELA DE PROFILES (USUÁRIOS) COM RBAC
-- ============================================================

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name VARCHAR(255),
  email VARCHAR(255),
  last_login_at TIMESTAMP,
  password_changed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- Criar índices para melhor performance
CREATE INDEX idx_profiles_email ON public.profiles(email);

-- ============================================================
-- 2. TABELA DE AUDITORIA
-- ============================================================

CREATE TABLE public.audit_logs (
  id BIGSERIAL PRIMARY KEY,
  affected_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  action VARCHAR(100) NOT NULL,
  performed_by_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  details JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT now()
);

-- Índices para melhor performance
CREATE INDEX idx_audit_logs_affected_user ON public.audit_logs(affected_user_id);
CREATE INDEX idx_audit_logs_performed_by ON public.audit_logs(performed_by_id);
CREATE INDEX idx_audit_logs_created_at ON public.audit_logs(created_at DESC);
CREATE INDEX idx_audit_logs_action ON public.audit_logs(action);

-- ============================================================
-- 3. POLÍTICAS RLS (ROW LEVEL SECURITY)
-- ============================================================

-- HABILITAR RLS NAS TABELAS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- PROFILES - POLÍTICAS DE ACESSO

-- Política 1: ADMINS podem ver TODOS os usuários
CREATE POLICY "admin_see_all_profiles"
  ON public.profiles
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.user_roles ur 
      WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
    )
  );

-- Política 2: Qualquer usuário autenticado pode ver SUA PRÓPRIA linha
CREATE POLICY "user_see_own_profile"
  ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Política 3: ADMINS podem ATUALIZAR qualquer usuário
CREATE POLICY "admin_update_all_profiles"
  ON public.profiles
  FOR UPDATE
  USING (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.user_roles ur 
      WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
    )
  )
  WITH CHECK (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.user_roles ur 
      WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
    )
  );

-- Política 4: Usuários podem ATUALIZAR apenas seus próprios dados (SEM poder mudar role)
CREATE POLICY "user_update_own_profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Política 5: ADMINS podem INSERIR novos usuários
CREATE POLICY "admin_create_profiles"
  ON public.profiles
  FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.user_roles ur 
      WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
    )
  );

-- Política 6: ADMINS podem DELETAR usuários
CREATE POLICY "admin_delete_profiles"
  ON public.profiles
  FOR DELETE
  USING (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.user_roles ur 
      WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
    )
  );

-- AUDIT_LOGS - POLÍTICAS DE ACESSO

-- Política 1: ADMINS podem ver TODOS os logs
CREATE POLICY "admin_view_all_audit_logs"
  ON public.audit_logs
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.user_roles ur 
      WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
    )
  );

-- Política 2: Usuários podem ver logs onde fizeram a ação OU foram afetados
CREATE POLICY "user_view_own_audit_logs"
  ON public.audit_logs
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL AND (
      performed_by_id = auth.uid() OR
      affected_user_id = auth.uid()
    )
  );

-- Política 3: Sistema pode INSERIR logs (via funções)
CREATE POLICY "system_insert_audit_logs"
  ON public.audit_logs
  FOR INSERT
  WITH CHECK (true);

-- ============================================================
-- 4. FUNÇÕES PARA OPERAÇÕES DE USUÁRIOS
-- ============================================================

-- Função para promover usuário para admin
CREATE OR REPLACE FUNCTION public.promote_user_to_admin(user_id UUID)
RETURNS JSONB AS $$
DECLARE
  current_admin_id UUID := auth.uid();
  is_admin BOOLEAN;
BEGIN
  -- Verificar se o usuário atual é admin
  SELECT EXISTS(SELECT 1 FROM public.user_roles WHERE user_id = current_admin_id AND role = 'admin')
  INTO is_admin;
  
  IF NOT is_admin THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only admins can promote users');
  END IF;

  -- Não permitir promover a si mesmo
  IF user_id = current_admin_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cannot promote yourself');
  END IF;

  -- Fazer a promoção
  UPDATE public.user_roles SET role = 'admin' WHERE user_id = user_id;

  -- Registrar no audit log
  INSERT INTO public.audit_logs (affected_user_id, action, performed_by_id, details)
  VALUES (user_id, 'PROMOTE_TO_ADMIN', current_admin_id, 
          jsonb_build_object('previous_role', 'user', 'new_role', 'admin'));

  RETURN jsonb_build_object('success', true, 'message', 'User promoted to admin');
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'error', SQLERROR_MESSAGE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para rebaixar admin para user
CREATE OR REPLACE FUNCTION public.demote_admin_to_user(user_id UUID)
RETURNS JSONB AS $$
DECLARE
  current_admin_id UUID := auth.uid();
  admin_count INT;
  is_admin BOOLEAN;
BEGIN
  -- Verificar se o usuário atual é admin
  SELECT EXISTS(SELECT 1 FROM public.user_roles WHERE user_id = current_admin_id AND role = 'admin')
  INTO is_admin;
  
  IF NOT is_admin THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only admins can demote users');
  END IF;

  -- Não permitir rebaixar a si mesmo
  IF user_id = current_admin_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cannot demote yourself');
  END IF;

  -- Contar admins ativos
  SELECT COUNT(*) INTO admin_count FROM public.user_roles WHERE role = 'admin' AND disabled = false;

  -- Não permitir se for o único admin
  IF admin_count <= 1 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cannot demote the last admin');
  END IF;

  -- Fazer o rebaixamento
  UPDATE public.user_roles SET role = 'user' WHERE user_id = user_id;

  -- Registrar no audit log
  INSERT INTO public.audit_logs (affected_user_id, action, performed_by_id, details)
  VALUES (user_id, 'DEMOTE_TO_USER', current_admin_id,
          jsonb_build_object('previous_role', 'admin', 'new_role', 'user'));

  RETURN jsonb_build_object('success', true, 'message', 'User demoted to standard user');
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'error', SQLERROR_MESSAGE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para resetar senha
CREATE OR REPLACE FUNCTION public.reset_user_password(user_id UUID)
RETURNS JSONB AS $$
DECLARE
  current_admin_id UUID := auth.uid();
  temp_password VARCHAR(32);
  is_admin BOOLEAN;
BEGIN
  -- Verificar se o usuário atual é admin
  SELECT EXISTS(SELECT 1 FROM public.user_roles WHERE user_id = current_admin_id AND role = 'admin')
  INTO is_admin;
  
  IF NOT is_admin THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only admins can reset passwords');
  END IF;

  -- Gerar senha temporária
  temp_password := SUBSTRING(MD5(RANDOM()::TEXT), 1, 12);

  -- Atualizar senha do usuário
  UPDATE auth.users 
  SET encrypted_password = crypt(temp_password, gen_salt('bf')),
      email_confirmed_at = now(),
      updated_at = now()
  WHERE id = user_id;

  -- Registrar no audit log
  INSERT INTO public.audit_logs (affected_user_id, action, performed_by_id, details)
  VALUES (user_id, 'RESET_PASSWORD', current_admin_id,
          jsonb_build_object('temp_password_length', LENGTH(temp_password)));

  RETURN jsonb_build_object('success', true, 'temp_password', temp_password, 'message', 'Password reset successfully');
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'error', SQLERROR_MESSAGE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para desativar/ativar usuário
CREATE OR REPLACE FUNCTION public.toggle_user_status(user_id UUID, should_disable BOOLEAN)
RETURNS JSONB AS $$
DECLARE
  current_admin_id UUID := auth.uid();
  current_status BOOLEAN;
  admin_count INT;
  is_admin BOOLEAN;
  user_role VARCHAR(50);
BEGIN
  -- Verificar se o usuário atual é admin
  SELECT EXISTS(SELECT 1 FROM public.user_roles WHERE user_id = current_admin_id AND role = 'admin')
  INTO is_admin;
  
  IF NOT is_admin THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only admins can toggle user status');
  END IF;

  -- Não pode desativar a si mesmo
  IF user_id = current_admin_id AND should_disable THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cannot disable yourself');
  END IF;

  -- Obter role e status atuais
  SELECT role, disabled INTO user_role, current_status FROM public.user_roles WHERE user_id = user_id;

  -- Se tentando desativar um admin, contar se é o último
  IF should_disable AND user_role = 'admin' THEN
    SELECT COUNT(*) INTO admin_count FROM public.user_roles WHERE role = 'admin' AND disabled = false;
    IF admin_count <= 1 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Cannot disable the last admin');
    END IF;
  END IF;

  -- Atualizar status
  UPDATE public.user_roles SET disabled = should_disable WHERE user_id = user_id;

  -- Registrar no audit log
  INSERT INTO public.audit_logs (affected_user_id, action, performed_by_id, details)
  VALUES (user_id, CASE WHEN should_disable THEN 'DISABLE_USER' ELSE 'ENABLE_USER' END, current_admin_id,
          jsonb_build_object('previous_status', CASE WHEN current_status THEN 'disabled' ELSE 'enabled' END,
                           'new_status', CASE WHEN should_disable THEN 'disabled' ELSE 'enabled' END));

  RETURN jsonb_build_object('success', true, 'message', 'User status updated');
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'error', SQLERROR_MESSAGE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para mudar a própria senha
CREATE OR REPLACE FUNCTION public.change_own_password(old_password VARCHAR, new_password VARCHAR)
RETURNS JSONB AS $$
DECLARE
  current_user_id UUID := auth.uid();
  stored_hash VARCHAR;
BEGIN
  -- Obter hash da senha atual
  SELECT encrypted_password INTO stored_hash FROM auth.users WHERE id = current_user_id;

  -- Verificar se a senha antiga está correta
  IF stored_hash IS NULL OR stored_hash != crypt(old_password, stored_hash) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Current password is incorrect');
  END IF;

  -- Atualizar senha
  UPDATE auth.users 
  SET encrypted_password = crypt(new_password, gen_salt('bf')),
      updated_at = now()
  WHERE id = current_user_id;

  -- Atualizar timestamp em profile
  UPDATE public.profiles SET password_changed_at = now(), updated_at = now() WHERE id = current_user_id;

  -- Registrar no audit log
  INSERT INTO public.audit_logs (affected_user_id, action, performed_by_id)
  VALUES (current_user_id, 'CHANGE_OWN_PASSWORD', current_user_id);

  RETURN jsonb_build_object('success', true, 'message', 'Password changed successfully');
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'error', SQLERROR_MESSAGE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para admin alterar senha de outro usuário
CREATE OR REPLACE FUNCTION public.change_user_password_admin(user_id UUID, new_password VARCHAR)
RETURNS JSONB AS $$
DECLARE
  current_admin_id UUID := auth.uid();
  is_admin BOOLEAN;
BEGIN
  -- Verificar se o usuário atual é admin
  SELECT EXISTS(SELECT 1 FROM public.user_roles WHERE user_id = current_admin_id AND role = 'admin')
  INTO is_admin;
  
  IF NOT is_admin THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only admins can change other user passwords');
  END IF;

  -- Atualizar senha
  UPDATE auth.users 
  SET encrypted_password = crypt(new_password, gen_salt('bf')),
      updated_at = now()
  WHERE id = user_id;

  -- Atualizar timestamp em profile
  UPDATE public.profiles SET password_changed_at = now(), updated_at = now() WHERE id = user_id;

  -- Registrar no audit log
  INSERT INTO public.audit_logs (affected_user_id, action, performed_by_id, details)
  VALUES (user_id, 'CHANGE_PASSWORD_ADMIN', current_admin_id,
          jsonb_build_object('force_change_needed', true));

  RETURN jsonb_build_object('success', true, 'message', 'User password changed by admin');
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'error', SQLERROR_MESSAGE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para excluir usuário (com proteção)
CREATE OR REPLACE FUNCTION public.delete_user_admin(user_id UUID)
RETURNS JSONB AS $$
DECLARE
  current_admin_id UUID := auth.uid();
  admin_count INT;
  is_admin BOOLEAN;
  user_email VARCHAR;
  user_role VARCHAR(50);
BEGIN
  -- Verificar se o usuário atual é admin
  SELECT EXISTS(SELECT 1 FROM public.user_roles WHERE user_id = current_admin_id AND role = 'admin')
  INTO is_admin;
  
  IF NOT is_admin THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only admins can delete users');
  END IF;

  -- Não pode deletar a si mesmo
  IF user_id = current_admin_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cannot delete yourself');
  END IF;

  -- Obter email e role do usuário
  SELECT email, role INTO user_email, user_role FROM public.user_roles WHERE user_id = user_id;

  -- Se tentando deletar um admin, contar se é o último
  IF user_role = 'admin' THEN
    SELECT COUNT(*) INTO admin_count FROM public.user_roles WHERE role = 'admin' AND disabled = false;
    IF admin_count <= 1 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Cannot delete the last admin');
    END IF;
  END IF;

  -- Registrar no audit log ANTES de deletar
  INSERT INTO public.audit_logs (affected_user_id, action, performed_by_id, details)
  VALUES (user_id, 'DELETE_USER', current_admin_id,
          jsonb_build_object('email', user_email, 'role', user_role));

  -- Deletar do auth.users (cascade para profiles e user_roles)
  DELETE FROM auth.users WHERE id = user_id;

  RETURN jsonb_build_object('success', true, 'message', 'User deleted successfully');
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'error', SQLERROR_MESSAGE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 5. TRIGGER PARA ATUALIZAR updated_at
-- ============================================================

CREATE OR REPLACE FUNCTION public.update_profiles_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_update_timestamp
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_profiles_timestamp();

-- ============================================================
-- 6. VISUALIZAÇÃO PARA ESTATÍSTICAS
-- ============================================================

CREATE OR REPLACE VIEW public.user_statistics AS
SELECT
  COUNT(*) FILTER (WHERE role = 'admin' AND disabled = false) as active_admins,
  COUNT(*) FILTER (WHERE role = 'user' AND disabled = false) as active_users,
  COUNT(*) FILTER (WHERE disabled = false) as total_active_users,
  COUNT(*) as total_users,
  COUNT(*) FILTER (WHERE disabled = true) as disabled_users
FROM public.user_roles;

-- ============================================================
-- 7. VERIFICAÇÃO FINAL
-- ============================================================

-- Teste 1: Tabelas criadas?
SELECT COUNT(*) as tables_created FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name IN ('profiles', 'audit_logs');

-- Teste 2: Número de políticas RLS criadas
SELECT COUNT(*) as rls_policies_count FROM pg_policies 
WHERE schemaname = 'public' AND tablename IN ('profiles', 'audit_logs');

-- Teste 3: Número de funções criadas
SELECT COUNT(*) as functions_count FROM information_schema.routines 
WHERE routine_schema = 'public' AND routine_name IN (
  'promote_user_to_admin', 
  'demote_admin_to_user', 
  'reset_user_password', 
  'toggle_user_status', 
  'change_own_password', 
  'change_user_password_admin', 
  'delete_user_admin'
);

-- ============================================================
-- 8. PRÓXIMOS PASSOS
-- ============================================================

-- PRÓXIMO: Execute os comandos abaixo para criar o primeiro ADMIN

-- 1. Primeiro, crie um usuário no Supabase (Dashboard > Auth > Users > Add User)
-- 2. Copie o UUID do usuário criado

-- 3. Execute AMBOS os comandos abaixo substituindo os valores:

--    -- Criar profile
--    INSERT INTO public.profiles (id, full_name, email, created_at, updated_at)
--    VALUES (
--      'COPIE-SEU-UUID-AQUI',
--      'Seu Nome Completo',
--      'seu.email@domain.com',
--      now(),
--      now()
--    );
--
--    -- Criar user_role com permissão de admin
--    INSERT INTO public.user_roles (user_id, role, disabled)
--    VALUES (
--      'COPIE-SEU-UUID-AQUI',
--      'admin',
--      false
--    );

-- 4. Depois teste um SELECT para confirmar:
--    SELECT p.id, p.full_name, ur.role FROM public.profiles p 
--    LEFT JOIN public.user_roles ur ON p.id = ur.user_id;

-- ============================================================
-- FIM - Limpeza e Setup Completo
-- ============================================================
