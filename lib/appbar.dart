import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/report_display.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:uuid/uuid.dart';

AppBar appbar(BuildContext context) => AppBar(
  iconTheme: IconThemeData(color: Theme.of(context).scaffoldBackgroundColor),
  leading: Builder(
    builder: (context) => IconButton(
      icon: Icon(Icons.menu),
      onPressed: () => Scaffold.of(context).openDrawer(),
    ),
  ),
  titleSpacing: 0,
  title: Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {},
          child: Text(
            "Objetos Perdidos",
            style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        BotonPublicar(),
      ],
    ),
  ),
  backgroundColor: Theme.of(context).primaryColor,
);

class BotonPublicar extends StatelessWidget {
  const BotonPublicar({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).primaryColor,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () => showDialog(
        barrierColor: Colors.black26,
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          alignment: Alignment.topRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 340,
              maxHeight: 300,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Tipo de reporte",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _BotonMenu(tipo: TipoReporte.perdido),
                    const SizedBox(height: 10),
                    _BotonMenu(tipo: TipoReporte.encontrado),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 6),
          Text(
            "Publicar",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonMenu extends StatelessWidget {
  const _BotonMenu({required this.tipo});

  final TipoReporte tipo;

  @override
  Widget build(BuildContext context) {
    String titulo;
    String descripcion;
    IconData icono;
    Color color;

    switch (tipo) {
      case TipoReporte.perdido:
        titulo = "Perdido";
        descripcion = "Publica un objeto que has perdido";
        icono = Icons.search;
        color = Theme.of(context).primaryColor;
      case TipoReporte.encontrado:
        titulo = "Encontrado";
        descripcion = "Publica un objeto que has encontrado";
        icono = Icons.check_circle_outline;
        color = Theme.of(context).primaryColor.withOpacity(0.8);
      case TipoReporte.administracion:
        titulo = "Anuncio";
        descripcion = "Publica anuncios de administración";
        icono = Icons.announcement_outlined;
        color = Theme.of(context).primaryColor.withOpacity(0.6);
    }
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
        color: Theme.of(context).primaryColor.withOpacity(0.05),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  final uuid = Uuid().v7();
                  return ReportEditor.vacio(uuid, tipo: tipo);
                },
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icono,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        descripcion,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
