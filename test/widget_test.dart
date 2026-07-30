import 'package:flutter_test/flutter_test.dart';
import 'package:todo1/main.dart';

void main() {
  testWidgets('App builds and shows Welcome and Todo title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // The app handles the case where Hive box is not open.
    await tester.pumpWidget(const MyApp());

    // Verify the Welcome text is present.
    expect(find.text('Welcome to MicCode App'), findsOneWidget);

    // Verify the title is present in the AppBar.
    expect(find.text('Todo'), findsWidgets);
  });
}
