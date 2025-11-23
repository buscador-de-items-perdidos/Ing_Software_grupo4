class Filter {
  final String input;
  final bool soloMisReportes;
  final Set<String> activeTagFilters;
  final Set<String> activeColorFilters;
  final Set<String> activeTipoFilters;

  const Filter(
    this.input,
    this.soloMisReportes,
    this.activeTagFilters,
    this.activeColorFilters,
    this.activeTipoFilters,
  );
}
