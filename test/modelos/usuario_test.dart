import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';

void main() {
  group('Usuario Model Tests', () {
    test('Crear usuario externo', () {
      final usuario = Usuario(
        nombreUsuario: 'usuario_test',
        correo: 'test@example.com',
        numero: '+56 9 1234 5678',
        miscelaneo: 'Información adicional',
        reportesPendientes: {},
        reportesAceptados: {},
        isAdmin: false,
        tipoUsuario: TipoUsuario.externo,
      );

      expect(usuario.nombreUsuario, 'usuario_test');
      expect(usuario.correo, 'test@example.com');
      expect(usuario.numero, '+56 9 1234 5678');
      expect(usuario.isAdmin, false);
      expect(usuario.tipoUsuario, TipoUsuario.externo);
      expect(usuario.matricula, null);
      expect(usuario.reportesPendientes.isEmpty, true);
      expect(usuario.reportesAceptados.isEmpty, true);
    });

    test('Crear usuario miembro de universidad', () {
      final usuario = Usuario(
        nombreUsuario: 'estudiante_test',
        correo: 'estudiante@udec.cl',
        numero: '+56 9 8765 4321',
        miscelaneo: 'Discord: estudiante123',
        reportesPendientes: {},
        reportesAceptados: {},
        isAdmin: false,
        tipoUsuario: TipoUsuario.miembroUniversidad,
        matricula: '2021012345',
      );

      expect(usuario.tipoUsuario, TipoUsuario.miembroUniversidad);
      expect(usuario.matricula, '2021012345');
    });

    test('Crear usuario administrador', () {
      final usuario = Usuario(
        nombreUsuario: 'admin_test',
        correo: 'admin@udec.cl',
        numero: '+56 9 1111 2222',
        miscelaneo: '',
        reportesPendientes: {},
        reportesAceptados: {},
        isAdmin: true,
      );

      expect(usuario.isAdmin, true);
    });

    test('Agregar reportes pendientes', () {
      final usuario = Usuario(
        nombreUsuario: 'usuario_test',
        correo: 'test@example.com',
        numero: '+56 9 1234 5678',
        miscelaneo: '',
        reportesPendientes: {},
        reportesAceptados: {},
        isAdmin: false,
      );

      usuario.reportesPendientes.add('reporte-1');
      usuario.reportesPendientes.add('reporte-2');

      expect(usuario.reportesPendientes.length, 2);
      expect(usuario.reportesPendientes.contains('reporte-1'), true);
      expect(usuario.reportesPendientes.contains('reporte-2'), true);
    });

    test('Agregar reportes aceptados', () {
      final usuario = Usuario(
        nombreUsuario: 'usuario_test',
        correo: 'test@example.com',
        numero: '+56 9 1234 5678',
        miscelaneo: '',
        reportesPendientes: {},
        reportesAceptados: {},
        isAdmin: false,
      );

      usuario.reportesAceptados.add('reporte-aceptado-1');
      usuario.reportesAceptados.add('reporte-aceptado-2');

      expect(usuario.reportesAceptados.length, 2);
      expect(usuario.reportesAceptados.contains('reporte-aceptado-1'), true);
    });

    test('Mover reporte de pendiente a aceptado', () {
      final usuario = Usuario(
        nombreUsuario: 'usuario_test',
        correo: 'test@example.com',
        numero: '+56 9 1234 5678',
        miscelaneo: '',
        reportesPendientes: {'reporte-1'},
        reportesAceptados: {},
        isAdmin: false,
      );

      const reporteId = 'reporte-1';
      usuario.reportesPendientes.remove(reporteId);
      usuario.reportesAceptados.add(reporteId);

      expect(usuario.reportesPendientes.contains(reporteId), false);
      expect(usuario.reportesAceptados.contains(reporteId), true);
    });
  });
}
