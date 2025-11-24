import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/modelos/filter.dart';
import 'package:ing_software_grupo4/modelos/filter_utils.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
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
                  child: SearchBar(
                    constraints: BoxConstraints(maxHeight: 30),
                    onChanged: (text) => input.value = text,
                    hintText: 'Que estas buscando?',
                    leading: Icon(Icons.search),
                  ),
                ),
                const SizedBox(width: 12),
                Tooltip(
                  message: 'Filtrar por etiquetas, colores o tipos',
                  child: TextButton.icon(
                    onPressed: _openFilterDialog,
                    icon: const Icon(Icons.filter_list),
                    label: Text(
                      (_activeTagFilters.length +
                                  _activeColorFilters.length +
                                  _activeTipoFilters.length) ==
                              0
                          ? 'Filtros'
                          : 'Filtros (${_activeTagFilters.length + _activeColorFilters.length + _activeTipoFilters.length})',
                    ),
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
    final result = await openFilterDialog(
      context,
      activeTagFilters: _activeTagFilters,
      activeColorFilters: _activeColorFilters,
      activeTipoFilters: _activeTipoFilters,
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
          !reporte.etiquetas.any(
            (tag) => filtro.activeTagFilters.contains(tag.nombre),
          ))
        return false;

      if (filtro.activeColorFilters.isNotEmpty &&
          !reporte.etiquetas.any(
            (tag) => filtro.activeColorFilters.contains(tag.colorName),
          ))
        return false;

      if (filtro.activeTipoFilters.isNotEmpty &&
          !filtro.activeTipoFilters.contains(reporte.tipo.name))
        return false;

      return true;
    }).toList();

    final bool hasActiveFilters =
        filtro.activeTagFilters.isNotEmpty ||
        filtro.activeColorFilters.isNotEmpty ||
        filtro.activeTipoFilters.isNotEmpty;

    if (filtrados.isEmpty && hasActiveFilters) {
      return const Center(
        child: Text(
          'No existen publicaciones pendientes con estas etiquetas',
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
            TarjetaReporte(uuid: id, modo: Modo.Revisar, pendiente: true),
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
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        childAspectRatio: 0.6,
      ),
    );
  }
}
