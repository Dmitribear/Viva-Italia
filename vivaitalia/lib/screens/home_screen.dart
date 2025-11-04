// ignore_for_file: undefined_prefixed_name, avoid_web_libraries_in_flutter

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vivaitalia/screens/details_screen.dart';


// Только для Web:
import 'dart:ui_web' as ui;   // platformViewRegistry
import 'dart:html' as html;   // IFrameElement

// ВСТАВЬ СВОЙ ТОКЕН MAPBOX
const String mapboxToken = 'pk.eyJ1IjoiZGltb25tb3Jrb3ZrYSIsImEiOiJjbWhidXdqa2kwNnN2MmxzYXAwejJ4NW1uIn0.wz_W82D5ImOj1Z2knhCskg';

// Центр Италии и масштаб
const double _centerLat = 41.9;  // Рим
const double _centerLon = 12.5;
const double _zoom      = 5.8;

// Доступные стили: mapbox/streets-v12, mapbox/outdoors-v12, mapbox/satellite-v9
const String _styleId = 'mapbox/streets-v12';

/// ------------ ГЛАВНЫЙ ЭКРАН (фон + текст) ------------
class VivaHomePage extends StatelessWidget {
  const VivaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Фон
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
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black26],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Viva Italia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 44, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Путеводитель по Италии. Красивые города, кухня, история и море.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, height: 1.35, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Перейди на вкладку «Карта» внизу, чтобы открыть интерактивную карту.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white60),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DetailsScreen()),
                        );
                      },
                      child: const Text('Перейти на экран деталей'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ------------ КАРТА (Mapbox, full-screen) ------------
class VivaMapPage extends StatelessWidget {
  const VivaMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SizedBox.expand гарантирует 100% ширину/высоту под навбаром
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(child: _buildMapContent()),
          // Атрибуция
          const Positioned(
            bottom: 8, right: 10,
            child: Text('© Mapbox © OpenStreetMap',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget _buildMapContent() {
    if (kIsWeb) {
      final url = _buildMapboxEmbedUrl(
        styleId: _styleId, token: mapboxToken,
        lat: _centerLat, lon: _centerLon, zoom: _zoom,
      );
      final viewType = _registerIFrame(url);
      return HtmlElementView(viewType: viewType);
    }

    // На не-web платформах показываем плейсхолдер
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.public, size: 48, color: Colors.black54),
          SizedBox(height: 12),
          Text('Карта доступна в веб-сборке (Chrome).',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // Страница Mapbox, которая нормально встраивается в iframe и растягивается.
  String _buildMapboxEmbedUrl({
    required String styleId,
    required String token,
    required double lat,
    required double lon,
    required double zoom,
  }) {
    // Параметры: отключаем заголовок, включаем колесо, ставим hash для центра/зума
    final base   = 'https://api.mapbox.com/styles/v1/$styleId.html';
    final params = 'title=false&zoomwheel=true&fresh=true&access_token=$token';
    final hash   = '#$zoom/$lat/$lon';
    return '$base?$params$hash';
  }

  /// Регистрируем iframe как платформенный виджет (только Web)
  String _registerIFrame(String url) {
    final viewType = 'mapbox-iframe-${DateTime.now().microsecondsSinceEpoch}';

    final element = html.IFrameElement()
      ..src = url
      ..style.border = '0'
      ..style.margin = '0'
      ..style.padding = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.display = 'block'         // убираем «квадратик»
      ..style.position = 'relative';

    // разрешения на всякий случай
    element.setAttribute('allow', 'geolocation *; fullscreen *');

    ui.platformViewRegistry.registerViewFactory(viewType, (int _) => element);
    return viewType;
  }
}
