import 'package:flutter/material.dart';

/// Заглушка для нативных платформ: карта доступна только в веб-сборке.
class VivaMapPage extends StatelessWidget {
  const VivaMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Карта доступна в веб-сборке (Chrome / Edge).',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

