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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoaded = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Configurar listeners
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    // Carregar áudio
    _loadAudio();
  }

  @override
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _stop();
      _loadAudio();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Carregar áudio
  Future<void> _loadAudio() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      print('Tentando carregar áudio de: ${widget.audioUrl}');

      // Tentar carregar o áudio
      await _audioPlayer.setSourceUrl(widget.audioUrl);

      setState(() {
        _isLoaded = true;
        _isLoading = false;
      });

      print('Áudio carregado com sucesso!');
    } catch (e) {
      print('Erro ao carregar áudio: $e');

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            'Não foi possível carregar o áudio. Tente novamente mais tarde.';
      });
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

  // Parar
  Future<void> _stop() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _position = Duration.zero;
      });
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título e descrição
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Mostrar erro se houver
            if (_hasError)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red[50],
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadAudio,
                      tooltip: 'Tentar novamente',
                    ),
                  ],
                ),
              ),

            // Mostrar carregamento
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Controles de áudio
            if (_isLoaded && !_isLoading && !_hasError) ...[
              // Slider para progresso
              Slider(
                value: _position.inSeconds.toDouble(),
                max: _duration.inSeconds.toDouble() > 0
                    ? _duration.inSeconds.toDouble()
                    : 1.0,
                onChanged: (value) {
                  final position = Duration(seconds: value.toInt());
                  _audioPlayer.seek(position);
                },
              ),

              // Tempo atual / duração total
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

              // Botões de controle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10),
                    onPressed: () {
                      _audioPlayer.seek(
                        Duration(
                          seconds: _position.inSeconds - 10,
                        ),
                      );
                    },
                    tooltip: 'Voltar 10 segundos',
                  ),
                  IconButton(
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 48,
                    ),
                    onPressed: _playPause,
                    tooltip: _isPlaying ? 'Pausar' : 'Reproduzir',
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10),
                    onPressed: () {
                      _audioPlayer.seek(
                        Duration(
                          seconds: _position.inSeconds + 10,
                        ),
                      );
                    },
                    tooltip: 'Avançar 10 segundos',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
