import 'dart:typed_data';
import 'dart:ui';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';
import 'package:latlong2/latlong.dart';

class Reporte {
  Reporte(
    this.titulo,
    this.descripcion,
    this.autor,
    this.objeto,
    this.encontrado,
    this.tipo,
    LatLng this.ubicacion, {
    DateTime? fecha,
    this.imagenes = const [],
    this.imagenesBytes = const [],
    this.etiquetas = const [],
  }) : fecha = fecha ?? DateTime.now();

  Reporte.vacio(this.tipo, this.autor)
    : titulo = "",
      descripcion = "",
      encontrado = false,
      ubicacion = null,
      fecha = DateTime.now(),
      imagenes = const [],
      imagenesBytes = const [],
      etiquetas = const [];

  final String titulo;
  final String descripcion;
  final String autor; //Se deberia cambiar una clase propia a futuro
  bool encontrado;
  final LatLng? ubicacion;
  final DateTime fecha;
  final TipoReporte tipo;
  final List<String> imagenes; // rutas absolutas de archivos de imagen
  final List<Uint8List> imagenesBytes; // imágenes en memoria (web/desktop)
  final List<Tag> etiquetas; // etiquetas asociadas al reporte (nombre + color)
}

Color? hexToColor(String? hex) {
  if (hex == null) return null;
  final cleaned = hex.replaceAll('#', '');
  final value = int.parse(
    cleaned.length == 6 ? 'FF$cleaned' : cleaned,
    radix: 16,
  );
  return Color(value);
}

const Map<String, String> colorNameToHex = {
  'blanco': '#FFFFFF',
  'negro': '#000000',
  'rojo': '#FF0000',
  'verde': '#00FF00',
  'azul': '#0000FF',
  'amarillo': '#FFFF00',
  'naranja': '#FFA500',
  'morado': '#800080',
  'rosa': '#FFC0CB',
  'celeste': '#87CEEB',
  'café': '#8B4513',
  'gris': '#808080',
  'turquesa': '#40E0D0',
  'lima': '#00FF7F',
  'cian': '#00FFFF',
  'fucsia': '#FF00FF',
  'beige': '#F5F5DC',
  'chocolate': '#D2691E',
  'dorado': '#FFD700',
  'plateado': '#C0C0C0',
  'azul_marino': '#000080',
  'burdeos': '#800020',
  'Otro': '#FFFFFF',
};
