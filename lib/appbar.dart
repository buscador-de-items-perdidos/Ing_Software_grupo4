import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/cambio_contactos.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/report_display.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:uuid/uuid.dart';

AppBar appbar(BuildContext context, GlobalKey<NavigatorState> navKey) {
  return AppBar(
    iconTheme: Theme.of(context).iconTheme,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => navKey.currentState?.popUntil((route) => route.isFirst),
          child: Row(
            children: [
              Icon(
                Icons.cast_outlined,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              Text(
                "Objetos Perdidos",
                style: TextStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        !SessionHandler.isAdmin ? SizedBox.shrink() : SizedBox.shrink(),
        Row(
          children: [
            BotonPublicar(navKey),
            IconButton.filled(
              onPressed: () => navKey.currentState!.push(
                MaterialPageRoute(builder: (_) => const CambioContactos()),
              ),
              icon: Icon(Icons.person),
            ),
          ],
        ),
      ],
    ),
    backgroundColor: Theme.of(context).primaryColor,
  );
}

class BotonPublicar extends StatelessWidget {
  const BotonPublicar(this.navKey, {super.key});

  final GlobalKey<NavigatorState> navKey;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty<Color>.fromMap(
          <WidgetStatesConstraint, Color>{
            WidgetState.any: Theme.of(context).scaffoldBackgroundColor,
          },
        ),
      ),
      onPressed: () => showDialog(
        barrierColor: Colors.black26,
        context: navKey.currentContext!,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding: const EdgeInsets.only(top: 56, right: 12, left: 12),
          alignment: Alignment.topRight,
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Text(
                    "Selecciona el tipo de reporte",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                const Divider(),
                _BotonMenu(navKey: navKey, tipo: TipoReporte.perdido),
                const SizedBox(height: 8),
                _BotonMenu(navKey: navKey, tipo: TipoReporte.encontrado),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),

      child: Row(
        children: [
          Icon(Icons.add, color: Theme.of(context).primaryColor),
          Text(
            "Publicar",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }
}

class _BotonMenu extends StatelessWidget {
  _BotonMenu({required this.navKey, required this.tipo});

  final GlobalKey<NavigatorState> navKey;
  final TipoReporte tipo;

  @override
  Widget build(BuildContext context) {
    late final String titulo;
    late final String descripcion;
    late final IconData icon;

    switch (tipo) {
      case TipoReporte.perdido:
        titulo = 'Perdido';
        descripcion = 'Publica un objeto que has perdido.';
        icon = Icons.report_problem_outlined;
        break;
      case TipoReporte.encontrado:
        titulo = 'Encontrado';
        descripcion = 'Publica un objeto que has encontrado.';
        icon = Icons.location_searching_outlined;
        break;
      default:
        titulo = 'Reporte';
        descripcion = 'Publica un reporte.';
        icon = Icons.info_outline;
        break;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.pop(context);
          navKey.currentState!.push(
            MaterialPageRoute(
              builder: (_) {
                final uuid = Uuid().v7();
                return ReportDisplay.vacio(uuid, modo: Modo.Editar, tipo: tipo);
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(icon, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(descripcion, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_outlined, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
