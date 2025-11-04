import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';

class CambioContactos extends StatefulWidget {
  const CambioContactos({super.key});

  @override
  State<CambioContactos> createState() => _CambioContactosState();
}

class _CambioContactosState extends State<CambioContactos> {
  final GlobalKey<FormState> _formKey24 = GlobalKey();
  final TextEditingController _usernameController = TextEditingController(
    text: SessionHandler.nombreUsuario,
  );
  final TextEditingController _correoController = TextEditingController(
    text: SessionHandler.correo,
  );
  final TextEditingController _numeroController = TextEditingController(
    text: SessionHandler.numero,
  );
  final TextEditingController _miscelaneoController = TextEditingController(
    text: SessionHandler.miscelaneo,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(
            "Modificar información de contacto",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            flex: 7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      children: [
                        const Text("Foto", style: TextStyle(fontSize: 16)),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.asset(
                              "assets/trial.jpeg",
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ),
                        Expanded(flex: 1, child: Container()),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            "Guardar cambios",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  if (_formKey24.currentState!.validate()) {
                                    SessionHandler.cambiarUsuario(
                                      SessionHandler.uuid,
                                      Usuario(
                                        nombreUsuario: _usernameController.text,
                                        correo: _correoController.text,
                                        numero: _numeroController.text,
                                        miscelaneo: _miscelaneoController.text,
                                        isAdmin: SessionHandler.isAdmin,
                                      ),
                                    );
                                  }
                                },
                                child: Icon(Icons.save),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Form(
                    key: _formKey24,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            "Nombre de usuario",
                            textAlign: TextAlign.left,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 100.0),
                            child: TextFormField(
                              controller: _usernameController,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Escribe un nombre de usuario"
                                  : null,
                            ),
                          ),
                          const Text("Correo Electronico"),
                          Padding(
                            padding: const EdgeInsets.only(right: 100.0),
                            child: TextFormField(
                              controller: _correoController,
                              validator: (v) =>
                                  RegExp(
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
                                  ).hasMatch(v ?? "")
                                  ? null
                                  : "Ingresa un correo electronico valido",
                            ),
                          ),
                          const Text("Numero de telefono (+## # #### ####)"),
                          Padding(
                            padding: const EdgeInsets.only(right: 100),
                            child: TextFormField(
                              controller: _numeroController,
                              validator: (v) =>
                                  v == null || v.isEmpty //TODO: poner un validador en esto
                                  ? "Ingresa un numero valido"
                                  : null,
                            ),
                          ),
                          const Text("Informacion de contacto miscelanea"),
                          Padding(
                            padding: const EdgeInsets.only(right: 100),
                            child: TextFormField(
                              controller: _miscelaneoController,
                              maxLines: 10,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
