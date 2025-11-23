import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ing_software_grupo4/mostrar_reporte.dart';
import 'package:latlong2/latlong.dart';

Color? hexToColor(String? hex) {
  if (hex == null) return null;
  final cleaned = hex.replaceAll('#', '');
  final value = int.parse(
    cleaned.length == 6 ? 'FF$cleaned' : cleaned,
    radix: 16,
  );
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

///Esta clase solo sirve para mostrar reportes en movil, si se quiere editar un reporte, mejor usar ReportDisplay
class ReportDisplayMovil extends StatefulWidget {
  final Reporte reporte;
  final String uuid;
  Usuario get usuario => SessionHandler.getUsuario(reporte.autor);
  const ReportDisplayMovil(this.reporte, this.uuid, {super.key});

  ReportDisplayMovil.vacio(this.uuid, {super.key, required TipoReporte tipo})
    : reporte = Reporte.vacio(tipo, SessionHandler.uuid);

  @override
  State<StatefulWidget> createState() {
    return _ReportDisplayMovilState();
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

class _ReportDisplayMovilState extends State<ReportDisplayMovil> {
  late bool _resuelto = widget.reporte.encontrado;

  late final LatLng _loc =
      widget.reporte.ubicacion ?? LatLng(-36.8288323, -73.0372646);
  late final List<Uint8List> _imagenesBytes = List<Uint8List>.from(
    widget.reporte.imagenesBytes,
  );
  late final List<Tag> _selectedTags = List<Tag>.from(widget.reporte.etiquetas);

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async => _editarReporte(context),
        child: const Icon(Icons.edit_document),
        tooltip: "Editar reporte",
      ),
      body: CustomScrollView(
        slivers: [
          _Barra(
            imagenesBytes: _imagenesBytes,
            pageController: _pageController,
            titulo: widget.reporte.titulo,
          ),

          // Tags section
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.reporte.etiquetas.length,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Chip(
                          avatar: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                              color: hexToColor(
                                colorNameToHex[widget
                                        .reporte
                                        .etiquetas[i]
                                        .colorName] ??
                                    '#000000',
                              ),
                            ),
                          ),
                          label: Text(widget.reporte.etiquetas[i].nombre),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Title section
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    widget.reporte.titulo,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),

          // Type section
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "Objeto ${widget.reporte.tipo.name}",
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),

          // Divider
          const SliverToBoxAdapter(child: Divider(indent: 30, endIndent: 30)),

          // Details
          SliverToBoxAdapter(child: DetallesReporte(reporte: widget.reporte)),

          // Divider
          const SliverToBoxAdapter(child: Divider(indent: 30, endIndent: 30)),

          // Resolution toggle (conditional)
          if (widget.reporte.autor == SessionHandler.uuid ||
              SessionHandler.getUsuario(widget.reporte.autor).isAdmin)
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              sliver: SliverToBoxAdapter(
                child: Card(
                  child: SwitchListTile(
                    title: const Text('Marcar reporte como resuelto'),
                    subtitle: Text(_resuelto ? 'Resuelto' : 'No resuelto'),
                    value: _resuelto,
                    onChanged: (bool value) {
                      setState(() => _resuelto = value);
                      _actualizarEstadoResuelto(value);
                    },
                  ),
                ),
              ),
            ),

          // Map section
          SliverToBoxAdapter(
            child: AspectRatio(aspectRatio: 3, child: mapaUdec()),
          ),

          // Description header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  "Descripción",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
              ),
            ),
          ),

          // Description content
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.reporte.descripcion,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
          ),

          // Contact information
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: _DatosContacto(
                  usuario: SessionHandler.getUsuario(widget.reporte.autor),
                ),
              ),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  void _actualizarEstadoResuelto(bool encontrado) {
    ReportHandler.estadoObjeto(widget.uuid, encontrado);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          encontrado
              ? 'Reporte marcado como resuelto'
              : 'Reporte marcado como no resuelto',
        ),
      ),
    );
  }

  Widget mapaUdec() {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(initialCenter: _loc, initialZoom: 16),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.perdidoudec.app',
            ),
            MarkerLayer(
              markers: [
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
      ],
    );
  }

  void _editarReporte(BuildContext context) async {
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
        builder: (_) => mostrarReporte(
          editarRevisionEnCola
              ? ReportHandler.getPeticion(widget.uuid)!
              : widget.reporte,
          widget.uuid,
          modo: Modo.Editar,
        ),
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({
    required List<Uint8List> imagenesBytes,
    required PageController pageController,
    required this.titulo,
  }) : _imagenesBytes = imagenesBytes,
       _pageController = pageController;

  final String titulo;
  final List<Uint8List> _imagenesBytes;
  final PageController _pageController;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      foregroundColor: Theme.of(context).scaffoldBackgroundColor,
      backgroundColor: Theme.of(context).primaryColor,
      pinned: true,
      stretch: true,
      expandedHeight: 450,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          return FlexibleSpaceBar(
            centerTitle: true,
            title: constraints.biggest.height <= kToolbarHeight
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: Text(
                      titulo,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                )
                : null,
            stretchModes: [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
              StretchMode.fadeTitle,
            ],
            background: _GaleriaImagenes(
              imagenesBytes: _imagenesBytes,
              controller: _pageController,
            ),
          );
        },
      ),
    );
  }
}

class _GaleriaImagenes extends StatefulWidget {
  const _GaleriaImagenes({
    required this.imagenesBytes,
    required this.controller,
  });
  final List<Uint8List> imagenesBytes;
  final PageController controller;

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 12,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Datos de contacto",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
        ),
      ),
    );
  }
}

class DetallesReporte extends StatelessWidget {
  const DetallesReporte({
    super.key,
    required this.reporte,
    this.editable = false,
  });

  final Reporte reporte;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Detalles del reporte",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          Text(
            "Autor: ${SessionHandler.nombreUsuario}",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
            textAlign: TextAlign.center,
          ),
          Text(
            "Fecha: ${reporte.fecha.day.toString().padLeft(2, '0')}/${reporte.fecha.month.toString().padLeft(2, '0')}/${reporte.fecha.year}",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
