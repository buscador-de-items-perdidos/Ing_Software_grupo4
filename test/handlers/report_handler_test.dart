import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('ReportHandler Tests', () {
    setUp(() {
      SessionHandler.logout();
    });

    test('getReporte retorna null para UUID inválido', () {
      final reporte = ReportHandler.getReporte('uuid-inexistente');
      
      expect(reporte, null);
    });

    test('getReportes retorna lista de reportes', () {
      final reportes = ReportHandler.getReportes;
      
      expect(reportes, isA<List<String>>());
    });

    test('submitPeticion agrega petición correctamente', () {
      SessionHandler.login('admin', 'admin123');
      
      final nuevoReporte = Reporte(
        'Test Reporte',
        'Descripción de prueba',
        SessionHandler.uuid,
        false,
        TipoReporte.perdido,
        const LatLng(-36.8201, -73.0444),
      );
      
      final resultado = ReportHandler.submitPeticion('test-uuid-1', nuevoReporte,);
      
      expect(resultado, true);
      final peticiones = ReportHandler.getPeticiones();
      expect(peticiones.contains('test-uuid-1'), true);
    });

    test('getPeticion retorna petición cuando es admin', () {
      SessionHandler.login('admin', 'admin123');
      
      final nuevoReporte = Reporte(
        'Test Peticion',
        'Descripción',
        SessionHandler.uuid,
        false,
        TipoReporte.perdido,
        null,
      );
      
      ReportHandler.submitPeticion('test-uuid-2', nuevoReporte,);
      
      final peticion = ReportHandler.getPeticion('test-uuid-2');
      expect(peticion, isNotNull);
      expect(peticion!.titulo, 'Test Peticion');
    });

    test('getPeticion retorna null cuando no es admin', () {
      SessionHandler.logout();
      
      final peticion = ReportHandler.getPeticion('cualquier-uuid');
      
      expect(peticion, null);
    });

    test('acceptPeticion mueve reporte a existentes', () {
      SessionHandler.login('admin', 'admin123');
      
      final nuevoReporte = Reporte(
        'Reporte a Aceptar',
        'Descripción',
        SessionHandler.uuid,
        false,
        TipoReporte.perdido,
        null,
      );
      
      ReportHandler.submitPeticion('test-uuid-3', nuevoReporte,);
      expect(ReportHandler.getPeticion('test-uuid-3'), isNotNull);
      
      ReportHandler.acceptPeticion('test-uuid-3');
      
      expect(ReportHandler.getPeticion('test-uuid-3'), null);
      expect(ReportHandler.getReporte('test-uuid-3'), isNotNull);
      
      ReportHandler.eliminarReporte('test-uuid-3');
    });

    test('rejectPeticion elimina petición', () {
      SessionHandler.login('admin', 'admin123');
      
      final nuevoReporte = Reporte(
        'Reporte a Rechazar',
        'Descripción',
        SessionHandler.uuid,
        false,
        TipoReporte.encontrado,
        null,
      );
      
      ReportHandler.submitPeticion('test-uuid-4', nuevoReporte,);
      expect(ReportHandler.getPeticion('test-uuid-4'), isNotNull);
      
      ReportHandler.rejectPeticion('test-uuid-4');
      
      expect(ReportHandler.getPeticion('test-uuid-4'), null);
    });

    test('eliminarReporte elimina de existentes', () {
      SessionHandler.login('admin', 'admin123');
      
      final nuevoReporte = Reporte(
        'Reporte a Eliminar',
        'Descripción',
        SessionHandler.uuid,
        false,
        TipoReporte.perdido,
        null,
      );
      
      ReportHandler.submitPeticion('test-uuid-5', nuevoReporte,);
      ReportHandler.acceptPeticion('test-uuid-5');
      expect(ReportHandler.getReporte('test-uuid-5'), isNotNull);
      
      ReportHandler.eliminarReporte('test-uuid-5');
      
      expect(ReportHandler.getReporte('test-uuid-5'), null);
    });

    test('buscarReporte encuentra en cualquier map', () {
      SessionHandler.login('admin', 'admin123');
      
      final nuevoReporte = Reporte(
        'Reporte a Buscar',
        'Descripción',
        SessionHandler.uuid,
        false,
        TipoReporte.perdido,
        null,
      );
      
      ReportHandler.submitPeticion('test-uuid-6', nuevoReporte,);
      
      final reporteEncontrado = ReportHandler.buscarReporte('test-uuid-6');
      expect(reporteEncontrado, isNotNull);
      expect(reporteEncontrado!.titulo, 'Reporte a Buscar');
      
      ReportHandler.rejectPeticion('test-uuid-6');
    });

    test('estadoObjeto mueve reporte a encontrados', () {
      SessionHandler.login('admin', 'admin123');
      
      final nuevoReporte = Reporte(
        'Objeto Perdido',
        'Descripción',
        SessionHandler.uuid,
        false,
        TipoReporte.perdido,
        null,
      );
      
      ReportHandler.submitPeticion('test-uuid-7', nuevoReporte,);
      ReportHandler.acceptPeticion('test-uuid-7');
      expect(ReportHandler.getReporte('test-uuid-7'), isNotNull);
      
      ReportHandler.estadoObjeto('test-uuid-7', true);
      
      expect(ReportHandler.getReporte('test-uuid-7'), null);
      expect(ReportHandler.getEncontrado('test-uuid-7'), isNotNull);
      
      ReportHandler.eliminarReporte('test-uuid-7');
    });

    test('estadoObjeto mueve reporte de encontrados a existentes', () {
      SessionHandler.login('admin', 'admin123');
      
      final nuevoReporte = Reporte(
        'Objeto Encontrado',
        'Descripción',
        SessionHandler.uuid,
        true,
        TipoReporte.perdido,
        null,
      );
      
      ReportHandler.submitPeticion('test-uuid-8', nuevoReporte,);
      ReportHandler.acceptPeticion('test-uuid-8');
      ReportHandler.estadoObjeto('test-uuid-8', true);
      expect(ReportHandler.getEncontrado('test-uuid-8'), isNotNull);
      
      ReportHandler.estadoObjeto('test-uuid-8', false);
      
      expect(ReportHandler.getEncontrado('test-uuid-8'), null);
      expect(ReportHandler.getReporte('test-uuid-8'), isNotNull);
      
      ReportHandler.eliminarReporte('test-uuid-8');
    });

    test('getPeticiones retorna vacío cuando no es admin', () {
      SessionHandler.logout();
      
      final peticiones = ReportHandler.getPeticiones();
      
      expect(peticiones.isEmpty, true);
    });

    test('reportNotifier y pendingNotifier están disponibles', () {
      expect(ReportHandler.reportNotifier, isNotNull);
      expect(ReportHandler.pendingNotifier, isNotNull);
    });
  });
}
