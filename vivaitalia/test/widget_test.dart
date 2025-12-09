import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vivaitalia/main.dart';

void main() {
  testWidgets('App builds and shows Viva Italia', (WidgetTester tester) async {
    // Мокаем SharedPreferences: никаких реальных файлов, только память
    SharedPreferences.setMockInitialValues({
      'lastTab': 0,
      'launchCount': 1,
    });

    final prefs = await SharedPreferences.getInstance();

    // Создаём приложение с теми же параметрами, что ожидает VivaItaliaApp
    final app = VivaItaliaApp(
      initialTab: 0,
      launchCount: 1,
      prefs: prefs,
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // Проверяем, что на экране есть текст "Viva Italia"
    expect(find.textContaining('Viva Italia'), findsOneWidget);
  });
}
