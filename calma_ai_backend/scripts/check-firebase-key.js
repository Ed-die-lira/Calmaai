/**
 * Script para verificar se a chave privada do Firebase está formatada corretamente
 * Uso: node scripts/check-firebase-key.js
 */

const dotenv = require('dotenv');
dotenv.config();

// Verificar se a chave privada está definida
if (!process.env.FIREBASE_PRIVATE_KEY) {
  console.error('FIREBASE_PRIVATE_KEY não está definida no arquivo .env');
  process.exit(1);
}

// Verificar formato da chave
const privateKey = process.env.FIREBASE_PRIVATE_KEY;
const formattedKey = privateKey.replace(/\\n/g, '\n');

console.log('Verificando formato da chave privada do Firebase...');

// Verificar se a chave começa e termina corretamente
if (!formattedKey.includes('-----BEGIN PRIVATE KEY-----')) {
  console.error('Erro: A chave privada não contém o cabeçalho correto (BEGIN PRIVATE KEY)');
  console.log('\nFormato esperado:');
  console.log('-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----');

  console.log('\nDica: Certifique-se de que a chave no .env está entre aspas duplas e que as quebras de linha estão como \\n');
  process.exit(1);
}

if (!formattedKey.includes('-----END PRIVATE KEY-----')) {
  console.error('Erro: A chave privada não contém o rodapé correto (END PRIVATE KEY)');
  process.exit(1);
}

console.log('A chave privada parece estar formatada corretamente!');

// Mostrar como a chave está sendo interpretada (primeiros e últimos caracteres)
console.log('\nPrimeiros 30 caracteres da chave formatada:');
console.log(formattedKey.substring(0, 30) + '...');

console.log('\nÚltimos 30 caracteres da chave formatada:');
console.log('...' + formattedKey.substring(formattedKey.length - 30));

console.log('\nSe você ainda tiver problemas, verifique se a chave no arquivo .env está entre aspas duplas:');
console.log('FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\\nABC...XYZ\\n-----END PRIVATE KEY-----"');