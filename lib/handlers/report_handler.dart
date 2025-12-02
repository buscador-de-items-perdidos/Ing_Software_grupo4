import 'dart:async';

import 'package:ing_software_grupo4/handlers/d_b_manager.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:flutter/foundation.dart';

class ReportHandler {
  ///Aqui se guardará la revisión del reporte mas reciente enviada a los admin para aprobar.

  //Por la naturaleza de esta implementacíon los usuarios perderan las revisiones anteriores, que pena.
  static final Map<String, Reporte?> _pendientes = {};

  ///Guarda todos los reportes existentes y aprobados en el sistema
  static final Map<String, Reporte?> _existentes = {};

  static DBManager? _dbManager;

  static final ValueNotifier<bool> _reportNotifier = ValueNotifier(false);
  static ValueNotifier<bool> get reportNotifier => _reportNotifier;

  static final ValueNotifier<bool> _pendingNotifier = ValueNotifier(false);
  static ValueNotifier<bool> get pendingNotifier => _pendingNotifier;

  ///Aqui pondría mi metodo inicializador de base de datos, si tuviera una base de datos.
  static Future<void> initialize(DBManager? db) async {
    _dbManager = db;
    if(db == null) return;
    for (String key in _dbManager!.reportKeys(EstadoReporte.existente)) {
      _existentes[key] = null;
    }
    for (String key in _dbManager!.reportKeys(EstadoReporte.pendiente)) {
      _pendientes[key] = null;
    }
  }

  static Iterable<String> getPeticiones() {
    return _pendientes.keys;
  }

  ///Entrega la petición de edicion/adición mas vieja.

  static Reporte? getPeticion(String key) {
    if (_pendientes.containsKey(key) && _pendientes[key] == null) {
      _pendientes[key] = _dbManager?.fetchReporte(key, EstadoReporte.pendiente);
    }
    return _pendientes[key];
  }

  static void submitPeticion(String key, Reporte r) {
    if (_pendientes.containsKey(key)) _pendientes.remove(key);

    _pendientes[key] = r;
    _dbManager?.updateReporte(key, r, EstadoReporte.pendiente);
    _pendingNotifier.value = !_pendingNotifier.value;
  }

  static void acceptPeticion(String uuid) {
    if (!_pendientes.containsKey(uuid)) return;

    final reporte = _pendientes[uuid]!;
    _existentes[uuid] = reporte;

    // Obtener el usuario autor del reporte y actualizar sus listas
    _dbManager?.updateReporte(uuid, reporte, EstadoReporte.existente);

    _pendientes.remove(uuid);
    _dbManager?.removeReporte(uuid, EstadoReporte.pendiente);
    _reportNotifier.value = !_reportNotifier.value;
    _pendingNotifier.value = !_pendingNotifier.value;
  }

  static void rejectPeticion(String uuid) {
    if (!_pendientes.containsKey(uuid)) return;

    _pendientes.remove(uuid);
    _dbManager?.removeReporte(uuid, EstadoReporte.pendiente);
    _pendingNotifier.value = !pendingNotifier.value;
  }

  static void eliminarReporte(String uuid) {
    _dbManager?.removeReporte(uuid, EstadoReporte.existente);
    _dbManager?.removeReporte(uuid, EstadoReporte.pendiente);
    _existentes.remove(uuid);
    _pendientes.remove(uuid);
    _reportNotifier.value = !_reportNotifier.value;
  }

  static List<String> get getReportes => _existentes.keys.toList();

  static Reporte? getReporte(String key) {
    if (_existentes.keys.contains(key) && _existentes[key] == null) {
      _existentes[key] = _dbManager?.fetchReporte(key, EstadoReporte.existente);
    }
    return _existentes[key];
  }

  /// Busca un reporte por UUID en los 3 maps: pendientes, existentes y encontrados
  static Reporte? buscarReporte(String uuid) {
    return getPeticion(uuid) ?? getReporte(uuid);
  }

  static void estadoObjeto(String uuid, bool encontrado) {
    _existentes[uuid]?.encontrado = encontrado;
    _dbManager?.setEncontrado(uuid, encontrado);
    _reportNotifier.value = !_reportNotifier.value;
  }

  ///SOLO USAR PARA WEB
  static Set<String> getReportesUsuario(String uuid, bool existente) {
    Set<String> reportes = {};
    for (var x in (existente ? _existentes : _pendientes).entries) {
      if (x.value?.autor == uuid) reportes.add(x.key);
    }
    return reportes;
  }

  ///Retorna uuid's de reportes similares al dado, que no tienen el mismo autor

  ///Si el reporte es de objetos perdidos, el metodo retorna objetos encontrados, y viceversa
  static List<String> getSimilares(String uuid) {
    if (_dbManager != null) return _dbManager!.getSimilares(uuid);
    List<String> similares = [];
    Reporte? reporte = _existentes[uuid];
    if (reporte == null) return const [];

    for (String x in _existentes.keys) {
      if (x != uuid &&
          _existentes[x]?.autor != reporte.autor &&
          _existentes[x]?.etiquetas.firstOrNull ==
              reporte.etiquetas.firstOrNull &&
          reporte.tipo != _existentes[x]?.tipo) {
        similares.add(x);
      }
    }
    return similares;
  }
}
