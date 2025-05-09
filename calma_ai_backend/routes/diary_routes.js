/**
 * Rotas para a funcionalidade de diário emocional
 * Fornece endpoints para salvar entradas e obter histórico
 */

const express = require('express');
const router = express.Router();
const DiaryEntry = require('../models/diary_entry');
const { analyzeSentiment } = require('../services/huggingface_service');

/**
 * @route POST /api/diary
 * @desc Salva uma nova entrada no diário com análise de sentimentos
 * @access Private
 * @body { text: string, userId: string }
 */
router.post('/', async (req, res) => {
  try {
    const { text, userId } = req.body;
    
    if (!text || !userId) {
      return res.status(400).json({ message: 'Texto e ID do usuário são obrigatórios' });
    }
    
    // Analisar sentimento do texto
    const { sentiment, score } = await analyzeSentiment(text);
    
    // Criar nova entrada
    const newEntry = new DiaryEntry({
      userId,
      text,
      sentiment,
      sentimentScore: score,
      date: new Date()
    });
    
    // Salvar no banco de dados
    await newEntry.save();
    
    res.status(201).json({
      entry: newEntry,
      analysis: {
        sentiment,
        score
      }
    });
  } catch (error) {
    console.error('Erro ao salvar entrada do diário:', error);
    res.status(500).json({ message: 'Erro ao processar entrada do diário' });
  }
});

/**
 * @route GET /api/diary/history/:userId
 * @desc Retorna o histórico de entradas do diário de um usuário
 * @access Private
 */
router.get('/history/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 30, skip = 0 } = req.query;
    
    // Buscar entradas do usuário, ordenadas por data (mais recentes primeiro)
    const entries = await DiaryEntry.find({ userId })
      .sort({ date: -1 })
      .skip(Number(skip))
      .limit(Number(limit));
    
    // Contar total de entradas
    const total = await DiaryEntry.countDocuments({ userId });
    
    res.json({
      entries,
      pagination: {
        total,
        limit: Number(limit),
        skip: Number(skip)
      }
    });
  } catch (error) {
    console.error('Erro ao buscar histórico do diário:', error);
    res.status(500).json({ message: 'Erro ao buscar histórico do diário' });
  }
});

/**
 * @route GET /api/diary/stats/:userId
 * @desc Retorna estatísticas de humor do usuário
 * @access Private
 */
router.get('/stats/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { days = 30 } = req.query;
    
    // Data limite (X dias atrás)
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - Number(days));
    
    // Buscar entradas no período
    const entries = await DiaryEntry.find({
      userId,
      date: { $gte: startDate }
    }).sort({ date: 1 });
    
    // Calcular estatísticas
    const stats = {
      total: entries.length,
      sentiments: {
        positive: entries.filter(e => e.sentiment === 'positive').length,
        negative: entries.filter(e => e.sentiment === 'negative').length,
        neutral: entries.filter(e => e.sentiment === 'neutral').length
      },
      // Dados para o gráfico (por dia)
      chartData: []
    };
    
    // Agrupar por dia para o gráfico
    const dailyData = {};
    entries.forEach(entry => {
      const dateStr = entry.date.toISOString().split('T')[0];
      if (!dailyData[dateStr]) {
        dailyData[dateStr] = { date: dateStr, positive: 0, negative: 0, neutral: 0 };
      }
      dailyData[dateStr][entry.sentiment]++;
    });
    
    // Converter para array
    stats.chartData = Object.values(dailyData);
    
    res.json(stats);
  } catch (error) {
    console.error('Erro ao buscar estatísticas do diário:', error);
    res.status(500).json({ message: 'Erro ao buscar estatísticas do diário' });
  }
});

module.exports = router;
