import 'package:flutter_test/flutter_test.dart';
import 'package:ing_software_grupo4/modelos/filter.dart';

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
        {'electrónico', 'urgente'},
        {},
        {},
      );

      expect(filter.activeTagFilters.length, 2);
      expect(filter.activeTagFilters.contains('electrónico'), true);
      expect(filter.activeTagFilters.contains('urgente'), true);
    });

    test('Crear filtro con colores activos', () {
      const filter = Filter(
        '',
        false,
        {},
        {'rojo', 'azul', 'verde'},
        {},
      );

      expect(filter.activeColorFilters.length, 3);
      expect(filter.activeColorFilters.contains('rojo'), true);
      expect(filter.activeColorFilters.contains('azul'), true);
      expect(filter.activeColorFilters.contains('verde'), true);
    });

    test('Crear filtro con tipos activos', () {
      const filter = Filter(
        '',
        false,
        {},
        {},
        {'perdido', 'encontrado'},
      );

      expect(filter.activeTipoFilters.length, 2);
      expect(filter.activeTipoFilters.contains('perdido'), true);
      expect(filter.activeTipoFilters.contains('encontrado'), true);
    });

    test('Crear filtro con múltiples criterios', () {
      const filter = Filter(
        'celular',
        true,
        {'electrónico'},
        {'azul'},
        {'perdido'},
        soloPendientes: true,
      );

      expect(filter.input, 'celular');
      expect(filter.soloMisReportes, true);
      expect(filter.soloPendientes, true);
      expect(filter.activeTagFilters.contains('electrónico'), true);
      expect(filter.activeColorFilters.contains('azul'), true);
      expect(filter.activeTipoFilters.contains('perdido'), true);
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
