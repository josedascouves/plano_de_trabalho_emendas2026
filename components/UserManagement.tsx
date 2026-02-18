import React, { useState, useEffect } from 'react';
import {
  Users, Search, Filter, Eye, EyeOff, Lock, Shield, Trash2, AlertCircle,
  ChevronDown, LogOut, Clock, CheckCircle, XCircle, Plus, MoreVertical,
  ChevronUp, Mail, Calendar, RotateCcw
} from 'lucide-react';
import { supabase } from '../supabase';
import { UserProfile, AuditLog, UserStats } from '../types';

const UserManagement: React.FC = () => {
  // ============================================================
  // STATES
  // ============================================================
  const [users, setUsers] = useState<UserProfile[]>([]);
  const [stats, setStats] = useState<UserStats | null>(null);
  const [auditLogs, setAuditLogs] = useState<AuditLog[]>([]);
  const [currentUser, setCurrentUser] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  // UI State
  const [searchQuery, setSearchQuery] = useState('');
  const [roleFilter, setRoleFilter] = useState<'all' | 'admin' | 'user'>('all');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive'>('all');
  const [sortBy, setSortBy] = useState<'name' | 'created' | 'role'>('name');
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc');
  const [showAuditLog, setShowAuditLog] = useState(false);
  const [expandedUser, setExpandedUser] = useState<string | null>(null);

  // Modal States
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [showRoleModal, setShowRoleModal] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [showCreateUser, setShowCreateUser] = useState(false);
  const [selectedUser, setSelectedUser] = useState<UserProfile | null>(null);
  const [passwordInput, setPasswordInput] = useState('');
  const [passwordConfirm, setPasswordConfirm] = useState('');
  const [selectedRole, setSelectedRole] = useState<'admin' | 'user'>('user');
  const [deleteConfirmStep, setDeleteConfirmStep] = useState(0);

  // ============================================================
  // EFEITOS
  // ============================================================

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Obter usuário atual
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        setError('Usuário não autenticado');
        return;
      }

      // Obter profile do usuário atual
      const { data: currentProfile } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single();
      setCurrentUser(currentProfile);

      // Verificar se é admin
      if (currentProfile?.role !== 'admin') {
        setError('Acesso restrito a administradores');
        return;
      }

      // Obter todos os usuários
      const { data: usersData, error: usersError } = await supabase
        .from('profiles')
        .select('*')
        .order('full_name', { ascending: true });

      if (usersError) throw usersError;
      setUsers(usersData || []);

      // Obter estatísticas
      const { data: statsData, error: statsError } = await supabase
        .from('user_statistics')
        .select('*')
        .single();

      if (!statsError) setStats(statsData);

      // Obter logs de auditoria
      const { data: logsData, error: logsError } = await supabase
        .from('audit_logs')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(50);

      if (!logsError) setAuditLogs(logsData || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao carregar dados');
    } finally {
      setLoading(false);
    }
  };

  // ============================================================
  // FUNÇÕES DE MANIPULAÇÃO DE USUÁRIOS
  // ============================================================

  const handleChangePassword = async () => {
    if (!selectedUser) return;
    if (passwordInput !== passwordConfirm) {
      setError('As senhas não correspondem');
      return;
    }

    try {
      const { data, error } = await supabase.rpc('change_user_password_admin', {
        user_id: selectedUser.id,
        new_password: passwordInput,
      });

      if (error) throw error;
      if (!data?.success) throw new Error(data?.error || 'Erro ao alterar senha');

      setSuccess('Senha alterada com sucesso!');
      setShowPasswordModal(false);
      setPasswordInput('');
      setPasswordConfirm('');
      loadData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao alterar senha');
    }
  };

  const handleChangeRole = async () => {
    if (!selectedUser) return;

    try {
      const functionName = selectedRole === 'admin' 
        ? 'promote_user_to_admin'
        : 'demote_admin_to_user';

      const { data, error } = await supabase.rpc(functionName, {
        user_id: selectedUser.id,
      });

      if (error) throw error;
      if (!data?.success) throw new Error(data?.error || 'Erro ao alterar perfil');

      setSuccess('Perfil alterado com sucesso!');
      setShowRoleModal(false);
      loadData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao alterar perfil');
    }
  };

  const handleToggleStatus = async (user: UserProfile) => {
    try {
      const { data, error } = await supabase.rpc('toggle_user_status', {
        user_id: user.id,
        should_disable: !user.disabled,
      });

      if (error) throw error;
      if (!data?.success) throw new Error(data?.error || 'Erro ao alterar status');

      setSuccess(`Usuário ${!user.disabled ? 'desativado' : 'ativado'} com sucesso!`);
      loadData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao alterar status');
    }
  };

  const handleResetPassword = async (user: UserProfile) => {
    try {
      const { data, error } = await supabase.rpc('reset_user_password', {
        user_id: user.id,
      });

      if (error) throw error;
      if (!data?.success) throw new Error(data?.error || 'Erro ao resetar senha');

      alert(`Senha temporária: ${data.temp_password}\n\nCompartilhe este código com o usuário de forma segura.`);
      setSuccess('Senha resetada com sucesso!');
      loadData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao resetar senha');
    }
  };

  const handleDeleteUser = async () => {
    if (!selectedUser) return;

    try {
      const { data, error } = await supabase.rpc('delete_user_admin', {
        user_id: selectedUser.id,
      });

      if (error) throw error;
      if (!data?.success) throw new Error(data?.error || 'Erro ao deletar usuário');

      setSuccess('Usuário deletado com sucesso!');
      setShowDeleteConfirm(false);
      setDeleteConfirmStep(0);
      loadData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao deletar usuário');
    }
  };

  // ============================================================
  // FUNÇÕES DE FILTRO E ORDENAÇÃO
  // ============================================================

  const filteredUsers = users.filter(user => {
    // Filtro de busca
    if (searchQuery.toLowerCase()) {
      const query = searchQuery.toLowerCase();
      if (!user.full_name?.toLowerCase().includes(query) &&
          !user.email?.toLowerCase().includes(query)) {
        return false;
      }
    }

    // Filtro de role
    if (roleFilter !== 'all' && user.role !== roleFilter) {
      return false;
    }

    // Filtro de status
    if (statusFilter === 'active' && user.disabled) return false;
    if (statusFilter === 'inactive' && !user.disabled) return false;

    return true;
  });

  const sortedUsers = [...filteredUsers].sort((a, b) => {
    let compareValue = 0;

    switch (sortBy) {
      case 'name':
        compareValue = (a.full_name || '').localeCompare(b.full_name || '');
        break;
      case 'created':
        compareValue = new Date(a.created_at).getTime() - new Date(b.created_at).getTime();
        break;
      case 'role':
        compareValue = a.role.localeCompare(b.role);
        break;
    }

    return sortOrder === 'asc' ? compareValue : -compareValue;
  });

  // ============================================================
  // RENDER DE COMPONENTES
  // ============================================================

  if (!currentUser) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center text-red-600">
          <AlertCircle className="w-12 h-12 mb-4" />
          <p>{error || 'Somente administradores podem acessar esta página.'}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-gradient-to-br from-slate-900 to-slate-800 min-h-screen p-6">
      <div className="max-w-7xl mx-auto">
        {/* ============================================================
            HEADER
            ============================================================ */}
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold text-white flex items-center gap-3">
              <Users className="w-8 h-8 text-blue-400" />
              Gestão de Usuários
            </h1>
            <p className="text-slate-400 mt-2">Administre usuários, permissões e auditoria</p>
          </div>
          <button
            onClick={() => setShowCreateUser(true)}
            className="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-lg flex items-center gap-2 transition"
          >
            <Plus className="w-5 h-5" />
            Novo Usuário
          </button>
        </div>

        {/* ============================================================
            STATÍSTICAS
            ============================================================ */}
        {stats && (
          <div className="grid grid-cols-1 md:grid-cols-5 gap-4 mb-8">
            <div className="bg-slate-700 rounded-lg p-4 border border-slate-600">
              <p className="text-slate-400 text-sm">Total de Usuários</p>
              <p className="text-2xl font-bold text-white">{stats.total_users}</p>
            </div>
            <div className="bg-green-900 rounded-lg p-4 border border-green-700">
              <p className="text-green-300 text-sm">Ativos</p>
              <p className="text-2xl font-bold text-green-400">{stats.total_active_users}</p>
            </div>
            <div className="bg-slate-700 rounded-lg p-4 border border-slate-600">
              <p className="text-slate-400 text-sm">Administradores</p>
              <p className="text-2xl font-bold text-blue-400">{stats.active_admins}</p>
            </div>
            <div className="bg-slate-700 rounded-lg p-4 border border-slate-600">
              <p className="text-slate-400 text-sm">Usuários Padrão</p>
              <p className="text-2xl font-bold text-slate-300">{stats.active_users}</p>
            </div>
            <div className="bg-red-900 rounded-lg p-4 border border-red-700">
              <p className="text-red-300 text-sm">Desativados</p>
              <p className="text-2xl font-bold text-red-400">{stats.disabled_users}</p>
            </div>
          </div>
        )}

        {/* ============================================================
            FILTROS E BUSCA
            ============================================================ */}
        <div className="bg-slate-700 rounded-lg p-6 mb-6 border border-slate-600">
          <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
            {/* Busca */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-slate-300 mb-2">
                <Search className="w-4 h-4 inline mr-2" />
                Buscar
              </label>
              <input
                type="text"
                placeholder="Nome ou email..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full px-4 py-2 bg-slate-600 border border-slate-500 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:border-blue-500"
              />
            </div>

            {/* Filtro de Perfil */}
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                <Shield className="w-4 h-4 inline mr-2" />
                Perfil
              </label>
              <select
                value={roleFilter}
                onChange={(e) => setRoleFilter(e.target.value as any)}
                className="w-full px-4 py-2 bg-slate-600 border border-slate-500 rounded-lg text-white focus:outline-none focus:border-blue-500"
              >
                <option value="all">Todos</option>
                <option value="admin">Administrador</option>
                <option value="user">Padrão</option>
              </select>
            </div>

            {/* Filtro de Status */}
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                <Filter className="w-4 h-4 inline mr-2" />
                Status
              </label>
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value as any)}
                className="w-full px-4 py-2 bg-slate-600 border border-slate-500 rounded-lg text-white focus:outline-none focus:border-blue-500"
              >
                <option value="all">Todos</option>
                <option value="active">Ativos</option>
                <option value="inactive">Inativos</option>
              </select>
            </div>

            {/* Ordenar */}
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Ordenar por
              </label>
              <div className="flex gap-2">
                <select
                  value={sortBy}
                  onChange={(e) => setSortBy(e.target.value as any)}
                  className="flex-1 px-4 py-2 bg-slate-600 border border-slate-500 rounded-lg text-white focus:outline-none focus:border-blue-500 text-sm"
                >
                  <option value="name">Nome</option>
                  <option value="created">Criação</option>
                  <option value="role">Perfil</option>
                </select>
                <button
                  onClick={() => setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')}
                  className="px-3 py-2 bg-slate-600 border border-slate-500 rounded-lg text-white hover:bg-slate-500 transition"
                >
                  {sortOrder === 'asc' ? <ChevronUp className="w-5 h-5" /> : <ChevronDown className="w-5 h-5" />}
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* ============================================================
            BOTÃO HISTÓRICO
            ============================================================ */}
        <button
          onClick={() => setShowAuditLog(!showAuditLog)}
          className="mb-6 bg-slate-600 hover:bg-slate-500 text-white px-4 py-2 rounded-lg flex items-center gap-2 transition"
        >
          <Clock className="w-5 h-5" />
          {showAuditLog ? 'Ocultar' : 'Ver'} Histórico de Auditoria
        </button>

        {/* ============================================================
            HISTÓRICO DE AUDITORIA
            ============================================================ */}
        {showAuditLog && (
          <div className="bg-slate-700 rounded-lg p-6 mb-6 border border-slate-600 max-h-96 overflow-y-auto">
            <h2 className="text-xl font-bold text-white mb-4">Histórico de Eventos</h2>
            <div className="space-y-2">
              {auditLogs.map((log) => (
                <div key={log.id} className="bg-slate-800 p-3 rounded text-sm border border-slate-600">
                  <div className="flex justify-between items-start">
                    <div className="flex-1">
                      <span className="font-semibold text-blue-400">{log.action}</span>
                      <p className="text-slate-300 text-xs mt-1">
                        {new Date(log.created_at).toLocaleString('pt-BR')}
                      </p>
                    </div>
                    <span className="text-slate-400 text-xs">ID: {log.affected_user_id?.substring(0, 8)}</span>
                  </div>
                  {log.details && (
                    <p className="text-slate-400 text-xs mt-2">
                      {JSON.stringify(log.details)}
                    </p>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}

        {/* ============================================================
            LISTAGEM DE USUÁRIOS
            ============================================================ */}
        <div className="space-y-4">
          <h2 className="text-xl font-bold text-white">
            {sortedUsers.length} usuário{sortedUsers.length !== 1 ? 's' : ''} encontrado{sortedUsers.length !== 1 ? 's' : ''}
          </h2>

          {sortedUsers.map((user) => (
            <div
              key={user.id}
              className="bg-slate-700 rounded-lg border border-slate-600 overflow-hidden transition hover:border-slate-500"
            >
              {/* CARD PRINCIPAL */}
              <div
                className="p-4 flex justify-between items-center cursor-pointer hover:bg-slate-600 transition"
                onClick={() => setExpandedUser(expandedUser === user.id ? null : user.id)}
              >
                <div className="flex items-center gap-4 flex-1">
                  {/* Status Visual */}
                  <div className={`w-3 h-3 rounded-full ${user.disabled ? 'bg-red-500' : 'bg-green-500'}`} />

                  {/* Informações */}
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <h3 className="font-semibold text-white">{user.full_name}</h3>
                      <span className={`px-2 py-1 rounded text-xs font-semibold ${
                        user.role === 'admin'
                          ? 'bg-blue-900 text-blue-300'
                          : 'bg-slate-800 text-slate-300'
                      }`}>
                        {user.role === 'admin' ? '⭐ Admin' : 'Padrão'}
                      </span>
                      {user.disabled && (
                        <span className="px-2 py-1 rounded text-xs font-semibold bg-red-900 text-red-300">
                          ⛔ Desativado
                        </span>
                      )}
                    </div>
                    <p className="text-slate-400 text-sm flex items-center gap-2 mt-1">
                      <Mail className="w-4 h-4" />
                      {user.email}
                    </p>
                    <p className="text-slate-500 text-xs flex items-center gap-2 mt-1">
                      <Calendar className="w-3 h-3" />
                      Criado em {new Date(user.created_at).toLocaleDateString('pt-BR')}
                    </p>
                  </div>
                </div>

                {/* Botão Expandir */}
                <button className="text-slate-400 hover:text-white transition">
                  {expandedUser === user.id ? (
                    <ChevronUp className="w-5 h-5" />
                  ) : (
                    <ChevronDown className="w-5 h-5" />
                  )}
                </button>
              </div>

              {/* DETALHES EXPANDIDOS */}
              {expandedUser === user.id && (
                <div className="bg-slate-800 border-t border-slate-600 p-4">
                  <div className="grid grid-cols-2 gap-4 mb-4">
                    <div>
                      <p className="text-slate-400 text-sm">Email</p>
                      <p className="text-white font-semibold">{user.email}</p>
                    </div>
                    <div>
                      <p className="text-slate-400 text-sm">Perfil</p>
                      <p className="text-white font-semibold">{user.role === 'admin' ? 'Administrador' : 'Padrão'}</p>
                    </div>
                    <div>
                      <p className="text-slate-400 text-sm">Status</p>
                      <p className="text-white font-semibold">{user.disabled ? 'Desativado' : 'Ativo'}</p>
                    </div>
                    <div>
                      <p className="text-slate-400 text-sm">Último Login</p>
                      <p className="text-white font-semibold">
                        {user.last_login_at ? new Date(user.last_login_at).toLocaleDateString('pt-BR') : 'Nunca'}
                      </p>
                    </div>
                  </div>

                  {/* AÇÕES */}
                  <div className="flex gap-2 flex-wrap">
                    {/* Alterar Perfil */}
                    {user.id !== currentUser.id && (
                      <button
                        onClick={() => {
                          setSelectedUser(user);
                          setSelectedRole(user.role === 'admin' ? 'user' : 'admin');
                          setShowRoleModal(true);
                        }}
                        className="bg-blue-600 hover:bg-blue-700 text-white px-3 py-2 rounded text-sm flex items-center gap-2 transition"
                      >
                        <Shield className="w-4 h-4" />
                        Alterar Perfil
                      </button>
                    )}

                    {/* Alterar Senha */}
                    {user.id !== currentUser.id && (
                      <button
                        onClick={() => {
                          setSelectedUser(user);
                          setPasswordInput('');
                          setPasswordConfirm('');
                          setShowPasswordModal(true);
                        }}
                        className="bg-yellow-600 hover:bg-yellow-700 text-white px-3 py-2 rounded text-sm flex items-center gap-2 transition"
                      >
                        <Lock className="w-4 h-4" />
                        Alterar Senha
                      </button>
                    )}

                    {/* Reset Senha */}
                    {user.id !== currentUser.id && (
                      <button
                        onClick={() => handleResetPassword(user)}
                        className="bg-orange-600 hover:bg-orange-700 text-white px-3 py-2 rounded text-sm flex items-center gap-2 transition"
                      >
                        <RotateCcw className="w-4 h-4" />
                        Reset Senha
                      </button>
                    )}

                    {/* Ativar/Desativar */}
                    {user.id !== currentUser.id && (
                      <button
                        onClick={() => handleToggleStatus(user)}
                        className={`${
                          user.disabled
                            ? 'bg-green-600 hover:bg-green-700'
                            : 'bg-red-600 hover:bg-red-700'
                        } text-white px-3 py-2 rounded text-sm flex items-center gap-2 transition`}
                      >
                        {user.disabled ? (
                          <>
                            <Eye className="w-4 h-4" />
                            Ativar
                          </>
                        ) : (
                          <>
                            <EyeOff className="w-4 h-4" />
                            Desativar
                          </>
                        )}
                      </button>
                    )}

                    {/* Deletar */}
                    {user.id !== currentUser.id && (
                      <button
                        onClick={() => {
                          setSelectedUser(user);
                          setDeleteConfirmStep(0);
                          setShowDeleteConfirm(true);
                        }}
                        className="bg-red-700 hover:bg-red-800 text-white px-3 py-2 rounded text-sm flex items-center gap-2 transition"
                      >
                        <Trash2 className="w-4 h-4" />
                        Deletar
                      </button>
                    )}
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* ============================================================
          MODAIS
          ============================================================ */}

      {/* Modal de Alteração de Senha */}
      {showPasswordModal && selectedUser && (
        <Modal
          title="Alterar Senha"
          onClose={() => setShowPasswordModal(false)}
          onConfirm={handleChangePassword}
        >
          <div className="space-y-4">
            <p className="text-slate-300">
              Alterando senha de: <strong>{selectedUser.full_name}</strong>
            </p>
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Nova Senha
              </label>
              <input
                type="password"
                value={passwordInput}
                onChange={(e) => setPasswordInput(e.target.value)}
                placeholder="Digite a nova senha"
                className="w-full px-4 py-2 bg-slate-600 border border-slate-500 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:border-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Confirmar Senha
              </label>
              <input
                type="password"
                value={passwordConfirm}
                onChange={(e) => setPasswordConfirm(e.target.value)}
                placeholder="Confirme a nova senha"
                className="w-full px-4 py-2 bg-slate-600 border border-slate-500 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:border-blue-500"
              />
            </div>
          </div>
        </Modal>
      )}

      {/* Modal de Alteração de Perfil */}
      {showRoleModal && selectedUser && (
        <Modal
          title="Alterar Perfil"
          onClose={() => setShowRoleModal(false)}
          onConfirm={handleChangeRole}
          confirmText="Sim, alterar perfil"
          confirmColor="blue"
        >
          <div className="space-y-4">
            <div className="bg-yellow-900 border border-yellow-700 rounded-lg p-4">
              <p className="text-yellow-300">
                ⚠️ Alterar o perfil modifica as permissões do usuário.
              </p>
            </div>
            <div>
              <p className="text-slate-300 mb-4">
                Alterando perfil de: <strong>{selectedUser.full_name}</strong>
              </p>
              <div className="bg-slate-800 p-4 rounded-lg mb-4">
                <p className="text-slate-400 text-sm">Perfil Atual</p>
                <p className="text-white font-semibold text-lg">
                  {selectedUser.role === 'admin' ? '⭐ Administrador' : '📋 Padrão'}
                </p>
              </div>
              <div className="bg-slate-800 p-4 rounded-lg">
                <p className="text-slate-400 text-sm">Novo Perfil</p>
                <select
                  value={selectedRole}
                  onChange={(e) => setSelectedRole(e.target.value as any)}
                  className="w-full px-4 py-2 bg-slate-700 border border-slate-600 rounded-lg text-white mt-2 focus:outline-none focus:border-blue-500"
                >
                  <option value="admin">⭐ Administrador</option>
                  <option value="user">📋 Padrão</option>
                </select>
              </div>
            </div>
          </div>
        </Modal>
      )}

      {/* Modal de Confirmação de Exclusão */}
      {showDeleteConfirm && selectedUser && (
        <Modal
          title="Deletar Usuário"
          onClose={() => {
            setShowDeleteConfirm(false);
            setDeleteConfirmStep(0);
          }}
          onConfirm={() => {
            if (deleteConfirmStep === 0) {
              setDeleteConfirmStep(1);
            } else {
              handleDeleteUser();
            }
          }}
          confirmText={deleteConfirmStep === 1 ? 'Deletar Permanentemente' : 'Próximo'}
          confirmColor={deleteConfirmStep === 1 ? 'red' : 'blue'}
          disableConfirm={false}
        >
          <div className="space-y-4">
            {deleteConfirmStep === 0 ? (
              <>
                <div className="bg-red-900 border border-red-700 rounded-lg p-4">
                  <p className="text-red-300">
                    ⚠️ AVISO: Esta ação é irreversível!
                  </p>
                </div>
                <p className="text-slate-300">
                  Tem certeza de que deseja deletar o usuário <strong>{selectedUser.full_name}</strong>?
                </p>
                <p className="text-slate-400 text-sm">
                  Ao clicar em "Próximo", você será solicitado a confirmar novamente por segurança.
                </p>
              </>
            ) : (
              <>
                <div className="bg-red-900 border border-red-700 rounded-lg p-4">
                  <p className="text-red-300">
                    ⚠️ Segunda Confirmação Necessária
                  </p>
                </div>
                <p className="text-slate-300">
                  Email do usuário a ser deletado:
                </p>
                <p className="text-slate-200 font-semibold bg-slate-800 p-3 rounded border border-slate-700">
                  {selectedUser.email}
                </p>
                <p className="text-slate-400 text-sm">
                  Esta é a última chance de cancelar. Clique em "Deletar Permanentemente" para confirmar irreversivelmente.
                </p>
              </>
            )}
          </div>
        </Modal>
      )}

      {/* Mensagens de Erro/Sucesso */}
      {error && (
        <div className="fixed bottom-4 right-4 bg-red-600 text-white px-6 py-3 rounded-lg flex items-center gap-2 shadow-lg">
          <XCircle className="w-5 h-5" />
          {error}
          <button onClick={() => setError(null)} className="ml-4 font-bold">✕</button>
        </div>
      )}
      {success && (
        <div className="fixed bottom-4 right-4 bg-green-600 text-white px-6 py-3 rounded-lg flex items-center gap-2 shadow-lg">
          <CheckCircle className="w-5 h-5" />
          {success}
          <button onClick={() => setSuccess(null)} className="ml-4 font-bold">✕</button>
        </div>
      )}
    </div>
  );
};

// ============================================================
// COMPONENTE Modal Reutilizável
// ============================================================

interface ModalProps {
  title: string;
  children: React.ReactNode;
  onClose: () => void;
  onConfirm: () => void;
  confirmText?: string;
  confirmColor?: 'blue' | 'red' | 'yellow' | 'green';
  disableConfirm?: boolean;
}

const Modal: React.FC<ModalProps> = ({
  title,
  children,
  onClose,
  onConfirm,
  confirmText = 'Confirmar',
  confirmColor = 'blue',
  disableConfirm = false,
}) => {
  const colorClasses = {
    blue: 'bg-blue-600 hover:bg-blue-700',
    red: 'bg-red-600 hover:bg-red-700',
    yellow: 'bg-yellow-600 hover:bg-yellow-700',
    green: 'bg-green-600 hover:bg-green-700',
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-slate-800 rounded-lg shadow-xl max-w-md w-full mx-4 border border-slate-700">
        {/* Header */}
        <div className="border-b border-slate-700 p-6">
          <h2 className="text-xl font-bold text-white">{title}</h2>
        </div>

        {/* Content */}
        <div className="p-6">
          {children}
        </div>

        {/* Footer */}
        <div className="border-t border-slate-700 p-6 flex justify-end gap-3">
          <button
            onClick={onClose}
            className="px-6 py-2 bg-slate-700 hover:bg-slate-600 text-white rounded-lg transition"
          >
            Cancelar
          </button>
          <button
            onClick={onConfirm}
            disabled={disableConfirm}
            className={`px-6 py-2 ${colorClasses[confirmColor]} text-white rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed`}
          >
            {confirmText}
          </button>
        </div>
      </div>
    </div>
  );
};

export default UserManagement;
