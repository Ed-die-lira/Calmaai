/**
 * Widget para reproduzir áudio
 * Usado na tela de meditação e respiração
 */

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String title;

  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoaded = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadAudio();

    // Ouvintes para atualizar estado
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Carregar áudio
  Future<void> _loadAudio() async {
    try {
      // Verificar se a URL é local ou remota
      if (widget.audioUrl.startsWith('http')) {
        // URL remota
        await _audioPlayer.setSourceUrl(widget.audioUrl);
      } else {
        // URL local (relativa ao servidor)
        final baseUrl = kReleaseMode
            ? 'https://calmaai.onrender.com' // URL de produção
            : 'http://10.0.2.2:3000'; // URL para emulador Android

        final fullUrl = '$baseUrl${widget.audioUrl}';
        print('Carregando áudio de: $fullUrl');

        await _audioPlayer.setSourceUrl(fullUrl);
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

  // Reproduzir ou pausar áudio
  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      print('Erro ao reproduzir/pausar áudio: $e');
    }
  }

  // Parar áudio
  Future<void> _stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Erro ao parar áudio: $e');
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
    return Column(
      children: [
        // Título
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2196F3),
          ),
        ),
        const SizedBox(height: 20),

        // Controles de reprodução
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botão de parar
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _isPlaying ? _stop : null,
              color: const Color(0xFF64B5F6),
              iconSize: 32,
            ),

            // Botão de reproduzir/pausar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF64B5F6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: _isLoaded ? _playPause : null,
                color: Colors.white,
                iconSize: 40,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Barra de progresso
        Slider(
          value: _position.inSeconds.toDouble(),
          min: 0,
          max: _duration.inSeconds.toDouble() > 0
              ? _duration.inSeconds.toDouble()
              : 1,
          activeColor: const Color(0xFF64B5F6),
          inactiveColor: Colors.grey[300],
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
      ],
    );
  }
}
