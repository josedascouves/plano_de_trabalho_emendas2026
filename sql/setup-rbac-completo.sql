-- ============================================================
-- SETUP RBAC COMPLETO - GESTÃO DE USUÁRIOS (CORRIGIDO)
-- Sistema de Controle de Acesso Baseado em Papéis
-- ============================================================

-- ============================================================
-- 1. TABELA DE PROFILES (USUÁRIOS) COM RBAC - RECRIADA
-- ============================================================

-- PASSO 1: Desabilitar RLS temporariamente para recriação
ALTER TABLE IF EXISTS public.profiles DISABLE ROW LEVEL SECURITY;

-- PASSO 2: Deletar políticas antigas se existirem
DROP POLICY IF EXISTS "Admins can view all users" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Admins can update any user" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Admins can create users" ON profiles;
DROP POLICY IF EXISTS "Admins can delete users" ON profiles;

-- PASSO 3: Deletar triggers antigos
DROP TRIGGER IF EXISTS profiles_update_timestamp ON profiles;

-- PASSO 4: Recrear tabela completamente
DROP TABLE IF EXISTS public.profiles CASCADE;

-- PASSO 5: Criar tabela nova e limpa
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user')),
  full_name VARCHAR(255),
  email VARCHAR(255),
  disabled BOOLEAN DEFAULT FALSE,
  last_login_at TIMESTAMP,
  password_changed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- PASSO 6: Criar índices
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_disabled ON public.profiles(disabled);

-- ============================================================
-- 2. TABELA DE AUDITORIA
-- ============================================================

CREATE TABLE IF NOT EXISTS public.audit_logs (
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
CREATE INDEX IF NOT EXISTS idx_audit_logs_affected_user ON public.audit_logs(affected_user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_performed_by ON public.audit_logs(performed_by_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON public.audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON public.audit_logs(action);

-- ============================================================
-- 3. POLÍTICAS RLS (ROW LEVEL SECURITY) - REVISADAS
-- ============================================================

-- Limpar todas as políticas antigas
DROP POLICY IF EXISTS "Users can view own audit" ON audit_logs;
DROP POLICY IF EXISTS "System can insert audit logs" ON audit_logs;

-- HABILITAR RLS NAS TABELAS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PROFILES - POLÍTICAS DE ACESSO
-- ============================================================

-- Política 1: ADMINS podem ver TODOS os usuários
CREATE POLICY "admin_see_all_profiles"
  ON public.profiles
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role = 'admin'
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
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  )
  WITH CHECK (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- Política 4: Usuários podem ATUALIZAR apenas seus próprios dados (SEM poder mudar role)
CREATE POLICY "user_update_own_profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (
    auth.uid() = id AND
    role = (SELECT role FROM public.profiles WHERE id = auth.uid())
  );

-- Política 5: ADMINS podem INSERIR novos usuários
CREATE POLICY "admin_create_profiles"
  ON public.profiles
  FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- Política 6: ADMINS podem DELETAR usuários (mas não a si mesmos - isso é validado na função)
CREATE POLICY "admin_delete_profiles"
  ON public.profiles
  FOR DELETE
  USING (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- ============================================================
-- AUDIT_LOGS - POLÍTICAS DE ACESSO SIMPLIFICADAS
-- ============================================================

-- Política 1: ADMINS podem ver TODOS os logs
CREATE POLICY "admin_view_all_audit_logs"
  ON public.audit_logs
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- Política 2: Usuários podem ver logs onde ELES fizeram a ação OU foram afetados
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
-- 4. FUNÇÕES PARA OPERAÇÕES DE USUÁRIOS - REVISADAS
-- ============================================================

-- Função para promover usuário para admin
CREATE OR REPLACE FUNCTION public.promote_user_to_admin(user_id UUID)
RETURNS JSONB AS $$
DECLARE
  current_admin_id UUID := auth.uid();
  is_admin BOOLEAN;
  result JSONB;
BEGIN
  -- Verificar se o usuário atual é admin
  SELECT EXISTS(SELECT 1 FROM public.profiles WHERE id = current_admin_id AND role = 'admin')
  INTO is_admin;
  
  IF NOT is_admin THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only admins can promote users');
  END IF;

  -- Não permitir promover a si mesmo
  IF user_id = current_admin_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cannot promote yourself');
  END IF;

  -- Fazer a promoção
  UPDATE public.profiles SET role = 'admin', updated_at = now() WHERE id = user_id;

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
  result JSONB;
BEGIN
  -- Verificar se o usuário atual é admin
  SELECT EXISTS(SELECT 1 FROM public.profiles WHERE id = current_admin_id AND role = 'admin')
  INTO is_admin;
  
  IF NOT is_admin THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only admins can demote users');
  END IF;

  -- Não permitir rebaixar a si mesmo
  IF user_id = current_admin_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cannot demote yourself');
  END IF;

  -- Contar admins ativos
  SELECT COUNT(*) INTO admin_count FROM public.profiles WHERE role = 'admin' AND disabled = false;

  -- Não permitir se for o único admin
  IF admin_count <= 1 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cannot demote the last admin');
  END IF;

  -- Fazer o rebaixamento
  UPDATE public.profiles SET role = 'user', updated_at = now() WHERE id = user_id;

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
  result JSONB;
BEGIN
  -- Verificar se o usuário atual é admin
  SELECT EXISTS(SELECT 1 FROM public.profiles WHERE id = current_admin_id AND role = 'admin')
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
  result JSONB;
BEGIN
  -- Verificar se o usuário atual é admin
  SELECT EXISTS(SELECT 1 FROM public.profiles WHERE id = current_admin_id AND role = 'admin')
  INTO is_admin;
  
  IF NOT is_admin THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only admins can toggle user status');
  END IF;

  -- Não pode desativar a si mesmo
  IF user_id = current_admin_id AND should_disable THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cannot disable yourself');
  END IF;

  -- Obter role e status atuais
  SELECT role, disabled INTO user_role, current_status FROM public.profiles WHERE id = user_id;

  -- Se tentando desativar um admin, contar se é o último
  IF should_disable AND user_role = 'admin' THEN
    SELECT COUNT(*) INTO admin_count FROM public.profiles WHERE role = 'admin' AND disabled = false;
    IF admin_count <= 1 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Cannot disable the last admin');
    END IF;
  END IF;

  -- Atualizar status
  UPDATE public.profiles SET disabled = should_disable, updated_at = now() WHERE id = user_id;

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

  -- Atualizar timestamp
  UPDATE public.profiles SET password_changed_at = now() WHERE id = current_user_id;

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
  SELECT EXISTS(SELECT 1 FROM public.profiles WHERE id = current_admin_id AND role = 'admin')
  INTO is_admin;
  
  IF NOT is_admin THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only admins can change other user passwords');
  END IF;

  -- Atualizar senha
  UPDATE auth.users 
  SET encrypted_password = crypt(new_password, gen_salt('bf')),
      updated_at = now()
  WHERE id = user_id;

  -- Atualizar timestamp
  UPDATE public.profiles SET password_changed_at = now() WHERE id = user_id;

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
  SELECT EXISTS(SELECT 1 FROM public.profiles WHERE id = current_admin_id AND role = 'admin')
  INTO is_admin;
  
  IF NOT is_admin THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only admins can delete users');
  END IF;

  -- Não pode deletar a si mesmo
  IF user_id = current_admin_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cannot delete yourself');
  END IF;

  -- Obter email e role do usuário
  SELECT email, role INTO user_email, user_role FROM public.profiles WHERE id = user_id;

  -- Se tentando deletar um admin, contar se é o último
  IF user_role = 'admin' THEN
    SELECT COUNT(*) INTO admin_count FROM public.profiles WHERE role = 'admin' AND disabled = false;
    IF admin_count <= 1 THEN
      RETURN jsonb_build_object('success', false, 'error', 'Cannot delete the last admin');
    END IF;
  END IF;

  -- Registrar no audit log ANTES de deletar
  INSERT INTO public.audit_logs (affected_user_id, action, performed_by_id, details)
  VALUES (user_id, 'DELETE_USER', current_admin_id,
          jsonb_build_object('email', user_email, 'role', user_role));

  -- Deletar do auth.users (cascade para profiles)
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

DROP TRIGGER IF EXISTS profiles_update_timestamp ON public.profiles;
CREATE TRIGGER profiles_update_timestamp
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_profiles_timestamp();

-- ============================================================
-- 6. VISUALIZAÇÃO PARA ESTATÍSTICAS
-- ============================================================

DROP VIEW IF EXISTS public.user_statistics;
CREATE OR REPLACE VIEW public.user_statistics AS
SELECT
  COUNT(*) FILTER (WHERE role = 'admin' AND disabled = false) as active_admins,
  COUNT(*) FILTER (WHERE role = 'user' AND disabled = false) as active_users,
  COUNT(*) FILTER (WHERE disabled = false) as total_active_users,
  COUNT(*) as total_users,
  COUNT(*) FILTER (WHERE disabled = true) as disabled_users
FROM public.profiles;

-- ============================================================
-- 7. DADOS INICIAIS - CRIAR ADMIN OU VERIFICAR
-- ============================================================

-- Verificação: Contar profiles
-- SELECT COUNT(*) as total_profiles FROM public.profiles;

-- PRIMEIRO ADMIN - Execute DEPOIS de criar usuário no Auth:
-- SUBSTITUA OS VALORES!
-- INSERT INTO public.profiles (id, role, full_name, email, created_at, updated_at)
-- VALUES (
--   'seu-uuid-aqui',
--   'admin',
--   'Seu Nome Completo',
--   'seu.email@domain.com',
--   now(),
--   now()
-- )
-- ON CONFLICT (id) DO UPDATE SET role = 'admin';

-- ============================================================
-- 8. VERIFICAÇÃO FINAL - EXECUTAR PARA VALIDAR SETUP
-- ============================================================

-- Test 1: Tabelas criadas?
-- SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename IN ('profiles', 'audit_logs');

-- Test 2: RLS habilitado?
-- SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename IN ('profiles', 'audit_logs');

-- Test 3: Política RLS criadas?
-- SELECT policyname, tablename FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, policyname;

-- Test 4: Funções criadas?
-- SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public' AND routine_name LIKE '%admin_%' OR routine_name LIKE '%password%' OR routine_name LIKE '%toggle%';

-- Test 5: Usuários existem?
-- SELECT id, full_name, email, role, disabled FROM public.profiles;

-- ============================================================
-- 9. TROUBLESHOOTING - SE HAJ PROBLEMAS
-- ============================================================

-- Se políticas RLS estão bloqueando:
-- ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
-- Depois execute o setup novamente

-- Se tabela profiles estava quebrada:
-- DROP TABLE IF EXISTS public.profiles CASCADE;
-- DROP TABLE IF EXISTS public.audit_logs CASCADE;
-- Depois execute do início

-- Listar TODAS as policies:
-- SELECT * FROM pg_policies WHERE schemaname = 'public';

-- ============================================================
-- FIM DO SETUP RBAC
-- ============================================================

