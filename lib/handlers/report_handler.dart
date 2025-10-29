import 'package:ing_software_grupo4/handlers/session_handler.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';

class ReportHandler {
  ///Aqui se guardará la revisión del reporte mas reciente enviada a los admin para aprobar.
 
  //No quiero retornar una excepcion, podria usar Either pero seria poco manejable para los demas
  //TODO: Buscar una solucion al problema de diferenciar retornos fallidos sin usar excepciones. Prioridad: Could

  //Por la naturaleza de esta implementacíon los usuarios perderan las revisiones anteriores, que pena.
  static final Map<String,Reporte?> _pendientes = {};  
  ///Guarda todos los reportes existentes y aprobados en el sistema
  static final Map<String,Reporte> _existentes = {};
  
  ///Aqui pondría mi metodo inicializador de base de datos, si tuviera una base de datos.
   static void initialize(){
    throw UnimplementedError();
  }

   static Reporte? getTeam(String key){
    return _existentes[key];
  }

   static Iterable<String> getPeticiones(){
    if(!SessionHandler.isAdmin) return const Iterable.empty();
    return _pendientes.keys;
  }
  ///Entrega la petición de edicion/adición mas vieja.

  ///Solo cuando un admin esta con la sesión prendida esta funcion retorna la petición.
   static Reporte? getPeticion(String key){
    if(!SessionHandler.isAdmin || _pendientes.isEmpty){
      return null;
    }
    return _pendientes[key];
  }
  

   static void submitPeticion(String key, Reporte r, bool nuevo){
    if(_pendientes.containsKey(key))
      _pendientes.remove(key);
    _pendientes[key] = r;
  }
}
