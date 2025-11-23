import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/modelos/filter.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/tarjeta_reporte.dart';

class MenuPendientes extends StatefulWidget {
  const MenuPendientes({super.key});

  @override
  State<MenuPendientes> createState() => _MenuPendientesState();
}

class _MenuPendientesState extends State<MenuPendientes> {
  ValueNotifier<String> input = ValueNotifier("");
  final Set<String> _activeTagFilters = {};
  final Set<String> _activeColorFilters = {};
  final Set<String> _activeTipoFilters = {};

  Filter get filtro => Filter(
        input.value,
        false,
        _activeTagFilters,
        _activeColorFilters,
        _activeTipoFilters,
        soloPendientes: true,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 28.0, left: 50, right: 50),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (text) => input.value = text,
                    decoration: const InputDecoration(
                      hintText: 'Que estas buscando?',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Tooltip(
                  message: 'Filtrar por etiquetas, colores o tipos',
                  child: TextButton.icon(
                    onPressed: _openFilterDialog,
                    icon: const Icon(Icons.filter_list),
                    label: Text((_activeTagFilters.length +
                                    _activeColorFilters.length +
                                    _activeTipoFilters.length) ==
                                0
                            ? 'Filtros'
                            : 'Filtros (${_activeTagFilters.length + _activeColorFilters.length + _activeTipoFilters.length})'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: ListenableBuilder(
              listenable: Listenable.merge([
                ReportHandler.pendingNotifier,
                input,
              ]),
              builder: (_, __) => ListaPendientes(filtro: filtro),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilterDialog() async {
    // Definir todas las categorías disponibles siempre
    final Set<String> availableTags = {
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
      'Botella de agua',
      'Libro',
      'Mochila',
      'Chaqueta',
      'Gorro',
      'Bufanda',
      'Guantes',
      'Calculadora',
      'USB / Pendrive',
      'Tarjeta de memoria',
      'Mouse',
      'Teclado',
      'Otro',
    };

    final Set<String> availableColors = {};
    try {
      availableColors.addAll(colorNameToHex.keys);
    } catch (_) {}

    final Set<String> availableTipos = {};
    try {
      availableTipos.addAll(
          TipoReporte.values.where((t) => t.name != 'administracion').map((t) => t.name));
    } catch (_) {}

    final tempTags = Set<String>.from(_activeTagFilters);
    final tempColors = Set<String>.from(_activeColorFilters);
    final tempTipos = Set<String>.from(_activeTipoFilters);

    final result = await showDialog<Map<String, Set<String>>>(
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

    if (result != null) {
      setState(() {
        _activeTagFilters
          ..clear()
          ..addAll(result['tags'] ?? {});
        _activeColorFilters
          ..clear()
          ..addAll(result['colors'] ?? {});
        _activeTipoFilters
          ..clear()
          ..addAll(result['tipos'] ?? {});
      });
    }
  }

  String prettifyColorName(String colorName) {
    return colorName[0].toUpperCase() +
        colorName.substring(1).replaceAll('_', ' ');
  }

  Map<String, int> get colorNameToHex {
    return {
      'rojo': 0xFFFF0000,
      'azul': 0xFF0000FF,
      'verde': 0xFF00FF00,
      'amarillo': 0xFFFFFF00,
      'negro': 0xFF000000,
      'blanco': 0xFFFFFFFF,
      'gris': 0xFF808080,
      'naranja': 0xFFFFA500,
      'morado': 0xFF800080,
      'rosa': 0xFFFFC0CB,
      'cafe': 0xFF8B4513,
    };
  }
}

class ListaPendientes extends StatelessWidget {
  const ListaPendientes({super.key, required this.filtro});

  final Filter filtro;

  @override
  Widget build(BuildContext context) {
    List<String> reportes = ReportHandler.getPeticiones().toList();

    List<String> filtrados = reportes.where((uuid) {
      final reporte = ReportHandler.buscarReporte(uuid);

      if (reporte == null) return false;

      if (!reporte.titulo.toLowerCase().contains(filtro.input.toLowerCase()))
        return false;

      if (filtro.activeTagFilters.isNotEmpty &&
          !reporte.etiquetas.any((tag) => filtro.activeTagFilters.contains(tag.nombre)))
        return false;

      if (filtro.activeColorFilters.isNotEmpty &&
          !reporte.etiquetas.any((tag) => filtro.activeColorFilters.contains(tag.colorName)))
        return false;

      if (filtro.activeTipoFilters.isNotEmpty &&
          !filtro.activeTipoFilters.contains(reporte.tipo.name))
        return false;

      return true;
    }).toList();

    final bool hasActiveFilters = filtro.activeTagFilters.isNotEmpty ||
        filtro.activeColorFilters.isNotEmpty ||
        filtro.activeTipoFilters.isNotEmpty;

    if (filtrados.isEmpty && hasActiveFilters) {
      return const Center(
        child: Text(
          'No existen publicaciones pendientes con estas etiquetas',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return GridView.builder(
      itemCount: filtrados.length,
      itemBuilder: (context, i) {
        final String id = filtrados.elementAt(i);
              return Stack(
                children: [
                  // Tarjeta que muestra los detalles del reporte en modo revisión
                  TarjetaReporte(nombre: id, modo: Modo.Revisar, pendiente: true),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Tooltip(
                      message: 'Aprobar reporte',
                      child: IconButton(
                        // Icono para indicar acción de aprobación
                        icon: Icon(Icons.check_circle, color: Colors.green[700]),
                        onPressed: () {
                          ReportHandler.acceptPeticion(id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reporte aprobado')),
                          );
                        },
                      ),
                    ),
                  ),
                  // Icono para indicar la acción de rechazar 
                  Positioned(
                    bottom: 6,
                    right: 44,
                    child: Tooltip(
                      message: 'Rechazar reporte',
                      child: IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red[700]),
                        onPressed: () {
                          ReportHandler.rejectPeticion(id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reporte rechazado')),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
            ),
          );
  }
}
