import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/details_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/map_screen_stub.dart' if (dart.library.html) 'screens/map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // считаем количество запусков (пример записи)
  final launches = (prefs.getInt('launchCount') ?? 0) + 1;
  await prefs.setInt('launchCount', launches);

  // читаем последнюю открытую вкладку (пример чтения)
  final lastTab = prefs.getInt('lastTab') ?? 0;

  runApp(VivaItaliaApp(
    initialTab: lastTab,
    launchCount: launches,
    prefs: prefs,
  ));
}

class VivaItaliaApp extends StatelessWidget {
  final int initialTab;
  final int launchCount;
  final SharedPreferences prefs;

  const VivaItaliaApp({
    super.key,
    required this.initialTab,
    required this.launchCount,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viva Italia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF008C45),
      ),
      routes: {
        '/details': (_) => const DetailsScreen(),
      },
      home: _Root(
        key: const ValueKey('root-shell'),
        initialTab: initialTab,
        launchCount: launchCount,
        prefs: prefs,
      ),
    );
  }
}

class _Root extends StatefulWidget {
  final int initialTab;
  final int launchCount;
  final SharedPreferences prefs;

  const _Root({
    super.key,
    required this.initialTab,
    required this.launchCount,
    required this.prefs,
  });

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  late int _index;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab;
    _pages = [
      VivaHomePage(
        launchCount: widget.launchCount,
        onNavigateToMap: (cityName) {
          _openMapWithCity(cityName);
        },
      ),
      VivaMapPage(prefs: widget.prefs),
      ProfileScreen(
        prefs: widget.prefs,
        onFocusCity: _openMapWithCity,
      ),
    ];
  }

  Future<void> _openMapWithCity(String cityName) async {
    setState(() => _index = 1);
    await widget.prefs.setString('focusCity', cityName);
    await widget.prefs.setInt('lastTab', 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) async {
          setState(() => _index = i);
          // сохраняем выбранную вкладку (пример записи)
          await widget.prefs.setInt('lastTab', i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Дом',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Карта',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Кабинет',
          ),
        ],
      ),
    );
  }
}
