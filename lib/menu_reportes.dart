import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/modelos/filter.dart';
import 'package:ing_software_grupo4/modelos/filter_utils.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';
import 'package:ing_software_grupo4/tarjeta_reporte.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';

class MenuReportes extends StatefulWidget {
  final bool soloMisReportes;

  const MenuReportes({super.key, this.soloMisReportes = false});

  @override
  State<MenuReportes> createState() => _MenuReportesState();
}

class _MenuReportesState extends State<MenuReportes> {
  ValueNotifier<String> input = ValueNotifier("");
  final Set<String> _activeTagFilters = {};
  final Set<String> _activeColorFilters = {};
  final Set<String> _activeTipoFilters = {};
  late bool soloMisReportes;

  Filter get filtro => Filter(
    input.value,
    soloMisReportes,
    _activeTagFilters,
    _activeColorFilters,
    _activeTipoFilters,
  );

  @override
  void initState() {
    super.initState();
    soloMisReportes = widget.soloMisReportes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 28.0, left: 50, right: 50),
            child: Row(
              children: [
                BarraBusqueda(input: input),
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
                ReportHandler.reportNotifier,
                input,
                if (soloMisReportes) ReportHandler.pendingNotifier,
              ]),
              builder: (_, __) => ListaReportes(filtro: filtro),
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

class BarraBusqueda extends StatelessWidget {
  const BarraBusqueda({super.key, required this.input});

  final ValueNotifier<String> input;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SearchBar(
        constraints: BoxConstraints(maxWidth: 20),
        onChanged: (text) => input.value = text,
        hintText: 'Que estas buscando?',
        leading: Icon(Icons.search),
      ),
    );
  }
}

class ListaReportes extends StatelessWidget {
  const ListaReportes({super.key, required this.filtro});

  final Filter filtro;

  @override
  Widget build(BuildContext context) {
    //Lista de UUID de reportes a mostrar
    List<String> reportes;

    if (filtro.soloPendientes) {
      // Obtener solo las peticiones pendientes
      reportes = ReportHandler.getPeticiones().toList();
    } else if (filtro.soloMisReportes) {
      // Obtener UUIDs del usuario desde SessionHandler
      Set<String> misReportesUUIDs = {
        ...SessionHandler.getPendientes,
        ...SessionHandler.getAceptados,
      };
      reportes = misReportesUUIDs.toList();
    } else {
      reportes = ReportHandler.getReportes;
    }

    List<String> filtrados = reportes.where((uuid) {
      // Buscar el reporte usando buscarReporte que busca en los 3 maps
      Reporte? reporte = ReportHandler.buscarReporte(uuid);

      if (reporte == null) return false;

      // Filtrar por búsqueda de texto

      if (!reporte.titulo.toLowerCase().contains(filtro.input.toLowerCase()))
        return false;

      // Filtrar por tags (categorías)
      if (filtro.activeTagFilters.isNotEmpty &&
          !reporte.etiquetas.any(
            (Tag t) => filtro.activeTagFilters.contains(t.nombre),
          ))
        return false;
      // Filtrar por colores
      if (filtro.activeColorFilters.isNotEmpty &&
          !reporte.etiquetas.any(
            (Tag t) => filtro.activeColorFilters.contains(t.colorName),
          ))
        return false;

      // Filtrar por tipo de reporte
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
          'No existen publicaciones con estas etiquetas',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Mostrar los reportes en una lista vertical con scroll.
    // Cada tarjeta está centrada horizontalmente
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        childAspectRatio: 0.6,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      itemCount: filtrados.length,
      itemBuilder: (context, i) {
        // Buscar el reporte usando buscarReporte
        Reporte? reporte = ReportHandler.buscarReporte(filtrados[i]);

        if (reporte == null) return const SizedBox.shrink();
        if (!reporte.titulo.toLowerCase().contains(filtro.input.toLowerCase()))
          return const SizedBox.shrink();

        // Determinar si es pendiente o no
        bool esPendiente = SessionHandler.getPendientes.contains(filtrados[i]);

        return Stack(
          children: [
            TarjetaReporte(
              key: ValueKey(filtrados[i]),
              nombre: filtrados[i],
              modo: Modo.Ver,
              pendiente: esPendiente,
            ),
            if (filtro.soloMisReportes)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: esPendiente ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        esPendiente ? Icons.schedule : Icons.check_circle,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        esPendiente ? 'Pendiente' : 'Publicado',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
