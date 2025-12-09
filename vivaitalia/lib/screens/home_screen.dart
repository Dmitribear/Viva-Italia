import 'package:flutter/material.dart';

class VivaHomePage extends StatefulWidget {
  final int launchCount;
  const VivaHomePage({super.key, required this.launchCount});

  @override
  State<VivaHomePage> createState() => _VivaHomePageState();
}

class _VivaHomePageState extends State<VivaHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
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
                  children: const [
                    _StatPill(
                      icon: Icons.museum_outlined,
                      label: '58 объектов ЮНЕСКО',
                    ),
                    _StatPill(
                      icon: Icons.wine_bar_outlined,
                      label: '20 регионов вкуса',
                    ),
                    _StatPill(
                      icon: Icons.beach_access_outlined,
                      label: '~7600 км береговой линии',
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

  Widget _wishForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Запиши город мечты — проверим, что ввёл осознанно',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _cityController,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Город или регион',
              hintText: 'Например, Болонья или Лигурия',
              labelStyle: const TextStyle(color: Colors.black87),
              prefixIcon: const Icon(Icons.location_on_outlined),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Поле не должно быть пустым';
              if (text.length < 3) return 'Минимум 3 символа';
              if (!RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s\-]+$').hasMatch(text)) {
                return 'Используй только буквы и пробелы';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final city = _cityController.text.trim();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Записали: $city. Добавь на карте свою метку!'),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.9),
              foregroundColor: Colors.black,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline),
                SizedBox(width: 8),
                Text('Проверить ввод'),
              ],
            ),
          ),
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
