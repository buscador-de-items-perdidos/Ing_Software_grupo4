import 'dart:typed_data';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:latlong2/latlong.dart';

class Reporte {
  const Reporte(
    this.titulo,
    this.descripcion,
    this.autor,
    this.objeto,
    this.tipo,
    LatLng this.ubicacion, {
    this.imagenes = const [],
    this.imagenesBytes = const [],
  });

  const Reporte.vacio(this.tipo, this.autor)
    : titulo = "",
      descripcion = "",
      objeto = "",
      ubicacion = null,
      imagenes = const [],
      imagenesBytes = const [];

  final String titulo;
  final String descripcion;
  final String autor; //Se deberia cambiar una clase propia a futuro
  final String objeto;
  final LatLng? ubicacion;
  final TipoReporte tipo;
  final List<String> imagenes; // rutas absolutas de archivos de imagen
  final List<Uint8List> imagenesBytes; // imágenes en memoria (web/desktop)
}
