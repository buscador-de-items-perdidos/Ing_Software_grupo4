import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';

class MenuPendientes extends StatelessWidget {
  const MenuPendientes({super.key});

  @override
  Widget build(BuildContext context) {
    Iterable<String> pendientes = ReportHandler.getPeticiones();

    return Scaffold(
      appBar: AppBar(title: const Text("Menu de reportes pendientes")),
      body: ListView.builder(
        itemCount: pendientes.length,
        itemBuilder: (context, i) => Card(
          child: ListTile(
            title: Text(
              ReportHandler.getPeticion(pendientes.elementAt(i))!.titulo,
            ),
          ),
        ),
      ),
    );
  }
}
