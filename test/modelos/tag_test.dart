import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';

void main() {
  group('Tag Model Tests', () {
    test('Crear tag con nombre y color', () {
      const tag = Tag('electrónico', 'azul');

      expect(tag.nombre, 'electrónico');
      expect(tag.colorName, 'azul');
    });

    test('Tag toString retorna formato correcto', () {
      const tag = Tag('urgente', 'rojo');
      
      expect(tag.toString(), 'Tag(nombre: urgente, colorName: rojo)');
    });

    test('Múltiples tags con diferentes colores', () {
      const tag1 = Tag('biblioteca', 'verde');
      const tag2 = Tag('cafetería', 'amarillo');
      const tag3 = Tag('sala_clases', 'naranja');

      expect(tag1.nombre, 'biblioteca');
      expect(tag1.colorName, 'verde');
      expect(tag2.nombre, 'cafetería');
      expect(tag2.colorName, 'amarillo');
      expect(tag3.nombre, 'sala_clases');
      expect(tag3.colorName, 'naranja');
    });

    test('Tags con mismo nombre pero diferente color', () {
      const tag1 = Tag('urgente', 'rojo');
      const tag2 = Tag('urgente', 'azul');

      expect(tag1.nombre, tag2.nombre);
      expect(tag1.colorName, isNot(tag2.colorName));
    });

    test('Tags con mismo color pero diferente nombre', () {
      const tag1 = Tag('electrónico', 'azul');
      const tag2 = Tag('documento', 'azul');

      expect(tag1.colorName, tag2.colorName);
      expect(tag1.nombre, isNot(tag2.nombre));
    });
  });
}
