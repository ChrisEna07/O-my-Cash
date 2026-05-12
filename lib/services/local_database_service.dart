import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'security_service.dart';
import '../models/transaction_model.dart';
import '../models/savings_goal_model.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Database? _database;
  final String _userId = 'local_user';
  final _uuid = const Uuid();
  final _security = SecurityService();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'omycash.db');
    
    // Obtenemos la llave de cifrado segura
    final String password = await _security.getEncryptionKey();
    
    return await openDatabase(
      path,
      password: password,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        rule_category TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE savings_goals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        goal_name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL DEFAULT 0,
        deadline TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        full_name TEXT,
        avatar_url TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
    
    await db.insert('profiles', {
      'id': _userId,
      'full_name': 'Usuario',
      'avatar_url': '',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // --- Transactions ---
  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final res = await db.query('transactions', orderBy: 'created_at DESC');
    return res.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final db = await database;
    final Map<String, dynamic> data = transaction.toJson();
    if (!data.containsKey('id') || data['id'] == null) {
      data['id'] = _uuid.v4();
    }
    data['user_id'] = _userId;
    await db.insert('transactions', data);
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTransactionAmount(String id, double newAmount) async {
    final db = await database;
    await db.update('transactions', {'amount': newAmount}, where: 'id = ?', whereArgs: [id]);
  }

  // --- Savings Goals ---
  Future<List<SavingsGoalModel>> getSavingsGoals() async {
    final db = await database;
    final res = await db.query('savings_goals');
    return res.map((json) => SavingsGoalModel.fromJson(json)).toList();
  }

  Future<void> addSavingsGoal(SavingsGoalModel goal) async {
    final db = await database;
    final Map<String, dynamic> data = goal.toJson();
    if (!data.containsKey('id') || data['id'] == null) {
      data['id'] = _uuid.v4();
    }
    data['user_id'] = _userId;
    if (!data.containsKey('created_at') || data['created_at'] == null) {
        data['created_at'] = DateTime.now().toIso8601String();
    }
    await db.insert('savings_goals', data);
  }

  Future<void> updateSavingsGoal(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('savings_goals', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSavingsGoal(String id) async {
    final db = await database;
    await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateSavingsGoalProgress(String id, double currentAmount) async {
    final db = await database;
    await db.update('savings_goals', {'current_amount': currentAmount}, where: 'id = ?', whereArgs: [id]);
  }

  // --- Profile ---
  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;
    final res = await db.query('profiles', where: 'id = ?', whereArgs: [_userId]);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final db = await database;
    data['updated_at'] = DateTime.now().toIso8601String();
    await db.update('profiles', data, where: 'id = ?', whereArgs: [_userId]);
  }

  Future<String?> saveAvatarLocal(dynamic fileBytes, String fileName) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String uniqueFileName = '${_uuid.v4()}_$fileName';
      String filePath = join(appDocDir.path, uniqueFileName);
      File file = File(filePath);
      await file.writeAsBytes(fileBytes);
      return filePath;
    } catch (e) {
      return null;
    }
  }

  Future<void> resetUserData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('savings_goals');
  }

  // --- Backup ---
  Future<String> exportDataToJson() async {
    final db = await database;
    final transactions = await db.query('transactions');
    final goals = await db.query('savings_goals');
    final profiles = await db.query('profiles');
    
    final data = {
      'transactions': transactions,
      'savings_goals': goals,
      'profiles': profiles,
    };
    
    return jsonEncode(data);
  }

  Future<void> importDataFromJson(String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final db = await database;
    
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('savings_goals');
      // No borramos perfiles completos, los actualizamos
      
      if (data['transactions'] != null) {
        for (var tx in data['transactions']) {
          await txn.insert('transactions', tx, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      if (data['savings_goals'] != null) {
        for (var goal in data['savings_goals']) {
          await txn.insert('savings_goals', goal, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      if (data['profiles'] != null && data['profiles'].isNotEmpty) {
        for (var profile in data['profiles']) {
          await txn.insert('profiles', profile, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }
}

