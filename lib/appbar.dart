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
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) => Dialog(
          constraints: BoxConstraints.loose(Size.square(250)),
          alignment: Alignment.topRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Selecciona el tipo de reporte",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              Divider(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _BotonMenu(tipo: TipoReporte.perdido)),
                    Expanded(child: _BotonMenu(tipo: TipoReporte.encontrado)),
                  ],
                ),
              ),
            ],
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
  const _BotonMenu({required this.tipo});

  final TipoReporte tipo;

  @override
  Widget build(BuildContext context) {
    String titulo;
    String descripcion;

    switch (tipo) {
      case TipoReporte.perdido:
        titulo = "Perdido";
        descripcion = "Publica un objeto que has perdido.";
      case TipoReporte.encontrado:
        titulo = "Encontrado";
        descripcion = "Publica un objeto que has encontrado.";
      case TipoReporte.administracion:
        titulo = "Anuncio";
        descripcion = "Publica anuncios de administración.";
    }
    return SizedBox(
      width: double.infinity,
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

                return ReportEditor.vacio(uuid, tipo: tipo);
              },
            ),
          );
        },
      ),
    );
  }
}
