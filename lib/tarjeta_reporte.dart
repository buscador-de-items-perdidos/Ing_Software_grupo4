import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/report_display.dart';

class TarjetaReporte extends StatelessWidget {
  const TarjetaReporte({super.key, required this.nombre, required this.modo, required this.pendiente});

  final String nombre;

  final Modo modo;

  final bool pendiente;

  @override
  Widget build(BuildContext context) {
    Reporte reporte = pendiente ? ReportHandler.getPeticion(nombre)! : ReportHandler.getReporte(nombre)!;
    return Card(
      child: ListTile(
        title: Column(
          children: [
            Image.asset('assets/trial.jpeg'),
            Expanded(child: Text(reporte.titulo)),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportDisplay(
                reporte,
                nombre,
                modo: modo,
              ),
            ),
          );
        },
      ),
    );
  }
}

