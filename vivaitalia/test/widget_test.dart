import 'package:flutter_test/flutter_test.dart';
import 'package:vivaitalia/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {

    await tester.pumpWidget(const VivaItaliaApp());


    expect(find.textContaining('Viva Italia'), findsOneWidget);
  });
}
