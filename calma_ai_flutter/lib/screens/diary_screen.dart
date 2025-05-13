import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isAnalyzing = false;
  String? _sentiment;
  double _sentimentScore = 0.0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _analyzeSentiment() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escreva algo no diário')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Simulação de análise de sentimento
      await Future.delayed(const Duration(seconds: 2));

      // Análise simulada - em um app real, isso viria da API
      final text = _textController.text.toLowerCase();
      String sentiment;
      double score;

      if (text.contains('feliz') ||
          text.contains('bom') ||
          text.contains('alegre')) {
        sentiment = 'positive';
        score = 0.8;
      } else if (text.contains('triste') ||
          text.contains('mal') ||
          text.contains('ansioso')) {
        sentiment = 'negative';
        score = 0.2;
      } else {
        sentiment = 'neutral';
        score = 0.5;
      }

      setState(() {
        _sentiment = sentiment;
        _sentimentScore = score;
        _isAnalyzing = false;
      });

      // Mostrar resultado
      _showSentimentResult(sentiment, score);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao analisar sentimento: $e')),
      );
    }
  }

  void _showSentimentResult(String sentiment, double score) {
    String message;
    Color color;

    if (sentiment == 'positive') {
      message = 'Seu humor parece positivo hoje! Continue assim!';
      color = Colors.green;
    } else if (sentiment == 'negative') {
      message =
          'Parece que você não está se sentindo muito bem. Que tal uma meditação?';
      color = Colors.red;
    } else {
      message = 'Seu humor parece neutro hoje.';
      color = Colors.blue;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Análise de Sentimento', style: TextStyle(color: color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 8),
            Text('Pontuação: ${(score * 100).toInt()}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário Emocional'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Como você está se sentindo hoje?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText:
                      'Escreva sobre seu dia, seus pensamentos e emoções...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _isAnalyzing
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _analyzeSentiment,
                    child: const Text('Analisar Sentimento'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
            if (_sentiment != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Sentimento: ${_sentiment == 'positive' ? 'Positivo' : _sentiment == 'negative' ? 'Negativo' : 'Neutro'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _sentiment == 'positive'
                              ? Colors.green
                              : _sentiment == 'negative'
                                  ? Colors.red
                                  : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _sentimentScore,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _sentiment == 'positive'
                              ? Colors.green
                              : _sentiment == 'negative'
                                  ? Colors.red
                                  : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
