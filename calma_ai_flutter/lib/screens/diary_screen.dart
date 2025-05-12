import 'package:flutter/material.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário Emocional'),
      ),
      body: const Center(
        child: Text('Tela do Diário Emocional - Em desenvolvimento'),
      ),
    );
  }
}
