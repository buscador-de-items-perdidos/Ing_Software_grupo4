import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/pantallas_dependientes.dart';

class TarjetaReporte extends StatelessWidget {
  const TarjetaReporte({
    super.key,
    required this.uuid,
    required this.modo,
    required this.pendiente,
  });

  final String uuid;
  final Modo modo;
  final bool pendiente;

  @override
  Widget build(BuildContext context) {
    final Reporte? reporte = _obtenerReporte();

    if (reporte == null) {
      return const SizedBox.shrink();
    }

    return _buildCard(context, reporte);
  }

  Reporte? _obtenerReporte() {
    return pendiente
        ? ReportHandler.getPeticion(uuid)
        : ReportHandler.getReporte(uuid);
  }

  Widget _buildCard(BuildContext context, Reporte reporte) {
    final bool puedeEliminar = _puedeEliminarReporte(reporte);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () => _navegarADetalle(context, reporte),
        child: Stack(
          children: [
            _buildContenidoTarjeta(context, reporte),
            if (puedeEliminar) _buildBotonEliminar(context),
          ],
        ),
      ),
    );
  }

  bool _puedeEliminarReporte(Reporte reporte) {
    final bool esAutor = reporte.autor == SessionHandler.uuid;
    return (esAutor || SessionHandler.isAdmin) && modo != Modo.Revisar;
  }

  Widget _buildContenidoTarjeta(BuildContext context, Reporte reporte) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: _buildImagen(reporte)),
        _buildTitulo(context, reporte),
        _buildEtiqueta(reporte),
        _buildTipoObjeto(context, reporte),
      ],
    );
  }

  Widget _buildImagen(Reporte reporte) {
    if (reporte.imagenesBytes.isEmpty) {
      return Image.asset('assets/trial.png', fit: BoxFit.cover);
    }

    return Image.memory(
      reporte.imagenesBytes.first,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) =>
          Image.asset('assets/trial.png', fit: BoxFit.cover),
    );
  }

  Widget _buildTitulo(BuildContext context, Reporte reporte) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        reporte.titulo,
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEtiqueta(Reporte reporte) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Chip(
        avatar: CircleAvatar(
          backgroundColor:
              reporte.etiquetas.firstOrNull?.color.color ?? Colors.white,
          radius: 12,
        ),
        label: Text(reporte.etiquetas.firstOrNull?.tipo.name ?? "Sin etiqueta"),
      ),
    );
  }

  Widget _buildTipoObjeto(BuildContext context, Reporte reporte) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 40.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 20, // Consistent height for this text
          ),
          child: Text(
            'Objeto ${reporte.tipo.name}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildBotonEliminar(BuildContext context) {
    return Positioned(
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
    );
  }

  void _navegarADetalle(BuildContext context, Reporte reporte) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => mostrarReporte(reporte, uuid, modo: modo),
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
      ReportHandler.eliminarReporte(uuid);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reporte eliminado')));
    }
  }
}
