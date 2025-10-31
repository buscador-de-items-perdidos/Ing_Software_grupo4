part of 'report_display.dart';

class _CampoTitulo extends StatelessWidget {
  const _CampoTitulo({required this.controller, required this.editable});

  final TextEditingController controller;

  final bool editable;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (v) => v == null || v.isEmpty ? "Ingresa un título" : null,
      controller: controller,
      readOnly: !editable,
      decoration: InputDecoration(
        hintText: "Ingresa un título",
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.0),
        ),
      ),
    );
  }
}
