import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';

void main() {
  group('SessionHandler Tests', () {
    setUp(() {
      SessionHandler.logout();
    });

    test('Login con credenciales correctas', () {
      final resultado = SessionHandler.login('admin', 'admin123');
      
      expect(resultado, true);
      expect(SessionHandler.isLoggedIn, true);
      expect(SessionHandler.nombreUsuario, 'pandita_45');
      expect(SessionHandler.isAdmin, true);
    });

    test('Login con credenciales incorrectas', () {
      final resultado = SessionHandler.login('admin', 'wrongpassword');
      
      expect(resultado, false);
      expect(SessionHandler.isLoggedIn, false);
      expect(SessionHandler.uuid, '');
    });

    test('Login con usuario inexistente', () {
      final resultado = SessionHandler.login('noexiste', 'password');
      
      expect(resultado, false);
      expect(SessionHandler.isLoggedIn, false);
    });

    test('Logout cierra la sesión', () {
      SessionHandler.login('admin', 'admin123');
      expect(SessionHandler.isLoggedIn, true);
      
      SessionHandler.logout();
      
      expect(SessionHandler.isLoggedIn, false);
      expect(SessionHandler.uuid, '');
      expect(SessionHandler.nombreUsuario, '');
    });

    test('Usuario actual retorna null cuando no hay sesión', () {
      SessionHandler.logout();
      
      expect(SessionHandler.usuarioActual, null);
      expect(SessionHandler.nombreUsuario, '');
      expect(SessionHandler.correo, '');
      expect(SessionHandler.numero, '');
    });

    test('Registrar nuevo usuario válido', () {
      final resultado = SessionHandler.registrarUsuario(
        nombreUsuario: 'nuevoUsuario',
        password: 'password123',
        correo: 'nuevo@example.com',
        tipoUsuario: TipoUsuario.externo,
        numero: '+56 9 1234 5678',
        miscelaneo: 'Info adicional',
      );
      
      expect(resultado, null);
      expect(SessionHandler.isUsernameAvailable('nuevoUsuario'), false);
      expect(SessionHandler.isEmailAvailable('nuevo@example.com'), false);
    });

    test('Registrar usuario con nombre de usuario duplicado', () {
      SessionHandler.registrarUsuario(
        nombreUsuario: 'usuario1',
        password: 'password123',
        correo: 'usuario1@example.com',
        tipoUsuario: TipoUsuario.externo,
      );
      
      final resultado = SessionHandler.registrarUsuario(
        nombreUsuario: 'usuario1',
        password: 'otherpassword',
        correo: 'otro@example.com',
        tipoUsuario: TipoUsuario.externo,
      );
      
      expect(resultado, 'El nombre de usuario ya está en uso');
    });

    test('Registrar usuario con correo duplicado', () {
      SessionHandler.registrarUsuario(
        nombreUsuario: 'usuario_correo_dup_1',
        password: 'password123',
        correo: 'correo_duplicado@example.com',
        tipoUsuario: TipoUsuario.externo,
      );
      
      final resultado = SessionHandler.registrarUsuario(
        nombreUsuario: 'usuario_correo_dup_2',
        password: 'password123',
        correo: 'correo_duplicado@example.com',
        tipoUsuario: TipoUsuario.externo,
      );
      
      expect(resultado, 'El correo ya está registrado');
    });

    test('Registrar usuario con correo inválido', () {
      final resultado = SessionHandler.registrarUsuario(
        nombreUsuario: 'usuario_correo_invalido',
        password: 'password123',
        correo: 'correo-invalido',
        tipoUsuario: TipoUsuario.externo,
      );
      
      expect(resultado, 'Formato de correo inválido');
    });

    test('Registrar usuario con contraseña corta', () {
      final resultado = SessionHandler.registrarUsuario(
        nombreUsuario: 'usuario_pass_corta',
        password: '12345',
        correo: 'usuario_pass_corta@example.com',
        tipoUsuario: TipoUsuario.externo,
      );
      
      expect(resultado, 'La contraseña debe tener al menos 6 caracteres');
    });

    test('Login después de registrar usuario', () {
      SessionHandler.registrarUsuario(
        nombreUsuario: 'testUser',
        password: 'test123456',
        correo: 'test@example.com',
        tipoUsuario: TipoUsuario.externo,
      );
      
      final loginExitoso = SessionHandler.login('testUser', 'test123456');
      
      expect(loginExitoso, true);
      expect(SessionHandler.isLoggedIn, true);
      expect(SessionHandler.nombreUsuario, 'testUser');
      expect(SessionHandler.isAdmin, false);
    });

    test('isUsernameAvailable retorna true para usuario disponible', () {
      expect(SessionHandler.isUsernameAvailable('usuarioDisponible'), true);
    });

    test('isUsernameAvailable retorna false para usuario existente', () {
      expect(SessionHandler.isUsernameAvailable('admin'), false);
    });

    test('isEmailAvailable retorna true para correo disponible', () {
      expect(SessionHandler.isEmailAvailable('disponible@example.com'), true);
    });

    test('isEmailAvailable retorna false para correo existente', () {
      expect(SessionHandler.isEmailAvailable('javcastillo@udec.cl'), false);
    });

    test('getUsername retorna nombre correcto para UUID válido', () {
      final nombre = SessionHandler.getUsername('019a2e2f-d31c-7441-8355-62c252a55cc6');
      expect(nombre, 'pandita_45');
    });

    test('getUsername retorna string vacío para UUID inválido', () {
      final nombre = SessionHandler.getUsername('uuid-inexistente');
      expect(nombre, '');
    });

    test('Usuario admin tiene permisos de administrador', () {
      SessionHandler.login('admin', 'admin123');
      
      expect(SessionHandler.isAdmin, true);
    });

    test('Usuario nuevo no es admin por defecto', () {
      SessionHandler.registrarUsuario(
        nombreUsuario: 'usuarioNormal',
        password: 'password123',
        correo: 'normal@example.com',
        tipoUsuario: TipoUsuario.externo,
      );
      
      SessionHandler.login('usuarioNormal', 'password123');
      
      expect(SessionHandler.isAdmin, false);
    });

    test('getPendientes retorna set vacío sin sesión', () {
      SessionHandler.logout();
      
      expect(SessionHandler.getPendientes.isEmpty, true);
    });

    test('Cambiar usuario modifica datos correctamente', () {
      SessionHandler.login('admin', 'admin123');
      final uuid = SessionHandler.uuid;
      
      final usuarioModificado = Usuario(
        nombreUsuario: 'nombreModificado',
        correo: 'modificado@udec.cl',
        numero: '+56 9 9999 9999',
        miscelaneo: 'Nuevo misc',
        reportes_pendientes: {},
        reportes_aceptados: {},
        isAdmin: true,
        tipoUsuario: TipoUsuario.miembroUniversidad,
      );
      
      SessionHandler.cambiarUsuario(uuid, usuarioModificado);
      
      expect(SessionHandler.nombreUsuario, 'nombreModificado');
      expect(SessionHandler.correo, 'modificado@udec.cl');
    });
  });
}
