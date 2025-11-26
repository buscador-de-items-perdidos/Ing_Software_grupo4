import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('Reporte Model Tests', () {
    test('Crear reporte completo', () {
      final fecha = DateTime(2024, 11, 23);
      final ubicacion = LatLng(-36.8201, -73.0444);
      final etiquetas = [
        const Tag('electrónico', 'azul'),
        const Tag('urgente', 'rojo'),
      ];

      final reporte = Reporte(
        'Laptop perdida',
        'Laptop HP color negro perdida en biblioteca',
        'usuario-uuid-123',
        false,
        TipoReporte.perdido,
        ubicacion,
        fecha: fecha,
        etiquetas: etiquetas,
      );

      expect(reporte.titulo, 'Laptop perdida');
      expect(reporte.descripcion, 'Laptop HP color negro perdida en biblioteca');
      expect(reporte.autor, 'usuario-uuid-123');
      expect(reporte.encontrado, false);
      expect(reporte.tipo, TipoReporte.perdido);
      expect(reporte.ubicacion, ubicacion);
      expect(reporte.fecha, fecha);
      expect(reporte.etiquetas.length, 2);
      expect(reporte.imagenes.isEmpty, true);
      expect(reporte.imagenesBytes.isEmpty, true);
    });

    test('Crear reporte vacío', () {
      final reporte = Reporte.vacio(TipoReporte.encontrado, 'autor-uuid');

      expect(reporte.titulo, '');
      expect(reporte.descripcion, '');
      expect(reporte.encontrado, false);
      expect(reporte.tipo, TipoReporte.encontrado);
      expect(reporte.autor, 'autor-uuid');
      expect(reporte.ubicacion, null);
      expect(reporte.etiquetas.isEmpty, true);
      expect(reporte.imagenes.isEmpty, true);
      expect(reporte.imagenesBytes.isEmpty, true);
    });

    test('Reporte tipo perdido', () {
      final reporte = Reporte(
        'Billetera perdida',
        'Billetera de cuero café',
        'usuario-uuid',
        false,
        TipoReporte.perdido,
        null,
      );

      expect(reporte.tipo, TipoReporte.perdido);
      expect(reporte.encontrado, false);
    });

    test('Reporte tipo encontrado', () {
      final reporte = Reporte(
        'Celular encontrado',
        'Celular Samsung encontrado en cafetería',
        'usuario-uuid',
        false,
        TipoReporte.encontrado,
        LatLng(-36.8205, -73.0450),
      );

      expect(reporte.tipo, TipoReporte.encontrado);
    });

    test('Marcar reporte como encontrado', () {
      final reporte = Reporte(
        'Llaves perdidas',
        'Llaves con llavero rojo',
        'usuario-uuid',
        false,
        TipoReporte.perdido,
        null,
      );

      expect(reporte.encontrado, false);
      
      reporte.encontrado = true;
      
      expect(reporte.encontrado, true);
    });

    test('Reporte con múltiples etiquetas', () {
      final etiquetas = [
        const Tag('electrónico', 'azul'),
        const Tag('urgente', 'rojo'),
        const Tag('biblioteca', 'verde'),
      ];

      final reporte = Reporte(
        'Tablet encontrada',
        'Tablet iPad encontrada',
        'usuario-uuid',
        false,
        TipoReporte.encontrado,
        null,
        etiquetas: etiquetas,
      );

      expect(reporte.etiquetas.length, 3);
      expect(reporte.etiquetas[0].tipo, 'electrónico');
      expect(reporte.etiquetas[1].tipo, 'urgente');
      expect(reporte.etiquetas[2].tipo, 'biblioteca');
    });

    test('Reporte con imágenes (rutas)', () {
      final reporte = Reporte(
        'Mochila encontrada',
        'Mochila azul Adidas',
        'usuario-uuid',
        false,
        TipoReporte.encontrado,
        null,
        imagenes: ['/path/to/image1.jpg', '/path/to/image2.jpg'],
      );

      expect(reporte.imagenes.length, 2);
      expect(reporte.imagenes[0], '/path/to/image1.jpg');
    });

    test('Reporte con ubicación', () {
      final ubicacion = LatLng(-36.8201, -73.0444);
      final reporte = Reporte(
        'Paraguas perdido',
        'Paraguas negro',
        'usuario-uuid',
        false,
        TipoReporte.perdido,
        ubicacion,
      );

      expect(reporte.ubicacion, isNotNull);
      expect(reporte.ubicacion!.latitude, -36.8201);
      expect(reporte.ubicacion!.longitude, -73.0444);
    });

    test('Reporte sin ubicación', () {
      final reporte = Reporte(
        'Cuaderno perdido',
        'Cuaderno de matemáticas',
        'usuario-uuid',
        false,
        TipoReporte.perdido,
        null,
      );

      expect(reporte.ubicacion, isNull);
    });

    test('Fecha por defecto es ahora', () {
      final antes = DateTime.now();
      final reporte = Reporte(
        'Objeto test',
        'Descripción test',
        'usuario-uuid',
        false,
        TipoReporte.perdido,
        null,
      );
      final despues = DateTime.now();

      expect(reporte.fecha.isAfter(antes.subtract(const Duration(seconds: 1))), true);
      expect(reporte.fecha.isBefore(despues.add(const Duration(seconds: 1))), true);
    });
  });
}
