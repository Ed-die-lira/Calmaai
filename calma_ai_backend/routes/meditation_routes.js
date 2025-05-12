/**
 * Rotas para a funcionalidade de meditações
 * Fornece endpoints para listar meditações e sugerir com base no humor
 */

const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const { suggestMeditation } = require('../services/huggingface_service');

// Função para listar arquivos de áudio em uma pasta
function getAudioFilesInFolder(folderName) {
  const folderPath = path.join(__dirname, '..', 'static', folderName);

  try {
    if (!fs.existsSync(folderPath)) {
      console.warn(`Pasta não encontrada: ${folderPath}`);
      return [];
    }

    const files = fs.readdirSync(folderPath);
    return files
      .filter(file => file.endsWith('.mp3'))
      .map(file => ({
        id: `${folderName.toLowerCase()}_${file.replace('.mp3', '')}`,
        title: `${file.replace('.mp3', '').replace(/_/g, ' ')}`,
        description: `Meditação de ${folderName}`,
        audioUrl: `/static/${folderName}/${file}`,
        category: folderName.toLowerCase(),
        duration: '10:00' // Duração padrão, idealmente seria calculada do arquivo
      }));
  } catch (error) {
    console.error(`Erro ao listar arquivos em ${folderPath}:`, error);
    return [];
  }
}

// Listar todas as meditações disponíveis
function getAllMeditations() {
  // Categorias de meditação
  const categories = ['Calma', 'Foco', 'Sono', 'Respiracao'];

  // Obter arquivos de cada categoria
  let allMeditations = [];

  categories.forEach(category => {
    const meditations = getAudioFilesInFolder(category);
    allMeditations = [...allMeditations, ...meditations];
  });

  return allMeditations;
}

/**
 * @route GET /api/meditations
 * @desc Lista todas as meditações disponíveis
 * @access Public
 */
router.get('/', (req, res) => {
  try {
    const meditations = getAllMeditations();

    if (meditations.length === 0) {
      return res.status(404).json({
        message: 'Nenhuma meditação encontrada',
        error: 'Verifique se os arquivos de áudio estão na pasta static'
      });
    }

    res.json(meditations);
  } catch (error) {
    console.error('Erro ao listar meditações:', error);
    res.status(500).json({ message: 'Erro ao listar meditações', error: error.message });
  }
});

/**
 * @route GET /api/meditations/categories
 * @desc Lista todas as categorias de meditação
 * @access Public
 */
router.get('/categories', (req, res) => {
  try {
    const categories = ['Calma', 'Foco', 'Sono', 'Respiracao'];

    const categoriesWithCount = categories.map(category => {
      const meditations = getAudioFilesInFolder(category);
      return {
        id: category.toLowerCase(),
        name: category,
        count: meditations.length,
        meditations: meditations
      };
    });

    res.json(categoriesWithCount);
  } catch (error) {
    console.error('Erro ao listar categorias:', error);
    res.status(500).json({ message: 'Erro ao listar categorias', error: error.message });
  }
});

/**
 * @route GET /api/meditations/category/:category
 * @desc Lista meditações de uma categoria específica
 * @access Public
 */
router.get('/category/:category', (req, res) => {
  try {
    const { category } = req.params;
    const categoryName = category.charAt(0).toUpperCase() + category.slice(1);

    const meditations = getAudioFilesInFolder(categoryName);

    if (meditations.length === 0) {
      return res.status(404).json({
        message: `Nenhuma meditação encontrada na categoria ${categoryName}`,
        error: 'Verifique se os arquivos de áudio estão na pasta correta'
      });
    }

    res.json(meditations);
  } catch (error) {
    console.error('Erro ao listar meditações por categoria:', error);
    res.status(500).json({ message: 'Erro ao listar meditações por categoria', error: error.message });
  }
});

/**
 * @route POST /api/meditations/suggest
 * @desc Sugere uma meditação com base no humor do usuário
 * @access Public
 * @body { mood: string } - Humor do usuário (ex: "Ansioso", "Cansado", "Feliz")
 */
router.post('/suggest', async (req, res) => {
  try {
    const { mood } = req.body;

    if (!mood) {
      return res.status(400).json({ message: 'Humor não informado' });
    }

    // Obter sugestão da Hugging Face
    const suggestedCategory = await suggestMeditation(mood);

    // Mapear categoria sugerida
    let category;
    if (suggestedCategory.includes('calma')) {
      category = 'Calma';
    } else if (suggestedCategory.includes('foco')) {
      category = 'Foco';
    } else if (suggestedCategory.includes('sono')) {
      category = 'Sono';
    } else {
      category = 'Calma'; // Padrão
    }

    // Obter meditações da categoria
    const meditations = getAudioFilesInFolder(category);

    if (meditations.length === 0) {
      return res.status(404).json({
        message: `Nenhuma meditação encontrada na categoria ${category}`,
        error: 'Verifique se os arquivos de áudio estão na pasta correta'
      });
    }

    // Selecionar uma meditação aleatória da categoria
    const randomIndex = Math.floor(Math.random() * meditations.length);
    const meditation = meditations[randomIndex];

    res.json({
      suggestion: meditation,
      category: category,
      basedOn: mood
    });
  } catch (error) {
    console.error('Erro ao sugerir meditação:', error);
    res.status(500).json({ message: 'Erro ao sugerir meditação', error: error.message });
  }
});

/**
 * @route GET /api/meditations/cors-test
 * @desc Testa se o CORS está configurado corretamente
 * @access Public
 */
router.get('/cors-test', (req, res) => {
  res.json({
    success: true,
    message: 'CORS está configurado corretamente!',
    headers: {
      'origin': req.headers.origin || 'Não disponível',
      'user-agent': req.headers['user-agent'] || 'Não disponível'
    }
  });
});

module.exports = router;

