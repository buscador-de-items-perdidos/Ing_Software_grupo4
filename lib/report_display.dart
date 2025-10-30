import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/modo.dart';

class ReportDisplay extends StatefulWidget {
  final Reporte reporte;
  final String uuid;
  final Modo modo;
  const ReportDisplay(
    this.reporte,
    this.uuid, {
    required this.modo,
    super.key,
  });
  const ReportDisplay.vacio(this.uuid, {super.key, required this.modo})
    : reporte = const Reporte.vacio(TipoReporte.encontrado);

  @override
  State<StatefulWidget> createState() {
    return _ReportDisplayState();
  }
}

class _ReportDisplayState extends State<ReportDisplay> {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100.0),
              child: _CampoTitulo(
                controller: _titleController,
                editable: widget.modo == Modo.Editar,
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
                    child: Padding(
                      padding: const EdgeInsets.only(right: 100.0),
                      child: Column(
                        children: [
                          const Text(
                            "Descripción",
                            textScaler: TextScaler.linear(1.2),
                          ),
                          Expanded(
                            flex: 4,
                            child: _DescripcionReporte(
                              controller: _descriptionController,
                              editable: widget.modo == Modo.Editar,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: switch (widget.modo) {
                              Modo.Ver => SizedBox.expand(),
                              Modo.Revisar => _crearBotonesGuardado(context),
                              Modo.Editar => _crearBotonesPublicacion(context),
                            },
                          ),
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

  Widget _crearBotonesGuardado(BuildContext context) {
    return Row(
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

  Widget _crearBotonesPublicacion(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Tooltip(
            message: "Aprobar revisión",
            child: ElevatedButton.icon(
              onPressed: () {},
              label: Icon(Icons.check),
            ),
          ),
        ),
        Expanded(
          child: Tooltip(
            message: "Rechazar y destruir revisión",
            child: ElevatedButton.icon(
              onPressed: () {},
              label: Icon(Icons.delete),
            ),
          ),
        ),
      ],
    );
  }
}

class _CampoTitulo extends StatelessWidget {
  const _CampoTitulo({required this.controller, required this.editable});

  final TextEditingController controller;

  final bool editable;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (v) => v == null || v.isEmpty ? "Ingresa un título" : null,
      controller: controller,
      enabled: editable,
      decoration: InputDecoration(
        hintText: "Ingresa un título",
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.0),
        ),
      ),
    );
  }
}

class _DescripcionReporte extends StatelessWidget {
  const _DescripcionReporte({required this.controller, required this.editable});
  final TextEditingController controller;

  final bool editable;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: null,
      maxLines: 100,
      enabled: editable,
      decoration: InputDecoration(
        hintText: "Escribe una descripción del objeto perdido",
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 0.0),
        ),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? "Escribe una descripción valida" : null,
    );
  }
}

//TODO: agregar modo editable cuando se puedan subir imagenes
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
