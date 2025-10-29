import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/editor_de_reportes.dart';

import 'modelos/reporte.dart';
import 'package:uuid/uuid.dart';

class MenuReportes extends StatefulWidget {
  const MenuReportes({super.key});

  @override
  State<MenuReportes> createState() => _MenuReportesState();
}

class _MenuReportesState extends State<MenuReportes> {
  final Map<String, Reporte> reportes = {};

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
  final Uuid uuidGen = const Uuid();
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              final String uuid = uuidGen.v7();
              return EditorDeReportes.vacio(uuid);
            },
          ),
        );
      },
      elevation: 3,
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Row(children: [Icon(Icons.add), const Text("Crear")]),
      ),
    );
  }
}
