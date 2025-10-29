import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';

class Reporte{
  const Reporte(this.titulo,this.descripcion,this.autor,this.objeto, this.tipo);

  final String titulo;
  final String descripcion;
  final String autor;  //Se deberia cambiar una clase propia a futuro
  final String objeto; ///Se deberia cambiar una clase propia a futuro
  final TipoReporte tipo;
  
}
