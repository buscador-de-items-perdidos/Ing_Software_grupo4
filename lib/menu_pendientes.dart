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
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: ReportHandler.pendingNotifier,
        builder: (context, value, child) {
          // Obtenemos la lista de IDs de reportes pendientes.
          final List<String> pendientes = ReportHandler.getPeticiones().toList();
          return GridView.builder(
            itemCount: pendientes.length,
            itemBuilder: (context, i) {
              final String id = pendientes.elementAt(i);
              return Stack(
                children: [
                  // Tarjeta que muestra los detalles del reporte en modo revisión
                  TarjetaReporte(nombre: id, modo: Modo.Revisar, pendiente: true),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Tooltip(
                      message: 'Aprobar reporte',
                      child: IconButton(
                        // Icono para indicar acción de aprobación
                        icon: Icon(Icons.check_circle, color: Colors.green[700]),
                        onPressed: () {
                          ReportHandler.acceptPeticion(id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reporte aprobado')),
                          );
                        },
                      ),
                    ),
                  ),
                  // Icono para indicar la acción de rechazar 
                  Positioned(
                    bottom: 6,
                    right: 44,
                    child: Tooltip(
                      message: 'Rechazar reporte',
                      child: IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red[700]),
                        onPressed: () {
                          ReportHandler.rejectPeticion(id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reporte rechazado')),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
            ),
          );
        }
      ),
    );
  }
}
