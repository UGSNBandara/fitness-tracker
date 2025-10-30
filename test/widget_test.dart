import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_tracker/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitnessApp());

    // Verify that the app loads without crashing.
    expect(find.text('Fitness App Home'), findsOneWidget);
  });
}
