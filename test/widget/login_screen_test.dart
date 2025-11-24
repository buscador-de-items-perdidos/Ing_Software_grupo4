import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/login_screen.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    setUp(() {
      SessionHandler.logout();
    });

    testWidgets('LoginScreen muestra campos de formulario', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Registrarse'), findsOneWidget);
    });

    testWidgets('LoginScreen muestra botones de acción', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Registrarse'), findsOneWidget);
    });

    testWidgets('LoginScreen permite ingresar texto', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'testuser');
      await tester.enterText(find.byType(TextField).last, 'testpass');
      
      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('testpass'), findsOneWidget);
    });
  });
}
