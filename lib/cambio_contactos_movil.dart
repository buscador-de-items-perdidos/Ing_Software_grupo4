import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';

class CambioContactosMovil extends StatefulWidget {
  const CambioContactosMovil({super.key});

  @override
  State<CambioContactosMovil> createState() => _CambioContactosMovilState();
}

class _CambioContactosMovilState extends State<CambioContactosMovil> {
  late final Usuario usuarioActual = SessionHandler.usuarioActual!;
  late final _usernameController = TextEditingController(
    text: usuarioActual.nombreUsuario,
  );
  late final _emailController = TextEditingController(
    text: usuarioActual.correo,
  );
  late final _numberController = TextEditingController(
    text: usuarioActual.numero,
  );
  late final _miscController = TextEditingController(
    text: usuarioActual.miscelaneo,
  );
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> camposEditarContacto = GlobalKey();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!(camposEditarContacto.currentState?.validate() ?? false)) {
            return;
          }
          SessionHandler.cambiarUsuario(
            SessionHandler.uuid,
            Usuario(
              nombreUsuario: _usernameController.text,
              correo: _emailController.text,
              numero: _numberController.text,
              miscelaneo: _miscController.text,
              reportes_pendientes: SessionHandler.getPendientes,
              reportes_aceptados: SessionHandler.getAceptados,
              isAdmin: usuarioActual.isAdmin,
            ),
          );
        },
        child: Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: camposEditarContacto,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
            child: Column(
              spacing: 32,
              children: [
                Text(
                  "Modifica tus datos",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Center(
                  child: CircleAvatar(
                    radius: 99,
                    backgroundImage: AssetImage('assets/trial.png'),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
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
                              SessionHandler.usuarioActual?.tipoUsuario ==
                                      TipoUsuario.miembroUniversidad
                                  ? Icons.school
                                  : Icons.person_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              SessionHandler.usuarioActual?.tipoUsuario ==
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
                            SessionHandler.usuarioActual?.matricula != null) ...[
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
                ),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de usuario',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un nombre de usuario';
                    }
                    if (value.length < 3) {
                      return 'Mínimo 3 caracteres';
                    }
                    if (value.trim() != SessionHandler.nombreUsuario &&
                        !SessionHandler.isUsernameAvailable(value.trim())) {
                      return 'Este usuario ya existe';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Correo electronico",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Correo inválido';
                    }
                    // Validar correo UdeC para miembros de la universidad
                    if (usuarioActual.tipoUsuario ==
                        TipoUsuario.miembroUniversidad) {
                      if (!value.trim().toLowerCase().endsWith('@udec.cl')) {
                        return 'Debes usar un correo @udec.cl';
                      }
                    }
                    if ((value.trim() != SessionHandler.correo) &&
                        !SessionHandler.isEmailAvailable(value.trim())) {
                      return 'Este correo ya está registrado';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _numberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Número de telefono (+## # #### ####)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu teléfono';
                    }
                    // Validar formato +## # #### ####
                    final phoneRegex = RegExp(r'^\+\d{2}\s\d\s\d{4}\s\d{4}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Formato inválido. Usa: +## # #### ####';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _miscController,
                  minLines: 5,
                  maxLines: 5,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Información de contacto miscelanea",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
