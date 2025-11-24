import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';

void main() {
  group('Modo Enum Tests', () {
    test('Modo tiene tres valores', () {
      expect(Modo.values.length, 3);
    });

    test('Modo.Editar existe', () {
      expect(Modo.values.contains(Modo.Editar), true);
      expect(Modo.Editar.name, 'Editar');
    });

    test('Modo.Revisar existe', () {
      expect(Modo.values.contains(Modo.Revisar), true);
      expect(Modo.Revisar.name, 'Revisar');
    });

    test('Modo.Ver existe', () {
      expect(Modo.values.contains(Modo.Ver), true);
      expect(Modo.Ver.name, 'Ver');
    });

    test('Modo valores son únicos', () {
      expect(Modo.Editar, isNot(equals(Modo.Revisar)));
      expect(Modo.Editar, isNot(equals(Modo.Ver)));
      expect(Modo.Revisar, isNot(equals(Modo.Ver)));
    });

    test('Modo puede ser comparado', () {
      final modo1 = Modo.Editar;
      final modo2 = Modo.Editar;
      final modo3 = Modo.Ver;
      
      expect(modo1 == modo2, true);
      expect(modo1 == modo3, false);
    });

    test('Modo puede ser usado en switch', () {
      String resultado = '';
      final modo = Modo.Revisar;
      
      switch (modo) {
        case Modo.Editar:
          resultado = 'editando';
          break;
        case Modo.Revisar:
          resultado = 'revisando';
          break;
        case Modo.Ver:
          resultado = 'viendo';
          break;
      }
      
      expect(resultado, 'revisando');
    });

    test('Modo.values contiene todos los valores', () {
      final valores = Modo.values;
      
      expect(valores, contains(Modo.Editar));
      expect(valores, contains(Modo.Revisar));
      expect(valores, contains(Modo.Ver));
    });
  });
}
