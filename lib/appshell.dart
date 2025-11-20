import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/appbar.dart';
import 'package:ing_software_grupo4/cambio_contactos.dart';
import 'package:ing_software_grupo4/menu_lateral.dart';
import 'package:ing_software_grupo4/menu_pendientes.dart';
import 'package:ing_software_grupo4/menu_reportes.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<StatefulWidget> createState() {
    return _AppShellState();
  }
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<NavigatorState> _navKey = GlobalKey();
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
      0 => MenuReportes(),
      1 => MenuPendientes(),
      2 => CambioContactos(),
      _ => MenuReportes(),
    };
  }
}
