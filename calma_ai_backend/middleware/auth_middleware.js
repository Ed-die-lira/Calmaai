/**
 * Middleware de autenticação
 * Verifica se o token JWT é válido antes de permitir acesso às rotas protegidas
 */

const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');

/**
 * Middleware para verificar token JWT
 * @param {Object} req - Requisição Express
 * @param {Object} res - Resposta Express
 * @param {Function} next - Função next do Express
 */
const verifyToken = async (req, res, next) => {
  try {
    // Obter token do cabeçalho Authorization
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Token de autenticação não fornecido' });
    }

    const token = authHeader.split(' ')[1];

    // Verificar token JWT
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Adicionar usuário decodificado à requisição
    req.user = decoded;

    next();
  } catch (error) {
    console.error('Erro na autenticação:', error);
    res.status(401).json({ message: 'Token inválido ou expirado' });
  }
};

/**
 * Middleware para verificar token do Firebase
 * @param {Object} req - Requisição Express
 * @param {Object} res - Resposta Express
 * @param {Function} next - Função next do Express
 */
const verifyFirebaseToken = async (req, res, next) => {
  try {
    // Obter token do cabeçalho Authorization
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Token de autenticação não fornecido' });
    }

    const token = authHeader.split(' ')[1];

    // Verificar token do Firebase
    const decodedToken = await admin.auth().verifyIdToken(token);

    // Adicionar usuário decodificado à requisição
    req.user = decodedToken;

    next();
  } catch (error) {
    console.error('Erro na autenticação Firebase:', error);
    res.status(401).json({ message: 'Token do Firebase inválido ou expirado' });
  }
};

module.exports = {
  verifyToken,
  verifyFirebaseToken
};