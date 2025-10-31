import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:ing_software_grupo4/report_display.dart';

class MenuPendientes extends StatelessWidget {
  const MenuPendientes({super.key});

  @override
  Widget build(BuildContext context) {
    Iterable<String> pendientes = ReportHandler.getPeticiones();

    return Scaffold(
      appBar: AppBar(title: const Text("Menu de reportes pendientes")),
      body: GridView.builder(
        itemCount: pendientes.length,
        itemBuilder: (context, i) {
          Reporte r = ReportHandler.getPeticion(pendientes.elementAt(i))!;
          return Card(
            child: ListTile(
              tileColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              title: Column(
                children: [
                  Image.asset('assets/trial.jpeg', fit: BoxFit.fill),
                  Text(r.titulo),
                ],
              ),
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
            ),
          );
        },
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
        ),
      ),
    );
  }
}
