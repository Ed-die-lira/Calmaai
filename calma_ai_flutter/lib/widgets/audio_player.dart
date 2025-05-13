/**
 * Widget para reproduzir áudio
 * Usado na tela de meditação e respiração
 */

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

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
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _loadAudio();
  }

  void _setupAudioPlayer() {
    // Configurar listeners
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

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

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

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const CircularProgressIndicator()
        else if (_hasError)
          Column(
            children: [
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: _loadAudio,
                child: const Text('Tentar Novamente'),
              ),
            ],
          )
        else
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: 48,
                    onPressed: _playPause,
                  ),
                ],
              ),
              Slider(
                value: _position.inSeconds.toDouble(),
                max: _duration.inSeconds > 0
                    ? _duration.inSeconds.toDouble()
                    : 1.0,
                onChanged: (value) {
                  final position = Duration(seconds: value.toInt());
                  _audioPlayer.seek(position);
                },
              ),
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
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
