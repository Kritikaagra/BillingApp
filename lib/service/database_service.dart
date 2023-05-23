import 'package:billing_app/models/receivable_model.dart';
import 'package:billing_app/models/item_result_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer_model.dart';
import '../models/invoice_model.dart';
import '../models/item_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('Bills.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE customerDetails ( 
    customerId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
    customerName TEXT NOT NULL,
    silverRate DECIMAL NOT NULL,
    purchaseDate TEXT NOT NULL
    )
    ''');

    await db.execute('''
  CREATE TABLE invoiceDetails (
  invoiceId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  customerId INTEGER NOT NULL,
  itemName TEXT NOT NULL,
  itemWeight DECIMAL NOT NULL,
  polyWeight TEXT,
  polyWeightinGm DECIMAL,
  itemRate DECIMAL NOT NULL,
  labourPerKg DECIMAL,
  labourPerPc DECIMAL,
  noOfPc INT,
  fineSilver INT NOT NULL,
  labourNet INT NOT NULL,
  labourInString TEXT
  )
  ''');

    await db.execute('''
  CREATE TABLE itemLookUpDetails (
  itemId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  itemName TEXT NOT NULL,
  wastage DECIMAL NOT NULL,
  labourPerKg DECIMAL,
  labourPerPc DECIMAL,
  polyWeightinGm DECIMAL,
  polyWeight TEXT
  )
  ''');

  await db.execute('''
  CREATE TABLE receivableItems(
  receivableId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  customerId INTEGER NOT NULL,
  itemName TEXT NOT NULL,
  itemWeight DECIMAL NOT NULL,
  itemRate DECIMAL NOT NULL,
  fineSilver DECIMAL NOT NULL,
  labourPerKg DECIMAL,
  labourPerPc DECIMAL,
  noOfPc INT,
  labourNet INT NOT NULL
  )
  ''');
  }

// ------------------------------------------- Customer CRUD ------------------------------
  Future<CustomerModel> insertCustomerDetails(CustomerModel customer) async {
    final db = await instance.database;
    final id = await db.insert("customerDetails", customer.toJson());
    return customer.copyWith(customerId: id);
  }

    Future<List<CustomerModel>> getCustomerList() async{
    final db = await instance.database;
    final res = await db.query("customerDetails");
    return res.map((e) => CustomerModel.fromJson(e)).toList(); 
  }

  // ------------------------------------------- invoice CRUD ------------------------------

  Future<void> insertInvoiceDetails(
      InvoiceModel invoice, ItemModel item, int? invoiceId) async {
    final db = await instance.database;
    insertItemDetails(item);
    if(invoiceId == null){
      await db.insert("invoiceDetails", invoice.toJson());
    }else{
      await db.update("invoiceDetails", invoice.toJson(), where: "invoiceId = ?", whereArgs: [invoiceId]);
    }
  }

  Future<List<InvoiceModel>> getInvoiceDetails(int customerId) async{
    final db = await instance.database;
    final res = await db.query("invoiceDetails", where: "customerId = ?", whereArgs: [customerId]);
    return res.map((e) => InvoiceModel.fromJson(e)).toList(); 
  }

  Future<void> deleteInvoiceId(int invoiceId) async {
    final db = await instance.database;
    await db.delete("invoiceDetails", where: "invoiceId = ?", whereArgs: [invoiceId]);
  }

  // -------------------------------------------item CURD ----------------------------------

  Future<void> insertItemDetails(ItemModel item) async {
    final db = await instance.database;
    final res = await db.query("itemLookUpDetails",
        where: "itemName = ?", whereArgs: [item.itemName]);
    if (res.isEmpty) {
      await db.insert("itemLookUpDetails", item.toJson());
    }else{
      await db.update("itemLookUpDetails", item.toJson(),
       where: "itemName = ?", whereArgs: [item.itemName]);
    }
  }

  Future<List<ItemResultModel>> getItemList() async {
    final db = await instance.database;
    final res = await db.query("itemLookUpDetails");
    return res.map((e) => ItemResultModel.fromJson(e)).toList();
  }

  // -------------------------------------------Receivable CURD ----------------------------------
  Future<void> insertReceivable(ItemPurchaseModel receivableItem, int? receivableId) async {
    final db = await instance.database;
    if(receivableId == null){
      await db.insert("receivableItems", receivableItem.toJson());
    }else{
      await db.update("receivableItems", receivableItem.toJson(), where: "receivableId = ?", whereArgs: [receivableId]);
    }
  }

  Future<List<ItemPurchaseModel>> getReceivable(int customerId) async{
    final db = await instance.database;
    final res = await db.query("receivableItems", where: "customerId = ?", whereArgs: [customerId]);
    //print(res);
    return res.map((e) => ItemPurchaseModel.fromJson(e)).toList(); 
  }

    Future<void> deleteRecevable(int receivableId) async {
    final db = await instance.database;
    await db.delete("receivableItems", where: "receivableId = ?", whereArgs: [receivableId]);
  }

  // Future<void> deleteItem(InvoiceModel item) async {
  //   final db = await instance.database;
  //   await db.delete("item", where: "itemId = ?", whereArgs: [item.itemId]);
  // }

  // Future<void> updateItem(InvoiceModel item) async {
  //   final db = await instance.database;
  //   await db.update("item", item.toJson(),
  //       where: "itemId = ?", whereArgs: [item.itemId]);
  // }

  // Future<void> setDefaultItem(InvoiceModel item) async {
  //   final db = await instance.database;
  //   await db.rawQuery("UPDATE item SET isDefault = 0");
  //   InvoiceModel temp = item.copyWith(isDefault: 1);
  //   await db.update("item", temp.toJson(),
  //       where: "itemId = ?", whereArgs: [item.itemId]);
  // }
}
