import 'package:flutter/material.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({Key? key}) : super(key: key);

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isBreathing = false;
  String _breathingState = "Toque para iniciar";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _breathingState = "Expire...";
          });
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            _breathingState = "Inspire...";
          });
          _controller.forward();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleBreathing() {
    setState(() {
      _isBreathing = !_isBreathing;
      if (_isBreathing) {
        _breathingState = "Inspire...";
        _controller.forward();
      } else {
        _breathingState = "Toque para iniciar";
        _controller.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercícios de Respiração'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _breathingState,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 150 + 100 * _controller.value,
                  height: 150 + 100 * _controller.value,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _toggleBreathing,
              child: Text(_isBreathing ? 'Parar' : 'Iniciar'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Respire profundamente para reduzir o estresse e a ansiedade.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
