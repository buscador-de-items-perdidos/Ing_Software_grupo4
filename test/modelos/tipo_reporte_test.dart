import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';

void main() {
  group('TipoReporte Enum Tests', () {
    test('TipoReporte tiene valores esperados', () {
      expect(TipoReporte.values.length, greaterThanOrEqualTo(2));
    });

    test('TipoReporte.perdido existe', () {
      expect(TipoReporte.values.contains(TipoReporte.perdido), true);
      expect(TipoReporte.perdido.name, 'perdido');
    });

    test('TipoReporte.encontrado existe', () {
      expect(TipoReporte.values.contains(TipoReporte.encontrado), true);
      expect(TipoReporte.encontrado.name, 'encontrado');
    });

    test('TipoReporte valores son únicos', () {
      expect(TipoReporte.perdido, isNot(equals(TipoReporte.encontrado)));
    });

    test('TipoReporte puede ser comparado', () {
      final tipo1 = TipoReporte.perdido;
      final tipo2 = TipoReporte.perdido;
      final tipo3 = TipoReporte.encontrado;
      
      expect(tipo1 == tipo2, true);
      expect(tipo1 == tipo3, false);
    });

    test('TipoReporte puede ser usado en switch', () {
      String resultado = '';
      final tipo = TipoReporte.encontrado;
      
      switch (tipo) {
        case TipoReporte.perdido:
          resultado = 'objeto perdido';
          break;
        case TipoReporte.encontrado:
          resultado = 'objeto encontrado';
          break;
        default:
          resultado = 'otro';
      }
      
      expect(resultado, 'objeto encontrado');
    });

    test('TipoReporte.values contiene todos los valores', () {
      final valores = TipoReporte.values;
      
      expect(valores, contains(TipoReporte.perdido));
      expect(valores, contains(TipoReporte.encontrado));
    });

    test('TipoReporte puede ser obtenido por índice', () {
      final primer = TipoReporte.values[0];
      final segundo = TipoReporte.values[1];
      
      expect(primer, isNotNull);
      expect(segundo, isNotNull);
      expect(primer, isNot(equals(segundo)));
    });

    test('TipoReporte tiene índices correctos', () {
      expect(TipoReporte.perdido.index, isA<int>());
      expect(TipoReporte.encontrado.index, isA<int>());
      expect(TipoReporte.perdido.index, isNot(equals(TipoReporte.encontrado.index)));
    });
  });
}
