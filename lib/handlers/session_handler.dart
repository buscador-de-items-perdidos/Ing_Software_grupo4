import 'package:ing_software_grupo4/modelos/usuario.dart';
import 'package:uuid/uuid.dart';

abstract class SessionHandler {
  static final _uuidGenerator = Uuid();
  
  static final Map<String, Usuario> usuarios = {
    "019a2e2f-d31c-7441-8355-62c252a55cc6": Usuario(
      nombreUsuario: "pandita_45",
      correo: "javcastillo@udec.cl",
      numero: "+56 9 8417 9674",
      miscelaneo: "Discord : pandita_45",
      reportes_pendientes: {},
      reportes_aceptados: {},
      isAdmin: true,
      tipoUsuario: TipoUsuario.miembroUniversidad,
    ),
  };

  // Mapa de credenciales para autenticación (en producción esto debería estar en una base de datos)
  static final Map<String, String> _credenciales = {
    "admin": "admin123",
  };

  // Mapa para asociar nombres de usuario con UUIDs
  static final Map<String, String> _usernameToUuid = {
    "admin": "019a2e2f-d31c-7441-8355-62c252a55cc6",
  };

  static Usuario? get usuarioActual => usuarios[uuid];
  static String get nombreUsuario => usuarioActual?.nombreUsuario ?? "";
  static String uuid = '';
  static bool get isAdmin => usuarioActual?.isAdmin ?? false;
  static String get correo =>
      usuarioActual?.correo ??
      ""; 
  static String get numero => usuarioActual?.numero ?? "";
  static String get miscelaneo => usuarioActual?.miscelaneo ?? "";

  static void cambiarUsuario(String uuid, Usuario usuario) {
    if (!usuarios.containsKey(uuid)) throw Exception();

    usuarios[uuid] = usuario;
  }

  // Método para autenticar usuario
  static bool login(String username, String password) {
    // Verificar si el usuario existe y la contraseña es correcta
    if (_credenciales.containsKey(username) && _credenciales[username] == password) {
      // Obtener el UUID del usuario y establecer la sesión
      final userUuid = _usernameToUuid[username];
      if (userUuid != null) {
        uuid = userUuid;
        return true;
      }
    }
    return false;
  }

  // Método para cerrar sesión
  static void logout() {
    uuid = '';
  }

  // Método para verificar si hay una sesión activa
  static bool get isLoggedIn => uuid.isNotEmpty && usuarios.containsKey(uuid);

  // Método para registrar un nuevo usuario
  static String? registrarUsuario({
    required String nombreUsuario,
    required String password,
    required String correo,
    required TipoUsuario tipoUsuario,
    String? numero,
    String? miscelaneo,
  }) {
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
      reportes_pendientes: {},
      reportes_aceptados: {},
      isAdmin: false, // Los nuevos usuarios no son administradores por defecto
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
  static bool isUsernameAvailable(String username) {
    return !_usernameToUuid.containsKey(username);
  }

  // Método para verificar si un correo está disponible
  static bool isEmailAvailable(String email) {
    return !usuarios.values.any((usuario) => usuario.correo == email);
  }

  void initialize() async {
    //Este metodo deberia pedir las sesiones que tiene el sistema a una base de datos, en teoria obvio
    throw UnimplementedError();
  }

  static String getUsername(String autor) {
    return usuarios[autor]?.nombreUsuario ?? "";
  }

  static Usuario getUsuario(String uuid) {
    return usuarios[uuid]!;
  }

  static Set<String> get getPendientes {
    return usuarioActual?.reportes_pendientes ?? {};
  }

  static Set<String> get getAceptados {
    return usuarioActual?.reportes_aceptados ?? {};
  }
}
