import 'package:ing_software_grupo4/handlers/d_b_manager.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';
import 'package:uuid/uuid.dart';

abstract class SessionHandler {
  static late DBManager? _dbManager;
  static Usuario? usuarioActual;
  static String get nombreUsuario => usuarioActual?.nombreUsuario ?? "";
  static String uuid = '';
  static bool get isAdmin => usuarioActual?.isAdmin ?? false;
  static String get correo => usuarioActual?.correo ?? "";
  static String get numero => usuarioActual?.numero ?? "";
  static String get miscelaneo => usuarioActual?.miscelaneo ?? "";
  static TipoUsuario get tipoUsuario =>
      usuarioActual?.tipoUsuario ?? TipoUsuario.externo;

  static final _uuidGenerator = Uuid();

  static final Map<String, Usuario> usuarios = {
    "019a2e2f-d31c-7441-8355-62c252a55cc6": Usuario(
      nombreUsuario: "pandita_45",
      correo: "javcastillo@udec.cl",
      numero: "+56 9 8417 9674",
      miscelaneo: "Discord : pandita_45",
      isAdmin: true,
      tipoUsuario: TipoUsuario.miembroUniversidad,
    ),
  };

  // Mapa de credenciales para autenticación (en producción esto debería estar en una base de datos)
  static final Map<String, String> _credenciales = {"admin": "admin123"};

  // Mapa para asociar nombres de usuario con UUIDs
  static final Map<String, String> _usernameToUuid = {
    "admin": "019a2e2f-d31c-7441-8355-62c252a55cc6",
  };

  static void cambiarUsuario(
    String uuid, {
    required String nombreUsuario,
    required String correo,
    required String numero,
    required String miscelaneo,
  }) {
    if (_dbManager == null) {
      if (!usuarios.containsKey(uuid)) throw Exception();

      usuarios[uuid] = Usuario(
        nombreUsuario: nombreUsuario,
        correo: correo,
        numero: numero,
        miscelaneo: miscelaneo,
        tipoUsuario: usuarios[uuid]?.tipoUsuario ?? TipoUsuario.externo,
        isAdmin: usuarios[uuid]?.isAdmin ?? false,
      );
      if (uuid == SessionHandler.uuid) usuarioActual = usuarios[uuid];
      return;
    }
    _dbManager!.updateUsuario(
      uuid,
      nombreUsuario: nombreUsuario,
      correo: correo,
      numero: numero,
      miscelaneo: miscelaneo,
    );

    //si editamos el usuario actual debemos pedirlo denuevo
    if (uuid == SessionHandler.uuid) {
      usuarioActual = _dbManager!.fetchUser(uuid);
    }
  }

  // Método para autenticar usuario
  static bool login(String username, String password) {
    // Verificar si el usuario existe y la contraseña es correcta
    if (_dbManager == null) {
      if (_credenciales.containsKey(username) &&
          _credenciales[username] == password) {
        // Obtener el UUID del usuario y establecer la sesión
        final userUuid = _usernameToUuid[username];
        if (userUuid != null) {
          uuid = userUuid;
          usuarioActual = usuarios[userUuid];
          return true;
        }
      }
      return false;
    }

    String? newUuid = _dbManager!.verifySession(username, password);
    if (newUuid != null) {
      uuid = newUuid;
      usuarioActual = _dbManager!.fetchUser(uuid);
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
  }) {
    if (_dbManager != null) {
      return _dbManager!.registrarUsuario(
        nombreUsuario: nombreUsuario,
        password: password,
        correo: correo,
        numero: numero,
        tipoUsuario: tipoUsuario,
      );
    }
    // Validar que el nombre de usuario no exista
    if (_usernameToUuid.containsKey(nombreUsuario)) {
      return "El nombre de usuario ya está en uso";
    }

    // Validar que el correo no esté registrado
    for (var usuario in usuarios.values) {
      if (usuario.correo == correo) {
        return "El correo ya está registrado";
      }
    }

    // Validar formato de correo básico
    if (!correo.contains('@') || !correo.contains('.')) {
      return "Formato de correo inválido";
    }

    // Validar longitud de contraseña
    if (password.length < 6) {
      return "La contraseña debe tener al menos 6 caracteres";
    }

    // Generar UUID para el nuevo usuario
    final nuevoUuid = _uuidGenerator.v7();

    // Crear nuevo usuario
    final nuevoUsuario = Usuario(
      nombreUsuario: nombreUsuario,
      correo: correo,
      numero: numero ?? "",
      miscelaneo: miscelaneo ?? "",
      isAdmin: nombreUsuario == 'admin', // Los nuevos usuarios no son administradores por defecto
      tipoUsuario: tipoUsuario,
      matricula: null,
    );

    // Guardar usuario y credenciales
    usuarios[nuevoUuid] = nuevoUsuario;
    _credenciales[nombreUsuario] = password;
    _usernameToUuid[nombreUsuario] = nuevoUuid;

    return null; // null indica éxito
  }

  // Método para verificar si un nombre de usuario está disponible
  static bool isUsernameAvailable(String username) => _dbManager == null
      ? !_usernameToUuid.containsKey(username)
      : _dbManager!.isUsernameAvailable(username);

  // Método para verificar si un correo está disponible
  static bool isEmailAvailable(String email) => _dbManager == null
      ? !usuarios.values.any((usuario) => usuario.correo == email)
      : _dbManager!.isEmailAvailable(correo);

  static void initialize(DBManager? db) async {
    _dbManager = db;
  }

  static String getUsername(String autor) {
    return getUsuario(autor).nombreUsuario;
  }

  static Usuario getUsuario(String uuid) =>
      _dbManager == null ? usuarios[uuid]! : _dbManager!.fetchUser(uuid)!;

  static Set<String> get getPendientes => _dbManager == null
      ? ReportHandler.getReportesUsuario(uuid, false)
      : _dbManager!.getReportesUsuario(uuid, EstadoReporte.pendiente);

  static Set<String> get getAceptados => _dbManager == null
      ? ReportHandler.getReportesUsuario(uuid, true)
      : _dbManager!.getReportesUsuario(uuid, EstadoReporte.existente);
}
