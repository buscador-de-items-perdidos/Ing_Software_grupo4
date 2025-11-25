import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';

void main() {
  group('Report Flow Integration Tests', () {
    setUp(() {
      SessionHandler.logout();
    });

    test('Usuario logueado puede acceder a reportes', () {
      SessionHandler.login('admin', 'admin123');

      expect(SessionHandler.isLoggedIn, true);
      expect(ReportHandler.getReportes, isA<List<String>>());
    });

    test('Admin puede ver peticiones', () {
      SessionHandler.login('admin', 'admin123');

      expect(SessionHandler.isAdmin, true);
      expect(ReportHandler.getPeticiones(), isNotNull);
    });

    test('Flujo completo de crear y aprobar reporte', () {
      SessionHandler.login('admin', 'admin123');

      final nuevoReporte = Reporte(
        'Objeto Perdido Test',
        'Descripción del objeto',
        SessionHandler.uuid,
        false,
        TipoReporte.perdido,
        null,
      );

      final uuid = 'integration-test-uuid-1';
      ReportHandler.submitPeticion(uuid, nuevoReporte,);

      expect(ReportHandler.getPeticion(uuid), isNotNull);

      ReportHandler.acceptPeticion(uuid);

      expect(ReportHandler.getReporte(uuid), isNotNull);
      expect(ReportHandler.getPeticion(uuid), null);

      ReportHandler.eliminarReporte(uuid);
    });

    test('Flujo de crear y rechazar reporte', () {
      SessionHandler.login('admin', 'admin123');

      final nuevoReporte = Reporte(
        'Objeto Test 2',
        'Descripción',
        SessionHandler.uuid,
        false,
        TipoReporte.encontrado,
        null,
      );

      final uuid = 'integration-test-uuid-2';
      ReportHandler.submitPeticion(uuid, nuevoReporte);

      expect(ReportHandler.getPeticion(uuid), isNotNull);

      ReportHandler.rejectPeticion(uuid);

      expect(ReportHandler.getPeticion(uuid), null);
      expect(ReportHandler.getReporte(uuid), null);
    });

    test('Flujo de cambiar estado de objeto', () {
      SessionHandler.login('admin', 'admin123');

      final nuevoReporte = Reporte(
        'Objeto para Encontrar',
        'Descripción',
        SessionHandler.uuid,
        false,
        TipoReporte.perdido,
        null,
      );

      final uuid = 'integration-test-uuid-3';
      ReportHandler.submitPeticion(uuid, nuevoReporte);
      ReportHandler.acceptPeticion(uuid);

      expect(ReportHandler.getReporte(uuid), isNotNull);

      ReportHandler.estadoObjeto(uuid, true);

      expect(ReportHandler.getEncontrado(uuid), isNotNull);
      expect(ReportHandler.getReporte(uuid), null);

      ReportHandler.estadoObjeto(uuid, false);

      expect(ReportHandler.getReporte(uuid), isNotNull);
      expect(ReportHandler.getEncontrado(uuid), null);

      ReportHandler.eliminarReporte(uuid);
    });

    test('Usuario no admin no puede ver peticiones', () {
      SessionHandler.registrarUsuario(
        nombreUsuario: 'usuarioNormal',
        password: 'password123',
        correo: 'normal@example.com',
        tipoUsuario: TipoUsuario.externo,
        numero: '+56 9 1111 1111',
      );

      SessionHandler.login('usuarioNormal', 'password123');

      expect(SessionHandler.isAdmin, false);
      expect(ReportHandler.getPeticiones().isEmpty, true);
    });
  });
}
