@startuml
class Reporte {
titulo : String
descripción : String
autor : UUID
ubicacion : Ubicación
}

enum TipoReporte{
perdido
encontrado
}

Reporte o--- [id: id] ReportHandler
TipoReporte o-- "1" Reporte

abstract class ReportHandler{
usuarioActual : Usuario
cambiarDetallesUsuario(uuid: UUID, usuario: Usuario)
obtenerNombreUsuario(uuid: UUID)
obtenerInstanciaUsuario(uuid: UUID)
}

enum TipoObjeto 

TipoObjeto o-- Reporte

abstract class SessionHandler

Usuario *-- "0.." [uuid: UUID]  SessionHandler

class Usuario
@enduml
