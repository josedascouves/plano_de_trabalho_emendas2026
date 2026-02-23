#!/usr/bin/env node

/**
 * Script para importar usuários do CSV para o Supabase
 * Uso: node scripts/import-users.js <caminho-do-csv>
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Configurações do Supabase
const SUPABASE_URL = 'https://tlpmspfnswaxwqzmwski.supabase.co';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_SERVICE_KEY) {
  console.error('❌ Erro: SUPABASE_SERVICE_ROLE_KEY não está definido');
  console.error('   Defina a variável de ambiente com a chave de serviço');
  process.exit(1);
}

// Função para fazer requisições HTTP
async function request(method, endpoint, body = null) {
  const url = `${SUPABASE_URL}/rest/v1${endpoint}`;
  
  const options = {
    method,
    headers: {
      'Content-Type': 'application/json',
      'apikey': SUPABASE_SERVICE_KEY,
      'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
    },
  };

  if (body) {
    options.body = JSON.stringify(body);
  }

  const response = await fetch(url, options);
  
  if (!response.ok) {
    const error = await response.text();
    throw new Error(`${response.status}: ${error}`);
  }

  const contentType = response.headers.get('content-type');
  if (contentType && contentType.includes('application/json')) {
    return await response.json();
  }
  
  return null;
}

// Função para criar usuário via API de Auth
async function createUser(email, password, metadata = {}) {
  const url = `${SUPABASE_URL}/auth/v1/admin/users`;
  
  const options = {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'apikey': SUPABASE_SERVICE_KEY,
      'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
    },
    body: JSON.stringify({
      email,
      password,
      email_confirm: true,
      user_metadata: metadata,
    }),
  };

  const response = await fetch(url, options);
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(`Erro ao criar usuário ${email}: ${error.message || JSON.stringify(error)}`);
  }

  return await response.json();
}

// Função para parsear CSV
async function parseCSV(filePath) {
  return new Promise((resolve, reject) => {
    const lines = [];
    const fileStream = fs.createReadStream(filePath, { encoding: 'utf8' });

    const rl = readline.createInterface({
      input: fileStream,
      crlfDelay: Infinity,
    });

    rl.on('line', (line) => {
      lines.push(line);
    });

    rl.on('close', () => {
      resolve(lines);
    });

    rl.on('error', reject);
  });
}

// Função para processar os dados do CSV
function processCSVLines(lines) {
  if (lines.length === 0) {
    throw new Error('Arquivo CSV vazio');
  }

  // Pular cabeçalho
  const users = [];
  
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) continue;

    // Parse do CSV com suporte a campos com ponto-e-vírgula
    const parts = line.split(';');
    if (parts.length < 4) continue;

    const [name, email, cnes, password] = parts.map(p => p.trim());

    // Validar email
    if (!email || !email.includes('@')) {
      console.warn(`⚠️  Linha ${i + 1}: Email inválido "${email}", pulando...`);
      continue;
    }

    users.push({
      name: name || `Usuário ${i}`,
      email: email.toLowerCase(),
      cnes: cnes || null,
      password: password || cnes || 'senha123', // Usar CNES como senha se não houver
    });
  }

  return users;
}

// Função principal
async function main() {
  const csvPath = process.argv[2];

  if (!csvPath) {
    console.error('❌ Erro: Caminho do CSV não fornecido');
    console.log('Uso: node scripts/import-users.js <caminho-do-csv>');
    process.exit(1);
  }

  if (!fs.existsSync(csvPath)) {
    console.error(`❌ Erro: Arquivo não encontrado: ${csvPath}`);
    process.exit(1);
  }

  console.log('📥 Lendo arquivo CSV...');
  const lines = await parseCSV(csvPath);
  
  console.log('📋 Processando dados...');
  const users = processCSVLines(lines);

  if (users.length === 0) {
    console.error('❌ Nenhum usuário válido encontrado no CSV');
    process.exit(1);
  }

  console.log(`\n✅ ${users.length} usuários encontrados\n`);
  console.log('Usuários a serem criados:');
  users.forEach((u, i) => {
    console.log(`  ${i + 1}. ${u.name} (${u.email}) - CNES: ${u.cnes || 'N/A'}`);
  });
  console.log('');

  // Confirmar antes de criar
  const confirmPrompt = 'Deseja continuar com a importação? (s/n): ';
  process.stdout.write(confirmPrompt);

  let confirmed = false;
  await new Promise((resolve) => {
    process.stdin.once('data', (data) => {
      confirmed = data.toString().trim().toLowerCase() === 's';
      resolve();
    });
  });

  if (!confirmed) {
    console.log('❌ Importação cancelada');
    process.exit(0);
  }

  console.log('\n🚀 Iniciando importação...\n');

  let successCount = 0;
  let errorCount = 0;

  for (let i = 0; i < users.length; i++) {
    const user = users[i];
    const progress = `[${i + 1}/${users.length}]`;

    try {
      const createdUser = await createUser(user.email, user.password, {
        full_name: user.name,
        cnes: user.cnes,
      });

      console.log(`✅ ${progress} ${user.email} criado com sucesso`);
      successCount++;

      // Pequeno delay para não sobrecarregar a API
      await new Promise(resolve => setTimeout(resolve, 500));
    } catch (error) {
      console.error(`❌ ${progress} Erro ao criar ${user.email}: ${error.message}`);
      errorCount++;
    }
  }

  console.log(`\n📊 Resultado Final:`);
  console.log(`   ✅ Criados: ${successCount}`);
  console.log(`   ❌ Erros: ${errorCount}`);

  if (errorCount === 0) {
    console.log('\n🎉 Importação concluída com sucesso!');
  } else {
    console.log('\n⚠️  Importação concluída com alguns erros.');
  }

  process.exit(errorCount > 0 ? 1 : 0);
}

main().catch((error) => {
  console.error('❌ Erro fatal:', error.message);
  process.exit(1);
});
