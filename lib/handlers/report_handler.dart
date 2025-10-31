import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';

class ReportHandler {
  ///Aqui se guardará la revisión del reporte mas reciente enviada a los admin para aprobar.

  //No quiero retornar una excepcion, podria usar Either pero seria poco manejable para los demas
  //TODO: Buscar una solucion al problema de diferenciar retornos fallidos sin usar excepciones. Prioridad: Could

  //Por la naturaleza de esta implementacíon los usuarios perderan las revisiones anteriores, que pena.
  static final Map<String, Reporte?> _pendientes = {};

  ///Guarda todos los reportes existentes y aprobados en el sistema
  static final Map<String, Reporte> _existentes = {};

  static final ValueNotifier<bool> _reportNotifier = ValueNotifier(false);
  static ValueNotifier<bool> get reportNotifier => _reportNotifier;

  static final ValueNotifier<bool> _pendingNotifier = ValueNotifier(false);
  static ValueNotifier<bool> get pendingNotifier => _pendingNotifier;
  static bool canPublish = true;

  ///Aqui pondría mi metodo inicializador de base de datos, si tuviera una base de datos.
  static void initialize() {
    throw UnimplementedError();
  }

  static Reporte? getTeam(String key) {
    return _existentes[key];
  }

  static Iterable<String> getPeticiones() {
    if (!SessionHandler.isAdmin) return const Iterable.empty();
    return _pendientes.keys;
  }

  ///Entrega la petición de edicion/adición mas vieja.

  ///Solo cuando un admin esta con la sesión prendida esta funcion retorna la petición.
  static Reporte? getPeticion(String key) {
    if (!SessionHandler.isAdmin || _pendientes.isEmpty) {
      return null;
    }
    return _pendientes[key];
  }

  static bool submitPeticion(String key, Reporte r, bool nuevo) {
    if (_pendientes.containsKey(key)) _pendientes.remove(key);
    _pendientes[key] = r;
    _pendingNotifier.value = !_pendingNotifier.value;
    return canPublish; //La idea es que esto nos diria si logramos publicar la petición, pero no tenemos nada aun
  }

  static void acceptPeticion(String uuid) {
    if (!_pendientes.containsKey(uuid)) return;
    _existentes[uuid] = _pendientes[uuid]!;
    _pendientes.remove(uuid);
    _reportNotifier.value = !_reportNotifier.value;
    _pendingNotifier.value = !_pendingNotifier.value;
  }

  static void rejectPeticion(String uuid) {
    _pendientes.remove(uuid);
    _pendingNotifier.value = !pendingNotifier.value;
  }

  static List<String> get getReportes => _existentes.keys.toList();

  static Reporte? getReporte(String key) {
    return _existentes[key];
  }
}
