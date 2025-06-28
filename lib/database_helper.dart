import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bmi_calculator.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bmi_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        gender TEXT,
        height REAL,
        weight REAL,
        bmi REAL,
        date TEXT
      )
    ''');
  }

  Future<int> insertBmiRecord(Map<String, dynamic> record) async {
    Database db = await database;
    return await db.insert('bmi_records', record);
  }

  Future<List<Map<String, dynamic>>> getBmiRecords() async {
    Database db = await database;
    // Query the table and order the results by date in descending order.
    return await db.query('bmi_records', orderBy: 'date DESC');
  }
}
