/**
 * Modelo de usuário para o MongoDB
 * Armazena informações do usuário e preferências
 */

const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  firebaseUid: {
    type: String,
    required: true,
    unique: true
  },
  email: {
    type: String,
    required: true,
    unique: true
  },
  displayName: {
    type: String,
    default: ''
  },
  reminders: [{
    title: String,
    time: String, // Formato HH:MM
    days: [Number], // 0-6 (domingo-sábado)
    active: {
      type: Boolean,
      default: true
    }
  }],
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('User', userSchema);
