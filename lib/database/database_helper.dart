import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/registro.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('registros.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        motivo TEXT NOT NULL,
        sentimientos TEXT NOT NULL,
        pensamiento TEXT NOT NULL,
        comportamiento TEXT NOT NULL,
        consecuencia TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_sentimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migrate from single sentimiento to multiple sentimientos
      // Rename column and convert data format
      await db.execute('ALTER TABLE registros RENAME COLUMN sentimiento TO sentimientos');

      // Update existing records to wrap single sentimiento in JSON array
      final records = await db.query('registros');
      for (var record in records) {
        final id = record['id'];
        final oldSentimiento = record['sentimientos'] as String;
        // Wrap in JSON array if not already
        if (!oldSentimiento.startsWith('[')) {
          final newSentimientos = '["$oldSentimiento"]';
          await db.update(
            'registros',
            {'sentimientos': newSentimientos},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      }
    }
  }

  // CRUD operations for Registro
  Future<int> createRegistro(Registro registro) async {
    final db = await database;
    return await db.insert('registros', registro.toMap());
  }

  Future<Registro?> readRegistro(int id) async {
    final db = await database;
    final maps = await db.query(
      'registros',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Registro.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Registro>> readAllRegistros() async {
    final db = await database;
    final maps = await db.query(
      'registros',
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => Registro.fromMap(map)).toList();
  }

  Future<int> updateRegistro(Registro registro) async {
    final db = await database;
    return await db.update(
      'registros',
      registro.toMap(),
      where: 'id = ?',
      whereArgs: [registro.id],
    );
  }

  Future<int> deleteRegistro(int id) async {
    final db = await database;
    return await db.delete(
      'registros',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Custom sentimientos operations
  Future<int> addCustomSentimiento(String nombre) async {
    final db = await database;
    try {
      return await db.insert('custom_sentimientos', {'nombre': nombre});
    } catch (e) {
      // Si ya existe, retornar 0
      return 0;
    }
  }

  Future<List<String>> getCustomSentimientos() async {
    final db = await database;
    final maps = await db.query('custom_sentimientos', orderBy: 'nombre ASC');
    return maps.map((map) => map['nombre'] as String).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
