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
  String? _hint;

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
                    const SizedBox(height: 6),
                    if (_hint != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          _hint!,
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
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
                              _hint = null;
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
    if (!_isInputShapeValid(query)) {
      setState(() => _error = 'Только буквы, пробелы и дефисы. Минимум 3 символа.');
      return;
    }

    final match = _matchCity(query);
    if (match == null) {
      setState(() {
        _error = 'Не узнали этот город. Попробуй: Рим, Милан, Пиза, Турин, Сицилия';
        _hint = null;
      });
      return;
    }

    setState(() {
      _error = null;
      _hint = match.hint;
      _center = match;
      _viewTypeId = _registerLeafletView(match);
    });
  }

  bool _isInputShapeValid(String value) {
    if (value.trim().length < 3) return false;
    return RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s\-]+$').hasMatch(value.trim());
  }

  _City? _matchCity(String raw) {
    final q = _normalize(raw);
    _City? best;
    var bestScore = 999;

    for (final city in _cities) {
      // мгновенное совпадение по основному имени
      if (_normalize(city.name) == q) return city;

      // совпадение по алиасам
      for (final alias in city.aliases) {
        if (_normalize(alias) == q) return city;
      }

      // частичное вхождение
      if (_normalize(city.name).contains(q) || q.contains(_normalize(city.name))) {
        return city;
      }

      // грубый fuzzy: берём минимальное расстояние по имени/алиасам
      final candidates = [city.name, ...city.aliases];
      for (final cand in candidates) {
        final score = _levenshtein(q, _normalize(cand));
        if (score < bestScore) {
          bestScore = score;
          best = city;
        }
      }
    }

    // допускаем неточное совпадение, если расстояние маленькое относительно длины
    final maxAllowed = (q.length / 3).ceil() + 1; // лояльный порог
    if (best != null && bestScore <= maxAllowed) return best;
    return null;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('ё', 'е')
        .replaceAll(RegExp(r'[\s\-]'), '')
        .trim();
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final m = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
    for (var i = 0; i <= a.length; i++) m[i][0] = i;
    for (var j = 0; j <= b.length; j++) m[0][j] = j;

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        m[i][j] = [
          m[i - 1][j] + 1,
          m[i][j - 1] + 1,
          m[i - 1][j - 1] + cost,
        ].reduce((v, e) => v < e ? v : e);
      }
    }
    return m[a.length][b.length];
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
  final List<String> aliases;
  final String hint;
  final double lat;
  final double lon;
  const _City({
    required this.name,
    required this.lat,
    required this.lon,
    this.aliases = const [],
    this.hint = '',
  });
}

const _cities = [
  _City(
    name: 'Рим',
    aliases: ['Rome', 'Roma'],
    hint: 'Вечный город, Колизей и Ватикан.',
    lat: 41.9028,
    lon: 12.4964,
  ),
  _City(
    name: 'Сицилия (Палермо)',
    aliases: ['Sicilia', 'Palermo', 'Sicily'],
    hint: 'Солнце, рынки, канноли и Этна.',
    lat: 38.1157,
    lon: 13.3615,
  ),
  _City(
    name: 'Пиза',
    aliases: ['Pisa'],
    hint: 'Наклонная башня и Тоскана рядом.',
    lat: 43.7228,
    lon: 10.4017,
  ),
  _City(
    name: 'Милан',
    aliases: ['Milano', 'Milan'],
    hint: 'Дуомо, опера и мода.',
    lat: 45.4642,
    lon: 9.19,
  ),
  _City(
    name: 'Турин',
    aliases: ['Torino', 'Turin'],
    hint: 'Шоколад, Альпы и кино.',
    lat: 45.0703,
    lon: 7.6869,
  ),
];

