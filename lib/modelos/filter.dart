import 'package:ing_software_grupo4/modelos/tagcolor.dart';
import 'package:ing_software_grupo4/modelos/tagtype.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';

class Filter {
  final String input;
  final bool soloMisReportes;
  final bool soloPendientes;
  final Set<TagType> activeTagFilters;
  final Set<TagColor> activeColorFilters;
  final Set<TipoReporte> activeTipoFilters;

  const Filter(
    this.input,
    this.soloMisReportes,
    this.activeTagFilters,
    this.activeColorFilters,
    this.activeTipoFilters, {
    this.soloPendientes = false,
  });
}
