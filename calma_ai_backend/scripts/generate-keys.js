/**
 * Script independente para gerar chaves seguras
 * Uso: node scripts/generate-keys.js
 */

const crypto = require('crypto');

// Gerar JWT_SECRET
const jwtSecret = crypto.randomBytes(64).toString('hex');
console.log('\nJWT_SECRET seguro:');
console.log(jwtSecret);

// Instruções
console.log('\nPara usar esta chave:');
console.log('1. Abra o arquivo .env');
console.log('2. Substitua o valor atual de JWT_SECRET pela chave acima');
console.log('3. Salve o arquivo\n');