/**
 * Utilitários para moderação de conteúdo
 * Fornece funções auxiliares para moderação além da API da Hugging Face
 */

/**
 * Verifica se o texto contém palavras proibidas
 * @param {string} text - Texto para verificar
 * @returns {boolean} - true se o texto é seguro, false se contém palavras proibidas
 */
function checkProhibitedWords(text) {
  // Lista básica de palavras proibidas (em produção, seria mais extensa)
  const prohibitedWords = [
    'palavrão1',
    'palavrão2',
    'palavrão3'
  ];
  
  // Converter para minúsculas para comparação
  const lowerText = text.toLowerCase();
  
  // Verificar cada palavra proibida
  for (const word of prohibitedWords) {
    if (lowerText.includes(word)) {
      return false;
    }
  }
  
  return true;
}

/**
 * Verifica se o texto contém informações pessoais
 * @param {string} text - Texto para verificar
 * @returns {boolean} - true se o texto é seguro, false se contém informações pessoais
 */
function checkPersonalInfo(text) {
  // Padrões para informações pessoais
  const patterns = [
    // Telefone (formato brasileiro)
    /\(\d{2}\)\s?\d{4,5}-?\d{4}/g,
    // E-mail
    /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g,
    // CPF
    /\d{3}\.?\d{3}\.?\d{3}-?\d{2}/g
  ];
  
  // Verificar cada padrão
  for (const pattern of patterns) {
    if (pattern.test(text)) {
      return false;
    }
  }
  
  return true;
}

/**
 * Realiza moderação local de conteúdo
 * @param {string} text - Texto para moderar
 * @returns {Object} - Resultado da moderação { passed: boolean, reason: string }
 */
function moderateLocally(text) {
  // Verificar palavras proibidas
  if (!checkProhibitedWords(text)) {
    return {
      passed: false,
      reason: 'O texto contém linguagem inapropriada'
    };
  }
  
  // Verificar informações pessoais
  if (!checkPersonalInfo(text)) {
    return {
      passed: false,
      reason: 'O texto contém informações pessoais'
    };
  }
  
  return {
    passed: true,
    reason: ''
  };
}

module.exports = {
  checkProhibitedWords,
  checkPersonalInfo,
  moderateLocally
};
