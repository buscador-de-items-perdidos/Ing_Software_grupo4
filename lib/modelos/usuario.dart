enum TipoUsuario {
  miembroUniversidad,
  externo,
}

class Usuario {
  String nombreUsuario;
  String correo;
  String numero;
  String miscelaneo;
  Set<String> reportesPendientes;
  Set<String> reportesAceptados;
  bool isAdmin;
  TipoUsuario tipoUsuario;
  String? matricula; // Solo para miembros de la universidad

  Usuario({
    required this.nombreUsuario,
    required this.correo,
    required this.numero,
    required this.miscelaneo,
    required this.reportesPendientes,
    required this.reportesAceptados,
    required this.isAdmin,
    this.tipoUsuario = TipoUsuario.externo,
    this.matricula,
  });
}
