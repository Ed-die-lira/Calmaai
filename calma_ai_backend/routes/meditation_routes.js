/**
 * Rotas para a funcionalidade de meditações
 * Fornece endpoints para listar meditações e sugerir com base no humor
 */

const express = require('express');
const router = express.Router();
const { suggestMeditation } = require('../services/huggingface_service');

// Lista de meditações disponíveis
const meditations = [
  {
    id: 'calma',
    title: 'Meditação para Calma',
    description: 'Ideal para momentos de ansiedade e estresse',
    audioUrl: '/static/Calma/calma.mp3',
    duration: '10:00'
  },
  {
    id: 'foco',
    title: 'Meditação para Foco',
    description: 'Ajuda a melhorar a concentração e produtividade',
    audioUrl: '/static/Foco/foco.mp3',
    duration: '8:30'
  },
  {
    id: 'sono',
    title: 'Meditação para Sono',
    description: 'Auxilia no relaxamento para uma noite tranquila',
    audioUrl: '/static/Sono/sono.mp3',
    duration: '15:00'
  },
  {
    id: 'Respiração',
    title: 'Meditação para Respiração',
    description: 'Auxilia no relaxamento, redução de ansiedade e estresse',
    audioUrl: '/static/Sono/sono.mp3',
    duration: '15:00'
  }
];

/**
 * @route GET /api/meditations
 * @desc Retorna lista de todas as meditações disponíveis
 * @access Public
 */
router.get('/', (req, res) => {
  res.json(meditations);
});

/**
 * @route GET /api/meditations/:id
 * @desc Retorna uma meditação específica pelo ID
 * @access Public
 */
router.get('/:id', (req, res) => {
  const meditation = meditations.find(m => m.id === req.params.id);

  if (!meditation) {
    return res.status(404).json({ message: 'Meditação não encontrada' });
  }

  res.json(meditation);
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
    const suggestedFile = await suggestMeditation(mood);

    // Encontrar a meditação correspondente
    const suggestedId = suggestedFile.replace('.mp3', '');
    const meditation = meditations.find(m => m.id === suggestedId);

    if (!meditation) {
      return res.status(404).json({ message: 'Meditação sugerida não encontrada' });
    }

    res.json({
      suggestion: meditation,
      basedOn: mood
    });
  } catch (error) {
    console.error('Erro ao sugerir meditação:', error);
    res.status(500).json({ message: 'Erro ao processar sugestão de meditação' });
  }
});

module.exports = router;
