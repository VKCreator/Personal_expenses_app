import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import './transaction.dart';

class DatabaseApp {
  late final database;

  Future<void> connectDB() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'personal_expenses_app.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE userTransaction(id INTEGER PRIMARY KEY, title TEXT, amount DOUBLE, date TEXT, category TEXT)',
        );
      },
      version: 1,
    );
  }

  DatabaseApp() {}

  void deleteTransaction(String id) async {
    final db = await database;

    await db.delete(
      'userTransaction',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> insertTransaction(tr) async {
    final db = await database;

    var newId = await db.insert(
      'userTransaction',
      {
        'title': tr["title"],
        'amount': tr["amount"],
        'date': tr["date"].toString(),
        'category': tr["category"]
      },
      // conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return "$newId";
  }

  Future<List<UserTransaction>> getAllTransactions() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('userTransaction');

    return List.generate(maps.length, (i) {
      return UserTransaction(
        id: maps[i]['id'].toString() as String,
        title: maps[i]['title'] as String,
        amount: maps[i]['amount'] as double,
        date: DateTime.parse(maps[i]['date']) as DateTime,
        category: maps[i]['category'] as String,
      );
    });
  }
}
