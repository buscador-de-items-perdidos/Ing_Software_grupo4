import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ing_software_grupo4/__datos_contacto.dart';
import 'package:ing_software_grupo4/__galeria_imagenes.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';
import 'package:ing_software_grupo4/modelos/tagcolor.dart';
import 'package:ing_software_grupo4/modelos/tagtype.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ing_software_grupo4/detalles_reporte.dart';

part 'campo_titulo.dart';
part 'descripcion_reporte.dart';

class ReportEditor extends StatefulWidget {
  final Reporte reporte;
  final String uuid;
  Usuario get usuario => SessionHandler.getUsuario(reporte.autor);
  const ReportEditor(this.reporte, this.uuid, {super.key});

  ReportEditor.vacio(this.uuid, {super.key, required TipoReporte tipo})
    : reporte = Reporte.vacio(tipo, SessionHandler.uuid);

  @override
  State<StatefulWidget> createState() {
    return _ReportEditorState();
  }
}

class _ReportEditorState extends State<ReportEditor> {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.reporte.titulo,
  );

  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.reporte.descripcion);

  final _formKey = GlobalKey<FormState>();
  late bool _encontrado = widget.reporte.encontrado;

  late LatLng _loc =
      widget.reporte.ubicacion ?? LatLng(-36.8288323, -73.0372646);
  LatLng? _finalLoc;
  late final List<Uint8List> _imagenesBytes = List<Uint8List>.from(
    widget.reporte.imagenesBytes,
  );
  late List<Tag> _selectedTags = List<Tag>.from(widget.reporte.etiquetas);
  bool _intentoPublicarSinEtiquetas = false;

  final PageController _pageController = PageController();

  Future<void> _pickOneImage() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
      allowCompression: false,
    );
    if (res == null || res.files.isEmpty) return;
    final file = res.files.first;
    if (file.bytes == null) return;
    setState(() {
      _imagenesBytes.add(file.bytes!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    child: SizedBox(
                      height: 480,
                      child: Stack(
                        children: [
                          GaleriaImagenes(
                            imagenesBytes: _imagenesBytes,
                            controller: _pageController,
                            editable: true,
                            onDelete: (i) {
                              setState(() {
                                _imagenesBytes.removeAt(i);
                              });
                            },
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Tooltip(
                              message: 'Agregar imagen',
                              child: IconButton.filled(
                                onPressed: _pickOneImage,
                                icon: const Icon(Icons.add_a_photo_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: _CampoTitulo(
                      controller: _titleController,
                      editable: true,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: _DescripcionReporte(
                      controller: _descriptionController,
                      tipo: widget.reporte.tipo,
                      editable: true,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        DatosContacto(usuario: widget.usuario),
                        const SizedBox(height: 24),
                        DetallesReporte(
                          reporte: widget.reporte,
                          selectedTags: _selectedTags,
                          editable: true,
                          onEditTags: _openTagEditor,
                          onEditColors: _openColorEditor,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    child: SizedBox(height: 360, child: mapaUdec()),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: _crearBotonesGuardado(context),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
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
            onTap: (_, pos) => setState(() {
              _loc = pos;
            }),
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
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _publicarYSalir(context),
            child: const Text("Publicar y Salir"),
          ),
        ),
      ],
    );
  }

  bool _publicar(BuildContext context) {
    if (!_formKey.currentState!.validate() ||
        _finalLoc == null ||
        _imagenesBytes.isEmpty) {
      if (_finalLoc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Recuerda que tienes que confirmar una ubicación antes de publicar",
            ),
          ),
        );
      } else if (_imagenesBytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Debes seleccionar al menos una imagen"),
          ),
        );
      }
      return false;
    }

    // Validación especial para etiquetas: permite omitir en segundo intento
    if (_selectedTags.isEmpty && !_intentoPublicarSinEtiquetas) {
      setState(() {
        _intentoPublicarSinEtiquetas = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Seleccione una etiqueta. Presiona nuevamente para publicar sin etiquetas.",
          ),
          duration: Duration(seconds: 4),
        ),
      );
      return false;
    }

    // Resetear el flag si se publica exitosamente
    _intentoPublicarSinEtiquetas = false;

    Reporte r = _recolectarCambios();
    ReportHandler.submitPeticion(widget.uuid, r);
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
      _encontrado,
      widget.reporte.tipo,
      _finalLoc!,
      imagenesBytes: _imagenesBytes,
      etiquetas: _selectedTags,
    );
  }

  Future<void> _openTagEditor() async {
    TagType? selected = _selectedTags.firstOrNull?.tipo;
    final Map<TagType, TagColor> currentColors = {
      for (var t in _selectedTags) t.tipo: t.color,
    };

    final result = await showDialog<List<Tag>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccione la categoría'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: TagType.values.map((t) {
                    return RadioListTile<TagType>(
                      title: Text(t.name),
                      value: t,
                      groupValue: selected,
                      onChanged: (v) => setState(() {
                        selected = v;
                      }),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final List<Tag> out = selected != null
                    ? [
                        Tag(
                          selected!,
                          currentColors[selected] ?? TagColor.blanco,
                        ),
                      ]
                    : <Tag>[];
                Navigator.pop(context, out);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        _selectedTags = result;
        // Resetear el flag cuando se modifican las etiquetas
        if (_selectedTags.isNotEmpty) {
          _intentoPublicarSinEtiquetas = false;
        }
      });
    }
  }

  Future<void> _openColorEditor() async {
    if (_selectedTags.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No hay etiquetas'),
          content: const Text(
            'Selecciona primero las categorías y luego asigna colores.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final Map<TagType,TagColor> colors = {
      for (var t in _selectedTags) t.tipo: t.color,
    };

    Future<TagColor?> pickColor(BuildContext ctx, String tag) async {
      final res = await showDialog<TagColor>(
        context: ctx,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Elegir color para "$tag"'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: TagColor.values.map((color) {
                  return ListTile(
                    title: Text(color.name),
                    onTap: () => Navigator.pop(ctx, color),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );
      return res;
    }

    final result = await showDialog<List<Tag>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar color'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _selectedTags.map((t) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: colors[t.tipo]?.color ?? Colors.white,
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.tipo.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          t.tipo.colorable
                              ? TextButton(
                                  onPressed: () async {
                                    final chosen = await pickColor(
                                      context,
                                      t.tipo.name,
                                    );
                                    if (chosen != null)
                                      setState(() => colors[t.tipo] = chosen);
                                  },
                                  child: const Text('Cambiar color'),
                                )
                              : TextButton(
                                  onPressed: null,
                                  child: const Text('No aplicable'),
                                ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final out = _selectedTags
                    .map((t) => Tag(t.tipo, colors[t.tipo] ?? t.color))
                    .toList();
                Navigator.pop(context, out);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedTags = result;
      });
    }
  }
}
