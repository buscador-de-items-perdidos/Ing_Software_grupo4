import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/appbar.dart';
import 'package:ing_software_grupo4/cambio_contactos.dart';
import 'package:ing_software_grupo4/menu_lateral.dart';
import 'package:ing_software_grupo4/menu_pendientes.dart';
import 'package:ing_software_grupo4/menu_reportes.dart';
import 'package:ing_software_grupo4/pantallas_dependientes.dart';

// Global navigator key so other widgets can access a root context
final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<StatefulWidget> createState() {
    return _AppShellState();
  }
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  int? selection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appbar(context),
      drawer: MenuLateral(
        select: (i) {
          setState(() {
            selection = i;
          });
          Navigator.of(context).pop();
        },
      ),
      body: _buildBody(),
    );
  }

  Widget? _buildBody() {
    return switch (selection) {
      0 => MenuReportes(key: ValueKey('todos-$selection')),
      1 => MenuPendientes(),
      2 => mostrarDatosContacto(),
      3 => MenuReportes(key: ValueKey('mis-$selection'), soloMisReportes: true),
      _ => MenuReportes(key: ValueKey('default-$selection')),
    };
  }
}
