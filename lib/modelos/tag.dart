class Tag {
  const Tag(this.nombre, this.colorName);

  final String nombre;
  // nombre del color en texto, por ejemplo: 'rojo', 'azul'
  final String colorName;

  @override
  String toString() => 'Tag(nombre: $nombre, colorName: $colorName)';
}
