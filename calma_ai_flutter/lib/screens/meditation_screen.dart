/**
 * Tela de meditação
 * Exibe um player de áudio para reproduzir meditações
 * e botões para selecionar o humor atual
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/meditation.dart';
import '../widgets/audio_player_widget.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({Key? key}) : super(key: key);

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  List<Meditation> _meditations = [];
  Meditation? _currentMeditation;
  bool _isLoading = true;
  ApiService? _apiService;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMeditations();
  }

  // Carregar meditações do backend
  Future<void> _loadMeditations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
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
        _errorMessage = 'Não foi possível carregar as meditações. $e';
      });
    }
  }

  // Sugerir meditação com base no humor
  Future<void> _suggestMeditation(String mood) async {
    try {
      if (_apiService == null) {
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final suggestion = await _apiService!.suggestMeditation(mood);

      setState(() {
        _currentMeditation = suggestion;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao sugerir meditação: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMeditations,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : _buildMeditationContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadMeditations,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildMeditationContent() {
    return Column(
      children: [
        // Área de seleção de humor
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Como você está se sentindo hoje?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMoodButton(
                      'Ansioso', Icons.sentiment_dissatisfied, Colors.orange),
                  _buildMoodButton(
                      'Cansado', Icons.sentiment_neutral, Colors.blue),
                  _buildMoodButton(
                      'Feliz', Icons.sentiment_satisfied, Colors.green),
                ],
              ),
            ],
          ),
        ),

        // Área do player de áudio
        if (_currentMeditation != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AudioPlayerWidget(
              audioUrl:
                  _apiService!.getFullAudioUrl(_currentMeditation!.audioUrl),
              title: _currentMeditation!.title,
              description: _currentMeditation!.description,
            ),
          ),

        // Lista de meditações disponíveis
        Expanded(
          child: ListView.builder(
            itemCount: _meditations.length,
            itemBuilder: (context, index) {
              final meditation = _meditations[index];
              final isSelected = _currentMeditation?.id == meditation.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: isSelected ? Colors.blue.shade50 : null,
                child: ListTile(
                  title: Text(meditation.title),
                  subtitle: Text(
                    '${meditation.category} • ${meditation.duration}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: Icon(
                    isSelected
                        ? Icons.play_circle_filled
                        : Icons.play_circle_outline,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  onTap: () {
                    setState(() {
                      _currentMeditation = meditation;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoodButton(String mood, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () => _suggestMeditation(mood),
      icon: Icon(icon, color: Colors.white),
      label: Text(mood),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
