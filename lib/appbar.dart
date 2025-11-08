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
        barrierColor: Colors.transparent,
        context: navKey.currentContext!,
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
                    Expanded(
                      child: _BotonMenu(
                        navKey: navKey,
                        tipo: TipoReporte.perdido,
                      ),
                    ),
                    Expanded(
                      child: _BotonMenu(
                        navKey: navKey,
                        tipo: TipoReporte.encontrado,
                      ),
                    ),
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
  _BotonMenu({required this.navKey, required this.tipo});

  final GlobalKey<NavigatorState> navKey;

  final TipoReporte tipo;
  String? titulo;
  String? descripcion;
  @override
  Widget build(BuildContext context) {
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
                titulo!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Text(descripcion!),
          ],
        ),
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
      ),
    );
  }
}
