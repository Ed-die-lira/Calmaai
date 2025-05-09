/**
 * Rotas para a funcionalidade de comunidade
 * Fornece endpoints para criar e listar posts com moderação
 */

const express = require('express');
const router = express.Router();
const Post = require('../models/post');
const { moderateContent } = require('../services/huggingface_service');

/**
 * @route POST /api/posts
 * @desc Cria um novo post com moderação de conteúdo
 * @access Private
 * @body { title: string, content: string, userId: string }
 */
router.post('/', async (req, res) => {
  try {
    const { title, content, userId } = req.body;
    
    if (!title || !content || !userId) {
      return res.status(400).json({ 
        message: 'Título, conteúdo e ID do usuário são obrigatórios' 
      });
    }
    
    // Moderar conteúdo
    const fullContent = `${title} ${content}`;
    const { passed, score } = await moderateContent(fullContent);
    
    // Criar novo post
    const newPost = new Post({
      userId,
      title,
      content,
      moderationPassed: passed,
      moderationScore: score
    });
    
    // Salvar no banco de dados
    await newPost.save();
    
    // Se não passou na moderação, informar ao usuário
    if (!passed) {
      return res.status(403).json({
        message: 'O conteúdo não passou na moderação. Por favor, revise e tente novamente.',
        moderationScore: score
      });
    }
    
    res.status(201).json({
      post: newPost,
      moderation: {
        passed,
        score
      }
    });
  } catch (error) {
    console.error('Erro ao criar post:', error);
    res.status(500).json({ message: 'Erro ao processar post' });
  }
});

/**
 * @route GET /api/posts
 * @desc Lista posts aprovados na moderação
 * @access Public
 */
router.get('/', async (req, res) => {
  try {
    const { limit = 20, skip = 0 } = req.query;
    
    // Buscar posts aprovados, ordenados por data (mais recentes primeiro)
    const posts = await Post.find({ moderationPassed: true })
      .sort({ createdAt: -1 })
      .skip(Number(skip))
      .limit(Number(limit));
    
    // Contar total de posts aprovados
    const total = await Post.countDocuments({ moderationPassed: true });
    
    res.json({
      posts,
      pagination: {
        total,
        limit: Number(limit),
        skip: Number(skip)
      }
    });
  } catch (error) {
    console.error('Erro ao listar posts:', error);
    res.status(500).json({ message: 'Erro ao listar posts' });
  }
});

/**
 * @route GET /api/posts/user/:userId
 * @desc Lista posts de um usuário específico
 * @access Private
 */
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 20, skip = 0 } = req.query;
    
    // Buscar posts do usuário, ordenados por data (mais recentes primeiro)
    const posts = await Post.find({ userId })
      .sort({ createdAt: -1 })
      .skip(Number(skip))
      .limit(Number(limit));
    
    // Contar total de posts do usuário
    const total = await Post.countDocuments({ userId });
    
    res.json({
      posts,
      pagination: {
        total,
        limit: Number(limit),
        skip: Number(skip)
      }
    });
  } catch (error) {
    console.error('Erro ao listar posts do usuário:', error);
    res.status(500).json({ message: 'Erro ao listar posts do usuário' });
  }
});

module.exports = router;
