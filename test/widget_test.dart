
import 'package:flutter_test/flutter_test.dart';
import 'package:smartroute_uganda/app/smartroute_app.dart';

void main() {
  testWidgets('SmartRoute foundation screen loads',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmartRouteApp());

    expect(find.text('SmartRoute Uganda'), findsOneWidget);

    expect(
      find.text('Beyond Navigation.\nTowards Smarter Mobility.'),
      findsOneWidget,
    );

    expect(
      find.text('Project foundation established.'),
      findsOneWidget,
    );
  });
}
