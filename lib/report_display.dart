import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

part 'campo_titulo.dart';
part 'descripcion_reporte.dart';

class ReportDisplay extends StatefulWidget {
  final Reporte reporte;
  final String uuid;
  final Modo modo;
  Usuario get usuario => SessionHandler.getUsuario(reporte.autor);
  const ReportDisplay(this.reporte, this.uuid, {required this.modo, super.key});

  ReportDisplay.vacio(
    this.uuid, {
    super.key,
    required this.modo,
    required TipoReporte tipo,
  }) : reporte = Reporte.vacio(tipo, SessionHandler.uuid);

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

  late LatLng _loc =
      widget.reporte.ubicacion ?? LatLng(-36.8288323, -73.0372646);
  LatLng? _finalLoc;
  late List<Uint8List> _imagenesBytes = List<Uint8List>.from(
    widget.reporte.imagenesBytes,
  );
  final PageController _pageController = PageController();
  Future<void> _pickOneImage() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (res == null || res.files.isEmpty) return;
    final file = res.files.first;
    if (file.bytes == null) return;
    setState(() {
      _imagenesBytes.add(file.bytes!);
    });
  }

  // Eliminado menú y selección múltiple para dejar sólo selección individual

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
                          child: Stack(
                            children: [
                              _GaleriaImagenes(
                                imagenesBytes: _imagenesBytes,
                                controller: _pageController,
                                editable: widget.modo == Modo.Editar,
                                onDelete: (i) {
                                  setState(() {
                                    _imagenesBytes.removeAt(i);
                                  });
                                },
                              ),
                              if (widget.modo == Modo.Editar)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Tooltip(
                                    message: 'Agregar imagen',
                                    child: IconButton.filled(
                                      onPressed: _pickOneImage,
                                      icon: const Icon(
                                        Icons.add_a_photo_outlined,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
                        flex: 3,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DetallesReporte(reporte: widget.reporte),
                            ),
                            Expanded(
                              flex: 3,
                              child: _DatosContacto(usuario: widget.usuario),
                            ),
                          ],
                        ),
                      ),
                      Expanded(flex: 4, child: mapaUdec()),
                      Expanded(
                        flex: 1,
                        child: switch (widget.modo) {
                          Modo.Editar => _crearBotonesGuardado(context),
                          Modo.Ver => _crearBotonEditar(context),
                          Modo.Revisar => _crearBotonesPublicacion(context),
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

  Widget mapaUdec() {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: _loc,
            initialZoom: 16,
            onTap: (_, pos) {
              if (widget.modo == Modo.Editar) {
                setState(() {
                  _loc = pos;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.perdidoudec.app',
            ),
            MarkerLayer(
              markers: [
                if (_finalLoc != null)
                  Marker(
                    point: _finalLoc!,
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.green,
                    ),
                  ),
                Marker(
                  point: _loc,
                  child: const Icon(
                    Icons.location_on,
                    color: Color.fromARGB(255, 255, 29, 33),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (widget.modo == Modo.Editar)
          Align(
            alignment: Alignment.bottomRight,
            child: Tooltip(
              message: "Confirmar selección",
              child: IconButton.filled(
                onPressed: () {
                  setState(() {
                    _finalLoc = LatLng(_loc.latitude, _loc.longitude);
                  });
                },
                icon: Icon(Icons.read_more),
              ),
            ),
          ),
      ],
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
    if (!_formKey.currentState!.validate() || _finalLoc == null) {
      if (_finalLoc == null)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Recuerda que tienes que confirmar una ubicación antes de publicar",
            ),
          ),
        );
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
    if (_publicar(context)) Navigator.of(context, rootNavigator: true).pop();
  }

  Reporte _recolectarCambios() {
    return Reporte(
      _titleController.text,
      _descriptionController.text,
      SessionHandler.uuid,
      "",
      widget.reporte.tipo,
      _finalLoc!,
      imagenesBytes: _imagenesBytes,
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
        if (!context.mounted) return;
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

class _GaleriaImagenes extends StatefulWidget {
  const _GaleriaImagenes({
    required this.imagenesBytes,
    required this.controller,
    this.onDelete,
    this.editable = false,
  });
  final List<Uint8List> imagenesBytes;
  final PageController controller;
  final void Function(int index)? onDelete;
  final bool editable;

  @override
  State<_GaleriaImagenes> createState() => _GaleriaImagenesState();
}

class _GaleriaImagenesState extends State<_GaleriaImagenes> {
  int index = 0;

  void _go(int delta) {
    final total = widget.imagenesBytes.length;
    if (total == 0) return;
    final next = (index + delta) % total;
    setState(() => index = (next + total) % total);
    widget.controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.imagenesBytes.length;
    if (count == 0) {
      return Container(
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Text('Sin imágenes'),
      );
    }
    return Stack(
      children: [
        PageView.builder(
          controller: widget.controller,
          onPageChanged: (i) => setState(() => index = i),
          itemCount: count,
          itemBuilder: (context, i) => GestureDetector(
            onTap: () => _openFullScreen(i),
            child: Image.memory(widget.imagenesBytes[i], fit: BoxFit.cover),
          ),
        ),
        if (widget.editable && widget.onDelete != null)
          Positioned(
            top: 8,
            left: 8,
            child: Tooltip(
              message: 'Eliminar imagen',
              child: IconButton.filled(
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.black54)),
                onPressed: () => widget.onDelete!(index),
                icon: const Icon(Icons.delete_outline, color: Colors.white),
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _go(-1),
            icon: const Icon(Icons.chevron_left, size: 36),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _go(1),
            icon: const Icon(Icons.chevron_right, size: 36),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              count,
              (i) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == index ? Colors.white : Colors.white54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullscreenGallery extends StatefulWidget {
  const _FullscreenGallery({required this.images, required this.initialIndex});
  final List<Uint8List> images;
  final int initialIndex;

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.images.length,
            itemBuilder: (context, i) => Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Image.memory(widget.images[i], fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _current ? Colors.white : Colors.white54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on _GaleriaImagenesState {
  void _openFullScreen(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenGallery(
          images: widget.imagenesBytes,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _DatosContacto extends StatelessWidget {
  const _DatosContacto({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Datos de contacto",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        Text("Correo Electronico: ${usuario.correo}"),
        Text("Numero de telefono: ${usuario.numero}"),
        Text(
          "Detalles adicionales",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(usuario.miscelaneo, textAlign: TextAlign.justify),
        SizedBox.shrink(),
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
      ],
    );
  }
}
