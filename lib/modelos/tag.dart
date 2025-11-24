class Tag {
  const Tag(this.nombre, this.colorName);

  final String nombre;
  // nombre del color en texto, por ejemplo: 'rojo', 'azul'
  final String colorName;

  @override
  String toString() => 'Tag(nombre: $nombre, colorName: $colorName)';

  @override
  bool operator ==(Object other) {
    if (other is! Tag) return false;
    return colorName == other.colorName && nombre == other.nombre;
  }

  @override
  int get hashCode => nombre.hashCode ^ colorName.hashCode;
}
