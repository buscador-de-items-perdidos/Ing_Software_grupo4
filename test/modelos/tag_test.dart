import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';

void main() {
  group('Tag Model Tests', () {
    test('Crear tag con nombre y color', () {
      const tag = Tag('electrónico', 'azul');

      expect(tag.tipo, 'electrónico');
      expect(tag.color, 'azul');
    });

    test('Tag toString retorna formato correcto', () {
      const tag = Tag('urgente', 'rojo');
      
      expect(tag.toString(), 'Tag(nombre: urgente, colorName: rojo)');
    });

    test('Múltiples tags con diferentes colores', () {
      const tag1 = Tag('biblioteca', 'verde');
      const tag2 = Tag('cafetería', 'amarillo');
      const tag3 = Tag('sala_clases', 'naranja');

      expect(tag1.tipo, 'biblioteca');
      expect(tag1.color, 'verde');
      expect(tag2.tipo, 'cafetería');
      expect(tag2.color, 'amarillo');
      expect(tag3.tipo, 'sala_clases');
      expect(tag3.color, 'naranja');
    });

    test('Tags con mismo nombre pero diferente color', () {
      const tag1 = Tag('urgente', 'rojo');
      const tag2 = Tag('urgente', 'azul');

      expect(tag1.tipo, tag2.tipo);
      expect(tag1.color, isNot(tag2.color));
    });

    test('Tags con mismo color pero diferente nombre', () {
      const tag1 = Tag('electrónico', 'azul');
      const tag2 = Tag('documento', 'azul');

      expect(tag1.color, tag2.color);
      expect(tag1.tipo, isNot(tag2.tipo));
    });
  });
}
