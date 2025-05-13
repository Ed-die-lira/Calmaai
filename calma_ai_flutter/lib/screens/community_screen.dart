import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  // Dados simulados para a comunidade
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'title': 'Como lidar com a ansiedade',
      'content':
          'Tenho praticado meditação diariamente e tem me ajudado muito com a ansiedade. Alguém mais tem dicas para compartilhar?',
      'author': 'Usuário Anônimo',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'likes': 15,
    },
    {
      'id': '2',
      'title': 'Meditação para iniciantes',
      'content':
          'Estou começando a meditar agora. Quais são as melhores práticas para quem está começando?',
      'author': 'Usuário Anônimo',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'likes': 8,
    },
    {
      'id': '3',
      'title': 'Exercícios de respiração',
      'content':
          'Os exercícios de respiração deste app têm me ajudado muito a dormir melhor. Recomendo!',
      'author': 'Usuário Anônimo',
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'likes': 12,
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showNewPostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Publicação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Conteúdo',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _titleController.clear();
              _contentController.clear();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty &&
                  _contentController.text.isNotEmpty) {
                _createPost();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos')),
                );
              }
            },
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPost() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulação de criação de post
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _posts.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': _titleController.text,
          'content': _contentController.text,
          'author': 'Usuário Anônimo',
          'date': DateTime.now(),
          'likes': 0,
        });

        _titleController.clear();
        _contentController.clear();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicação criada com sucesso!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar publicação: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidade'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(post['content']),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Por ${post['author']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDate(post['date']),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.thumb_up_outlined),
                              onPressed: () {
                                setState(() {
                                  post['likes']++;
                                });
                              },
                            ),
                            Text('${post['likes']}'),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.comment_outlined),
                              onPressed: () {
                                // Implementar comentários
                              },
                            ),
                            const Text('Comentar'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewPostDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'} atrás';
    } else {
      return 'Agora mesmo';
    }
  }
}
