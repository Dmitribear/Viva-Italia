import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Заглушка для нативных платформ: карта доступна только в веб-сборке.
class VivaMapPage extends StatelessWidget {
  final SharedPreferences? prefs;
  const VivaMapPage({super.key, this.prefs});

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

