part of 'report_display.dart';

class _DescripcionReporte extends StatelessWidget {
  const _DescripcionReporte({required this.controller, required this.editable});
  final TextEditingController controller;

  final bool editable;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: null,
      maxLines: 100,
      readOnly: !editable,
      controller: controller,
      decoration: InputDecoration(
        hintText: "Escribe una descripción del objeto perdido",
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 0.0),
        ),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? "Escribe una descripción valida" : null,
    );
  }
}
