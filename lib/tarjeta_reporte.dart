import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/report_display.dart';

class TarjetaReporte extends StatelessWidget {
  const TarjetaReporte({
    super.key,
    required this.nombre,
    required this.modo,
    required this.pendiente,
  });

  final String nombre;

  final Modo modo;

  final bool pendiente;

  @override
  Widget build(BuildContext context) {
    Reporte reporte = pendiente
        ? ReportHandler.getPeticion(nombre)!
        : ReportHandler.getReporte(nombre)!;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportDisplay(reporte, nombre, modo: modo),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: reporte.imagenesBytes.isNotEmpty
                  ? Image.memory(
                      reporte.imagenesBytes.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          Image.asset('assets/trial.png', fit: BoxFit.cover),
                    )
                  : Image.asset('assets/trial.png', fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                reporte.titulo,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
