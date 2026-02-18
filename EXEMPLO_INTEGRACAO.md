# 📋 EXEMPLO DE INTEGRAÇÃO - UserManagement

## 🎯 Como Integrar o Novo Componente UserManagement

### Opção 1: Importar e Usar Diretamente

```tsx
// Em App.tsx
import UserManagement from './components/UserManagement';

function App() {
  const [showUserManagement, setShowUserManagement] = useState(false);

  return (
    <div>
      {/* Seu conteúdo... */}
      
      {/* Botão para abrir */}
      <button onClick={() => setShowUserManagement(true)}>
        Gerenciar Usuários
      </button>

      {/* Modal ou página de gestão */}
      {showUserManagement && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg w-11/12 max-h-[90vh] overflow-auto">
            <UserManagement />
            <button 
              onClick={() => setShowUserManagement(false)}
              className="mt-4 px-4 py-2 bg-blue-600 text-white rounded"
            >
              Fechar
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
```

### Opção 2: Criar uma Rota Separada

```tsx
// Em App.tsx - se usando React Router
import { Routes, Route } from 'react-router-dom';
import UserManagement from './components/UserManagement';

function App() {
  return (
    <Routes>
      {/* Outras rotas... */}
      
      <Route 
        path="/admin/usuarios" 
        element={
          <AdminLayout>
            <UserManagement />
          </AdminLayout>
        } 
      />
    </Routes>
  );
}
```

### Opção 3: Integrar no Dashboard Administrativo

```tsx
// Em um novo arquivo: components/AdminDashboard.tsx
import React, { useState } from 'react';
import UserManagement from './UserManagement';
import { Users, Settings, BarChart3 } from 'lucide-react';

interface TabProps {
  id: string;
  label: string;
  icon: React.ComponentType<any>;
}

const AdminDashboard: React.FC = () => {
  const [activeTab, setActiveTab] = useState('users');

  const tabs: TabProps[] = [
    { id: 'users', label: 'Gestão de Usuários', icon: Users },
    { id: 'settings', label: 'Configurações', icon: Settings },
    { id: 'analytics', label: 'Relatórios', icon: BarChart3 },
  ];

  return (
    <div className="bg-slate-900 min-h-screen p-6">
      <div className="max-w-7xl mx-auto">
        {/* Cabeçalho */}
        <h1 className="text-4xl font-bold text-white mb-8">Painel Administrativo</h1>

        {/* Abas */}
        <div className="flex gap-4 mb-8 border-b border-slate-700">
          {tabs.map(tab => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`px-4 py-3 flex items-center gap-2 font-semibold transition ${
                  activeTab === tab.id
                    ? 'text-blue-400 border-b-2 border-blue-400'
                    : 'text-slate-400 hover:text-slate-300'
                }`}
              >
                <Icon className="w-5 h-5" />
                {tab.label}
              </button>
            );
          })}
        </div>

        {/* Conteúdo da Aba */}
        <div>
          {activeTab === 'users' && <UserManagement />}
          {activeTab === 'settings' && <div>Configurações em breve...</div>}
          {activeTab === 'analytics' && <div>Relatórios em breve...</div>}
        </div>
      </div>
    </div>
  );
};

export default AdminDashboard;
```

## 🔗 Adicionar Link no Menu Principal

No seu menu de navegação, adicione:

```tsx
{currentUser?.role === 'admin' && (
  <button
    onClick={() => navigate('/admin/usuarios')}
    className="flex items-center gap-2 px-4 py-2 hover:bg-slate-700 rounded"
  >
    <Users className="w-5 h-5" />
    Gerenciar Usuários
  </button>
)}
```

## 🔄 Fluxo de Autenticação e Redirecionamento

```tsx
// Após login bem-sucedido:
useEffect(() => {
  const checkAuth = async () => {
    const { data } = await supabase.auth.getUser();
    
    if (data?.user) {
      // Obter perfil
      const { data: profile } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', data.user.id)
        .single();

      if (profile?.role !== 'admin') {
        // Redirecionar para página do usuário padrão
        navigate('/dashboard');
      } else {
        // Permitir acesso admin
        setCurrentUser(profile);
      }
    }
  };

  checkAuth();
}, []);
```

## 📊 Exemplo Completo no App.tsx

Here's how to integrate everything:

```tsx
import React, { useState, useEffect } from 'react';
import { Users as UsersIcon, ChevronDown } from 'lucide-react';
import UserManagement from './components/UserManagement';
import { supabase } from './supabase';

const App: React.FC = () => {
  const [currentUser, setCurrentUser] = useState<any>(null);
  const [showUserMenu, setShowUserMenu] = useState(false);
  const [showUserManagement, setShowUserManagement] = useState(false);

  // Verificar autenticação
  useEffect(() => {
    const getCurrentUser = async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        const { data: profile } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single();
        setCurrentUser(profile);
      }
    };

    getCurrentUser();
  }, []);

  return (
    <div className="bg-gradient-to-br from-slate-900 to-slate-800 min-h-screen">
      {/* Navbar */}
      <nav className="bg-slate-800 border-b border-slate-700 p-4">
        <div className="flex justify-between items-center max-w-7xl mx-auto">
          <h1 className="text-2xl font-bold text-white">Plano de Trabalho</h1>

          {currentUser && (
            <div className="relative">
              <button
                onClick={() => setShowUserMenu(!showUserMenu)}
                className="flex items-center gap-2 px-4 py-2 bg-slate-700 hover:bg-slate-600 rounded-lg text-white transition"
              >
                {currentUser.full_name}
                <ChevronDown className="w-4 h-4" />
              </button>

              {showUserMenu && (
                <div className="absolute right-0 mt-2 w-48 bg-slate-700 border border-slate-600 rounded-lg shadow-lg py-2 z-10">
                  {currentUser.role === 'admin' && (
                    <button
                      onClick={() => {
                        setShowUserManagement(true);
                        setShowUserMenu(false);
                      }}
                      className="w-full text-left px-4 py-2 hover:bg-slate-600 text-white flex items-center gap-2"
                    >
                      <UsersIcon className="w-4 h-4" />
                      Gerenciar Usuários
                    </button>
                  )}
                  <button
                    onClick={async () => {
                      await supabase.auth.signOut();
                      setCurrentUser(null);
                    }}
                    className="w-full text-left px-4 py-2 hover:bg-slate-600 text-white"
                  >
                    Logout
                  </button>
                </div>
              )}
            </div>
          )}
        </div>
      </nav>

      {/* Conteúdo Principal */}
      <main className="max-w-7xl mx-auto p-6">
        {showUserManagement ? (
          <>
            <button
              onClick={() => setShowUserManagement(false)}
              className="mb-4 px-4 py-2 bg-slate-700 hover:bg-slate-600 text-white rounded-lg"
            >
              ← Voltar
            </button>
            <UserManagement />
          </>
        ) : (
          <div>
            {/* Seu conteúdo aqui */}
            <h2 className="text-3xl font-bold text-white">Bem-vindo!</h2>
          </div>
        )}
      </main>
    </div>
  );
};

export default App;
```

## 🎨 CSS Necessário (Tailwind)

O componente `UserManagement` usa Tailwind CSS. Certifique-se de que está configurado em `tailwind.config.js`:

```js
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        slate: {
          700: '#334155',
          800: '#1e293b',
          900: '#0f172a',
        },
      },
    },
  },
  plugins: [],
}
```

## 📦 Dependências Necessárias

Certifique-se de instalar:

```bash
npm install lucide-react
```

Já deve estar instalado segundo o `package.json`, mas confirme:

```bash
npm ls lucide-react
```

## ✅ Checklist de Integração

- [ ] Execute `setup-rbac-completo.sql`
- [ ] Atualize `types.ts` (já feito)
- [ ] Copie `components/UserManagement.tsx` para seu projeto
- [ ] Importe `UserManagement` em `App.tsx`
- [ ] Adicione rota ou estado para mostrar/ocultar
- [ ] Teste login com usuário admin
- [ ] Teste criação de novo usuário
- [ ] Teste alteração de perfil
- [ ] Teste alteração de senha
- [ ] Teste logs de auditoria
- [ ] Implemente rate limiting/segurança adicional se necessário

## 🧪 Testes Recomendados

```typescript
// 1. Teste: Criar novo admin
// Resultado: Nova entrada em profiles com role='admin'

// 2. Teste: Tentar rebaixar último admin
// Resultado: Erro "Cannot demote the last admin"

// 3. Teste: Alterar própria senha
// Resultado: Sucesso, log registrado

// 4. Teste: Admin alterar senha de outro
// Resultado: Sucesso, senha temporária exibida

// 5. Teste: Deletar com dupla confirmação
// Resultado: Dois modais e exclusão completa

// 6. Teste: Verificar RLS
// Resultado: Usuário comum não consegue ver audit_logs
```

## 🚀 Próximos Passos

1. **Implementar Email**: Enviar senha temporária por email
2. **2FA**: Autenticação de dois fatores
3. **Rate Limiting**: Proteção contra força bruta
4. **Backup de Senhas**: Hash mais seguro
5. **SSO**: Integração com provedores de identidade

