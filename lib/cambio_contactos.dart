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
  late final Usuario usuarioActual = SessionHandler.usuarioActual!;
  late final TextEditingController _usernameController = TextEditingController(
    text: usuarioActual.nombreUsuario,
  );
  late final TextEditingController _correoController = TextEditingController(
    text: usuarioActual.correo,
  );
  late final TextEditingController _numeroController = TextEditingController(
    text: usuarioActual.numero,
  );
  late final TextEditingController _miscelaneoController =
      TextEditingController(text: usuarioActual.miscelaneo);
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
                              "assets/trial.png",
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
                                      nombreUsuario: _usernameController.text,
                                      correo: _correoController.text,
                                      numero: _numeroController.text,
                                      miscelaneo: _miscelaneoController.text,
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
                          // Información del tipo de usuario
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(
                              right: 100,
                              bottom: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      SessionHandler
                                                  .usuarioActual
                                                  ?.tipoUsuario ==
                                              TipoUsuario.miembroUniversidad
                                          ? Icons.school
                                          : Icons.person_outline,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      SessionHandler
                                                  .usuarioActual
                                                  ?.tipoUsuario ==
                                              TipoUsuario.miembroUniversidad
                                          ? 'Miembro de la Universidad'
                                          : 'Usuario Externo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                if (SessionHandler.usuarioActual?.tipoUsuario ==
                                        TipoUsuario.miembroUniversidad &&
                                    SessionHandler.usuarioActual?.matricula !=
                                        null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Matrícula: ${SessionHandler.usuarioActual?.matricula}',
                                    style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu correo';
                                }
                                if (!value.contains('@') ||
                                    !value.contains('.')) {
                                  return 'Correo inválido';
                                }
                                // Validar correo UdeC para miembros de la universidad
                                if (usuarioActual.tipoUsuario ==
                                    TipoUsuario.miembroUniversidad) {
                                  if (!value.trim().toLowerCase().endsWith(
                                    '@udec.cl',
                                  )) {
                                    return 'Debes usar un correo @udec.cl';
                                  }
                                }
                                if ((value.trim() != SessionHandler.correo) &&
                                    !SessionHandler.isEmailAvailable(
                                      value.trim(),
                                    )) {
                                  return 'Este correo ya está registrado';
                                }
                                return null;
                              },
                            ),
                          ),
                          const Text("Numero de telefono (+## # #### ####)"),
                          Padding(
                            padding: const EdgeInsets.only(right: 100),
                            child: TextFormField(
                              controller: _numeroController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu teléfono';
                                }
                                // Validar formato +## # #### ####
                                final phoneRegex = RegExp(
                                  r'^\+\d{2}\s\d\s\d{4}\s\d{4}$',
                                );
                                if (!phoneRegex.hasMatch(value)) {
                                  return 'Formato inválido. Usa: +## # #### ####';
                                }
                                return null;
                              },
                            ),
                          ),
                          const Text("Informacion de contacto miscelanea"),
                          Padding(
                            padding: const EdgeInsets.only(right: 100),
                            child: TextFormField(
                              controller: _miscelaneoController,
                              maxLines: 5,
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
