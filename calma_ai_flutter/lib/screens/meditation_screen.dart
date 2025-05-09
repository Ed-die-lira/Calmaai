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

// Importar widgets
import '../widgets/audio_player.dart';
import '../widgets/mood_button.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  // Meditação atual
  Meditation? _currentMeditation;
  
  // Lista de meditações
  List<Meditation> _meditations = [];
  
  // Estado de carregamento
  bool _isLoading = true;
  bool _isSuggesting = false;
  
  // Humor selecionado
  String? _selectedMood;
  
  @override
  void initState() {
    super.initState();
    
    // Carregar meditações
    _loadMeditations();
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
      final apiService = ApiService(token: token);
      
      // Obter meditações
      final meditations = await apiService.getMeditations();
      
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
  
  // Sugerir meditação com base no humor
  Future<void> _suggestMeditation(String mood) async {
    setState(() {
      _isSuggesting = true;
      _selectedMood = mood;
    });
    
    try {
      // Obter token de autenticação
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();
      
      // Criar instância do serviço de API
      final apiService = ApiService(token: token);
      
      // Obter sugestão
      final meditation = await apiService.suggestMeditation(mood);
      
      setState(() {
        _currentMeditation = meditation;
        _isSuggesting = false;
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
    // Verificar se recebeu meditação como argumento
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Meditation && _currentMeditation == null) {
      _currentMeditation = args;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditação'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Título da tela
                    const Text(
                      'Meditações Personalizadas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Botões de humor
                    const Text(
                      'Como você está se sentindo hoje?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Botões de humor
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        MoodButton(
                          mood: 'Ansioso',
                          emoji: '😰',
                          isSelected: _selectedMood == 'Ansioso',
                          onTap: () => _suggestMeditation('Ansioso'),
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
                    
                    // Indicador de carregamento da sugestão
                    if (_isSuggesting)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        child: const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Sugerindo meditação...'),
                          ],
                        ),
                      ),
                    
                    // Player de áudio
                    if (_currentMeditation != null && !_isSuggesting)
                      Container(
                        margin: const EdgeInsets.only(top: 32),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: AudioPlayerWidget(
                          audioUrl: _currentMeditation!.audioUrl,
                          title: _currentMeditation!.title,
                        ),
                      ),
                    
                    // Lista de outras meditações
                    if (_meditations.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Outras Meditações',
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
                                
                                return ListTile(
                                  title: Text(meditation.title),
                                  subtitle: Text(meditation.duration),
                                  leading: const Icon(Icons.music_note),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.play_circle_fill,
                                          color: Color(0xFF64B5F6),
                                        )
                                      : null,
                                  selected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      _currentMeditation = meditation;
                                    });
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
