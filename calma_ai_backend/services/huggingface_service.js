/**
 * Serviço para integração com a API da Hugging Face
 * Fornece funções para análise de sentimentos, sugestões de meditação e moderação de conteúdo
 */

const axios = require('axios');
const dotenv = require('dotenv');

dotenv.config();

// Configuração base para requisições à API da Hugging Face
const hfApi = axios.create({
  baseURL: 'https://api-inference.huggingface.co/models',
  headers: {
    'Authorization': `Bearer ${process.env.HF_API_KEY}`,
    'Content-Type': 'application/json'
  }
});

/**
 * Analisa o sentimento de um texto usando o modelo distilbert
 * @param {string} text - Texto para análise
 * @returns {Promise<Object>} - Resultado da análise (positive, negative, neutral)
 */
async function analyzeSentiment(text) {
  try {
    const response = await hfApi.post('/distilbert-base-uncased-finetuned-sst-2-english', {
      inputs: text
    });

    // Processar resultado
    const result = response.data[0];
    let sentiment = 'neutral';
    let score = 0.5;

    // Verificar se há resultados
    if (result && result.length > 0) {
      // Encontrar o sentimento com maior pontuação
      const positiveResult = result.find(item => item.label === 'POSITIVE');
      const negativeResult = result.find(item => item.label === 'NEGATIVE');

      if (positiveResult && negativeResult) {
        if (positiveResult.score > negativeResult.score) {
          sentiment = 'positive';
          score = positiveResult.score;
        } else {
          sentiment = 'negative';
          score = negativeResult.score;
        }
      }
    }

    return { sentiment, score };
  } catch (error) {
    console.error('Erro na análise de sentimento:', error.message);
    // Retornar valor padrão em caso de erro
    return { sentiment: 'neutral', score: 0.5 };
  }
}

/**
 * Sugere uma meditação com base no humor do usuário usando o modelo mistral-7b
 * @param {string} mood - Humor do usuário (ex: "Ansioso", "Cansado", "Feliz")
 * @returns {Promise<string>} - Nome do arquivo de meditação sugerido
 */
async function suggestMeditation(mood) {
  try {
    const prompt = `Com base no humor "${mood}", qual meditação seria mais adequada entre as opções: "calma.mp3" (para ansiedade), "foco.mp3" (para cansaço) ou "sono.mp3" (para relaxamento)? Responda apenas com o nome do arquivo.`;
    
    const response = await hfApi.post('/mistralai/Mistral-7B-Instruct-v0.2', {
      inputs: prompt
    });

    // Extrair o nome do arquivo da resposta
    let suggestion = response.data[0].generated_text || '';
    
    // Extrair apenas o nome do arquivo da resposta
    const fileNameMatch = suggestion.match(/(calma|foco|sono)\.mp3/i);
    if (fileNameMatch) {
      return fileNameMatch[0].toLowerCase();
    }
    
    // Mapeamento padrão se não conseguir extrair da resposta
    const defaultMappings = {
      'ansioso': 'calma.mp3',
      'cansado': 'foco.mp3',
      'feliz': 'sono.mp3'
    };
    
    // Verificar se o humor está no mapeamento padrão
    const lowerMood = mood.toLowerCase();
    for (const [key, value] of Object.entries(defaultMappings)) {
      if (lowerMood.includes(key)) {
        return value;
      }
    }
    
    // Valor padrão
    return 'calma.mp3';
  } catch (error) {
    console.error('Erro ao sugerir meditação:', error.message);
    // Retornar valor padrão em caso de erro
    return 'calma.mp3';
  }
}

/**
 * Modera conteúdo usando o modelo facebook/moderation
 * @param {string} content - Conteúdo para moderação
 * @returns {Promise<Object>} - Resultado da moderação (passed, score)
 */
async function moderateContent(content) {
  try {
    const response = await hfApi.post('/facebook/bart-large-mnli', {
      inputs: content,
      parameters: {
        candidate_labels: ['safe', 'unsafe']
      }
    });

    // Processar resultado
    const result = response.data;
    const safeIndex = result.labels.indexOf('safe');
    const safeScore = result.scores[safeIndex];
    
    // Considerar conteúdo seguro se a pontuação for maior que 0.7
    const passed = safeScore > 0.7;
    
    return { passed, score: safeScore };
  } catch (error) {
    console.error('Erro na moderação de conteúdo:', error.message);
    // Em caso de erro, rejeitar o conteúdo por segurança
    return { passed: false, score: 0 };
  }
}

module.exports = {
  analyzeSentiment,
  suggestMeditation,
  moderateContent
};
