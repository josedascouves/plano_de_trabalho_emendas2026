// Script para criar usuários no Supabase usando Admin API
// Execute: node criar-usuarios.js

import { createClient } from '@supabase/supabase-js';

// Substitua pelas suas credenciais do Supabase
const SUPABASE_URL = 'https://tlpmspfnswaxwqzmwski.supabase.co';
const SUPABASE_ADMIN_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRscG1zcGZuc3dheHdxem13c2tpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDMwMDk1OCwiZXhwIjoyMDg1ODc2OTU4fQ.enjDo9Ob3SwsINnUenmXos81XYf1WE-Bpm_NsG4G-ys';

const supabase = createClient(SUPABASE_URL, SUPABASE_ADMIN_KEY);

const usuarios = [
  {
    email: 'janete.sgueglia@saude.sp.gov.br',
    password: '0052124',
    full_name: 'JANETE LOURENÇO SGUEGLIA',
    cnes: '0052124'
  },
  {
    email: 'lhribeiro@saude.sp.gov.br',
    password: '0052124',
    full_name: 'Lúcia Henrique Ribeiro',
    cnes: '0052124'
  },
  {
    email: 'gtcosta@saude.sp.gov.br',
    password: '0052124',
    full_name: 'Geisel Guimarães Torres Costa',
    cnes: '0052124'
  },
  {
    email: 'casouza@saude.sp.gov.br',
    password: '0052124',
    full_name: 'Cristiane Aparecida Barreto de Souza',
    cnes: '0052124'
  }
];

async function criarUsuarios() {
  console.log('🚀 Iniciando criação de usuários...\n');

  for (const usuario of usuarios) {
    try {
      // 1. Criar usuário em auth.users
      const { data, error } = await supabase.auth.admin.createUser({
        email: usuario.email,
        password: usuario.password,
        email_confirm: true,
        user_metadata: {
          full_name: usuario.full_name,
          cnes: usuario.cnes
        }
      });

      if (error) {
        console.error(`❌ Erro ao criar ${usuario.email}:`, error.message);
        continue;
      }

      const userId = data.user.id;
      console.log(`✅ Usuário criado: ${usuario.email} (ID: ${userId})`);

      // 2. Criar profile
      const { error: profileError } = await supabase
        .from('profiles')
        .insert({
          id: userId,
          email: usuario.email,
          full_name: usuario.full_name,
          cnes: usuario.cnes
        });

      if (profileError) {
        console.error(`❌ Erro ao criar profile para ${usuario.email}:`, profileError.message);
        continue;
      }
      console.log(`✅ Profile criado para ${usuario.email}`);

      // 3. Criar user_role
      const { error: roleError } = await supabase
        .from('user_roles')
        .insert({
          user_id: userId,
          role: 'intermediate',
          disabled: false
        });

      if (roleError) {
        console.error(`❌ Erro ao criar role para ${usuario.email}:`, roleError.message);
        continue;
      }
      console.log(`✅ Role (intermediate) criado para ${usuario.email}\n`);

    } catch (err) {
      console.error(`❌ Erro geral ao processar ${usuario.email}:`, err.message);
    }
  }

  console.log('✨ Processo concluído!');
}

criarUsuarios();
