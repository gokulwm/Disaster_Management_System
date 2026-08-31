import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbDatasource {
  static final LocalDbDatasource _instance = LocalDbDatasource._internal();
  factory LocalDbDatasource() => _instance;
  LocalDbDatasource._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'disaster_link.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE offline_queue (
            id TEXT PRIMARY KEY,
            type TEXT,
            json_data TEXT,
            created_at TEXT,
            synced INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE bt_seen_hashes (
            payload_hash TEXT PRIMARY KEY,
            seen_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE local_help_requests (
            uuid TEXT PRIMARY KEY,
            json_data TEXT,
            created_at_ms INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertToQueue(String id, String type, String jsonData) async {
    final database = await db;
    await database.insert(
      'offline_queue',
      {
        'id': id,
        'type': type,
        'json_data': jsonData,
        'created_at': DateTime.now().toIso8601String(),
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedItems() async {
    final database = await db;
    return await database.query('offline_queue', where: 'synced = 0');
  }

  Future<void> markAsSynced(String id) async {
    final database = await db;
    await database.update('offline_queue', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSynced() async {
    final database = await db;
    await database.delete('offline_queue', where: 'synced = 1');
  }

  Future<bool> isPayloadSeen(String hash) async {
    final database = await db;
    final res = await database.query('bt_seen_hashes', where: 'payload_hash = ?', whereArgs: [hash]);
    return res.isNotEmpty;
  }

  Future<void> markPayloadSeen(String hash) async {
    final database = await db;
    await database.insert(
      'bt_seen_hashes',
      {'payload_hash': hash, 'seen_at': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Map<String, dynamic>?> getLocalHelpRequest(String uuid) async {
    final database = await db;
    final res = await database.query('local_help_requests', where: 'uuid = ?', whereArgs: [uuid]);
    if (res.isNotEmpty) {
      return res.first;
    }
    return null;
  }

  Future<void> upsertLocalHelpRequest(String uuid, String jsonData, int createdAtMs) async {
    final database = await db;
    await database.insert(
      'local_help_requests',
      {
        'uuid': uuid,
        'json_data': jsonData,
        'created_at_ms': createdAtMs,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearAll() async {
    final database = await db;
    await database.delete('offline_queue');
    await database.delete('bt_seen_hashes');
    await database.delete('local_help_requests');
  }
}
