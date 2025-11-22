import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/report_display.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:uuid/uuid.dart';

AppBar appbar(BuildContext context) => AppBar(
  iconTheme: IconThemeData(color: Theme.of(context).scaffoldBackgroundColor),
  leading: Builder(
    builder: (context) => IconButton(
      icon: Icon(Icons.menu),
      onPressed: () => Scaffold.of(context).openDrawer(),
    ),
  ),
  titleSpacing: 0,
  title: Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {},
          child: Text(
            "Objetos Perdidos",
            style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        BotonPublicar(),
      ],
    ),
  ),
  backgroundColor: Theme.of(context).primaryColor,
);

class BotonPublicar extends StatelessWidget {
  const BotonPublicar({super.key});

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
  _BotonMenu({required this.tipo});

  final TipoReporte tipo;

  @override
  Widget build(BuildContext context) {
    String titulo;
    String descripcion;

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                titulo,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Text(descripcion),
          ],
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
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
