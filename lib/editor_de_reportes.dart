import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';

class EditorDeReportes extends StatefulWidget {
  final Reporte reporte;
  final String uuid;

  const EditorDeReportes(this.reporte, this.uuid, {super.key});
  const EditorDeReportes.vacio(this.uuid, {super.key})
    : reporte = const Reporte.vacio(TipoReporte.encontrado);

  @override
  State<StatefulWidget> createState() {
    return _EditorDeReportesState();
  }
}

class _EditorDeReportesState extends State<EditorDeReportes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Image.network(
        "https://static.wikia.nocookie.net/enciclopedia-meme/images/d/dc/Troll_face.png/revision/latest?cb=20131215222952&path-prefix=es",
      ),
    );
  }
}
