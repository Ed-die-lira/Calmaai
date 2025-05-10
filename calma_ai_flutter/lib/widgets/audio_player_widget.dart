/**
 * Widget para reprodução de áudio
 */

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String description;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.title,
    required this.description,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  // Player de áudio
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Estado do player
  bool _isPlaying = false;
  bool _isLoaded = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Configurar listeners
    _setupAudioPlayer();

    // Carregar áudio
    _loadAudio();
  }

  @override
  void dispose() {
    // Liberar recursos
    _audioPlayer.dispose();
    super.dispose();
  }

  // Configurar listeners do player
  void _setupAudioPlayer() {
    // Ouvir mudanças de estado
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    // Ouvir mudanças de duração
    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    // Ouvir mudanças de posição
    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });
  }

  // Carregar áudio
  Future<void> _loadAudio() async {
    try {
      // Verificar se a URL é local ou remota
      if (widget.audioUrl.startsWith('http')) {
        // URL remota
        print('Carregando áudio de URL remota: ${widget.audioUrl}');
        await _audioPlayer.setSourceUrl(widget.audioUrl);
      } else {
        // URL local (relativa ao servidor)
        final baseUrl = kReleaseMode
            ? 'https://calmaai.onrender.com' // URL de produção
            : 'http://10.0.2.2:3000'; // URL para emulador Android

        final fullUrl = '$baseUrl${widget.audioUrl}';
        print('Carregando áudio de: $fullUrl');

        try {
          await _audioPlayer.setSourceUrl(fullUrl);
          print('Áudio carregado com sucesso de: $fullUrl');
        } catch (e) {
          print('Erro ao carregar áudio de $fullUrl: $e');

          // Tentar localhost como fallback
          final localUrl = 'http://localhost:3000${widget.audioUrl}';
          print('Tentando carregar áudio de localhost: $localUrl');

          try {
            await _audioPlayer.setSourceUrl(localUrl);
            print('Áudio carregado com sucesso de localhost');
          } catch (localError) {
            print('Erro ao carregar áudio de localhost: $localError');

            // Tentar usar áudio local como fallback
            try {
              await _audioPlayer
                  .play(AssetSource('audio/default_meditation.mp3'));
            } catch (assetError) {
              print('Erro ao carregar áudio local: $assetError');
              throw e; // Repassar erro original se o fallback falhar
            }
          }
        }
      }

      setState(() {
        _isLoaded = true;
      });
    } catch (e) {
      print('Erro ao carregar áudio: $e');
      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar áudio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Reproduzir ou pausar
  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  // Formatar duração
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 8),

            // Descrição
            Text(
              widget.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),

            // Controles de áudio
            if (!_isLoaded)
              // Indicador de carregamento
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Column(
                children: [
                  // Slider de progresso
                  Slider(
                    value: _position.inSeconds.toDouble(),
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    activeColor: const Color(0xFF2196F3),
                    inactiveColor: const Color(0xFFE3F2FD),
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await _audioPlayer.seek(position);
                    },
                  ),

                  // Tempo atual / Duração total
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(_position)),
                        Text(_formatDuration(_duration)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botão de play/pause
                  Center(
                    child: ElevatedButton(
                      onPressed: _playPause,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xFF2196F3),
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
