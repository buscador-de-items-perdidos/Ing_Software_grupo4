import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';

class DatosContacto extends StatelessWidget {
  const DatosContacto({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 12,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Datos de contacto",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text("Correo Electronico: ${usuario.correo}"),
            Text("Numero de telefono: ${usuario.numero}"),
            Text(
              "Detalles adicionales",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(usuario.miscelaneo, textAlign: TextAlign.justify),
            SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

