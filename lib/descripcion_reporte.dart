part of 'report_display.dart';

class _DescripcionReporte extends StatelessWidget {
  const _DescripcionReporte({required this.controller,required this.tipo, required this.editable});
  final TextEditingController controller;

  final bool editable;

  final TipoReporte tipo;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: null,
      maxLines: 100,
      readOnly: !editable,
      controller: controller,
      decoration: InputDecoration(
        hintText: tipo == TipoReporte.encontrado ? "Escribe una descripción del objeto que encontraste" : "Escribe una descripción del objeto perdido",
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 0.0),
        ),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? "Escribe una descripción valida" : null,
    );
  }
}
