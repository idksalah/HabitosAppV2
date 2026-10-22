import 'package:flutter_test/flutter_test.dart';
import 'package:habitosappv2/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Carga la pantalla inicial correctamente', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a HabitosApp'), findsOneWidget);
  });
}
