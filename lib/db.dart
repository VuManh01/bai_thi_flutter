import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'order_model.dart';

class OrderDatabase {
  static final OrderDatabase instance = OrderDatabase._init();
  static Database? _database;

  OrderDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('orders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      item TEXT,
      itemName TEXT,
      price REAL,
      currency TEXT,
      quantity INTEGER
    )
    ''');
  }

  Future<void> insertOrder(Order order) async {
    final db = await instance.database;
    await db.insert('orders', order.toMap());
  }

  Future<List<Order>> getAllOrders({String? keyword}) async {
    final db = await instance.database;
    final whereClause = keyword != null && keyword.isNotEmpty
        ? "WHERE item LIKE ? OR itemName LIKE ?"
        : "";
    final result = await db.rawQuery(
      'SELECT * FROM orders $whereClause ORDER BY id ASC',
      keyword != null && keyword.isNotEmpty
          ? ['%$keyword%', '%$keyword%']
          : [],
    );
    return result.map((json) => Order.fromMap(json)).toList();
  }
  Future<void> deleteOrder(int id) async {
    final db = await instance.database;
    await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateOrder(Order order) async {
    final db = await instance.database;
    await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

}
