/**
 * Script independente para criptografar/descriptografar o arquivo .env
 * Uso: 
 *   - Para criptografar: node scripts/secure-env.js encrypt senha123
 *   - Para descriptografar: node scripts/secure-env.js decrypt senha123
 */

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const ENV_FILE = path.join(process.cwd(), '.env');
const ENV_ENCRYPTED_FILE = path.join(process.cwd(), '.env.encrypted');

// Algoritmo e parâmetros
const ALGORITHM = 'aes-256-cbc';
const IV_LENGTH = 16;

function encrypt(text, password) {
  const key = crypto.scryptSync(password, 'salt', 32);
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  return iv.toString('hex') + ':' + encrypted;
}

function decrypt(text, password) {
  const parts = text.split(':');
  const iv = Buffer.from(parts[0], 'hex');
  const encryptedText = parts[1];
  const key = crypto.scryptSync(password, 'salt', 32);
  const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
  let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  return decrypted;
}

// Processar argumentos
const command = process.argv[2];
const password = process.argv[3];

if (!command || !password) {
  console.error('Uso: node secure-env.js [encrypt|decrypt] [senha]');
  process.exit(1);
}

if (command === 'encrypt') {
  try {
    const envContent = fs.readFileSync(ENV_FILE, 'utf8');
    const encrypted = encrypt(envContent, password);
    fs.writeFileSync(ENV_ENCRYPTED_FILE, encrypted);
    console.log(`Arquivo .env criptografado com sucesso em ${ENV_ENCRYPTED_FILE}`);
  } catch (error) {
    console.error('Erro ao criptografar:', error.message);
    process.exit(1);
  }
} else if (command === 'decrypt') {
  try {
    const encryptedContent = fs.readFileSync(ENV_ENCRYPTED_FILE, 'utf8');
    const decrypted = decrypt(encryptedContent, password);
    fs.writeFileSync(ENV_FILE, decrypted);
    console.log(`Arquivo .env descriptografado com sucesso em ${ENV_FILE}`);
  } catch (error) {
    console.error('Erro ao descriptografar:', error.message);
    process.exit(1);
  }
} else {
  console.error('Comando inválido. Use "encrypt" ou "decrypt".');
  process.exit(1);
}