/**
 * Modelo de entrada do diário para o MongoDB
 * Armazena entradas do diário com análise de sentimentos
 */

const mongoose = require('mongoose');

const diaryEntrySchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    ref: 'User'
  },
  text: {
    type: String,
    required: true
  },
  sentiment: {
    type: String,
    enum: ['positive', 'negative', 'neutral'],
    required: true
  },
  sentimentScore: {
    type: Number, // Valor entre 0 e 1
    required: true
  },
  date: {
    type: Date,
    default: Date.now
  }
});

// Índice para consultas mais rápidas por usuário e data
diaryEntrySchema.index({ userId: 1, date: -1 });

module.exports = mongoose.model('DiaryEntry', diaryEntrySchema);
