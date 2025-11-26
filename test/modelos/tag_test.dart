import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';
import 'package:ing_software_grupo4/modelos/tagcolor.dart';
import 'package:ing_software_grupo4/modelos/tagtype.dart';

void main() {
  group('Tag Model Tests', () {
    test('Crear tag con nombre y color', () {
      const tag = Tag(TagType.Celular, TagColor.azul);

      expect(tag.tipo, TagType.Celular);
      expect(tag.color, TagColor.azul);
    });

    test('Tag toString retorna formato correcto', () {
      const tag = Tag(TagType.Documentos, TagColor.rojo);
      
      expect(tag.toString(), 'Tag(nombre: Documentos, colorName: Rojo)');
    });

    test('Múltiples tags con diferentes colores', () {
      const tag1 = Tag(TagType.Mochila, TagColor.verde);
      const tag2 = Tag(TagType.Estuche, TagColor.amarillo);
      const tag3 = Tag(TagType.Paraguas, TagColor.naranja);

      expect(tag1.tipo, TagType.Mochila);
      expect(tag1.color, TagColor.verde);
      expect(tag2.tipo, TagType.Estuche);
      expect(tag2.color, TagColor.amarillo);
      expect(tag3.tipo, TagType.Paraguas);
      expect(tag3.color, TagColor.naranja);
    });

    test('Tags con mismo nombre pero diferente color', () {
      const tag1 = Tag(TagType.Tablet, TagColor.rojo);
      const tag2 = Tag(TagType.Tablet, TagColor.azul);

      expect(tag1.tipo, tag2.tipo);
      expect(tag1.color, isNot(tag2.color));
    });

    test('Tags con mismo color pero diferente nombre', () {
      const tag1 = Tag(TagType.Otro, TagColor.azul);
      const tag2 = Tag(TagType.LicenciaDeConducir, TagColor.azul);

      expect(tag1.color, tag2.color);
      expect(tag1.tipo, isNot(tag2.tipo));
    });
  });
}
