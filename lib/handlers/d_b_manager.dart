import 'dart:typed_data';

import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/modelos/tag.dart';
import 'package:ing_software_grupo4/modelos/tagcolor.dart';
import 'package:ing_software_grupo4/modelos/tagtype.dart';
import 'package:ing_software_grupo4/modelos/tipo_reporte.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqlite3/sqlite3.dart';

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
  matricula TEXT
);''';

  static const reportes = '''CREATE TABLE IF NOT EXISTS Reportes (
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

  static const tagJunction = '''CREATE TABLE IF NOT EXISTS TagJunction (
  reporte TEXT NOT NULL,
  tipo INTEGER NOT NULL,
  color INTEGER NOT NULL,
  PRIMARY KEY(reporte, tipo),
  FOREIGN KEY(reporte) REFERENCES Reportes(uuid) ON DELETE CASCADE
);''';

  static const imageJunction = '''CREATE TABLE IF NOT EXISTS ImageJunction (
  reporte TEXT NOT NULL,
  image TEXT NOT NULL,
  PRIMARY KEY(reporte, image),
  FOREIGN KEY(reporte) REFERENCES Reportes(uuid) ON DELETE CASCADE
);''';

  static const imageBLOBJunction =
      '''CREATE TABLE IF NOT EXISTS ImageBLOBJunction (
  reporte TEXT NOT NULL,
  image BLOB NOT NULL,
  PRIMARY KEY(reporte, image),
  FOREIGN KEY(reporte) REFERENCES Reportes(uuid) ON DELETE CASCADE
);''';
  //NECESITAMOS TRES JUNCTION TABLES D:

  bool _initializedTables = false;

  DBManager(this.db);

  void createUserTables() {
    if (_initializedTables) return;

    db.execute(usuarios);
    db.execute(reportes);
    db.execute(tagJunction);
    db.execute(imageJunction);
    db.execute(imageBLOBJunction);

    _initializedTables = true;
  }

  Reporte? fetchReporte(String uuid) {
    final reporteQuery = db.select('SELECT * FROM Reportes WHERE uuid = ?', [
      uuid,
    ]);
    if (reporteQuery.isEmpty) return null;
    final tagsQuery = db.select('SELECT * FROM tagJunction WHERE reporte = ?', [
      uuid,
    ]);
    final imageQuery = db.select(
      'SELECT * FROM imageJunction WHERE reporte = ?',
      [uuid],
    );
    final blobQuery = db.select(
      'SELECT * FROM ImageBLOBJunction WHERE reporte = ?',
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

  void updateReporte(String uuid, Reporte reporte) {
    final queryReporte = '''
    INSERT INTO Reportes (uuid, titulo, descripcion, autor, encontrado, tipo, lat, lng, fecha)
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
    db.execute('DELETE FROM imageJunction WHERE reporte = ?', [uuid]);
    for (String imagen in reporte.imagenes) {
      db.execute('INSERT INTO imageJunction VALUES (?,?)', [uuid, imagen]);
    }
    db.execute('DELETE FROM ImageBLOBJunction WHERE reporte = ?', [uuid]);
    for (Uint8List imagen in reporte.imagenesBytes) {
      db.execute('INSERT INTO ImageBLOBJunction VALUES (?,?)', [uuid, imagen]);
    }
    db.execute('DELETE FROM tagJunction WHERE reporte = ?', [uuid]);
    for (Tag tag in reporte.etiquetas) {
      db.execute('INSERT INTO tagJunction VALUES (?,?,?)', [uuid,tag.tipo.index,tag.color.index]);
    }
  }
}
