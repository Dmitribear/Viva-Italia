// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class VivaMapPage extends StatefulWidget {
  const VivaMapPage({super.key});

  @override
  State<VivaMapPage> createState() => _VivaMapPageState();
}

class _VivaMapPageState extends State<VivaMapPage> {
  late String _viewTypeId;
  _City _center = _cities.first;
  final _controller = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _viewTypeId = _registerLeafletView(_center);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Карта доступна в веб-сборке (Chrome / Edge).',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: HtmlElementView(viewType: _viewTypeId),
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              color: Colors.white.withOpacity(0.92),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'OpenStreetMap · ключ не нужен',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Отмечены Рим, Сицилия (Палермо), Пиза, Милан и Турин. '
                      'Введи город — подвинем центр карты.',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Город для фокуса',
                        hintText: 'Например, Милан',
                        errorText: _error,
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _focusOnCity(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: _focusOnCity,
                          icon: const Icon(Icons.my_location_outlined),
                          label: const Text('Показать'),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _controller.clear();
                              _error = null;
                              _center = _cities.first;
                              _viewTypeId = _registerLeafletView(_center);
                            });
                          },
                          child: const Text('Сбросить'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _cities
                          .map(
                            (c) => Chip(
                              label: Text(c.name),
                              avatar: const Icon(Icons.place, size: 18),
                              labelStyle: const TextStyle(fontSize: 13),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          bottom: 8,
          right: 12,
          child: Text(
            '© OpenStreetMap, Leaflet',
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  void _focusOnCity() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() => _error = 'Поле не должно быть пустым');
      return;
    }
    if (query.length < 3) {
      setState(() => _error = 'Минимум 3 символа');
      return;
    }
    if (!RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s\-]+$').hasMatch(query)) {
      setState(() => _error = 'Только буквы и пробелы');
      return;
    }

    final match = _findCity(query);
    if (match == null) {
      setState(() => _error = 'Такой город не отмечен (добавь ближний)');
      return;
    }

    setState(() {
      _error = null;
      _center = match;
      _viewTypeId = _registerLeafletView(match);
    });
  }

  _City? _findCity(String value) {
    final q = value.toLowerCase();
    for (final city in _cities) {
      final name = city.name.toLowerCase();
      if (name.contains(q) || q.contains(name)) return city;
    }
    return null;
  }

  String _registerLeafletView(_City center) {
    final viewType = 'osm-leaflet-${DateTime.now().microsecondsSinceEpoch}';
    final htmlContent = _buildHtml(center);
    ui.platformViewRegistry.registerViewFactory(viewType, (int _) {
      final element = html.IFrameElement()
        ..srcdoc = htmlContent
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.margin = '0'
        ..style.padding = '0';
      element.setAttribute('allow', 'geolocation *; fullscreen *');
      return element;
    });
    return viewType;
  }

  String _buildHtml(_City center) {
    final markers = _cities
        .map((c) => "{name:'${c.name}',lat:${c.lat},lon:${c.lon}}")
        .join(',');

    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
      html, body, #map { height: 100%; margin: 0; }
      .leaflet-container { font-family: "Segoe UI", sans-serif; }
    </style>
  </head>
  <body>
    <div id="map"></div>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
      const map = L.map('map', { scrollWheelZoom: true })
        .setView([${center.lat}, ${center.lon}], 6.2);
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '© OpenStreetMap'
      }).addTo(map);

      const points = [$markers];
      points.forEach(p => {
        L.marker([p.lat, p.lon]).addTo(map).bindPopup(p.name);
      });
    </script>
  </body>
</html>
''';
  }
}

class _City {
  final String name;
  final double lat;
  final double lon;
  const _City(this.name, this.lat, this.lon);
}

const _cities = [
  _City('Рим', 41.9028, 12.4964),
  _City('Сицилия (Палермо)', 38.1157, 13.3615),
  _City('Пиза', 43.7228, 10.4017),
  _City('Милан', 45.4642, 9.19),
  _City('Турин', 45.0703, 7.6869),
];

