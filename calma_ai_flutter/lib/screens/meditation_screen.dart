/**
 * Tela de meditação
 * Exibe um player de áudio para reproduzir meditações
 * e botões para selecionar o humor atual
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importar serviços
import '../services/auth_service.dart';
import '../services/api_service.dart';

// Importar modelos
import '../models/meditation.dart';
import '../models/category.dart';

// Importar widgets
import '../widgets/audio_player_widget.dart';
import '../widgets/mood_button.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  // Meditação atual
  Meditation? _currentMeditation;

  // Lista de meditações
  List<Meditation> _meditations = [];

  // Lista de categorias
  List<Category> _categories = [];

  // Estado de carregamento
  bool _isLoading = true;
  bool _isSuggesting = false;

  // Humor selecionado
  String? _selectedMood;

  // Categoria selecionada
  String? _selectedCategory;

  // Controlador de abas
  late TabController _tabController;

  // API Service
  ApiService? _apiService;

  @override
  void initState() {
    super.initState();

    // Inicializar controlador de abas
    _tabController = TabController(length: 2, vsync: this);

    // Carregar meditações
    _loadMeditations();

    // Carregar categorias
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Verificar conexão com o servidor
  Future<void> _checkServerConnection() async {
    try {
      // Obter token de autenticação
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      // Criar instância do serviço de API
      final apiService = ApiService(token: token);

      // Verificar conexão
      final isConnected = await apiService.checkConnection();

      if (!isConnected && mounted) {
        // Mostrar diálogo para usar servidor local
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Problema de conexão'),
            content: const Text('Não foi possível conectar ao servidor remoto. '
                'Deseja usar o servidor local para testes?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  // Usar servidor local (localhost)
                  setState(() {
                    _apiService = ApiService(
                      token: token,
                      customBaseUrl: 'http://localhost:3000/api',
                    );
                  });

                  // Recarregar meditações
                  _loadMeditations();

                  Navigator.of(context).pop();
                },
                child: const Text('Usar local'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Erro ao verificar conexão: $e');
    }
  }

  // Carregar meditações do backend
  Future<void> _loadMeditations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obter token de autenticação
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      // Criar instância do serviço de API
      _apiService = ApiService(token: token);

      // Obter meditações
      final meditations = await _apiService!.getMeditations();

      setState(() {
        _meditations = meditations;

        // Selecionar primeira meditação por padrão
        if (meditations.isNotEmpty && _currentMeditation == null) {
          _currentMeditation = meditations.first;
        }

        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar meditações: $e');
      setState(() {
        _isLoading = false;
      });

      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar meditações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Carregar categorias do backend
  Future<void> _loadCategories() async {
    try {
      // Verificar se API Service já foi inicializado
      if (_apiService == null) {
        final authService = Provider.of<AuthService>(context, listen: false);
        final token = await authService.getToken();
        _apiService = ApiService(token: token);
      }

      // Obter categorias
      final categories = await _apiService!.getMeditationCategories();

      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Erro ao carregar categorias: $e');

      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar categorias: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Carregar meditações de uma categoria específica
  Future<void> _loadMeditationsByCategory(String category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });

    try {
      // Verificar se API Service já foi inicializado
      if (_apiService == null) {
        final authService = Provider.of<AuthService>(context, listen: false);
        final token = await authService.getToken();
        _apiService = ApiService(token: token);
      }

      // Obter meditações da categoria
      final meditations = await _apiService!.getMeditationsByCategory(category);

      setState(() {
        _meditations = meditations;

        // Selecionar primeira meditação por padrão
        if (meditations.isNotEmpty) {
          _currentMeditation = meditations.first;
        }

        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar meditações da categoria: $e');
      setState(() {
        _isLoading = false;
      });

      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar meditações da categoria: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Sugerir meditação com base no humor
  Future<void> _suggestMeditation(String mood) async {
    setState(() {
      _isSuggesting = true;
      _selectedMood = mood;
    });

    try {
      // Verificar se API Service já foi inicializado
      if (_apiService == null) {
        final authService = Provider.of<AuthService>(context, listen: false);
        final token = await authService.getToken();
        _apiService = ApiService(token: token);
      }

      // Obter sugestão
      final meditation = await _apiService!.suggestMeditation(mood);

      setState(() {
        _currentMeditation = meditation;
        _isSuggesting = false;

        // Atualizar categoria selecionada
        _selectedCategory = meditation.category;

        // Mudar para a aba de player
        _tabController.animateTo(1);
      });
    } catch (e) {
      print('Erro ao sugerir meditação: $e');
      setState(() {
        _isSuggesting = false;
      });

      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sugerir meditação: $e'),
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
        title: const Text('Meditações'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Categorias'),
            Tab(text: 'Player'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba de categorias
          _buildCategoriesTab(),

          // Aba de player
          _buildPlayerTab(),
        ],
      ),
    );
  }

  // Construir aba de categorias
  Widget _buildCategoriesTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE3F2FD), Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Escolha uma categoria',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 24),

            // Categorias
            if (_categories.isEmpty)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        _loadMeditationsByCategory(category.id);
                        _tabController.animateTo(1);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF64B5F6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${category.count} áudios',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Toque para ver os áudios disponíveis',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),

            // Título
            const Text(
              'Como está se sentindo hoje?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 16),

            // Botões de humor
            if (_isSuggesting)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  MoodButton(
                    mood: 'Ansioso',
                    emoji: '😰',
                    isSelected: _selectedMood == 'Ansioso',
                    onTap: () => _suggestMeditation('Ansioso'),
                  ),
                  MoodButton(
                    mood: 'Estressado',
                    emoji: '😤',
                    isSelected: _selectedMood == 'Estressado',
                    onTap: () => _suggestMeditation('Estressado'),
                  ),
                  MoodButton(
                    mood: 'Triste',
                    emoji: '😢',
                    isSelected: _selectedMood == 'Triste',
                    onTap: () => _suggestMeditation('Triste'),
                  ),
                  MoodButton(
                    mood: 'Cansado',
                    emoji: '😴',
                    isSelected: _selectedMood == 'Cansado',
                    onTap: () => _suggestMeditation('Cansado'),
                  ),
                  MoodButton(
                    mood: 'Feliz',
                    emoji: '😊',
                    isSelected: _selectedMood == 'Feliz',
                    onTap: () => _suggestMeditation('Feliz'),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Texto explicativo
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dica:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Selecione como está se sentindo e receberá uma sugestão '
                      'personalizada de meditação para ajudar com seu estado emocional atual.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Construir aba de player
  Widget _buildPlayerTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE3F2FD), Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            if (_selectedCategory != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.category,
                      color: Color(0xFF2196F3),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Categoria: ${_categories.firstWhere((c) => c.id == _selectedCategory, orElse: () => Category(id: '', name: 'Desconhecida', count: 0, meditations: [])).name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ),

            // Player de áudio
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_currentMeditation != null)
              AudioPlayerWidget(
                audioUrl: _currentMeditation!.audioUrl,
                title: _currentMeditation!.title,
                description: _currentMeditation!.description,
              )
            else
              const Center(
                child: Text(
                  'Nenhuma meditação selecionada',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Lista de meditações disponíveis
            if (_meditations.isNotEmpty) ...[
              const Text(
                'Outras meditações disponíveis:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _meditations.length,
                itemBuilder: (context, index) {
                  final meditation = _meditations[index];
                  final isSelected = _currentMeditation?.id == meditation.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 4 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected
                          ? const BorderSide(color: Color(0xFF2196F3), width: 2)
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentMeditation = meditation;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Ícone
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF2196F3)
                                    : const Color(0xFFE3F2FD),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.music_note,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF2196F3),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Informações
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meditation.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? const Color(0xFF2196F3)
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    meditation.duration,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Ícone de seleção
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF2196F3),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
