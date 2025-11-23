import 'package:ing_software_grupo4/modelos/usuario.dart';

abstract class SessionHandler {
  //En teoria estos campos deberian empezar vacios y ser inicializados desde
  //nuestra base de datos, pero para probar lo dejaremos así
  static final Map<String, Usuario> usuarios = {
    "019a2e2f-d31c-7441-8355-62c252a55cc6": Usuario(
      nombreUsuario: "pandita_45",
      correo: "javcastillo@udec.cl",
      numero: "+56 9 8417 9674",
      miscelaneo: "Discord : pandita_45",
      reportes_pendientes: {},
      reportes_aceptados: {},
      isAdmin: true,
    ),
  };

  // Mapa de credenciales para autenticación (en producción esto debería estar en una base de datos)
  static final Map<String, String> _credenciales = {
    "pandita_45": "admin123",
  };

  // Mapa para asociar nombres de usuario con UUIDs
  static final Map<String, String> _usernameToUuid = {
    "pandita_45": "019a2e2f-d31c-7441-8355-62c252a55cc6",
  };

  static Usuario? get usuarioActual => usuarios[uuid];
  static String get nombreUsuario => usuarioActual?.nombreUsuario ?? "";
  //NUNCA guardes los nombres de usuario en cosas que requieran identificación, guarden UUID
  static String uuid = '';
  static bool get isAdmin => usuarioActual?.isAdmin ?? false;
  static String get correo =>
      usuarioActual?.correo ??
      ""; //Aca vendría bien un enum, si es que pusieramos distintos niveles de privilegio
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
