import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';

class Reporte {
  const Reporte(
    this.titulo,
    this.descripcion,
    this.autor,
    this.objeto,
    this.tipo,
  );

  const Reporte.vacio(this.tipo,this.autor)
    : titulo = "",
      descripcion = "",
      objeto = "";

  final String titulo;
  final String descripcion;
  final String autor; //Se deberia cambiar una clase propia a futuro
  final String objeto;

  ///Se deberia cambiar una clase propia a futuro
  final TipoReporte tipo;
}
