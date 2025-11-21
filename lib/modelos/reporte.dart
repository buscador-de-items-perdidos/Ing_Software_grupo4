import 'dart:typed_data';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';
import 'package:latlong2/latlong.dart';

class Reporte {
  Reporte(
    this.titulo,
    this.descripcion,
    this.autor,
    this.objeto,
    this.tipo,
    LatLng? this.ubicacion, {
    DateTime? fecha,
    this.imagenes = const [],
    this.imagenesBytes = const [],
    this.etiquetas = const [],
  }) : fecha = fecha ?? DateTime.now();

  Reporte.vacio(this.tipo, this.autor)
    : titulo = "",
      descripcion = "",
      objeto = "",
      ubicacion = null,
      fecha = DateTime.now(),
      imagenes = const [],
      imagenesBytes = const [],
      etiquetas = const [];

  final String titulo;
  final String descripcion;
  final String autor; //Se deberia cambiar una clase propia a futuro
  final String objeto;
  final LatLng? ubicacion;
  final DateTime fecha;
  final TipoReporte tipo;
  final List<String> imagenes; // rutas absolutas de archivos de imagen
  final List<Uint8List> imagenesBytes; // imágenes en memoria (web/desktop)
  final List<Tag> etiquetas; // etiquetas asociadas al reporte (nombre + color)
}
