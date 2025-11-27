import 'package:ing_software_grupo4/handlers/d_b_manager.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';

abstract class SessionHandler {
  static late DBManager _dbManager;
  static Usuario? usuarioActual;
  static String get nombreUsuario => usuarioActual?.nombreUsuario ?? "";
  static String uuid = '';
  static bool get isAdmin => usuarioActual?.isAdmin ?? false;
  static String get correo => usuarioActual?.correo ?? "";
  static String get numero => usuarioActual?.numero ?? "";
  static String get miscelaneo => usuarioActual?.miscelaneo ?? "";
  static TipoUsuario get tipoUsuario =>
      usuarioActual?.tipoUsuario ?? TipoUsuario.externo;

  static void cambiarUsuario(
    String uuid, {
    required String nombreUsuario,
    required String correo,
    required String numero,
    required String miscelaneo,
  }) {
    _dbManager.updateUsuario(
      uuid,
      nombreUsuario: nombreUsuario,
      correo: correo,
      numero: numero,
      miscelaneo: miscelaneo,
    );
    //si editamos el usuario actual debemos pedirlo denuevo
    if (uuid == SessionHandler.uuid) {
      usuarioActual = _dbManager.fetchUser(uuid);
    }
  }

  // Método para autenticar usuario
  static bool login(String username, String password) {
    String? newUuid = _dbManager.verifySession(username, password);
    if (newUuid != null) {
      uuid = newUuid;
      usuarioActual = _dbManager.fetchUser(uuid);
      return true;
    }
    return false;
  }

  // Método para cerrar sesión
  static void logout() {
    uuid = '';
    usuarioActual = null;
  }

  // Método para verificar si hay una sesión activa
  static bool get isLoggedIn => uuid.isNotEmpty;

  // Método para registrar un nuevo usuario
  static String? registrarUsuario({
    required String nombreUsuario,
    required String password,
    required String correo,
    required TipoUsuario tipoUsuario,
    String? numero,
    String? miscelaneo,
  }) => _dbManager.registrarUsuario(
    nombreUsuario: nombreUsuario,
    password: password,
    correo: correo,
    numero: numero,
    tipoUsuario: tipoUsuario,
  );

  // Método para verificar si un nombre de usuario está disponible
  static bool isUsernameAvailable(String username) =>
      _dbManager.isUsernameAvailable(username);

  // Método para verificar si un correo está disponible
  static bool isEmailAvailable(String email) =>
      _dbManager.isEmailAvailable(correo);

  static void initialize(DBManager db) async {
    _dbManager = db;
  }

  static String getUsername(String autor) {
    return getUsuario(autor).nombreUsuario;
  }

  static Usuario getUsuario(String uuid) {
    return _dbManager.fetchUser(uuid)!;
  }

  static Set<String> get getPendientes =>
      _dbManager.getReportesUsuario(uuid, EstadoReporte.pendiente);

  static Set<String> get getAceptados =>
      _dbManager.getReportesUsuario(uuid, EstadoReporte.existente);
}
