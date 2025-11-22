import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/tarjeta_reporte.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:ing_software_grupo4/report_display.dart';
import 'package:uuid/uuid.dart';

class MenuReportes extends StatefulWidget {
  final bool soloMisReportes;

  const MenuReportes({super.key, this.soloMisReportes = false});

  @override
  State<MenuReportes> createState() => _MenuReportesState();
}

class _MenuReportesState extends State<MenuReportes> {
  String input = "";
  late bool soloMisReportes;
  final Set<String> _activeTagFilters = {};
  final Set<String> _activeColorFilters = {};
  final Set<String> _activeTipoFilters = {};
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
                Expanded(
                  child: TextField(
                    onChanged: (text) => setState(() {
                      input = text;
                    }),
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
                    label: Text((_activeTagFilters.length + _activeColorFilters.length + _activeTipoFilters.length) == 0
                        ? 'Filtros'
                        : 'Filtros (${_activeTagFilters.length + _activeColorFilters.length + _activeTipoFilters.length})'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: ValueListenableBuilder(
              valueListenable: ReportHandler.reportNotifier,
              builder: (context, value, child) {
                List<String> reportes = ReportHandler.getReportes;
                List<String> filtrados = reportes.where((x) {
                  final rep = ReportHandler.getReporte(x);
                  if (rep == null) return false;
                  final matchesText = rep.titulo.toLowerCase().contains(input.toLowerCase());

                  bool matchesFilters = true;

                  if (_activeTagFilters.isNotEmpty) {
                    matchesFilters = matchesFilters && rep.etiquetas.any((Tag t) => _activeTagFilters.contains(t.nombre));
                  }
                  if (_activeColorFilters.isNotEmpty) {
                    matchesFilters = matchesFilters && rep.etiquetas.any((Tag t) => _activeColorFilters.contains(t.colorName));
                  }
                  if (_activeTipoFilters.isNotEmpty) {
                    matchesFilters = matchesFilters && _activeTipoFilters.contains(rep.tipo.name);
                  }

                  return matchesText && matchesFilters;
                }).toList();
                // Mostrar los reportes en una lista vertical con scroll.
                // Cada tarjeta está centrada horizontalmente
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 8.0,
                  ),
                  itemCount: filtrados.length,
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(),
                  ),
                  itemBuilder: (context, i) {
                    // Buscar el reporte usando buscarReporte
                    Reporte? reporte = ReportHandler.buscarReporte(
                      filtrados[i],
                    );

                    if (reporte == null) return const SizedBox.shrink();
                    if (!reporte.titulo.toLowerCase().contains(
                      input.toLowerCase(),
                    ))
                      return const SizedBox.shrink();

                    final double width =
                        MediaQuery.of(context).size.width * 0.4;
                    const double height = 670;

                    // Determinar si es pendiente o no
                    bool esPendiente = SessionHandler.getPendientes.contains(
                      filtrados[i],
                    );

                    return Center(
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: Stack(
                          children: [
                            Container(
                              width: width,
                              height: height,
                              child: TarjetaReporte(
                                key: ValueKey(filtrados[i]),
                                nombre: filtrados[i],
                                modo: Modo.Ver,
                                pendiente: esPendiente,
                              ),
                            ),
                            if (soloMisReportes && esPendiente)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Pendiente',
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
                            if (soloMisReportes && !esPendiente)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Publicado',
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
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilterDialog() async {
    final reports = ReportHandler.getReportes;
    final Set<String> availableTags = {};
    final Set<String> availableColorsFromReports = {};
    final Set<String> availableTiposFromReports = {};
    for (var k in reports) {
      final r = ReportHandler.getReporte(k);
      if (r == null) continue;
      for (var tag in r.etiquetas) {
        availableTags.add(tag.nombre);
        availableColorsFromReports.add(tag.colorName);
      }
      if (r.tipo.name != 'administracion') availableTiposFromReports.add(r.tipo.name);
    }

    final Set<String> availableColors = {};
    try {
      availableColors.addAll(colorNameToHex.keys);
    } catch (_) {

    }
    availableColors.addAll(availableColorsFromReports);

    final Set<String> availableTipos = {};
    try {
      availableTipos.addAll(TipoReporte.values.where((t) => t.name != 'administracion').map((t) => t.name));
    } catch (_) {}
    availableTipos.addAll(availableTiposFromReports);

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
                      const Text('Categorías', style: TextStyle(fontWeight: FontWeight.w700)),
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
                      const Text('Colores', style: TextStyle(fontWeight: FontWeight.w700)),
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
                      const Text('Tipos', style: TextStyle(fontWeight: FontWeight.w700)),
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
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
}

class BotonCrear extends StatelessWidget {
  const BotonCrear(this.tipo, {super.key});
  final Uuid uuidGen = const Uuid();

  final TipoReporte tipo;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tipo == TipoReporte.encontrado
          ? "Reporta un objeto que has encontrado"
          : "Reporta un objeto que has perdido",
      child: FloatingActionButton.extended(
        heroTag: tipo,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                final String uuid = uuidGen.v7();
                return ReportDisplay.vacio(
                  key: ValueKey(uuid),
                  uuid,
                  modo: Modo.Editar,
                  tipo: tipo,
                );
              },
            ),
          );
        },
        elevation: 3,
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              Icon(
                tipo == TipoReporte.encontrado
                    ? Icons.downloading
                    : Icons.search,
              ),
            ],
          ),
        ), //TODO: cambiar los iconos
      ),
    );
  }
}
