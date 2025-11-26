import 'package:ing_software_grupo4/modelos/tagcolor.dart';
import 'package:ing_software_grupo4/modelos/tagtype.dart';

class Tag {
  const Tag(this.tipo, this.color);

  final TagType tipo;
  // nombre del color en texto, por ejemplo: 'rojo', 'azul'
  final TagColor color;

  @override
  String toString() => 'Tag(nombre: ${tipo.name}, colorName: ${color.color.toARGB32()})';

  @override
  bool operator ==(Object other) {
    if (other is! Tag) return false;
    return color == other.color && tipo == other.tipo;
  }

  @override
  int get hashCode => tipo.hashCode ^ color.hashCode;
}
