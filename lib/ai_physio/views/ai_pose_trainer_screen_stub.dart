import 'package:flutter/material.dart';

class AIPoseTrainerScreen extends StatelessWidget {
  const AIPoseTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Physiotherapist')),
      body: const Center(
        child: Text(
          'AI Physiotherapist is not supported on Web.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}


