import 'package:flutter/material.dart';

import 'modelos/reporte.dart';

class MenuReportes extends StatefulWidget {
  const MenuReportes({super.key});

  @override
  State<MenuReportes> createState() => _MenuReportesState();
}

class _MenuReportesState extends State<MenuReportes> {
  final List<Reporte> reportes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menu de reportes"), centerTitle: true),
      body: ListView(),
      floatingActionButton: BotonCrear(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class BotonCrear extends StatelessWidget {
  const BotonCrear({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => debugPrint("abusadol"),
      elevation: 3,
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(children: [Icon(Icons.add), const Text("Crear")]),
      ),
    );
  }
}
