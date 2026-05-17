import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('integration smoke runs', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('ARACIYOK integration smoke'),
          ),
        ),
      ),
    );

    expect(find.text('ARACIYOK integration smoke'), findsOneWidget);
  });
}
