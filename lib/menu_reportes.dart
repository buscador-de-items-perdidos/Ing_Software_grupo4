import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
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
          Expanded(
            flex: 5,
            child: ValueListenableBuilder(
              valueListenable: ReportHandler.reportNotifier,
              builder: (context, value, child) {
                List<String> reportes;

                if (soloMisReportes) {
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

                  // Filtrar por búsqueda
                  return reporte.titulo.toLowerCase().contains(
                    input.toLowerCase(),
                  );
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
                        child: Container(
                          width: width,
                          height: height,
                          child: TarjetaReporte(
                            key: ValueKey(filtrados[i]),
                            nombre: filtrados[i],
                            modo: Modo.Ver,
                            pendiente: esPendiente,
                          ),
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
