import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/tarjeta_reporte.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/menu_pendientes.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:ing_software_grupo4/report_display.dart';

import 'package:uuid/uuid.dart';

class MenuReportes extends StatefulWidget {
  const MenuReportes({super.key});

  @override
  State<MenuReportes> createState() => _MenuReportesState();
}

class _MenuReportesState extends State<MenuReportes> {
  String input = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SessionHandler.isAdmin ? BotonPendientes() : SizedBox.shrink(),
        title: Text("Menu de reportes"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 28.0, left: 50, right: 50),
            child: TextField(
              onChanged: (text) => setState(() {
                input = text;
              }),
            ),
          ),
          Expanded(
            flex: 5,
            child: ValueListenableBuilder(
              valueListenable: ReportHandler.reportNotifier,
              builder: (context, value, child) {
                List<String> reportes = ReportHandler.getReportes;
                List<String> filtrados = reportes
                    .where(
                      (x) =>
                          ReportHandler.getReporte(x)?.titulo
                              .toLowerCase()
                              .contains(input.toLowerCase()) ??
                          false,
                    )
                    .toList();
                return GridView.builder(
                  itemCount: filtrados.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: 200,
                  ),
                  itemBuilder: (context, i) {
                    Reporte? reporte = ReportHandler.getReporte(filtrados[i]);
                    if (reporte == null) return Card();
                    if (!reporte.titulo.toLowerCase().contains(
                      input.toLowerCase(),
                    ))
                      return SizedBox.shrink();
                    return TarjetaReporte(
                      key: ValueKey(filtrados[i]),
                      nombre: filtrados[i],
                      modo: Modo.Ver,
                      pendiente: false,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: BotonCrear(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class BotonPendientes extends StatelessWidget {
  const BotonPendientes({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MenuPendientes()),
        );
      },
      icon: Icon(Icons.timer),
    );
  }
}

class BotonCrear extends StatelessWidget {
  const BotonCrear({super.key});
  final Uuid uuidGen = const Uuid();
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
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
              );
            },
          ),
        );
      },
      elevation: 3,
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Row(children: [Icon(Icons.add), const Text("Crear")]),
      ),
    );
  }
}
