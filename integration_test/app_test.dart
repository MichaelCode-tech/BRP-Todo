import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify welcome text and title', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify the Welcome text is present.
      expect(find.text('Welcome to MicCode App'), findsOneWidget);

      // Verify the title is present.
      expect(find.text('Todo'), findsWidgets);
    });
  });
}
