import 'package:flutter/material.dart';
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
  late TextEditingController _titleController = TextEditingController(
    text: widget.reporte.titulo,
  );

  late TextEditingController _descriptionController = TextEditingController(
    text: widget.reporte.descripcion,
  );
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: TextFormField(
              validator: (v) => v == "" ? "Ingresa un título" : null,
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Ingresa un título",
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 0.0),
                ),
              ),
            ),
          ),
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
                  child: Column(
                    children: [
                      Expanded(flex: 4, child: TextFormField()),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                onPressed: _formKey.currentState?.validate() ?? false
                                    ? () => print("3")
                                    : () {},
                                child: const Text("Guardar y salir"),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text("Guardar"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Reporte _recolectarCambios() {
    //Este metodo obtendra la información entrada al widget y creara un nuevo reporte
    throw UnimplementedError();
  }
}

class _ImagenDeObjeto extends StatelessWidget {
  const _ImagenDeObjeto({super.key});

  @override
  Widget build(BuildContext context) {
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
