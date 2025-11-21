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

  ///Guarda reportes encontrados
  static final Map<String, Reporte> _encontrados = {};

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
    SessionHandler.getPendientes.add(key);
    _pendientes[key] = r;
    _pendingNotifier.value = !_pendingNotifier.value;
    return canPublish; //La idea es que esto nos diria si logramos publicar la petición, pero no tenemos nada aun
  }

  static void acceptPeticion(String uuid) {
    if (!_pendientes.containsKey(uuid)) return;
    _existentes[uuid] = _pendientes[uuid]!;
    SessionHandler.getAceptados.add(uuid);
    SessionHandler.getPendientes.remove(uuid);
    _pendientes.remove(uuid);
    _reportNotifier.value = !_reportNotifier.value;
    _pendingNotifier.value = !_pendingNotifier.value;
  }

  static void rejectPeticion(String uuid) {
    _pendientes.remove(uuid);
    SessionHandler.getPendientes.remove(uuid);
    _pendingNotifier.value = !pendingNotifier.value;
  }

  static void eliminarReporte(String uuid) {
    // Obtener el reporte para saber quién es el autor
    Reporte? reporte =
        _existentes[uuid] ?? _pendientes[uuid] ?? _encontrados[uuid];

    if (reporte == null) return;

    // Obtener el usuario autor del reporte
    final autorUsuario = SessionHandler.getUsuario(reporte.autor);

    // Eliminar de existentes (aceptados)
    if (_existentes.containsKey(uuid)) {
      _existentes.remove(uuid);
      autorUsuario.reportes_aceptados.remove(uuid);
    }
    // Eliminar de pendientes
    if (_pendientes.containsKey(uuid)) {
      _pendientes.remove(uuid);
      autorUsuario.reportes_pendientes.remove(uuid);
    }
    // Eliminar de encontrados
    if (_encontrados.containsKey(uuid)) {
      _encontrados.remove(uuid);
      autorUsuario.reportes_aceptados.remove(uuid);
    }
    _reportNotifier.value = !_reportNotifier.value;
  }

  static List<String> get getReportes => _existentes.keys.toList();

  static Reporte? getReporte(String key) {
    return _existentes[key];
  }

  static Reporte? getEncontrado(String key) {
    return _encontrados[key];
  }

  /// Busca un reporte por UUID en los 3 maps: pendientes, existentes y encontrados
  static Reporte? buscarReporte(String uuid) {
    return _pendientes[uuid] ?? _existentes[uuid] ?? _encontrados[uuid];
  }

  static void estadoObjeto(String uuid, bool encontrado) {
    if (encontrado) {
      _existentes[uuid]?.encontrado = true;
      _encontrados[uuid] = _existentes[uuid]!;
      _existentes.remove(uuid);
    } else {
      _existentes[uuid] = _encontrados[uuid]!;
      _encontrados.remove(uuid);
    }
    _reportNotifier.value = !_reportNotifier.value;
  }
}
