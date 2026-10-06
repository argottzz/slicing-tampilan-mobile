import 'package:flutter_test/flutter_test.dart';

import 'package:tugas_slicing/main.dart';

void main() {
  testWidgets('Splash is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Leafboard'), findsWidgets);
    expect(find.text('Get Started for Free'), findsOneWidget);
  });
}
