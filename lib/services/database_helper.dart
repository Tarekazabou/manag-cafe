import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/inventory_item.dart';
import '../models/sale.dart';
import '../models/inventory_snapshot.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  static const String _databaseName = 'coffee_shop.db';
  static const int _databaseVersion = 9; // Already at 9 for isSellable field

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print('Database path: $path');
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    print('Creating database tables for version $version');
    await db.execute('''
      CREATE TABLE inventory_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        buyPrice REAL NOT NULL,
        sellPrice REAL NOT NULL,
        lowStockThreshold REAL NOT NULL,
        isSellable INTEGER NOT NULL DEFAULT 1 -- New column for sellable status
      )
    ''');
    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        itemName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        sellingPrice REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE snapshots (
        id TEXT PRIMARY KEY,
        itemId TEXT NOT NULL,
        quantity REAL NOT NULL,
        timestamp TEXT NOT NULL,
        timeSlot TEXT NOT NULL,
        weather TEXT NOT NULL,
        FOREIGN KEY (itemId) REFERENCES inventory_items(id)
      )
    ''');
    print('Database tables created successfully');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    // Helper function to check if a table exists
    Future<bool> tableExists(Database db, String table) async {
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='$table'");
      return tables.isNotEmpty;
    }

    // Helper function to check if a column exists in a table
    Future<bool> columnExists(Database db, String table, String column) async {
      final columns = await db.rawQuery('PRAGMA table_info($table)');
      return columns.any((col) => col['name'] == column);
    }

    // Handle table renames and schema updates
    if (oldVersion < 2) {
      if (!(await tableExists(db, 'snapshots'))) {
        print('snapshots table does not exist, creating it');
        await db.execute('''
          CREATE TABLE snapshots (
            id TEXT PRIMARY KEY,
            itemId TEXT NOT NULL,
            quantity REAL NOT NULL,
            timestamp TEXT NOT NULL,
            timeSlot TEXT NOT NULL,
            weather TEXT NOT NULL,
            FOREIGN KEY (itemId) REFERENCES inventory_items(id)
          )
        ''');
      }
    }

    if (oldVersion < 3) {
      print('No additional migrations needed for version 3');
    }

    if (oldVersion < 4) {
      print('Checking and adding sellPrice column to inventory_items table');
      if (!(await tableExists(db, 'inventory_items'))) {
        await db.execute('''
          CREATE TABLE inventory_items (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            quantity REAL NOT NULL,
            buyPrice REAL NOT NULL,
            sellPrice REAL NOT NULL,
            lowStockThreshold REAL NOT NULL
          )
        ''');
      } else {
        if (!(await columnExists(db, 'inventory_items', 'sellPrice'))) {
          await db.execute(
              'ALTER TABLE inventory_items ADD COLUMN sellPrice REAL NOT NULL DEFAULT 0.0');
          print('sellPrice column added successfully');
        } else {
          print('sellPrice column already exists, skipping');
        }
      }
    }

    if (oldVersion < 5) {
      print('Checking and adding buyPrice column to inventory_items table');
      if (!(await columnExists(db, 'inventory_items', 'buyPrice'))) {
        await db.execute(
            'ALTER TABLE inventory_items ADD COLUMN buyPrice REAL NOT NULL DEFAULT 0.0');
        print('buyPrice column added successfully');
      } else {
        print('buyPrice column already exists, skipping');
      }
      if (!(await columnExists(db, 'inventory_items', 'sellPrice'))) {
        await db.execute(
            'ALTER TABLE inventory_items ADD COLUMN sellPrice REAL NOT NULL DEFAULT 0.0');
        print('sellPrice column added successfully');
      } else {
        print('sellPrice column already exists, skipping');
      }
    }

    if (oldVersion < 6) {
      print('Ensuring all columns exist in inventory_items table');
      final columns =
          await db.rawQuery('PRAGMA table_info(inventory_items)');
      final columnNames = columns.map((column) => column['name'] as String).toList();
      if (!columnNames.contains('buyPrice')) {
        await db.execute(
            'ALTER TABLE inventory_items ADD COLUMN buyPrice REAL NOT NULL DEFAULT 0.0');
        print('buyPrice column added successfully');
      }
      if (!columnNames.contains('sellPrice')) {
        await db.execute(
            'ALTER TABLE inventory_items ADD COLUMN sellPrice REAL NOT NULL DEFAULT 0.0');
        print('sellPrice column added successfully');
      }
      if (!columnNames.contains('lowStockThreshold')) {
        await db.execute(
            'ALTER TABLE inventory_items ADD COLUMN lowStockThreshold REAL NOT NULL DEFAULT 0.0');
        print('lowStockThreshold column added successfully');
      }
      if (!columnNames.contains('quantity')) {
        await db.execute(
            'ALTER TABLE inventory_items ADD COLUMN quantity REAL NOT NULL DEFAULT 0.0');
        print('quantity column added successfully');
      }
    }

    if (oldVersion < 7) {
      print('Finalizing migration for version 7');
      final columns =
          await db.rawQuery('PRAGMA table_info(inventory_items)');
      final columnNames = columns.map((column) => column['name'] as String).toList();
      final requiredColumns = [
        'id',
        'name',
        'quantity',
        'buyPrice',
        'sellPrice',
        'lowStockThreshold'
      ];
      for (var column in requiredColumns) {
        if (!columnNames.contains(column)) {
          print('Missing column $column, adding it');
          await db.execute(
              'ALTER TABLE inventory_items ADD COLUMN $column ${column == 'id' ? 'TEXT PRIMARY KEY' : column == 'name' ? 'TEXT NOT NULL' : 'REAL NOT NULL DEFAULT 0.0'}');
        }
      }
    }

    if (oldVersion < 8) {
      print('Migration for version 8: Standardizing table names and schema');
      // Rename 'inventory' to 'inventory_items' if it exists
      if (await tableExists(db, 'inventory') && !(await tableExists(db, 'inventory_items'))) {
        print('Renaming table inventory to inventory_items');
        await db.execute('ALTER TABLE inventory RENAME TO inventory_items');
      }

      // Rename 'inventory_snapshots' to 'snapshots' if it exists
      if (await tableExists(db, 'inventory_snapshots') && !(await tableExists(db, 'snapshots'))) {
        print('Renaming table inventory_snapshots to snapshots');
        await db.execute('ALTER TABLE inventory_snapshots RENAME TO snapshots');
      }

      // Ensure all tables exist with the correct schema
      if (!(await tableExists(db, 'inventory_items'))) {
        await db.execute('''
          CREATE TABLE inventory_items (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            quantity REAL NOT NULL,
            buyPrice REAL NOT NULL,
            sellPrice REAL NOT NULL,
            lowStockThreshold REAL NOT NULL
          )
        ''');
      }

      if (!(await tableExists(db, 'sales'))) {
        await db.execute('''
          CREATE TABLE sales (
            id TEXT PRIMARY KEY,
            itemName TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            sellingPrice REAL NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      }

      if (!(await tableExists(db, 'snapshots'))) {
        await db.execute('''
          CREATE TABLE snapshots (
            id TEXT PRIMARY KEY,
            itemId TEXT NOT NULL,
            quantity REAL NOT NULL,
            timestamp TEXT NOT NULL,
            timeSlot TEXT NOT NULL,
            weather TEXT NOT NULL,
            FOREIGN KEY (itemId) REFERENCES inventory_items(id)
          )
        ''');
      }

      // Ensure snapshots table has timeSlot and weather columns
      final snapshotColumns = await db.rawQuery('PRAGMA table_info(snapshots)');
      final snapshotColumnNames = snapshotColumns.map((column) => column['name'] as String).toList();
      if (!snapshotColumnNames.contains('timeSlot')) {
        await db.execute('ALTER TABLE snapshots ADD COLUMN timeSlot TEXT NOT NULL DEFAULT "14:00"');
        print('timeSlot column added to snapshots');
      }
      if (!snapshotColumnNames.contains('weather')) {
        await db.execute('ALTER TABLE snapshots ADD COLUMN weather TEXT NOT NULL DEFAULT "Nice"');
        print('weather column added to snapshots');
      }
    }

    if (oldVersion < 9) {
      print('Migration for version 9: Adding isSellable column to inventory_items');
      if (!(await columnExists(db, 'inventory_items', 'isSellable'))) {
        await db.execute(
            'ALTER TABLE inventory_items ADD COLUMN isSellable INTEGER NOT NULL DEFAULT 1');
        // Update existing rows to ensure they have a valid isSellable value
        await db.execute('UPDATE inventory_items SET isSellable = 1 WHERE isSellable IS NULL');
        print('isSellable column added successfully and existing rows updated');
      } else {
        print('isSellable column already exists, skipping');
      }
    }

    print('Database upgrade completed');
  }

  Future<int> insertInventoryItem(InventoryItem item) async {
    final db = await database;
    try {
      final result = await db.insert(
        'inventory_items',
        item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Inserted item with id: ${item.id}, result: $result');
      return result;
    } catch (e) {
      print('Error inserting inventory item: $e');
      rethrow;
    }
  }

  Future<List<InventoryItem>> getInventoryItems() async {
    final db = await database;
    try {
      final maps = await db.query('inventory_items');
      print('Retrieved ${maps.length} inventory items');
      return maps.map((map) => InventoryItem.fromJson(map)).toList();
    } catch (e) {
      print('Error retrieving inventory items: $e');
      rethrow; // Rethrow to allow calling code to handle the error
    }
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    final db = await database;
    try {
      await db.update(
        'inventory_items',
        item.toJson(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
      print('Updated item with id: ${item.id}');
    } catch (e) {
      print('Error updating inventory item: $e');
      rethrow;
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    final db = await database;
    try {
      await db.delete(
        'inventory_items',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Deleted item with id: $id');
    } catch (e) {
      print('Error deleting inventory item: $e');
      rethrow;
    }
  }

  Future<void> insertSale(Sale sale) async {
    final db = await database;
    try {
      await db.insert(
        'sales',
        sale.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Inserted sale with id: ${sale.id}');
    } catch (e) {
      print('Error inserting sale: $e');
      rethrow;
    }
  }

  Future<void> deleteSale(String id) async {
    final db = await database;
    try {
      await db.delete(
        'sales',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Deleted sale with id: $id');
    } catch (e) {
      print('Error deleting sale: $e');
      rethrow;
    }
  }

  Future<List<Sale>> getSales() async {
    final db = await database;
    try {
      final maps = await db.query('sales');
      print('Retrieved ${maps.length} sales');
      return maps.map((map) => Sale.fromJson(map)).toList();
    } catch (e) {
      print('Error retrieving sales: $e');
      rethrow;
    }
  }

  Future<void> insertSnapshot(InventorySnapshot snapshot) async {
    final db = await database;
    try {
      await db.insert(
        'snapshots',
        snapshot.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Inserted snapshot with id: ${snapshot.id}');
    } catch (e) {
      print('Error inserting snapshot: $e');
      rethrow;
    }
  }

  Future<List<InventorySnapshot>> getSnapshots() async {
    final db = await database;
    try {
      final maps = await db.query('snapshots');
      print('Retrieved ${maps.length} snapshots');
      return maps.map((map) => InventorySnapshot.fromJson(map)).toList();
    } catch (e) {
      print('Error retrieving snapshots: $e');
      rethrow;
    }
  }

  // Utility method to clear the database (for testing or debugging)
  Future<void> clearDatabase() async {
    final db = await database;
    try {
      await db.delete('inventory_items');
      await db.delete('sales');
      await db.delete('snapshots');
      print('Database cleared successfully');
    } catch (e) {
      print('Error clearing database: $e');
      rethrow;
    }
  }
}