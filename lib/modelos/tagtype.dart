// ignore_for_file: constant_identifier_names

enum TagType {
  Celular('Celular', true),
  Notebook('Notebook / Laptop', true),
  Tablet('Tablet', true),
  Audifonos('Audífonos', true),
  Cargador('Cargador / Cable', true),
  RelojInteligente('Reloj inteligente', true),
  Lentes('Lentes', true),
  Llaves('Llaves', true),
  Billetera('Billetera', true),
  Cartera('Cartera', true),
  Paraguas('Paraguas', true),
  Mochila('Mochila', true),
  Estuche('Estuche', true),
  Documentos('Documentos', false),
  Cedula('Cédula', false),
  Pasaporte('Pasaporte', false),
  TarjetaBancaria('Tarjeta bancaria', false),
  LicenciaDeConducir('Licencia de conducir', false),
  Credencial('Credencial universitaria / laboral', false),
  Poleron('Polerón / Chaqueta', true),
  Gorro('Gorro', true),
  Polera('Polera', true),
  Pantalones('Pantalones', true),
  Zapatos('Zapatos / Zapatillas', true),
  Bicicleta('Bicicleta', true),
  Guantes('Guantes', true),
  Botella('Botella', true),
  Termo('Termo', true),
  Llaveros('Llaveros', true),
  CuadernosLibretas('Cuadernos / Libretas', true),
  Otro('Otro', true);

  final String name;
  final bool colorable;

  const TagType(this.name, this.colorable);
}
