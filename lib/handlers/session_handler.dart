import 'package:ing_software_grupo4/modelos/usuario.dart';

abstract class SessionHandler {
  //En teoria estos campos deberian empezar vacios y ser inicializados desde
  //nuestra base de datos, pero para probar lo dejaremos así
  static final Map<String, Usuario> usuarios = {
    "019a2e2f-d31c-7441-8355-62c252a55cc6": const Usuario(
      nombreUsuario: "pandita_45",
      correo: "jvidal@udec.cl",
      numero: "+56 9 8417 9674",
      miscelaneo: "Discord : pandita_45",
    ),
  };
  static Usuario? get usuarioActual => usuarios[uuid];
  static String get nombreUsuario => usuarioActual?.nombreUsuario ?? "";
  //NUNCA guardes los nombres de usuario en cosas que requieran identificación, guarden UUID
  static String uuid = '019a2e2f-d31c-7441-8355-62c252a55cc6';
  static bool isAdmin =
      true; //Aca vendría bien un enum, si es que pusieramos distintos niveles de privilegio

  void initialize() async {
    //Este metodo deberia pedir las sesiones que tiene el sistema a una base de datos, en teoria obvio
    throw UnimplementedError();
  }
}
