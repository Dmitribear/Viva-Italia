// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VivaMapPage extends StatefulWidget {
  final SharedPreferences? prefs;
  const VivaMapPage({super.key, this.prefs});

  @override
  State<VivaMapPage> createState() => _VivaMapPageState();
}

class _VivaMapPageState extends State<VivaMapPage> {
  late String _viewTypeId;
  late final String _channelId;
  _City _center = _cities.first;
  final _controller = TextEditingController();
  String? _error;
  String? _hint;
  bool _panelVisible = true;
  html.IFrameElement? _iframeElement;

  @override
  void initState() {
    super.initState();
    _channelId = 'osm-channel-${DateTime.now().microsecondsSinceEpoch}';
    _viewTypeId = _registerLeafletView(_center);
    _checkFocusCity();
  }

  Future<void> _checkFocusCity() async {
    if (widget.prefs == null) return;
    final focusCity = widget.prefs!.getString('focusCity');
    if (focusCity != null && focusCity.isNotEmpty) {
      // Очищаем сразу, чтобы не фокусироваться повторно
      await widget.prefs!.remove('focusCity');
      
      // Ищем город в списке
      final city = _findCityByName(focusCity);
      if (city != null) {
        // Небольшая задержка для загрузки iframe
        Future.delayed(const Duration(milliseconds: 500), () {
          _setCenter(city);
          _controller.text = city.name;
          setState(() {
            _hint = city.hint;
            _error = null;
          });
        });
      }
    }
  }

  _City? _findCityByName(String name) {
    final normalized = name.toLowerCase().trim();
    for (final city in _cities) {
      if (city.name.toLowerCase() == normalized) return city;
      for (final alias in city.aliases) {
        if (alias.toLowerCase() == normalized) return city;
      }
    }
    return null;
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
        if (_panelVisible)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: PointerInterceptor(
                child: Card(
                  color: Colors.white.withOpacity(0.94),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'OpenStreetMap · ключ не нужен',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Скрыть панель',
                              onPressed: () =>
                                  setState(() => _panelVisible = false),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
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
                                });
                                _setCenter(_cities.first);
                              },
                              child: const Text('Сбросить'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: _cities
                                .map(
                                  (c) => ActionChip(
                                    onPressed: () {
                                      _controller.text = c.name;
                                      _focusOnCity();
                                    },
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          Positioned(
            top: 12,
            left: 12,
            child: PointerInterceptor(
              child: FloatingActionButton.small(
                heroTag: 'show-panel',
                onPressed: () => setState(() => _panelVisible = true),
                child: const Icon(Icons.search),
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
      _setCenter(match);
    });
  }

  void _setCenter(_City city) {
    _center = city;
    // Сообщаем iframe: сдвинь карту и при желании открой модалку
    final message = {
      'channel': _channelId,
      'type': 'pan',
      'lat': city.lat,
      'lon': city.lon,
      'city': city.toMap(),
    };
    
    // Пытаемся отправить в iframe напрямую
    if (_iframeElement != null) {
      try {
        _iframeElement!.contentWindow?.postMessage(message, '*');
      } catch (e) {
        // Если не получилось, отправляем в window
        html.window.postMessage(message, '*');
      }
    } else {
      // Если iframe ещё не создан, отправляем в window
      html.window.postMessage(message, '*');
    }
    
    // Дублируем отправку с небольшой задержкой на случай, если iframe ещё загружается
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_iframeElement != null) {
        try {
          _iframeElement!.contentWindow?.postMessage(message, '*');
        } catch (e) {
          // Игнорируем ошибки
        }
      }
    });
    
    setState(() {});
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
      _iframeElement = element;
      return element;
    });
    return viewType;
  }

  String _buildHtml(_City center) {
    final citiesJson = jsonEncode(_cities.map((c) => c.toMap()).toList());

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
      const cities = $citiesJson;
      const channel = "${_channelId}";

      const map = L.map('map', { scrollWheelZoom: true })
        .setView([${center.lat}, ${center.lon}], 6.2);
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '© OpenStreetMap'
      }).addTo(map);

      // Modal helpers
      const modal = document.createElement('div');
      modal.id = 'city-modal';
      modal.style.cssText = 'position:fixed;inset:0;display:none;align-items:center;justify-content:center;background:rgba(0,0,0,0.5);backdrop-filter:blur(4px);z-index:9999;font-family:"Segoe UI",system-ui,-apple-system,sans-serif;animation:fadeIn 0.2s ease-out;';
      modal.innerHTML = '<style>@keyframes fadeIn{from{opacity:0;}to{opacity:1;}}@keyframes slideUp{from{transform:translateY(20px);opacity:0;}to{transform:translateY(0);opacity:1;}}#city-card{animation:slideUp 0.3s ease-out;display:flex;flex-direction:column;height:85vh;max-height:85vh;}.modal-scroll::-webkit-scrollbar{width:8px;}.modal-scroll::-webkit-scrollbar-track{background:#f1f5f9;border-radius:4px;}.modal-scroll::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:4px;}.modal-scroll::-webkit-scrollbar-thumb:hover{background:#94a3b8;}</style><div id="city-card" style="background:#fff;border-radius:20px;max-width:600px;width:92%;box-shadow:0 20px 60px rgba(0,0,0,0.3);overflow:hidden;"><div id="city-content"></div></div>';
      document.body.appendChild(modal);
      modal.addEventListener('click', (e) => { if (e.target === modal) hideModal(); });

      function hideModal(){ 
        const card = modal.querySelector('#city-card');
        card.style.animation = 'slideUp 0.2s ease-in reverse';
        setTimeout(() => { modal.style.display='none'; }, 200);
      }
      
      function showModal(city){
        const wrap = modal.querySelector('#city-content');
        const card = modal.querySelector('#city-card');
        card.style.animation = 'slideUp 0.3s ease-out';
        
        const section = (icon, label, items, color) => {
          if (!items || items.length === 0) return '';
          const itemsHtml = items.map(p => {
            const linkStyle = 'display:flex;align-items:center;gap:8px;padding:10px 12px;margin:6px 0;background:#f8fafc;border-radius:10px;text-decoration:none;color:#1e293b;transition:all 0.2s;border-left:3px solid ' + color + ';';
            const hoverStyle = 'background:#f1f5f9;transform:translateX(4px);';
            if (p.url) {
              return '<a href="'+p.url+'" target="_blank" rel="noopener" style="'+linkStyle+'" onmouseover="this.style.cssText=\\''+linkStyle+hoverStyle+'\\'" onmouseout="this.style.cssText=\\''+linkStyle+'\\'"><span style="font-size:16px;">🔗</span><span style="flex:1;font-size:14px;line-height:1.4;">'+p.title+'</span><span style="font-size:12px;color:#64748b;">→</span></a>';
            }
            return '<div style="'+linkStyle+'"><span style="font-size:16px;">📍</span><span style="flex:1;font-size:14px;line-height:1.4;">'+p.title+'</span></div>';
          }).join('');
          return '<div style="margin-top:20px;"><div style="display:flex;align-items:center;gap:10px;margin-bottom:12px;padding-bottom:8px;border-bottom:2px solid '+color+'20;"><span style="font-size:22px;">'+icon+'</span><div style="font-weight:700;font-size:16px;color:#1e293b;">'+label+'</div></div>'+itemsHtml+'</div>';
        };
        
        wrap.innerHTML = \`
          <div style="background:linear-gradient(135deg, #667eea 0%, #764ba2 100%);padding:24px 22px 20px;color:#fff;position:relative;flex-shrink:0;">
            <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:16px;">
              <div style="flex:1;">
                <div style="font-size:24px;font-weight:800;margin-bottom:6px;text-shadow:0 2px 4px rgba(0,0,0,0.2);">\${city.name}</div>
                <div style="font-size:14px;opacity:0.95;line-height:1.4;">\${city.hint || ''}</div>
              </div>
              <button aria-label="Close" onclick="hideModal();" style="border:none;background:rgba(255,255,255,0.2);backdrop-filter:blur(10px);border-radius:50%;width:36px;height:36px;cursor:pointer;color:#fff;font-size:18px;display:flex;align-items:center;justify-content:center;transition:all 0.2s;flex-shrink:0;" onmouseover="this.style.background='rgba(255,255,255,0.3)'" onmouseout="this.style.background='rgba(255,255,255,0.2)'">✕</button>
            </div>
          </div>
          <div class="modal-scroll" style="padding:20px 22px 24px;font-size:14px;color:#1f2937;line-height:1.6;overflow-y:auto;overflow-x:hidden;flex:1;min-height:0;max-height:calc(85vh - 120px);-webkit-overflow-scrolling:touch;scrollbar-width:thin;scrollbar-color:#cbd5e1 #f1f5f9;">
            <div style="background:#f8fafc;padding:14px 16px;border-radius:12px;margin-bottom:8px;border-left:4px solid #667eea;font-size:14.5px;line-height:1.6;color:#475569;">\${city.description}</div>
            \${section('🏛️', 'Что посмотреть', city.places, '#667eea')}
            \${section('🏨', 'Отели и жильё', city.hotels, '#f59e0b')}
            \${section('🍝', 'Еда и кофе', city.food, '#ef4444')}
            \${section('💡', 'Полезные факты', city.facts, '#10b981')}
          </div>
        \`;
        modal.style.display = 'flex';
      }

      cities.forEach(c => {
        const marker = L.marker([c.lat, c.lon]).addTo(map);
        marker.on('click', () => showModal(c));
      });

      // Обработка сообщений от родительского окна
      window.addEventListener('message', (event) => {
        try {
          const data = event.data || {};
          if (!data.channel || data.channel !== channel) return;
          
          if (data.type === 'pan' && typeof data.lat === 'number' && typeof data.lon === 'number') {
            map.flyTo([data.lat, data.lon], 11, {
              duration: 1.2,
              easeLinearity: 0.25
            });
          }
          if (data.type === 'focus-city' && data.city) {
            map.flyTo([data.city.lat, data.city.lon], 11, {
              duration: 1.2,
              easeLinearity: 0.25
            });
            showModal(data.city);
          }
        } catch (e) {
          console.error('Error handling message:', e);
        }
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
  final String description;
  final List<_Poi> places;
  final List<_Poi> hotels;
  final List<_Poi> food;
  final List<_Poi> facts;
  const _City({
    required this.name,
    required this.lat,
    required this.lon,
    this.aliases = const [],
    this.hint = '',
    this.description = '',
    this.places = const [],
    this.hotels = const [],
    this.food = const [],
    this.facts = const [],
  });

  Map<String, Object> toMap() => {
        'name': name,
        'hint': hint,
        'lat': lat,
        'lon': lon,
        'description': description,
        'places': places.map((p) => p.toMap()).toList(),
        'hotels': hotels.map((p) => p.toMap()).toList(),
        'food': food.map((p) => p.toMap()).toList(),
        'facts': facts.map((p) => p.toMap()).toList(),
      };
}

class _Poi {
  final String title;
  final String? url;
  const _Poi(this.title, {this.url});
  Map<String, String> toMap() =>
      url == null ? {'title': title} : {'title': title, 'url': url!};
}

const _cities = [
  _City(
    name: 'Рим',
    aliases: ['Rome', 'Roma'],
    hint: 'Вечный город, Колизей и Ватикан.',
    description:
        'Исторический центр, античные руины и музеи мирового уровня. Легко пешком + метро.',
    places: [
      _Poi('Колизей', url: 'https://colosseum.tickets/'),
      _Poi('Ватикан и Сикстинская капелла', url: 'https://tickets.museivaticani.va/'),
      _Poi('Фонтан Треви'),
    ],
    hotels: [
      _Poi('Trastevere B&B'),
      _Poi('Hotel Artemide'),
    ],
    food: [
      _Poi('Roscioli (паста/сулугуни)'),
      _Poi('Pizzarium Bonci (пицца на срез)'),
    ],
    facts: [
      _Poi('Метро всего 3 линии, автобусами быстрее по центру'),
    ],
    lat: 41.9028,
    lon: 12.4964,
  ),
  _City(
    name: 'Сицилия (Палермо)',
    aliases: ['Sicilia', 'Palermo', 'Sicily'],
    hint: 'Солнце, рынки, канноли и Этна.',
    description:
        'Островный вайб: барокко Палермо, вулкан Этна, уличная еда и пляжи Чефалу.',
    places: [
      _Poi('Собор Палермо'),
      _Poi('Монреале'),
      _Poi('Этна', url: 'https://www.etnaexperience.com/'),
    ],
    hotels: [
      _Poi('NH Palermo'),
      _Poi('B&B Quattro Incanti'),
    ],
    food: [
      _Poi('Cannoli у Cannoli & Co'),
      _Poi('Arancina у Ke Palle'),
    ],
    facts: [
      _Poi('Лучшее время май–июнь и сентябрь'),
    ],
    lat: 38.1157,
    lon: 13.3615,
  ),
  _City(
    name: 'Пиза',
    aliases: ['Pisa'],
    hint: 'Наклонная башня и Тоскана рядом.',
    description: 'Компактный старый город, башня и быстрый доступ во Флоренцию.',
    places: [
      _Poi('Площадь Чудес и башня', url: 'https://www.opapisa.it/'),
      _Poi('Арно и мосты'),
    ],
    hotels: [
      _Poi('Hotel Bologna Pisa'),
    ],
    food: [
      _Poi('La Taverna di Emma'),
    ],
    facts: [
      _Poi('Башня допускает подъём по билетам с тайм-слотами'),
    ],
    lat: 43.7228,
    lon: 10.4017,
  ),
  _City(
    name: 'Милан',
    aliases: ['Milano', 'Milan'],
    hint: 'Дуомо, опера и мода.',
    description:
        'Столица дизайна: Дуомо, Галерея Виктора Эммануила и кварталы Навильи.',
    places: [
      _Poi('Дуомо', url: 'https://www.duomomilano.it/en/'),
      _Poi('Santa Maria delle Grazie (Тайная вечеря)', url: 'https://cenacolovinciano.vivaticket.it/'),
      _Poi('Каналы Навильи'),
    ],
    hotels: [
      _Poi('Room Mate Giulia'),
      _Poi('Ostello Bello (хостел)'),
    ],
    food: [
      _Poi('Luini (панцеротти)'),
      _Poi('Pavé (кофе/круассаны)'),
    ],
    facts: [
      _Poi('Проездной ATM выгоден на 1–3 дня'),
    ],
    lat: 45.4642,
    lon: 9.19,
  ),
  _City(
    name: 'Турин',
    aliases: ['Torino', 'Turin'],
    hint: 'Шоколад, Альпы и кино.',
    description:
        'Барокко, музеи кино и Египта, вида на Альпы. Город кофе и джандуйи.',
    places: [
      _Poi('Mole Antonelliana (музей кино)', url: 'https://www.museocinema.it/'),
      _Poi('Египетский музей', url: 'https://museoegizio.it/'),
    ],
    hotels: [
      _Poi('NH Collection Torino Piazza Carlina'),
    ],
    food: [
      _Poi('Caffè Torino (бичерин)'),
      _Poi('Guido Gobino (джандуйя)'),
    ],
    facts: [
      _Poi('Линия метро всего одна — удобно по центру'),
    ],
    lat: 45.0703,
    lon: 7.6869,
  ),
];

