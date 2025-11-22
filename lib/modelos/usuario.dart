class Usuario {
  String nombreUsuario;
  String correo;
  String numero;
  String miscelaneo;
  Set<String> reportes_pendientes;
  Set<String> reportes_aceptados;
  bool isAdmin;

  Usuario({
    required this.nombreUsuario,
    required this.correo,
    required this.numero,
    required this.miscelaneo,
    required this.reportes_pendientes,
    required this.reportes_aceptados,
    required this.isAdmin,
  });
}
