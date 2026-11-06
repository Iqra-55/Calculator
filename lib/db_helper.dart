import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // Database Instance Getter
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  // Database Initialization Logic
  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'calculator_history.db');
    
    return await openDatabase(
      path,
      version: 5,
      onCreate: (Database database, int version) async {
        // 1. Calculator History Table
        await database.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            expression TEXT,
            result TEXT,
            date_time TEXT
          )
        ''');

        // 2. Currency Rates Cache Table
        await database.execute('''
          CREATE TABLE currency_rates (
            code TEXT PRIMARY KEY,
            name TEXT,
            flag TEXT,
            rate REAL
          )
        ''');

        // 3. Metadata Table
        await database.execute('''
          CREATE TABLE update_meta (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
      onUpgrade: (Database database, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await database.execute('ALTER TABLE history ADD COLUMN date_time TEXT');
        }
        if (oldVersion < 3) {
          await database.execute('''
            CREATE TABLE currency_rates (
              code TEXT PRIMARY KEY,
              name TEXT,
              flag TEXT,
              rate REAL
            )
          ''');
        }
        if (oldVersion < 4) {
          await database.execute('''
            CREATE TABLE update_meta (
              key TEXT PRIMARY KEY,
              value TEXT
            )
          ''');
        }
      },
    );
  }

  // ==========================================
  //     CALCULATOR HISTORY SECTION
  // ==========================================

  Future<int> insertHistory(String expression, String result) async {
    final database = await db;
    String currentDateTime = DateTime.now().toIso8601String();
    return await database.insert(
      'history',
      {'expression': expression, 'result': result, 'date_time': currentDateTime},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final database = await db;
    return await database.query('history', orderBy: 'date_time DESC');
  }

  Future<int> clearHistory() async {
    final database = await db;
    return await database.delete('history');
  }

  // ==========================================
  //     CURRENCY EXCHANGE RATES SECTION
  // ==========================================

  Future<void> saveCurrencyRates(Map<String, Map<String, dynamic>> ratesData) async {
    final database = await db;
    Batch batch = database.batch();
    ratesData.forEach((code, info) {
      batch.insert(
        'currency_rates',
        {'code': code, 'name': info['name'], 'flag': info['flag'], 'rate': info['rate']},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true);
  }

  Future<void> saveCurrencyRatesWithTime(Map<String, Map<String, dynamic>> ratesData, String timeString) async {
    final database = await db;
    Batch batch = database.batch();
    
    ratesData.forEach((code, info) {
      batch.insert(
        'currency_rates',
        {'code': code, 'name': info['name'], 'flag': info['flag'], 'rate': info['rate']},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    
    batch.insert(
      'update_meta',
      {'key': 'last_api_update', 'value': timeString},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    await batch.commit(noResult: true);
  }

  Future<Map<String, Map<String, dynamic>>> getSavedCurrencyRates() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query('currency_rates');
    Map<String, Map<String, dynamic>> savedRates = {};
    for (var item in maps) {
      savedRates[item['code']] = {
        'name': item['name'],
        'flag': item['flag'],
        'rate': item['rate'],
      };
    }
    return savedRates;
  }

  // ==========================================
  //     API LIVE TIMESTAMP STORAGE
  // ==========================================
  
  Future<void> saveLastUpdateTime(String timeString) async {
    final database = await db;
    await database.insert(
      'update_meta',
      {'key': 'last_api_update', 'value': timeString},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> getLastUpdateTime() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'update_meta',
      where: 'key = ?',
      whereArgs: ['last_api_update'],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return "";
  }

  // ==========================================
  //     SELECTED CURRENCIES SECTION (NEW)
  // ==========================================

  Future<void> saveSelectedCurrencies(String top, String bottom) async {
    final database = await db;
    final batch = database.batch();
    
    batch.insert(
      'update_meta',
      {'key': 'top_currency', 'value': top},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    batch.insert(
      'update_meta',
      {'key': 'bottom_currency', 'value': bottom},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    await batch.commit(noResult: true);
  }

  Future<String> getSavedTopCurrency() async {
    final database = await db;
    final result = await database.query(
      'update_meta',
      where: 'key = ?',
      whereArgs: ['top_currency'],
    );
    return result.isNotEmpty ? result.first['value'] as String : '';
  }

  Future<String> getSavedBottomCurrency() async {
    final database = await db;
    final result = await database.query(
      'update_meta',
      where: 'key = ?',
      whereArgs: ['bottom_currency'],
    );
    return result.isNotEmpty ? result.first['value'] as String : '';
  }
}