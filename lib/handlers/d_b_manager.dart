import 'dart:typed_data';

import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';
import 'package:ing_software_grupo4/modelos/tagcolor.dart';
import 'package:ing_software_grupo4/modelos/tagtype.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:ing_software_grupo4/modelos/usuario.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

///Maneja todas las llamadas a la base de datos SQL
class DBManager {
  final Database db;

  static const usuarios = '''CREATE TABLE IF NOT EXISTS Usuarios (
  uuid TEXT NOT NULL PRIMARY KEY,
  nombreUsuario TEXT NOT NULL UNIQUE,
  correo TEXT NOT NULL UNIQUE,
  miscelaneo TEXT,
  isAdmin INTEGER NOT NULL CHECK(isAdmin IN (0, 1)),
  tipoUsuario INTEGER NOT NULL,
  matricula TEXT,
  numero TEXT NOT NULL
);''';

  static const credenciales = '''
    CREATE TABLE IF NOT EXISTS Credenciales (
  uuid TEXT NOT NULL PRIMARY KEY,
  password TEXT,
  FOREIGN KEY(uuid) REFERENCES Usuarios(uuid) ON DELETE CASCADE
  );''';

  static reportes(String s) => '''CREATE TABLE IF NOT EXISTS Reportes$s (
  uuid TEXT NOT NULL PRIMARY KEY,
  titulo TEXT NOT NULL,
  descripcion TEXT NOT NULL,
  autor TEXT NOT NULL,
  encontrado INTEGER NOT NULL CHECK(encontrado IN (0, 1)),
  tipo INTEGER NOT NULL,
  lat REAL,
  lng REAL,
  fecha INTEGER NOT NULL,
  FOREIGN KEY(autor) REFERENCES Usuarios(uuid) ON DELETE CASCADE
);''';

  static tagJunction(String s) =>
      '''CREATE TABLE IF NOT EXISTS TagJunction$s (
  reporte TEXT NOT NULL,
  tipo INTEGER NOT NULL,
  color INTEGER NOT NULL,
  PRIMARY KEY(reporte, tipo),
  FOREIGN KEY(reporte) REFERENCES Reportes$s(uuid) ON DELETE CASCADE
);''';

  static imageJunction(String s) =>
      '''CREATE TABLE IF NOT EXISTS ImageJunction$s (
  reporte TEXT NOT NULL,
  image TEXT NOT NULL,
  PRIMARY KEY(reporte, image),
  FOREIGN KEY(reporte) REFERENCES Reportes$s(uuid) ON DELETE CASCADE
);''';

  static imageBLOBJunction(String s) =>
      '''CREATE TABLE IF NOT EXISTS ImageBLOBJunction$s (
  reporte TEXT NOT NULL,
  image BLOB NOT NULL,
  PRIMARY KEY(reporte, image),
  FOREIGN KEY(reporte) REFERENCES Reportes$s(uuid) ON DELETE CASCADE
);''';
  //NECESITAMOS TRES JUNCTION TABLES D:

  bool _initializedTables = false;

  DBManager(this.db);

  void createUserTables() {
    if (_initializedTables) return;

    db.execute(usuarios);
    db.execute(credenciales);

    for (var x in EstadoReporte.values) {
      db.execute(reportes(x.name));
      db.execute(tagJunction(x.name));
      db.execute(imageJunction(x.name));
      db.execute(imageBLOBJunction(x.name));
    }
    _initializedTables = true;
  }

  List<String> reportKeys(EstadoReporte estado) {
    return db
        .select('SELECT uuid from Reportes${estado.name}')
        .map((r) => r.values[0] as String)
        .toList();
  }

  void removeReporte(String uuid, EstadoReporte estado) {
    db.execute('DELETE FROM Reportes${estado.name} WHERE uuid = ?', [uuid]);
    db.execute('DELETE FROM tagJunction${estado.name} WHERE reporte = ?', [
      uuid,
    ]);
    db.execute('DELETE FROM imageJunction${estado.name} WHERE reporte = ?', [
      uuid,
    ]);
    db.execute(
      'DELETE FROM imageBLOBJunction${estado.name} WHERE reporte = ?',
      [uuid],
    );
  }

  Reporte? fetchReporte(String uuid, EstadoReporte estado) {
    final reporteQuery = db.select(
      'SELECT * FROM Reportes${estado.name} WHERE uuid = ?',
      [uuid],
    );
    if (reporteQuery.isEmpty) return null;
    final tagsQuery = db.select(
      'SELECT * FROM tagJunction${estado.name} WHERE reporte = ?',
      [uuid],
    );
    final imageQuery = db.select(
      'SELECT * FROM imageJunction${estado.name} WHERE reporte = ?',
      [uuid],
    );
    final blobQuery = db.select(
      'SELECT * FROM ImageBLOBJunction${estado.name} WHERE reporte = ?',
      [uuid],
    );

    final Row reporteMap = reporteQuery.first;
    final tags = tagsQuery.rows
        .map(
          (row) => Tag(
            TagType.values[row[1] as int],
            TagColor.values[row[2] as int],
          ),
        )
        .toList();
    final images = imageQuery.rows.map((row) => row[1] as String).toList();
    final blobs = blobQuery.rows.map((row) => row[1] as Uint8List).toList();
    return Reporte(
      reporteMap['titulo'],
      reporteMap['descripcion'],
      reporteMap['autor'],
      (reporteMap['encontrado'] as int) == 1,
      TipoReporte.values[reporteMap['tipo'] as int],
      LatLng(reporteMap['lat'] as double, reporteMap['lng'] as double),
      fecha: DateTime.fromMillisecondsSinceEpoch(reporteMap['fecha'] as int),
      imagenes: images,
      imagenesBytes: blobs,
      etiquetas: tags,
    );
  }

  void updateReporte(String uuid, Reporte reporte, EstadoReporte estado) {
    final queryReporte =
        '''
    INSERT INTO Reportes${estado.name} (uuid, titulo, descripcion, autor, encontrado, tipo, lat, lng, fecha)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(uuid) DO UPDATE SET
      titulo = excluded.titulo,
      descripcion = excluded.descripcion,
      autor = excluded.autor,
      encontrado = excluded.encontrado,
      tipo = excluded.tipo,
      lat = excluded.lat,
      lng = excluded.lng,
      fecha = excluded.fecha
  ''';

    db.execute(queryReporte, [
      uuid,
      reporte.titulo,
      reporte.descripcion,
      reporte.autor,
      reporte.encontrado ? 1 : 0,
      reporte.tipo.index,
      reporte.ubicacion?.latitude,
      reporte.ubicacion?.longitude,
      reporte.fecha.millisecondsSinceEpoch,
    ]);
    db.execute('DELETE FROM imageJunction${estado.name} WHERE reporte = ?', [
      uuid,
    ]);
    for (String imagen in reporte.imagenes) {
      db.execute('INSERT INTO imageJunction${estado.name} VALUES (?,?)', [
        uuid,
        imagen,
      ]);
    }
    db.execute(
      'DELETE FROM ImageBLOBJunction${estado.name} WHERE reporte = ?',
      [uuid],
    );
    for (Uint8List imagen in reporte.imagenesBytes) {
      db.execute('INSERT INTO ImageBLOBJunction${estado.name} VALUES (?,?)', [
        uuid,
        imagen,
      ]);
    }
    db.execute('DELETE FROM tagJunction${estado.name} WHERE reporte = ?', [
      uuid,
    ]);
    for (Tag tag in reporte.etiquetas) {
      db.execute('INSERT INTO tagJunction${estado.name} VALUES (?,?,?)', [
        uuid,
        tag.tipo.index,
        tag.color.index,
      ]);
    }
  }

  Usuario? fetchUser(String uuid) {
    var userQuery = db.select('SELECT * FROM Usuarios WHERE uuid = ?', [
      uuid,
    ]).first;
    if (userQuery.isEmpty) return null;

    return Usuario(
      nombreUsuario: userQuery['nombreUsuario'] as String,
      correo: userQuery['correo'] as String,
      numero: userQuery['numero'] as String,
      miscelaneo: userQuery['miscelaneo'] as String? ?? "",
      isAdmin: (userQuery['isAdmin'] as int) == 1,
      tipoUsuario: TipoUsuario.values[userQuery['tipoUsuario'] as int],
      matricula: userQuery['matricula'] as String?,
    );
  }

  String? verifySession(String username, String password) {
    var uuid = db.select('SELECT uuid FROM Usuarios WHERE nombreUsuario = ?', [
      username,
    ]).firstOrNull?['uuid'];

    if (uuid == null) return null;

    return db.select(
          'SELECT 1 FROM Credenciales WHERE uuid = ? AND password = ?',
          [uuid, password],
        ).isEmpty
        ? null
        : uuid;
  }

  String? registrarUsuario({
    required String nombreUsuario,
    required String password,
    required String correo,
    required TipoUsuario tipoUsuario,
    String? numero,
    String? miscelaneo,
  }) {
    String uuid = Uuid().v7();
    var checkCond = db.select(
      'SELECT 1 FROM Usuarios WHERE nombreUsuario = ? OR correo = ?',
      [nombreUsuario, correo],
    );
    if (checkCond.isNotEmpty) {
      return checkCond.first["nombreUsuario"] as String == nombreUsuario
          ? "El nombre de usuario ya está en uso"
          : "El correo ya está registrado";
    }

    db.execute('INSERT INTO Usuarios VALUES (?,?,?,?,?,?,?,?)', [
      uuid,
      nombreUsuario,
      correo,
      miscelaneo ?? "",
      0,
      tipoUsuario.index,
      null,
      numero ?? "",
    ]);

    db.execute('INSERT INTO Credenciales VALUES (?,?)', [uuid, password]);
    return null;
  }

  bool updateUsuario(
    String uuid, {
    required String nombreUsuario,
    required String correo,
    required String numero,
    required String miscelaneo,
  }) {
    try {
      db.execute(
        'UPDATE Usuarios SET nombreUsuario = ?, correo = ?, numero = ?, miscelaneo = ? WHERE uuid = ?',
        [nombreUsuario, correo, numero, miscelaneo, uuid],
      );
      return true;
    } on Exception {
      return false;
    }
  }

  bool isUsernameAvailable(String username) => db.select(
    'SELECT 1 FROM USUARIOS WHERE NOMBREUSUARIO = ?',
    [username],
  ).isEmpty;

  bool isEmailAvailable(String correo) =>
      db.select('SELECT 1 FROM USUARIOS WHERE correo = ?', [correo]).isEmpty;

  Set<String> getReportesUsuario(String uuid, EstadoReporte estado) {
    return db
        .select('SELECT UUID FROM Reportes${estado.name} WHERE autor = ?', [
          uuid,
        ])
        .map((row) => row['uuid'] as String)
        .toSet();
  }

  void setEncontrado(String uuid, bool encontrado) => db.execute(
    'UPDATE Reportesexistente SET encontrado = ? WHERE uuid = ?',
    [encontrado ? 1 : 0, uuid],
  );

  List<String> getSimilares(String uuid) {
    return db
        .select(
          '''SELECT r2.uuid
        FROM Reportesexistente r1
      JOIN Reportesexistente r2 ON r1.uuid != r2.uuid
WHERE r1.uuid = ? 
AND r1.autor != r2.autor
AND r1.tipo != r2.tipo
AND r2.encontrado = 0
AND (
    SELECT COUNT(*) FROM TagJunctionexistente WHERE reporte = r1.uuid
) = (
    SELECT COUNT(*) FROM TagJunctionexistente WHERE reporte = r2.uuid
)
AND (
    SELECT COUNT(*) FROM (
        SELECT tj1.tipo, tj1.color
        FROM TagJunctionexistente tj1
        WHERE tj1.reporte = r1.uuid
        INTERSECT
        SELECT tj2.tipo, tj2.color
        FROM TagJunctionexistente tj2
        WHERE tj2.reporte = r2.uuid
    )
) = (
    SELECT COUNT(*) FROM TagJunctionexistente WHERE reporte = r1.uuid
);''',
          [uuid],
        )
        .map((row) => row['uuid'] as String)
        .toList();
  }
}

enum EstadoReporte { pendiente, existente }
