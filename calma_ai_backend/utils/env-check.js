/**
 * Script para verificar se todas as variáveis de ambiente necessárias estão definidas
 */

const dotenv = require('dotenv');
dotenv.config();

// Lista de variáveis de ambiente necessárias
const requiredEnvVars = [
  'PORT',
  'MONGODB_URI',
  'JWT_SECRET',
  'FIREBASE_PROJECT_ID'
];

// Variáveis opcionais (recomendadas, mas não obrigatórias)
const optionalEnvVars = [
  'FIREBASE_CLIENT_EMAIL',
  'FIREBASE_PRIVATE_KEY',
  'HF_API_KEY'
];

console.log('Verificando variáveis de ambiente...');

// Verificar variáveis obrigatórias
let missingRequired = false;
for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    console.error(`ERRO: Variável de ambiente obrigatória ${envVar} não está definida no arquivo .env`);
    missingRequired = true;
  } else {
    console.log(`✓ ${envVar}: Definido`);
  }
}

// Verificar variáveis opcionais
for (const envVar of optionalEnvVars) {
  if (!process.env[envVar]) {
    console.warn(`AVISO: Variável de ambiente opcional ${envVar} não está definida no arquivo .env`);
  } else {
    console.log(`✓ ${envVar}: Definido`);
  }
}

if (missingRequired) {
  console.error('Algumas variáveis de ambiente obrigatórias estão faltando. Por favor, verifique seu arquivo .env');
  process.exit(1);
} else {
  console.log('Todas as variáveis de ambiente obrigatórias estão definidas!');
}