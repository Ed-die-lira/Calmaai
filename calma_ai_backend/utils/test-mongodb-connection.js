/**
 * Script para testar a conexão com o MongoDB
 * Execute com: node utils/test-mongodb-connection.js
 */

const mongoose = require('mongoose');
const dotenv = require('dotenv');

// Carregar variáveis de ambiente
dotenv.config();

// Função para testar a conexão
async function testConnection() {
  console.log('Testando conexão com MongoDB...');

  // Obter a string de conexão
  const mongoUri = process.env.MONGODB_URI;

  if (!mongoUri) {
    console.error('ERRO: MONGODB_URI não está definido no arquivo .env');
    process.exit(1);
  }

  // Ocultar a senha nos logs
  const logSafeUri = mongoUri.replace(/:([^:@]+)@/, ':****@');
  console.log(`Tentando conectar com: ${logSafeUri}`);

  try {
    // Tentar conectar
    await mongoose.connect(mongoUri);
    console.log('✅ Conexão bem-sucedida com o MongoDB!');

    // Listar as coleções disponíveis
    const collections = await mongoose.connection.db.listCollections().toArray();
    console.log('Coleções disponíveis:');
    collections.forEach(collection => {
      console.log(`- ${collection.name}`);
    });

    // Fechar a conexão
    await mongoose.connection.close();
    console.log('Conexão fechada.');
  } catch (error) {
    console.error('❌ Erro ao conectar ao MongoDB:');
    console.error(`Mensagem: ${error.message}`);

    if (error.name === 'MongoServerError' && error.code === 8000) {
      console.error('\n🔑 PROBLEMA DE AUTENTICAÇÃO DETECTADO:');
      console.error('- Verifique se o nome de usuário está correto');
      console.error('- Verifique se a senha está correta');
      console.error('- Verifique se o usuário tem acesso ao banco de dados especificado');
      console.error('- Verifique se o IP atual está na lista de permissões do MongoDB Atlas');

      console.error('\n📝 PASSOS PARA RESOLVER:');
      console.error('1. Faça login no MongoDB Atlas (https://cloud.mongodb.com)');
      console.error('2. Vá para Database Access e verifique/redefina a senha do usuário');
      console.error('3. Vá para Network Access e adicione seu IP atual');
      console.error('4. Atualize o arquivo .env com as credenciais corretas');
    }
  }
}

// Executar o teste
testConnection();