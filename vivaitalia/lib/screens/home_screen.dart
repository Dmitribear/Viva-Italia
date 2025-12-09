import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vivaitalia/screens/details_screen.dart';

class VivaHomePage extends StatefulWidget {
  final int launchCount;
  final void Function(String cityName)? onNavigateToMap;
  const VivaHomePage({
    super.key,
    required this.launchCount,
    this.onNavigateToMap,
  });

  @override
  State<VivaHomePage> createState() => _VivaHomePageState();
}

class _VivaHomePageState extends State<VivaHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  List<String> _wishList = [];
  String? _foundCityInfo;
  List<String> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWishList();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadWishList() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('wishList') ?? [];
    setState(() => _wishList = list);
  }

  Future<void> _saveWishList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('wishList', _wishList);
  }

  // Расширенный список известных итальянских городов и регионов
  static const _knownCities = {
    'Рим': 'Столица Италии, Колизей, Ватикан',
    'Милан': 'Столица моды, Дуомо, Навильи',
    'Венеция': 'Каналы, Гранд-канал, площадь Сан-Марко',
    'Флоренция': 'Родина Возрождения, Уффици, Дуомо',
    'Неаполь': 'Пицца, Помпеи, Везувий',
    'Турин': 'Шоколад, музеи, Альпы',
    'Пиза': 'Наклонная башня, площадь Чудес',
    'Болонья': 'Университет, башни, кухня',
    'Генуя': 'Порт, аквариум, старый город',
    'Палермо': 'Сицилия, барокко, рынки',
    'Катания': 'Сицилия, Этна, вулкан',
    'Бари': 'Апулия, мощи Николая Чудотворца',
    'Сиена': 'Тоскана, Палио, средневековье',
    'Перуджа': 'Умбрия, шоколад, университет',
    'Ассизи': 'Умбрия, святой Франциск',
    'Верона': 'Ромео и Джульетта, арена',
    'Падуя': 'Венето, капелла Скровеньи',
    'Равенна': 'Эмилия-Романья, мозаики',
    'Мантуя': 'Ломбардия, дворец Гонзага',
    'Кремона': 'Ломбардия, скрипки',
    'Лигурия': 'Регион: Генуя, Чинкве-Терре',
    'Тоскана': 'Регион: Флоренция, Сиена, Пиза',
    'Умбрия': 'Регион: Перуджа, Ассизи',
    'Венето': 'Регион: Венеция, Верона, Падуя',
    'Ломбардия': 'Регион: Милан, Мантуя',
    'Эмилия-Романья': 'Регион: Болонья, Равенна',
    'Сицилия': 'Остров: Палермо, Катания, Этна',
    'Сардиния': 'Остров: Кальяри, пляжи',
    'Апулия': 'Регион: Бари, Лечче, Трулли',
    'Кампания': 'Регион: Неаполь, Амальфи',
  };

  String? _findCity(String query) {
    final q = query.trim().toLowerCase();
    for (final entry in _knownCities.entries) {
      final name = entry.key.toLowerCase();
      if (name == q || name.startsWith(q) || name.contains(q)) {
        return entry.key;
      }
    }
    return null;
  }

  List<String> _findSuggestions(String query) {
    if (query.length < 2) return [];
    final q = query.trim().toLowerCase();
    final matches = <String>[];
    for (final entry in _knownCities.entries) {
      final name = entry.key.toLowerCase();
      if (name.contains(q) && name != q) {
        matches.add(entry.key);
        if (matches.length >= 3) break;
      }
    }
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/fon.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.32),
                  Colors.black.withOpacity(0.65),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Viva Italia · вдохновляющий гид',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.98),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Запусков приложения: ${widget.launchCount}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 22),
                const Text(
                  'От античного Рима до футуристичного Милана, от вулканов '
                  'Сицилии до белых пляжей Апулии. Собрали главное, чтобы '
                  'спланировать поездку без лишнего шума.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    const _StatPill(
                      icon: Icons.museum_outlined,
                      label: '58 объектов ЮНЕСКО',
                    ),
                    const _StatPill(
                      icon: Icons.wine_bar_outlined,
                      label: '20 регионов вкуса',
                    ),
                    const _StatPill(
                      icon: Icons.beach_access_outlined,
                      label: '~7600 км береговой линии',
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
                const SizedBox(height: 20),
                _infoCard(
                  'Маршрут на неделю',
                  'Рим → Флоренция → Пиза → Милан → Турин. Быстрый ритм, '
                  'поезда Frecciarossa, вкусная еда на каждом вокзале.',
                ),
                const SizedBox(height: 12),
                _infoCard(
                  'Медленный юг',
                  'Неаполь, Амальфи, перелёт на Сицилию: Катания, Этна, '
                  'Палермо и пляжи Чефалу. Темп «piano, piano».',
                ),
                const SizedBox(height: 12),
                _infoCard(
                  'Когда ехать',
                  'Апрель–июнь и сентябрь–октябрь — мягкая погода и меньше толп. '
                  'Июль–август — жара и высокий спрос.',
                ),
                const SizedBox(height: 24),
                _miniGrid(),
                const SizedBox(height: 22),
                _wishForm(context),
                const SizedBox(height: 26),
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/details'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.92),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('О стране подробнее'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ниже переключись на «Карта», там уже отмечены Рим, Сицилия, '
                  'Пиза, Милан и Турин.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _infoCard(String title, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.45,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniGrid() {
    const tiles = [
      (
        '🚄 Транспорт',
        'Берите билеты на поезда заранее — дешевле и место лучше.',
      ),
      (
        '🍦 Еда',
        'В полдень — паста, вечером — аперитиво, утром — корнетто и капучино.',
      ),
      (
        '🎟 Музеи',
        'Бронируйте вход онлайн, чтобы не стоять под солнцем.',
      ),
      (
        '🌊 Море',
        'Лучший комфорт — Тирренское побережье и Сардиния в сентябре.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 520;
        final crossAxisCount = isWide ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isWide ? 2.6 : 3.6,
          ),
          itemBuilder: (_, i) {
            final data = tiles[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.$1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.$2,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _checkCity() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _foundCityInfo = null;
      _suggestions = [];
    });

    final query = _cityController.text.trim();
    
    // Имитация небольшой задержки для UX
    await Future.delayed(const Duration(milliseconds: 300));

    final found = _findCity(query);
    
    setState(() {
      _isLoading = false;
      if (found != null) {
        _foundCityInfo = _knownCities[found]!;
        if (!_wishList.contains(found)) {
          _wishList.add(found);
          _saveWishList();
        }
      } else {
        _suggestions = _findSuggestions(query);
      }
    });
  }

  Widget _wishForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Найди свой город мечты в Италии',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Введи название города или региона — найдём информацию',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _cityController,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Город или регион Италии',
              hintText: 'Например, Болонья, Венеция, Тоскана',
              labelStyle: const TextStyle(color: Colors.black87),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _foundCityInfo = null;
                _suggestions = [];
              });
            },
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Введи название города';
              if (text.length < 2) return 'Минимум 2 символа';
              if (!RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s\-]+$').hasMatch(text)) {
                return 'Только буквы, пробелы и дефисы';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _checkCity,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_isLoading ? 'Ищем...' : 'Найти город'),
            ),
          ),
          if (_foundCityInfo != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _cityController.text.trim(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _foundCityInfo!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            final cityName = _cityController.text.trim();
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('focusCity', cityName);
                            widget.onNavigateToMap?.call(cityName);
                          },
                          icon: const Icon(Icons.map),
                          label: const Text('Показать на карте'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _wishList.remove(_cityController.text.trim());
                            _saveWishList();
                            _foundCityInfo = null;
                            _cityController.clear();
                          });
                        },
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.white70,
                        tooltip: 'Удалить из списка',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (_suggestions.isNotEmpty && _foundCityInfo == null) ...[
            const SizedBox(height: 12),
            Text(
              'Возможно, ты имел в виду:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions.map((city) {
                return ActionChip(
                  label: Text(city),
                  onPressed: () {
                    _cityController.text = city;
                    _checkCity();
                  },
                  backgroundColor: Colors.white.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
          ],
          if (_wishList.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Избранные города',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${_wishList.length} ${_wishList.length == 1 ? 'город' : _wishList.length < 5 ? 'города' : 'городов'}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_wishList.length > 1)
                        TextButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Очистить список?'),
                                content: const Text(
                                  'Удалить все города из избранного?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Отмена'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Удалить всё'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              setState(() {
                                _wishList.clear();
                                _saveWishList();
                              });
                            }
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Очистить'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._wishList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final city = entry.value;
                    final cityInfo = _knownCities[city];
                    return Container(
                      margin: EdgeInsets.only(
                        bottom: index < _wishList.length - 1 ? 10 : 0,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  city,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                if (cityInfo != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    cityInfo,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('focusCity', city);
                              widget.onNavigateToMap?.call(city);
                            },
                            icon: const Icon(Icons.map),
                            color: Colors.white,
                            tooltip: 'Показать на карте',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _wishList.remove(city);
                                _saveWishList();
                              });
                            },
                            icon: const Icon(Icons.close, size: 18),
                            color: Colors.white70,
                            tooltip: 'Удалить',
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
