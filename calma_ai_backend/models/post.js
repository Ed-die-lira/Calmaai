/**
 * Modelo de post para o MongoDB
 * Armazena posts da comunidade com moderação
 */

const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    ref: 'User'
  },
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  content: {
    type: String,
    required: true,
    trim: true,
    maxlength: 1000
  },
  // Resultado da moderação
  moderationPassed: {
    type: Boolean,
    default: false
  },
  moderationScore: {
    type: Number, // Valor entre 0 e 1
    default: 0
  },
  // Metadados
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Atualizar o timestamp quando o documento for atualizado
postSchema.pre('save', function(next) {
  if (this.isModified()) {
    this.updatedAt = Date.now();
  }
  next();
});

// Índice para consultas mais rápidas
postSchema.index({ createdAt: -1 });
postSchema.index({ userId: 1, createdAt: -1 });
postSchema.index({ moderationPassed: 1, createdAt: -1 });

module.exports = mongoose.model('Post', postSchema);
