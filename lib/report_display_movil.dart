import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ing_software_grupo4/__datos_contacto.dart';
import 'package:ing_software_grupo4/__galeria_imagenes.dart';
import 'package:ing_software_grupo4/detalles_reporte.dart';
import 'package:ing_software_grupo4/handlers/report_handler.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';
import 'package:ing_software_grupo4/pantallas_dependientes.dart';
import 'package:ing_software_grupo4/tarjeta_reporte.dart';
import 'package:latlong2/latlong.dart';

///Clase estandar para mostrar reportes, sin poder editarlos
class ReportDisplay extends StatefulWidget {
  final Reporte reporte;
  final String uuid;

  final Modo modo;
  Usuario get usuario => SessionHandler.getUsuario(reporte.autor);
  const ReportDisplay(this.reporte, this.uuid, this.modo, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _ReportDisplayState();
  }
}

class _ReportDisplayState extends State<ReportDisplay> {
  late bool _resuelto = widget.reporte.encontrado;

  late final LatLng _loc =
      widget.reporte.ubicacion ?? LatLng(-36.8288323, -73.0372646);
  late final List<Uint8List> _imagenesBytes = List<Uint8List>.from(
    widget.reporte.imagenesBytes,
  );

  final PageController _pageController = PageController();

  bool get isLandscape {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width > mediaQuery.size.height;
  }

  bool get isPortrait => !isLandscape;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          children: [
            Container(
              height: 100,
              color: Theme.of(context).primaryColor,
              child: Center(
                child: Text(
                  "Similitudes",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            for (String reporte in ReportHandler.getSimilares(widget.uuid))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: TarjetaReporte(
                    uuid: reporte,
                    modo: Modo.Ver,
                    pendiente: false,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: widget.modo == Modo.Revisar
          ? _crearBotonesRevisar()
          : FloatingActionButton(
              onPressed: () async => _editarReporte(context),
              tooltip: "Editar reporte",
              child: const Icon(Icons.edit_document),
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
                              color: widget.reporte.etiquetas[i].color.color,
                            ),
                          ),
                          label: Text(widget.reporte.etiquetas[i].tipo.name),
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

          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverToBoxAdapter(
              child: isLandscape
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 30.0,
                              horizontal: 8,
                            ),
                            child: DetallesReporte(reporte: widget.reporte),
                          ),
                        ),
                        DatosContacto(
                          usuario: SessionHandler.getUsuario(
                            widget.reporte.autor,
                          ),
                        ),
                      ],
                    )
                  : DetallesReporte(reporte: widget.reporte),
            ),
          ),

          // Divider
          const SliverToBoxAdapter(child: Divider(indent: 30, endIndent: 30)),

          // Resolution toggle (conditional)
          if ((widget.reporte.autor == SessionHandler.uuid ||
                  SessionHandler.isAdmin) &&
              !SessionHandler.getPendientes.contains(widget.uuid))
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
          if (isPortrait)
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverToBoxAdapter(
                child: DatosContacto(
                  usuario: SessionHandler.getUsuario(widget.reporte.autor),
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

  Widget _crearBotonesRevisar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FloatingActionButton(
          heroTag: null,
          onPressed: () {
            ReportHandler.acceptPeticion(widget.uuid);
            Navigator.pop(context);
          },
          child: Icon(Icons.check),
        ),
        FloatingActionButton(
          heroTag: null,
          onPressed: () {
            ReportHandler.rejectPeticion(widget.uuid);
            Navigator.pop(context, true);
          },
          child: Icon(Icons.delete),
        ),
      ],
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
            background: GaleriaImagenes(
              imagenesBytes: _imagenesBytes,
              controller: _pageController,
            ),
          );
        },
      ),
    );
  }
}
