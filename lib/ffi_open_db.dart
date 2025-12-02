import 'package:ing_software_grupo4/handlers/d_b_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

Future<DBManager> openDb() async {
  final dir = await getApplicationDocumentsDirectory();
  final CommonDatabase db = sqlite3.open('${dir.path}/appDB.db');
  final dbHandler = DBManager(db);
  return dbHandler;
}
