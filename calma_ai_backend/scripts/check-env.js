/**
 * Script independente para verificar variáveis de ambiente
 * Uso: node scripts/check-env.js
 */

const fs = require('fs');
const path = require('path');

// Carregar variáveis de ambiente manualmente
const envPath = path.join(process.cwd(), '.env');
let envVars = {};

try {
  const envContent = fs.readFileSync(envPath, 'utf8');
  envContent.split('\n').forEach(line => {
    const match = line.match(/^\s*([\w.-]+)\s*=\s*(.*)?\s*$/);
    if (match) {
      envVars[match[1]] = match[2] || '';
    }
  });
} catch (error) {
  console.error('Erro ao ler arquivo .env:', error.message);
  process.exit(1);
}

// Lista de variáveis obrigatórias
const requiredVars = [
  'PORT',
  'MONGODB_URI',
  'JWT_SECRET'
];

// Verificar variáveis obrigatórias
const missingVars = requiredVars.filter(varName => !envVars[varName]);

if (missingVars.length > 0) {
  console.error('Variáveis de ambiente obrigatórias não encontradas:');
  console.error(missingVars.join(', '));
  process.exit(1);
}

// Verificar força do JWT_SECRET
if (envVars.JWT_SECRET && envVars.JWT_SECRET.length < 32) {
  console.error('JWT_SECRET é muito curto. Deve ter pelo menos 32 caracteres.');
  process.exit(1);
}

console.log('Verificação de variáveis de ambiente concluída com sucesso.');