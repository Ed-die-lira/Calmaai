/**
 * Servidor principal para o aplicativo Calma AI
 * Configura Express, conecta ao MongoDB e carrega as rotas
 */

// Importações de pacotes
const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

// Middleware personalizado para CORS
const corsMiddleware = require('./utils/cors_middleware');

// Rotas
const meditationRoutes = require('./routes/meditation_routes');
const diaryRoutes = require('./routes/diary_routes');
const communityRoutes = require('./routes/community_routes');

// Middleware de autenticação
const { verifyToken } = require('./utils/auth');

// Carregar variáveis de ambiente
dotenv.config();

// Inicializar Express
const app = express();
const PORT = process.env.PORT || 3000;
const mongoUri = process.env.MONGODB_URI;

// Aplicar middleware CORS personalizado
app.use(corsMiddleware);

// Outros middlewares
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/static', express.static(path.join(__dirname, 'public')));

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


