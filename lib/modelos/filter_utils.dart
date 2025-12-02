import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';
import 'package:ing_software_grupo4/modelos/tagcolor.dart';
import 'package:ing_software_grupo4/modelos/tagtype.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';

/// Abre el diálogo de filtros y retorna los filtros seleccionados
Future<Map<String, Set>?> openFilterDialog(
  BuildContext context, {
  required Set<TagType> activeTagFilters,
  required Set<TagColor> activeColorFilters,
  required Set<TipoReporte> activeTipoFilters,
}) async {
  final tempTags = Set<TagType>.from(activeTagFilters);
  final tempColors = Set<TagColor>.from(activeColorFilters);
  final tempTipos = Set<TipoReporte>.from(activeTipoFilters);

  return await showDialog<Map<String, Set>>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Filtros'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categorías',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    ...TagType.values.map((type) {
                      return CheckboxListTile(
                        title: Text(type.name),
                        value: tempTags.contains(type),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            tempTags.add(type);
                          } else {
                            tempTags.remove(type);
                          }
                        }),
                      );
                    }),
                    const Divider(),
                    const Text('Colores',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    ...TagColor.values.map((color) {
                      return CheckboxListTile(
                        title: Text(color.name),
                        value: tempColors.contains(color),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            tempColors.add(color);
                          } else {
                            tempColors.remove(color);
                          }
                        }),
                      );
                    }),
                    const Divider(),
                    const Text('Tipos',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    ...TipoReporte.values.map((tipo) {
                      return CheckboxListTile(
                        title: Text(tipo.name[0].toUpperCase() + tipo.name.substring(1)),
                        value: tempTipos.contains(tipo),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            tempTipos.add(tipo);
                          } else {
                            tempTipos.remove(tipo);
                          }
                        }),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, {
                    'tags': tempTags,
                    'colors': tempColors,
                    'tipos': tempTipos,
                  }),
              child: const Text('Aplicar')),
        ],
      );
    },
  );
}
