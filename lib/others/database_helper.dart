import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';
import '../models/reminder.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  String reminderTable = 'reminder_table';
  String remColId = 'id';
  String remColName = 'name';
  String remColType = 'type';
  String remColTimes = 'times';
  String remColTime1 = 'time1';
  String remColTime2 = 'time2';
  String remColTime3 = 'time3';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'app.db';

    // Open/create the database at a given path
    var appDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return appDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $reminderTable($remColId INTEGER PRIMARY KEY AUTOINCREMENT, $remColName TEXT, '
            '$remColType TEXT, $remColTimes INTEGER, $remColTime1 TEXT,$remColTime2 TEXT,$remColTime3 TEXT)');

    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
            '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Fetch Operation: Get all reminder objects from database
  Future<List<Map<String, dynamic>>> getReminderMapList() async {
    Database db = await this.database;

    var result = await db.rawQuery('SELECT * FROM $reminderTable ');
    //   var result = await db.query(reminderTable, orderBy: '$colId ASC');
    return result;
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // Insert Operation: Insert a reminder object to database
  Future<int> insertReminder(Reminder reminder) async {
    Database db = await this.database;
    var result = await db.insert(reminderTable, reminder.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Update Operation: Update a reminder object and save it to database
  Future<int> updateReminder(Reminder reminder) async {
    var db = await this.database;
    var result = await db.update(reminderTable, reminder.toMap(),
        where: '$remColId = ?', whereArgs: [reminder.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result =
    await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  // Delete Operation: Delete a Reminder object from database
  Future<int> deleteReminder(int id) async {
    var db = await this.database;
    int result =
    await db.rawDelete('DELETE FROM $reminderTable WHERE $remColId = $id');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get number of reminder objects in database
  Future<int> getRemCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $reminderTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList(); // Get 'Map List' from database
    int count =
        noteMapList.length; // Count the number of map entries in db table

    List<Note> noteList = List<Note>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Reminder List' [ List<Reminder> ]
  Future<List<Reminder>> getRemList() async {
    var reminderMapList =
    await getReminderMapList(); // Get 'Map List' from database
    int count =
        reminderMapList.length; // Count the number of map entries in db table

    List<Reminder> reminderList = List<Reminder>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      reminderList.add(Reminder.fromMapObject(reminderMapList[i]));
    }

    return reminderList;
  }
}
