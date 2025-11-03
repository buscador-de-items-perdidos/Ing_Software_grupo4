import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:ing_software_grupo4/tarjeta_reporte.dart';

class MenuPendientes extends StatefulWidget {
  const MenuPendientes({super.key});

  @override
  State<MenuPendientes> createState() => _MenuPendientesState();
}

class _MenuPendientesState extends State<MenuPendientes> {
  @override
  Widget build(BuildContext context) {
    Iterable<String> pendientes = ReportHandler.getPeticiones();

    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: ReportHandler.pendingNotifier,
        builder: (context, value, child) {
          return GridView.builder(
            itemCount: pendientes.length,
            itemBuilder: (context, i) => TarjetaReporte(nombre: pendientes.elementAt(i), modo: Modo.Revisar, pendiente:true),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
            ),
          );
        }
      ),
    );
  }
}
