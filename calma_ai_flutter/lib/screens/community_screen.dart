/**
 * Tela de comunidade
 * Exibe posts da comunidade e permite criar novos posts
 * com moderação de conteúdo
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importar serviços
import '../services/auth_service.dart';
import '../services/api_service.dart';

// Importar modelos
import '../models/post.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  // Controladores para o formulário
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Estado de carregamento
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Lista de posts
  List<Post> _posts = [];

  // Controlador de abas
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Inicializar controlador de abas
    _tabController = TabController(length: 2, vsync: this);

    // Carregar posts
    _loadPosts();
  }

  @override
  void dispose() {
    // Liberar recursos
    _titleController.dispose();
    _contentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Carregar posts da comunidade
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obter token de autenticação
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      // Criar instância do serviço de API
      final apiService = ApiService(token: token);

      // Obter posts
      final posts = await apiService.getPosts();

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar posts: $e');
      setState(() {
        _isLoading = false;
      });

      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar posts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Criar novo post
  Future<void> _createPost() async {
    // Validar formulário
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe um título para o post'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, escreva o conteúdo do post'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Obter token e ID do usuário
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();
      final userId = authService.user?.uid;

      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      // Criar instância do serviço de API
      final apiService = ApiService(token: token);

      // Criar post
      await apiService.createPost(
          userId: userId, title: title, content: content);

      // Limpar formulário
      _titleController.clear();
      _contentController.clear();

      // Atualizar lista de posts
      await _loadPosts();

      setState(() {
        _isSubmitting = false;
      });

      // Mostrar confirmação
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post criado com sucesso! Aguardando moderação.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Mudar para a aba de posts
      _tabController.animateTo(0);
    } catch (e) {
      print('Erro ao criar post: $e');
      setState(() {
        _isSubmitting = false;
      });

      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidade'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Novo Post'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba de posts
          _buildPostsTab(),

          // Aba de novo post
          _buildNewPostTab(),
        ],
      ),
    );
  }

  // Construir aba de posts
  Widget _buildPostsTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadPosts,
            child: _posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.forum_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum post na comunidade ainda',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _tabController.animateTo(1),
                          child: const Text('Criar o primeiro post'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título do post
                              Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Data de criação
                              Text(
                                post.formattedCreatedAt,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Conteúdo do post
                              Text(post.content),
                              const SizedBox(height: 16),

                              // Botões de interação
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Botão de curtir
                                  IconButton(
                                    icon: const Icon(Icons.favorite_border),
                                    onPressed: () {
                                      // Implementar curtida
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Funcionalidade em desenvolvimento'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    },
                                  ),

                                  // Botão de comentar
                                  IconButton(
                                    icon: const Icon(Icons.comment_outlined),
                                    onPressed: () {
                                      // Implementar comentário
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Funcionalidade em desenvolvimento'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
  }

  // Construir aba de novo post
  Widget _buildNewPostTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text(
            'Compartilhe com a comunidade',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 8),

          // Descrição
          const Text(
            'Compartilhe suas experiências, dicas ou peça conselhos. '
            'Todos os posts passam por moderação para garantir um ambiente seguro.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Campo de título
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 16),

          // Campo de conteúdo
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Conteúdo',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 8,
            maxLength: 1000,
          ),
          const SizedBox(height: 16),

          // Botão de enviar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _createPost,
              child: _isSubmitting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Enviando...'),
                      ],
                    )
                  : const Text('Publicar'),
            ),
          ),
          const SizedBox(height: 16),

          // Aviso de moderação
          const Card(
            color: Color(0xFFE3F2FD),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF2196F3),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Seu post será revisado antes de ser publicado. '
                      'Conteúdo ofensivo ou inadequado não será aprovado.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
