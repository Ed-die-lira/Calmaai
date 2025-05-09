/**
 * Script independente para fazer backup do arquivo .env
 * Uso: node scripts/backup-env.js
 */

const fs = require('fs');
const path = require('path');

const ENV_FILE = path.join(process.cwd(), '.env');
const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
const BACKUP_FILE = path.join(process.cwd(), `.env.backup.${timestamp}`);

try {
  // Verificar se o arquivo .env existe
  if (!fs.existsSync(ENV_FILE)) {
    console.error('Arquivo .env não encontrado.');
    process.exit(1);
  }
  
  // Copiar arquivo
  fs.copyFileSync(ENV_FILE, BACKUP_FILE);
  
  // Definir permissões restritas para o backup
  try {
    fs.chmodSync(BACKUP_FILE, 0o600); // Apenas o proprietário pode ler/escrever
  } catch (permError) {
    console.warn('Aviso: Não foi possível definir permissões restritas para o backup.');
  }
  
  console.log(`Backup criado com sucesso: ${BACKUP_FILE}`);
} catch (error) {
  console.error('Erro ao fazer backup:', error.message);
  process.exit(1);
}