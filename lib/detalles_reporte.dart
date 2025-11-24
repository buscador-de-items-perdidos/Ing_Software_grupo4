import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';

class DetallesReporte extends StatelessWidget {
  const DetallesReporte({
    super.key,
    required this.reporte,
    this.selectedTags = const [],
    this.editable = false,
    this.onEditTags,
    this.onEditColors,
  });

  final Reporte reporte;
  final List<Tag> selectedTags;
  final bool editable;
  final VoidCallback? onEditTags;
  final VoidCallback? onEditColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 6),
        Text(
          "Detalles del reporte",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          "Autor: ${SessionHandler.getUsuario(reporte.autor).nombreUsuario}",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          "Fecha: ${reporte.fecha.day.toString().padLeft(2, '0')}/${reporte.fecha.month.toString().padLeft(2, '0')}/${reporte.fecha.year}",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            final cats = selectedTags.map((t) => t.nombre).join(', ');
            final colorSet = selectedTags
                .map((t) => t.colorName)
                .where((c) => c != 'blanco')
                .toSet();
            final colorsPretty = colorSet
                .map((c) => prettifyColorName(c))
                .join(', ');
            return Column(
              children: [
                if (cats.isNotEmpty)
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Categoría: $cats',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                if (colorsPretty.isNotEmpty) const SizedBox(height: 6),
                if (colorsPretty.isNotEmpty)
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Color: $colorsPretty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 2),
        if (editable)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 6,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                  onPressed: onEditTags,
                  icon: const Icon(Icons.label_outline, size: 18),
                  label: const Text('Seleccionar Categoria'),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                  onPressed: onEditColors,
                  icon: const Icon(Icons.color_lens_outlined, size: 18),
                  label: const Text('Seleccionar Color'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String prettifyColorName(String key) {
  return key
      .split('_')
      .map((s) => s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1)))
      .join(' ');
}
