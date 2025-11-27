import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/modelos/filter.dart';
import 'package:ing_software_grupo4/modelos/tagcolor.dart';
import 'package:ing_software_grupo4/modelos/tagtype.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';

void main() {
  group('Filter Model Tests', () {
    test('Crear filtro básico sin filtros activos', () {
      const filter = Filter(
        'laptop',
        false,
        {},
        {},
        {},
      );

      expect(filter.input, 'laptop');
      expect(filter.soloMisReportes, false);
      expect(filter.soloPendientes, false);
      expect(filter.activeTagFilters.isEmpty, true);
      expect(filter.activeColorFilters.isEmpty, true);
      expect(filter.activeTipoFilters.isEmpty, true);
    });

    test('Crear filtro con solo mis reportes', () {
      const filter = Filter(
        '',
        true,
        {},
        {},
        {},
      );

      expect(filter.soloMisReportes, true);
      expect(filter.input, '');
    });

    test('Crear filtro con solo pendientes', () {
      const filter = Filter(
        '',
        false,
        {},
        {},
        {},
        soloPendientes: true,
      );

      expect(filter.soloPendientes, true);
    });

    test('Crear filtro con tags activos', () {
      const filter = Filter(
        '',
        false,
        {TagType.RelojInteligente, TagType.Cargador},
        {},
        {},
      );

      expect(filter.activeTagFilters.length, 2);
      expect(filter.activeTagFilters.contains(TagType.RelojInteligente), true);
      expect(filter.activeTagFilters.contains(TagType.Cargador), true);
    });

    test('Crear filtro con colores activos', () {
      const filter = Filter(
        '',
        false,
        {},
        {TagColor.rojo, TagColor.azul, TagColor.verde},
        {},
      );

      expect(filter.activeColorFilters.length, 3);
      expect(filter.activeColorFilters.contains(TagColor.rojo), true);
      expect(filter.activeColorFilters.contains(TagColor.azul), true);
      expect(filter.activeColorFilters.contains(TagColor.verde), true);
    });

    test('Crear filtro con tipos activos', () {
      const filter = Filter(
        '',
        false,
        {},
        {},
        {TipoReporte.perdido, TipoReporte.encontrado},
      );

      expect(filter.activeTipoFilters.length, 2);
      expect(filter.activeTipoFilters.contains(TipoReporte.perdido), true);
      expect(filter.activeTipoFilters.contains(TipoReporte.encontrado), true);
    });

    test('Crear filtro con múltiples criterios', () {
      const filter = Filter(
        'celular',
        true,
        {TagType.Celular},
        {TagColor.azul},
        {TipoReporte.perdido},
        soloPendientes: true,
      );

      expect(filter.input, 'celular');
      expect(filter.soloMisReportes, true);
      expect(filter.soloPendientes, true);
      expect(filter.activeTagFilters.contains(TagType.Celular), true);
      expect(filter.activeColorFilters.contains(TagColor.azul), true);
      expect(filter.activeTipoFilters.contains(TipoReporte.perdido), true);
    });

    test('Filtro vacío (sin criterios)', () {
      const filter = Filter(
        '',
        false,
        {},
        {},
        {},
      );

      expect(filter.input.isEmpty, true);
      expect(filter.soloMisReportes, false);
      expect(filter.soloPendientes, false);
      expect(filter.activeTagFilters.isEmpty, true);
      expect(filter.activeColorFilters.isEmpty, true);
      expect(filter.activeTipoFilters.isEmpty, true);
    });
  });
}
