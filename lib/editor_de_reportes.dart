import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
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
  late final TextEditingController _titleController = TextEditingController(
    text: widget.reporte.titulo,
  );

  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.reporte.descripcion);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _crearCampoTitulo(),
            Text(
              "Autor: ${SessionHandler.nombreUsuario}",
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ImagenDeObjeto(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 100.0),
                      child: Column(
                        children: [
                          const Text(
                            "Descripción",
                            textScaler: TextScaler.linear(1.2),
                          ),
                          _crearCampoDescripcion(),
                          _crearBotonesGuardado(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _crearCampoTitulo() {
    return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: TextFormField(
              validator: (v) =>
                  v == null || v.isEmpty ? "Ingresa un título" : null,
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Ingresa un título",
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 0.0),
                ),
              ),
            ),
          );
  }

  Expanded _crearBotonesGuardado(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () => _publicarYSalir(context),
              child: const Text("Publicar y Salir"),
            ),
          ),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () => _publicar(context),
              child: Text("Publicar"),
            ),
          ),
        ],
      ),
    );
  }

  Expanded _crearCampoDescripcion() {
    return Expanded(
      flex: 4,
      child: TextFormField(
        minLines: null,
        maxLines: 100,
        decoration: InputDecoration(
          hintText: "Escribe una descripción del objeto perdido",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlueAccent, width: 0.0),
          ),
        ),
        validator: (v) =>
            v == null || v.isEmpty ? "Escribe una descripción valida" : null,
      ),
    );
  }

  void _publicar(BuildContext context) {
    if (!_formKey.currentState!.validate()) {}
    Reporte r = _recolectarCambios();
    if (!ReportHandler.submitPeticion(widget.uuid, r, true)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: const Text("FAILED PUBLISH")));
    }
  }

  void _publicarYSalir(BuildContext context) {
    _publicar(context);
    Navigator.pop(context);
  }

  Reporte _recolectarCambios() {
    return Reporte(
      _titleController.text,
      _descriptionController.text,
      SessionHandler.uuid,
      "",
      widget.reporte.tipo,
    );
  }
}

class _ImagenDeObjeto extends StatelessWidget {
  const _ImagenDeObjeto();

  @override
  Widget build(BuildContext context) {
    if (true) {
      //Esta condición a futuro seria si el reporte tiene una imagen, por ahora asumimos que sí
      return Expanded(
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/trial.jpeg'),
          maxRadius: 99999,
        ),
      );
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(70.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: BoxBorder.all(color: Colors.deepPurpleAccent, width: 1),
          ),
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}
