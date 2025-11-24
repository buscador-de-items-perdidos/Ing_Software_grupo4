import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/main.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/login_screen.dart';

void main() {
  group('Auth Flow Integration Tests', () {
    setUp(() {
      SessionHandler.logout();
    });

    testWidgets('Flujo completo de login exitoso', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'admin');
      await tester.enterText(find.byType(TextField).last, 'admin123');
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(SessionHandler.isLoggedIn, true);
    });

    testWidgets('Flujo de login con credenciales incorrectas', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'admin');
      await tester.enterText(find.byType(TextField).last, 'wrongpassword');
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(SessionHandler.isLoggedIn, false);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Navegación a pantalla de registro', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Registrarse'), findsWidgets);
      
      await tester.tap(find.widgetWithText(OutlinedButton, 'Registrarse'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Usuario puede cerrar sesión', (WidgetTester tester) async {
      SessionHandler.login('admin', 'admin123');
      
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(SessionHandler.isLoggedIn, true);
      
      SessionHandler.logout();
      await tester.pumpAndSettle();

      expect(SessionHandler.isLoggedIn, false);
    });
  });
}
