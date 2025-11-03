import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';

part 'campo_titulo.dart';
part 'imagen_de_objeto.dart';
part 'descripcion_reporte.dart';

class ReportDisplay extends StatefulWidget {
  final Reporte reporte;
  final String uuid;
  final Modo modo;
  const ReportDisplay(this.reporte, this.uuid, {required this.modo, super.key});
  ReportDisplay.vacio(
    this.uuid, {
    super.key,
    required this.modo,
    required TipoReporte tipo,
  }) : reporte = Reporte.vacio(tipo);

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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: SizedBox.expand(
                          child: Image.asset(
                            'assets/trial.jpeg',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: _CampoTitulo(
                            controller: _titleController,
                            editable: widget.modo == Modo.Editar,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: _DescripcionReporte(
                          controller: _descriptionController,
                          tipo: widget.reporte.tipo,
                          editable: widget.modo == Modo.Editar,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DetallesReporte(reporte: widget.reporte),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Expanded(flex: 3, child: Container()),
                      Expanded(
                        flex: 1,
                        child: switch (widget.modo) {
                          Modo.Editar => _crearBotonesGuardado(context),
                          Modo.Ver => _crearBotonEditar(context),
                          Modo.Revisar => _crearBotonesPublicacion(context)
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  bool _publicar(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    Reporte r = _recolectarCambios();
    if (!ReportHandler.submitPeticion(widget.uuid, r, true)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: const Text("FAILED PUBLISH")));
      return false;
    }
    return true;
  }

  void _publicarYSalir(BuildContext context) {
    if (_publicar(context)) Navigator.pop(context);
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

  Widget _crearBotonEditar(BuildContext context) {
    return ElevatedButton(
      child: const Text("Editar"),
      onPressed: () async {
        bool editarRevisionEnCola = false;
        if (ReportHandler.getPeticion(widget.uuid) != null) {
          editarRevisionEnCola = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Revisión en cola"),
              content: const Text(
                "Se ha detectado que tienes una revisión de este reporte en cola. ¿Deseas editar aquella revisión en vez de la versión aceptada?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Sí"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No"),
                ),
              ],
            ),
          );
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDisplay(
              editarRevisionEnCola
                  ? ReportHandler.getPeticion(widget.uuid)!
                  : widget.reporte,
              widget.uuid,
              modo: Modo.Editar,
            ),
          ),
        );
      },
    );
  }

  Widget _crearBotonesPublicacion(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Tooltip(
            message: "Aprobar revisión",
            child: ElevatedButton.icon(
              onPressed: () {
                ReportHandler.acceptPeticion(widget.uuid);
                Navigator.pop(context);
              },
              label: Icon(Icons.check),
            ),
          ),
        ),
        Expanded(
          child: Tooltip(
            message: "Rechazar y destruir revisión",
            child: ElevatedButton.icon(
              onPressed: () {
                ReportHandler.rejectPeticion(widget.uuid);
                Navigator.pop(context, true);
              },
              label: Icon(Icons.delete),
            ),
          ),
        ),
      ],
    );
  }
}

class DetallesReporte extends StatelessWidget {
  const DetallesReporte({super.key, required this.reporte});

  final Reporte reporte;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Detalles del reporte",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              Text(
                "Autor: ${SessionHandler.nombreUsuario}",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                textAlign: TextAlign.left,
              ),
              Text(
                "Tipo: Objeto ${reporte.tipo.name}",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                textAlign: TextAlign.left,
              ),
              Text(
                "Fecha: 04/11/2025", //TODO: Incluir fecha en reporte
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
              ),
              SizedBox.shrink(),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                "Datos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
