/**
 * Middleware personalizado para CORS
 * Permite um controle mais granular sobre as configurações CORS
 */
module.exports = function (req, res, next) {
  // Lista de origens permitidas
  const allowedOrigins = [
    'https://calmaai.netlify.app',
    'http://localhost:3000',
    'http://localhost:53064',
    'http://localhost:50000', // Adicione todas as portas que o Flutter web pode usar
    'http://localhost:60000',
    'http://localhost:8080',
    'http://localhost:8000'
  ];

  // Obter a origem da solicitação
  const origin = req.headers.origin;

  // Verificar se a origem está na lista de permitidas ou permitir qualquer origem em desenvolvimento
  if (allowedOrigins.includes(origin) || process.env.NODE_ENV === 'development') {
    res.setHeader('Access-Control-Allow-Origin', origin || '*');
  } else {
    // Para produção, você pode querer ser mais restritivo
    res.setHeader('Access-Control-Allow-Origin', 'https://calmaai.netlify.app');
  }

  // Configurações adicionais de CORS
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Allow-Credentials', 'true');

  // Lidar com solicitações OPTIONS (preflight)
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // Passar para o próximo middleware
  next();
};