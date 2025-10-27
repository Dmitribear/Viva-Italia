// ignore_for_file: undefined_prefixed_name, avoid_web_libraries_in_flutter

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


import 'dart:ui_web' as ui;   // web only
import 'dart:html' as html;   // web only

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showMap = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: showMap
            ? _MapView(onClose: () => setState(() => showMap = false))
            : _WelcomeView(onOpenMap: () => setState(() => showMap = true)),
      ),
    );
  }
}

/// Главная: фон-фото + текст + кнопка
class _WelcomeView extends StatelessWidget {
  final VoidCallback onOpenMap;
  const _WelcomeView({required this.onOpenMap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Фон из сети
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.35),
              BlendMode.darken,
            ),
            child: Image.network(
              'https://images.unsplash.com/photo-1505765050516-f72dcac9c60e?q=80&w=1600&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black26],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Viva Italia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Путеводитель по Италии: история, кухня, города и море. '
                        'Открой карту, чтобы увидеть страну целиком.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF008C45),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onOpenMap,
                    icon: const Icon(Icons.map),
                    label: const Text('Открыть карту', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Карта: в вебе — живой OpenStreetMap в iframe; вне веба — плейсхолдер.
class _MapView extends StatelessWidget {
  final VoidCallback onClose;
  const _MapView({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _buildMapContent()),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              onPressed: onClose,
              child: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapContent() {
    if (kIsWeb) {
      // Центр и bbox Италии
      final url =
          'https://www.openstreetmap.org/export/embed.html?bbox=6.0,36.0,19.0,47.0&layer=mapnik&marker=41.9,12.5';
      final viewType = _registerIFrame(url);
      return HtmlElementView(viewType: viewType);
    }

    // Не web: заглушка
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.public, size: 48, color: Colors.black54),
          SizedBox(height: 12),
          Text(
            'Карта доступна в веб-версии (Chrome).',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Регистрация iframe для Platform Views (только Web)
  String _registerIFrame(String url) {
    final viewType = 'osm-iframe-${DateTime.now().microsecondsSinceEpoch}';
    final element = html.IFrameElement()
      ..src = url
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%';

    // ВАЖНО: используем ui_web
    ui.platformViewRegistry.registerViewFactory(viewType, (int _) => element);
    return viewType;
  }
}
