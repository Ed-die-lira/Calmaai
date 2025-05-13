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
  bool _isLoading = true;
  String? _errorMessage;
  List<Meditation> _meditations = [];
  Meditation? _currentMeditation;
  bool _isPlaying = false;
  ApiService? _apiService;

  @override
  void initState() {
    super.initState();
    _loadMeditations();
  }

  // Carregar meditações do backend
  Future<void> _loadMeditations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _selectMeditation(Meditation meditation) {
    setState(() {
      _currentMeditation = meditation;
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditações'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    // Player de meditação atual
                    if (_currentMeditation != null)
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                _currentMeditation!.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(_currentMeditation!.description),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(_isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_filled),
                                    iconSize: 48,
                                    onPressed: _togglePlayPause,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Duração: ${_currentMeditation!.duration ~/ 60} minutos',
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Lista de meditações disponíveis
                    Expanded(
                      child: ListView.builder(
                        itemCount: _meditations.length,
                        itemBuilder: (context, index) {
                          final meditation = _meditations[index];
                          final isSelected =
                              _currentMeditation?.id == meditation.id;

                          return ListTile(
                            title: Text(meditation.title),
                            subtitle: Text(
                              '${meditation.category} - ${meditation.duration ~/ 60} min',
                            ),
                            leading: const Icon(Icons.music_note),
                            selected: isSelected,
                            onTap: () => _selectMeditation(meditation),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
