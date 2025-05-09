/**
 * Servidor principal para o aplicativo Calma AI
 * Configura Express, conecta ao MongoDB e carrega as rotas
 */

// Importações de pacotes
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

// Carrega .env apenas se existir (opcional para Render)
dotenv.config({ path: '.env', silent: true });

// Importar middleware de autenticação
const { verifyToken, verifyFirebaseToken } = require('./utils/auth');

// Carrega variáveis de ambiente
//const result = dotenv.config();

if (result.error) {
  console.error('Erro ao carregar o arquivo .env:', result.error);
  process.exit(1);
}

console.log('Variáveis de ambiente carregadas:', {
  PORT: process.env.PORT,
  MONGODB_URI: process.env.MONGODB_URI ? 'Definido' : 'Não definido',
  FIREBASE_PROJECT_ID: process.env.FIREBASE_PROJECT_ID || 'Não definido',
  JWT_SECRET: process.env.JWT_SECRET ? 'Definido' : 'Não definido',
});

// Importações de rotas
const meditationRoutes = require('./routes/meditation_routes');
const diaryRoutes = require('./routes/diary_routes');
const communityRoutes = require('./routes/community_routes');

// Inicializa o app Express
const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Servir arquivos estáticos (áudios)
app.use('/static', express.static('static'));

// Construir a string de conexão do MongoDB
const mongoUri = process.env.MONGODB_URI ||
  `mongodb+srv://${process.env.MONGODB_USER}:${encodeURIComponent(process.env.MONGODB_PASSWORD)}@${process.env.MONGODB_CLUSTER}/${process.env.MONGODB_DATABASE}?retryWrites=true&w=majority`;

// Conexão com MongoDB
mongoose.connect(mongoUri)
  .then(() => console.log('Conectado ao MongoDB Atlas'))
  .catch(err => {
    console.error('Erro ao conectar ao MongoDB:', err);
    process.exit(1);
  });

// Rotas públicas
app.use('/api/meditations', meditationRoutes);

// Rotas protegidas
app.use('/api/diary', verifyToken, diaryRoutes);
app.use('/api/posts', verifyToken, communityRoutes);

// Rota de teste
app.get('/', (req, res) => {
  res.send('API do Calma AI está funcionando!');
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});

module.exports = app; // Para testes







