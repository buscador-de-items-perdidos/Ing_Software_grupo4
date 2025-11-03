import 'package:flutter/material.dart';
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
                "Brr Brr Patapim",
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
            IconButton.filled(onPressed: () {}, icon: Icon(Icons.person)),
          ],
        ),
      ],
    ),
    backgroundColor: Theme.of(context).primaryColor,
  );
}

class BotonPublicar extends StatelessWidget {
  const BotonPublicar(this.navKey, {super.key});

  final GlobalKey<NavigatorState>? navKey;

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
      onPressed: () {
        // Abrir directamente el formulario de creación 
        final String uuid = const Uuid().v7();
        if (navKey?.currentState != null) {
          navKey!.currentState!.push(
            MaterialPageRoute(
              builder: (_) => ReportDisplay.vacio(
                key: ValueKey(uuid),
                uuid,
                modo: Modo.Editar,
                tipo: TipoReporte.perdido,
              ),
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDisplay.vacio(
              key: ValueKey(uuid),
              uuid,
              modo: Modo.Editar,
              tipo: TipoReporte.perdido,
            ),
          ),
        );
      },
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
