import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

part 'campo_titulo.dart';
part 'descripcion_reporte.dart';

Color hexToColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  final value = int.parse(cleaned.length == 6 ? 'FF$cleaned' : cleaned, radix: 16);
  return Color(value);
}

const Map<String, String> colorNameToHex = {
  'blanco': '#FFFFFF',
  'negro': '#000000',
  'rojo': '#FF0000',
  'verde': '#00FF00',
  'azul': '#0000FF',
  'amarillo': '#FFFF00',
  'naranja': '#FFA500',
  'morado': '#800080',
  'rosa': '#FFC0CB',
  'celeste': '#87CEEB',
  'café': '#8B4513',
  'gris': '#808080',
  'turquesa': '#40E0D0',
  'lima': '#00FF7F',
  'cian': '#00FFFF',
  'fucsia': '#FF00FF',
  'beige': '#F5F5DC',
  'chocolate': '#D2691E',
  'dorado': '#FFD700',
  'plateado': '#C0C0C0',
  'azul_marino': '#000080',
  'burdeos': '#800020',
  'Otro': '#FFFFFF',
};

String prettifyColorName(String key) {
  return key
      .split('_')
      .map((s) => s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1)))
      .join(' ');
}

String _normalizeTagName(String s) {
  var t = s.toLowerCase();
  t = t.replaceAll(RegExp(r'[áàäâ]'), 'a');
  t = t.replaceAll(RegExp(r'[éèëê]'), 'e');
  t = t.replaceAll(RegExp(r'[íìïî]'), 'i');
  t = t.replaceAll(RegExp(r'[óòöô]'), 'o');
  t = t.replaceAll(RegExp(r'[úùüû]'), 'u');
  t = t.replaceAll(RegExp(r'[ñ]'), 'n');
  t = t.replaceAll(RegExp(r'[ç]'), 'c');
  t = t.replaceAll(RegExp(r'[^a-z0-9]'), '');
  return t;
}

bool _isColorable(String tagName) {
  const blocked = {
    'documentos',
    'cedula',
    'pasaporte',
    'licenciadeconducir',
    'credencial',
    'credencialuniversitarialaboral',
    'tarjetabancaria',
  };
  return !blocked.contains(_normalizeTagName(tagName));
}

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

class _MemoryImageWithFallback extends StatelessWidget {
  const _MemoryImageWithFallback(this.bytes, {this.fit = BoxFit.cover});

  final Uint8List bytes;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      bytes,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset('assets/trial.png', fit: fit);
      },
    );
  }
}

class _ReportDisplayState extends State<ReportDisplay> {
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
  late List<Uint8List> _imagenesBytes = List<Uint8List>.from(
    widget.reporte.imagenesBytes,
  );
  late List<Tag> _selectedTags = List<Tag>.from(widget.reporte.etiquetas);

  final List<String> _availableTags = [
    'Celular',
    'Notebook / Laptop',
    'Tablet',
    'Audífonos',
    'Cargador / Cable',
    'Reloj inteligente',
    'Lentes',
    'Llaves',
    'Billetera',
    'Cartera',
    'Paraguas',
    'Mochila',
    'Estuche',
    'Documentos',
    'Cédula',
    'Pasaporte',
    'Tarjeta bancaria',
    'Licencia de conducir',
    'Credencial universitaria / laboral',
    'Polerón / Chaqueta',
    'Gorro',
    'Polera',
    'Pantalones',
    'Zapatos / Zapatillas',
    'Guantes',
    'Botella',
    'Termo',
    'Llaveros',
    'Cuadernos / Libretas',
    'Otro',
  ];
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
                    editable: widget.modo == Modo.Editar,
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
                    editable: widget.modo == Modo.Editar,
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      _DatosContacto(usuario: widget.usuario),
                      const SizedBox(height: 24),
                      DetallesReporte(
                        reporte: widget.reporte,
                        selectedTags: _selectedTags,
                        editable: widget.modo == Modo.Editar,
                        onEditTags: _openTagEditor,
                        onEditColors: _openColorEditor,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              if (widget.modo == Modo.Ver &&
                  widget.reporte.autor == SessionHandler.uuid)
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SwitchListTile(
                        title: const Text('Marcar como encontrado'),
                        subtitle: Text(
                          _encontrado ? 'Encontrado' : 'Pendiente',
                        ),
                        value: _encontrado,
                        onChanged: (bool value) {
                          setState(() => _encontrado = value);
                          _actualizarEstadoEncontrado(value);
                        },
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  child: SizedBox(
                    height: 360,
                    child: mapaUdec(),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: switch (widget.modo) {
                    Modo.Editar => _crearBotonesGuardado(context),
                    Modo.Ver => _crearBotonEditar(context),
                    Modo.Revisar => _crearBotonesPublicacion(context),
                  },
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
void _actualizarEstadoEncontrado(bool encontrado) {
    ReportHandler.estadoObjeto(widget.uuid, encontrado);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          encontrado
              ? 'Reporte marcado como encontrado'
              : 'Reporte marcado como pendiente',
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
        _imagenesBytes.isEmpty ||
        _selectedTags.isEmpty) {
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
      } else if (_selectedTags.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Debes seleccionar al menos una etiqueta"),
          ),
        );
      }
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
      _encontrado,
      widget.reporte.tipo,
      _finalLoc!,
      imagenesBytes: _imagenesBytes,
      etiquetas: _selectedTags,
    );
  }

  Future<void> _openTagEditor() async {
    String? selected = _selectedTags.isNotEmpty ? _selectedTags.first.nombre : null;
    final Map<String, String> currentColors = {for (var t in _selectedTags) t.nombre: t.colorName};

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
                  children: _availableTags.map((t) {
                    return RadioListTile<String>(
                      title: Text(t),
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
                final List<Tag> out = selected != null ? [Tag(selected!, currentColors[selected] ?? 'blanco')] : <Tag>[];
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

  Future<void> _openColorEditor() async {
    if (_selectedTags.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No hay etiquetas'),
          content: const Text('Selecciona primero las categorías y luego asigna colores.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }

    final Map<String, String> colors = {for (var t in _selectedTags) t.nombre: t.colorName};
    final List<String> presetColorNames = colorNameToHex.keys.toList();

    Future<String?> _pickColor(BuildContext ctx, String tag) async {
      final res = await showDialog<String>(
        context: ctx,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Elegir color para "$tag"'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                  children: presetColorNames.map((name) {
                  return ListTile(
                    title: Text(prettifyColorName(name)),
                    onTap: () => Navigator.pop(ctx, name),
                  );
                }).toList(),
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar'))],
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
                              color: hexToColor(colorNameToHex[colors[t.nombre]!] ?? colorNameToHex['blanco']!),
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _isColorable(t.nombre)
                              ? TextButton(
                                  onPressed: () async {
                                    final chosen = await _pickColor(context, t.nombre);
                                    if (chosen != null) setState(() => colors[t.nombre] = chosen);
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                final out = _selectedTags.map((t) => Tag(t.nombre, colors[t.nombre] ?? t.colorName)).toList();
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
            child: _MemoryImageWithFallback(
              widget.imagenesBytes[i],
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (widget.editable && widget.onDelete != null)
          Positioned(
            top: 8,
            left: 8,
            child: Tooltip(
              message: 'Eliminar imagen',
              child: IconButton.filled(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.black54),
                ),
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
                child: _MemoryImageWithFallback(
                  widget.images[i],
                  fit: BoxFit.contain,
                ),
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
  const DetallesReporte({
    super.key,
    required this.reporte,
    this.selectedTags = const [],
    this.editable = false,
    this.onEditTags,
    this.onEditColors,
  });

  final Reporte reporte;
  final List<Tag> selectedTags;
  final bool editable;
  final VoidCallback? onEditTags;
  final VoidCallback? onEditColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 6),
        Text(
          "Detalles del reporte",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          "Autor: ${SessionHandler.nombreUsuario}",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          "Tipo: Objeto ${reporte.tipo.name}",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
          textAlign: TextAlign.center,
        ),
        Text(
          "Fecha: ${reporte.fecha.day.toString().padLeft(2,'0')}/${reporte.fecha.month.toString().padLeft(2,'0')}/${reporte.fecha.year}",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Builder(builder: (context) {
          final cats = selectedTags.map((t) => t.nombre).join(', ');
          final colorSet = selectedTags.map((t) => t.colorName).where((c) => c != 'blanco').toSet();
          final colorsPretty = colorSet.map((c) => prettifyColorName(c)).join(', ');
          return Column(
            children: [
              if (cats.isNotEmpty)
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Categoría: $cats',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
              if (colorsPretty.isNotEmpty) const SizedBox(height: 6),
              if (colorsPretty.isNotEmpty)
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Color: $colorsPretty',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 2),
        if (editable)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 6,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                  onPressed: onEditTags,
                  icon: const Icon(Icons.label_outline, size: 18),
                  label: const Text('Seleccionar Categoria'),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                  onPressed: onEditColors,
                  icon: const Icon(Icons.color_lens_outlined, size: 18),
                  label: const Text('Seleccionar Color'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
