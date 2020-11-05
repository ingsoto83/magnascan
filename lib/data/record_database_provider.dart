import 'dart:async';
import 'dart:io';

import 'package:inventario_magna/data/record.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class RecordDatabaseProvider {
  RecordDatabaseProvider._();

  static final RecordDatabaseProvider db = RecordDatabaseProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await getDatabaseInstance();
    return _database;
  }

  Future<Database> getDatabaseInstance() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "persons.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE Record ("
              "id INTEGER PRIMARY KEY AUTOINCREMENT,"
              "codigo TEXT,"
              "codigo_original TEXT,"
              "quantity INTEGER,"
              "date TEXT,"
              "time TEXT,"
              "user TEXT"
              ")");
        });
  }

  addRecordToDatabase(Record record) async {
    final db = await database;
    var raw = await db.insert(
      "Record",
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;
  }

  updateRecord(Record record) async {
    final db = await database;
    var response = await db.update("Record", record.toMap(),
        where: "id = ?", whereArgs: [record.id]);
    return response;
  }

  Future<Record> getRecordWithId(int id) async {
    final db = await database;
    var response = await db.query("Record", where: "id = ?", whereArgs: [id]);
    return response.isNotEmpty ? Record.fromMap(response.first) : null;
  }

  Future<List<Record>> getAllRecordsWithDate(String date) async {
    final db = await database;
    var response = await db.query("Record", where: "date = ?", whereArgs: [date]);
    List<Record> list = response.map((c) => Record.fromMap(c)).toList();
    return list;
  }

  Future<int> getAllRecords() async {
    final db = await database;
    var response = await db.query("Record");
    List<Record> list = response.map((c) => Record.fromMap(c)).toList();
    return list.length;
  }

  deleteRecordWithId(int id) async {
    final db = await database;
    return db.delete("Record", where: "id = ?", whereArgs: [id]);
  }

  deleteAllRecords() async {
    final db = await database;
    db.delete("Record");
  }
}