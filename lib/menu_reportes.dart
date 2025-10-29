import 'package:flutter/material.dart';

import 'modelos/reporte.dart';

class MenuReportes extends StatefulWidget{
  
  const MenuReportes({super.key});

  @override
  State<MenuReportes> createState() => _MenuReportesState();
}

class _MenuReportesState extends State<MenuReportes> {
  final List<Reporte> reportes = [];

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Text"),),
      body: ListView(
      )
    );
  }
}
