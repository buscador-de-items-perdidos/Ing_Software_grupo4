import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/modelos/filter_utils.dart';

void main() {
  group('Filter Utils Tests', () {
    test('availableCategories contiene todas las categorías esperadas', () {
      expect(availableCategories, isNotEmpty);
      expect(availableCategories.contains('Celular'), true);
      expect(availableCategories.contains('Notebook / Laptop'), true);
      expect(availableCategories.contains('Llaves'), true);
      expect(availableCategories.contains('Billetera'), true);
      expect(availableCategories.contains('Otro'), true);
    });

    test('availableCategories tiene al menos 20 categorías', () {
      expect(availableCategories.length, greaterThanOrEqualTo(20));
    });

    test('colorNameToHex contiene colores básicos', () {
      expect(colorNameToHex['rojo'], '#FF0000');
      expect(colorNameToHex['verde'], '#00FF00');
      expect(colorNameToHex['azul'], '#0000FF');
      expect(colorNameToHex['amarillo'], '#FFFF00');
      expect(colorNameToHex['negro'], '#000000');
      expect(colorNameToHex['blanco'], '#FFFFFF');
    });

    test('colorNameToHex contiene colores extendidos', () {
      expect(colorNameToHex['morado'], '#800080');
      expect(colorNameToHex['naranja'], '#FFA500');
      expect(colorNameToHex['celeste'], '#87CEEB');
      expect(colorNameToHex['plateado'], '#C0C0C0');
      expect(colorNameToHex['dorado'], '#FFD700');
    });

    test('getAvailableColors retorna set de colores', () {
      final colors = getAvailableColors();
      
      expect(colors, isA<Set<String>>());
      expect(colors.isNotEmpty, true);
      expect(colors.contains('rojo'), true);
      expect(colors.contains('azul'), true);
      expect(colors.contains('verde'), true);
    });

    test('getAvailableColors retorna todos los colores del mapa', () {
      final colors = getAvailableColors();
      
      expect(colors.length, colorNameToHex.length);
    });

    test('getAvailableTipos retorna set de tipos de reporte', () {
      final tipos = getAvailableTipos();
      
      expect(tipos, isA<Set<String>>());
      expect(tipos.isNotEmpty, true);
    });

    test('getAvailableTipos no incluye administracion', () {
      final tipos = getAvailableTipos();
      
      expect(tipos.contains('administracion'), false);
    });

    test('prettifyColorName capitaliza correctamente', () {
      expect(prettifyColorName('rojo'), 'Rojo');
      expect(prettifyColorName('azul'), 'Azul');
      expect(prettifyColorName('verde'), 'Verde');
    });

    test('prettifyColorName reemplaza guiones bajos por espacios', () {
      expect(prettifyColorName('verde_oscuro'), 'Verde oscuro');
      expect(prettifyColorName('azul_marino'), 'Azul marino');
    });

    test('prettifyColorName maneja nombres con múltiples guiones', () {
      expect(prettifyColorName('un_color_muy_largo'), 'Un color muy largo');
    });

    test('todos los valores de colorNameToHex son códigos hex válidos', () {
      for (final hex in colorNameToHex.values) {
        expect(hex.startsWith('#'), true);
        expect(hex.length, 7); // #RRGGBB
        expect(
          RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex),
          true,
          reason: '$hex no es un código hex válido',
        );
      }
    });

    test('availableCategories no tiene duplicados', () {
      final uniqueCategories = availableCategories.toSet();
      expect(uniqueCategories.length, availableCategories.length);
    });

    test('colorNameToHex keys están en minúsculas', () {
      for (final key in colorNameToHex.keys) {
        expect(key, key.toLowerCase());
      }
    });
  });
}
