import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models.dart';
import 'dart:io';

class Db {
  static Future<IsarService> openIsar() async {
    final dir = await getApplicationSupportDirectory();
    final isar = await Isar.open([PartySchema, ProductSchema, TransactionEntrySchema, AppUserSchema], directory: dir.path);
    final svc = IsarService(isar);
    await svc._prepareSampleData();
    return svc;
  }
}

class IsarService {
  final Isar isar;
  IsarService(this.isar);

  Future<void> _prepareSampleData() async {
    final cnt = await isar.partys.count();
    if (cnt == 0) {
      await isar.writeTxn(() async {
        final cA = Party()..name='عميل A'..type=PartyType.client..openingBalance=0.0;
        final cB = Party()..name='عميل B'..type=PartyType.client..openingBalance=0.0;
        final sX = Party()..name='مورد X'..type=PartyType.supplier..openingBalance=0.0;
        final sY = Party()..name='مورد Y'..type=PartyType.supplier..openingBalance=0.0;
        await isar.partys.putAll([cA,cB,sX,sY]);

        final p1 = Product()..name='منتج 1'..barcode='123456789'..price=100..cost=60..stock=50;
        final p2 = Product()..name='منتج 2'..barcode='987654321'..price=200..cost=120..stock=20;
        await isar.products.putAll([p1,p2]);

        final u = AppUser()..username='admin'..passwordHash='admin'..permissions=['all'];
        await isar.appUsers.put(u);
      });
    }
  }

  // Parties
  Future<List<Party>> getAllParties() => isar.partys.where().sortByName().findAll();
  Future<int> addParty(Party p) async => await isar.writeTxn(() async => isar.partys.put(p));

  // Products
  Future<List<Product>> getAllProducts() => isar.products.where().sortByName().findAll();
  Future<int> addProduct(Product p) async => await isar.writeTxn(() async => isar.products.put(p));
  Future<Product?> findProductByBarcode(String barcode) async => isar.products.filter().barcodeEqualTo(barcode).findFirst();

  // Entries
  Future<List<TransactionEntry>> getAllEntries() => isar.transactionEntrys.where().sortByDate().findAll();
  Future<int> addEntry(TransactionEntry e) async => await isar.writeTxn(() async => isar.transactionEntrys.put(e));

  // Users
  Future<List<AppUser>> getAllUsers() => isar.appUsers.where().findAll();
  Future<int> addUser(AppUser u) async => await isar.writeTxn(() async => isar.appUsers.put(u));
}