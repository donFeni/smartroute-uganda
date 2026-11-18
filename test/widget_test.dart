import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartroute_uganda/features/home/presentation/screens/foundation_screen.dart';

void main() {
  testWidgets('SmartRoute foundation screen loads', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: FoundationScreen()),
    );

    expect(find.text('SmartRoute Uganda'), findsOneWidget);

    expect(
      find.text('Beyond Navigation.\nTowards Smarter Mobility.'),
      findsOneWidget,
    );

    expect(find.text('Project foundation established.'), findsOneWidget);
  });
}
