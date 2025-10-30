import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modo.dart';
import 'package:ing_software_grupo4/report_display.dart';

class MenuPendientes extends StatelessWidget {
  const MenuPendientes({super.key});

  @override
  Widget build(BuildContext context) {
    Iterable<String> pendientes = ReportHandler.getPeticiones();

    return Scaffold(
      appBar: AppBar(title: const Text("Menu de reportes pendientes")),
      body: ListView.builder(
        itemCount: pendientes.length,
        itemBuilder: (context, i) {
          Reporte r = ReportHandler.getPeticion(pendientes.elementAt(i))!;
          return InkWell(
            child: ListTile(title: Text(r.titulo)),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportDisplay(
                    r,
                    pendientes.elementAt(i),
                    modo: Modo.Revisar,
                  ),
                ),
              ),
            },
          );
        },
      ),
    );
  }
}
