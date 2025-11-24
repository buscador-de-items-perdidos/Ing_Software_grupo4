import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';

/// Constantes para las categorías disponibles
const List<String> availableCategories = [
  'Celular',
    'Notebook / Laptop',
    'Tablet',
    'Audífonos',
    'Cargador / Cable',
    'Reloj inteligente',
    'Lentes',
    'Llaves',
    'Billetera',
    'Cartera',
    'Paraguas',
    'Mochila',
    'Estuche',
    'Documentos',
    'Cédula',
    'Pasaporte',
    'Tarjeta bancaria',
    'Licencia de conducir',
    'Credencial universitaria / laboral',
    'Polerón / Chaqueta',
    'Gorro',
    'Polera',
    'Pantalones',
    'Zapatos / Zapatillas',
    'Guantes',
    'Botella',
    'Termo',
    'Llaveros',
    'Cuadernos / Libretas',
    'Otro',
];

/// Mapa de nombres de colores a sus valores hexadecimales
const Map<String, String> colorNameToHex = {
  'rojo': '#FF0000',
  'verde': '#00FF00',
  'azul': '#0000FF',
  'amarillo': '#FFFF00',
  'naranja': '#FFA500',
  'morado': '#800080',
  'rosa': '#FFC0CB',
  'negro': '#000000',
  'blanco': '#FFFFFF',
  'gris': '#808080',
  'cafe': '#8B4513',
  'celeste': '#87CEEB',
  'turquesa': '#40E0D0',
  'plateado': '#C0C0C0',
  'dorado': '#FFD700',
  'beige': '#F5F5DC',
  'marron': '#A52A2A',
  'verde_oscuro': '#006400',
  'azul_marino': '#000080',
  'violeta': '#8A2BE2',
  'fucsia': '#FF00FF',
  'crema': '#FFFDD0',
  'coral': '#FF7F50',
  'salmon': '#FA8072',
  'lavanda': '#E6E6FA',
  'menta': '#98FF98',
  'durazno': '#FFE5B4',
  'bordo': '#B80F0A',
  'burdeos': '#800020',
};

/// Función para obtener todos los colores disponibles
Set<String> getAvailableColors() {
  return colorNameToHex.keys.toSet();
}

/// Función para obtener todos los tipos de reporte disponibles
Set<String> getAvailableTipos() {
  return TipoReporte.values
      .where((t) => t.name != 'administracion')
      .map((t) => t.name)
      .toSet();
}

/// Función para formatear nombres de colores
String prettifyColorName(String colorName) {
  return colorName[0].toUpperCase() +
      colorName.substring(1).replaceAll('_', ' ');
}

/// Abre el diálogo de filtros y retorna los filtros seleccionados
Future<Map<String, Set<String>>?> openFilterDialog(
  BuildContext context, {
  required Set<String> activeTagFilters,
  required Set<String> activeColorFilters,
  required Set<String> activeTipoFilters,
}) async {
  final tempTags = Set<String>.from(activeTagFilters);
  final tempColors = Set<String>.from(activeColorFilters);
  final tempTipos = Set<String>.from(activeTipoFilters);

  final availableTags = availableCategories.toSet();
  final availableColors = getAvailableColors();
  final availableTipos = getAvailableTipos();

  return await showDialog<Map<String, Set<String>>>(
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
                    ...availableTags.map((name) {
                      return CheckboxListTile(
                        title: Text(name),
                        value: tempTags.contains(name),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            tempTags.add(name);
                          } else {
                            tempTags.remove(name);
                          }
                        }),
                      );
                    }),
                    const Divider(),
                    const Text('Colores',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    ...availableColors.map((name) {
                      return CheckboxListTile(
                        title: Text(prettifyColorName(name)),
                        value: tempColors.contains(name),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            tempColors.add(name);
                          } else {
                            tempColors.remove(name);
                          }
                        }),
                      );
                    }),
                    const Divider(),
                    const Text('Tipos',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    ...availableTipos.map((name) {
                      return CheckboxListTile(
                        title: Text(name[0].toUpperCase() + name.substring(1)),
                        value: tempTipos.contains(name),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            tempTipos.add(name);
                          } else {
                            tempTipos.remove(name);
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
