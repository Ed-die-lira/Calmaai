/**
 * Tela de exercícios de respiração
 * Exibe uma animação circular para guiar a respiração
 * e reproduz áudio de narração
 */

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:audioplayers/audioplayers.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  // Controlador de animação
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Player de áudio
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Estado do exercício
  bool _isPlaying = false;
  String _phaseText = 'Toque para iniciar';

  // Duração das fases (em segundos)
  static const int _inhaleSeconds = 4;
  static const int _exhaleSeconds = 6;
  static const int _totalSeconds = _inhaleSeconds + _exhaleSeconds;

  @override
  void initState() {
    super.initState();

    // Inicializar controlador de animação
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _totalSeconds),
    );

    // Criar animação
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Ouvir mudanças na animação para atualizar texto
    _animationController.addListener(_updatePhaseText);

    // Repetir animação
    _animationController.repeat();

    // Pausar inicialmente
    _animationController.stop();
  }

  @override
  void dispose() {
    // Liberar recursos
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Atualizar texto da fase
  void _updatePhaseText() {
    final progress = _animationController.value;

    // Fase de inspiração (primeira metade do ciclo)
    if (progress < _inhaleSeconds / _totalSeconds) {
      if (_phaseText != 'Inspire...') {
        setState(() {
          _phaseText = 'Inspire...';
        });
      }
    }
    // Fase de expiração (segunda metade do ciclo)
    else {
      if (_phaseText != 'Expire...') {
        setState(() {
          _phaseText = 'Expire...';
        });
      }
    }
  }

  // Iniciar ou pausar exercício
  Future<void> _toggleExercise() async {
    if (_isPlaying) {
      // Pausar
      _animationController.stop();
      await _audioPlayer.pause();

      setState(() {
        _isPlaying = false;
      });
    } else {
      // Iniciar
      _animationController.repeat();

      // Reproduzir áudio
      try {
        // URL do áudio
        final audioUrl = kReleaseMode
            ? 'https://calmaai.onrender.com/static/respiracao.mp3' // URL de produção
            : 'http://10.0.2.2:3000/static/respiracao.mp3'; // URL para emulador

        // Verificar se já está carregado
        final playerState = _audioPlayer.state;

        if (playerState == PlayerState.stopped) {
          // Tentar carregar e reproduzir
          try {
            await _audioPlayer.play(UrlSource(audioUrl));
          } catch (e) {
            print('Erro ao carregar áudio remoto: $e');

            // Tentar usar áudio local como fallback
            try {
              await _audioPlayer.play(AssetSource('audio/respiracao.mp3'));
            } catch (assetError) {
              print('Erro ao carregar áudio local: $assetError');
              throw e; // Repassar erro original se o fallback falhar
            }
          }

          await _audioPlayer.resume();
        } else {
          // Apenas reproduzir
          await _audioPlayer.resume();
        }
      } catch (e) {
        print('Erro ao reproduzir áudio: $e');

        // Mostrar erro
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao reproduzir áudio: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      setState(() {
        _isPlaying = true;
      });
    }
  }

  // Reiniciar exercício
  void _resetExercise() {
    _animationController.reset();
    _audioPlayer.stop();

    setState(() {
      _isPlaying = false;
      _phaseText = 'Toque para iniciar';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercícios de Respiração'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título
              const Text(
                'Respiração Consciente',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 40),

              // Animação circular
              GestureDetector(
                onTap: _toggleExercise,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    // Calcular tamanho do círculo
                    final progress = _animationController.value;
                    double size;

                    // Fase de inspiração (primeira metade do ciclo)
                    if (progress < _inhaleSeconds / _totalSeconds) {
                      // Mapear 0-0.4 para 100-200
                      final normalizedProgress =
                          progress / (_inhaleSeconds / _totalSeconds);
                      size = 100 + normalizedProgress * 100;
                    }
                    // Fase de expiração (segunda metade do ciclo)
                    else {
                      // Mapear 0.4-1.0 para 200-100
                      final normalizedProgress =
                          (progress - _inhaleSeconds / _totalSeconds) /
                              (_exhaleSeconds / _totalSeconds);
                      size = 200 - normalizedProgress * 100;
                    }

                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: const Color(0xFF64B5F6).withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2196F3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF64B5F6).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _phaseText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),

              // Instruções
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Inspire lentamente por 4 segundos e expire por 6 segundos. '
                  'Siga o ritmo da animação para uma respiração adequada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botão de reiniciar
                  ElevatedButton.icon(
                    onPressed: _resetExercise,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reiniciar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Botão de iniciar/pausar
                  ElevatedButton.icon(
                    onPressed: _toggleExercise,
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(_isPlaying ? 'Pausar' : 'Iniciar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
