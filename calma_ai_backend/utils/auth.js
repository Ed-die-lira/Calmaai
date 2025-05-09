/**
 * Utilitários para autenticação
 * Fornece middleware para verificar tokens JWT e integração com Firebase Auth
 */

const admin = require('firebase-admin');
const jwt = require('jsonwebtoken');

// Inicializar Firebase Admin SDK
if (process.env.NODE_ENV !== 'test') {
  try {
    // Verificar se as variáveis de ambiente estão definidas
    if (!process.env.FIREBASE_PROJECT_ID) {
      console.error('AVISO: FIREBASE_PROJECT_ID não definido no .env. Algumas funcionalidades de autenticação podem não funcionar corretamente.');
      // Não interromper a execução, apenas avisar
    } else {
      // Tentar inicializar com credenciais de serviço se disponíveis
      if (process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
        admin.initializeApp({
          credential: admin.credential.cert({
            projectId: process.env.FIREBASE_PROJECT_ID,
            clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
            privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
          })
        });
        console.log('Firebase Admin SDK inicializado com credenciais completas');
      } else {
        // Inicializar apenas com projectId (funciona em ambientes específicos)
        admin.initializeApp({
          projectId: process.env.FIREBASE_PROJECT_ID
        });
        console.log('Firebase Admin SDK inicializado apenas com projectId (modo limitado)');
      }
    }
  } catch (error) {
    console.error('Erro ao inicializar Firebase Admin SDK:', error);
    // Não interromper a execução, apenas avisar
    console.warn('Continuando sem inicialização do Firebase. Algumas funcionalidades podem não estar disponíveis.');
  }
}

/**
 * Middleware para verificar token JWT
 * @param {Object} req - Requisição Express
 * @param {Object} res - Resposta Express
 * @param {Function} next - Função next do Express
 */
const verifyToken = (req, res, next) => {
  // Obter token do cabeçalho
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Token não fornecido' });
  }

  try {
    // Verificar token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    console.error('Erro ao verificar token:', error);
    return res.status(403).json({ message: 'Token inválido' });
  }
};

/**
 * Middleware para verificar token do Firebase
 * @param {Object} req - Requisição Express
 * @param {Object} res - Resposta Express
 * @param {Function} next - Função next do Express
 */
const verifyFirebaseToken = async (req, res, next) => {
  // Obter token do cabeçalho
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Token não fornecido' });
  }

  try {
    // Verificar token do Firebase
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Erro ao verificar token do Firebase:', error);
    return res.status(403).json({ message: 'Token inválido' });
  }
};

/**
 * Gera um token JWT para o usuário
 * @param {Object} user - Objeto com dados do usuário
 * @returns {string} - Token JWT
 */
const generateToken = (user) => {
  return jwt.sign(
    { id: user.id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
};

module.exports = {
  verifyToken,
  verifyFirebaseToken,
  generateToken
};


