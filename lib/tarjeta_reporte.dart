import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
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
    // Usar buscarReporte para buscar en todos los maps (pendientes, existentes, encontrados)
    Reporte? reporte = ReportHandler.buscarReporte(nombre);

    if (reporte == null) {
      return const SizedBox.shrink();
    }

    final esAutor = reporte.autor == SessionHandler.uuid;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(3),
      ),
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: reporte.imagenesBytes.isNotEmpty
                      ? Image.memory(
                          reporte.imagenesBytes.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Image.asset(
                            'assets/trial.png',
                            fit: BoxFit.cover,
                          ),
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
            if ((esAutor || SessionHandler.isAdmin) && modo != Modo.Revisar)
              Positioned(
                top: 4,
                right: 4,
                child: Material(
                  color: Colors.transparent,
                  child: Tooltip(
                    message: 'Eliminar reporte',
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                      ),
                      onPressed: () => _eliminarReporte(context),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _eliminarReporte(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este reporte? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      ReportHandler.eliminarReporte(nombre);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reporte eliminado')));
    }
  }
}
