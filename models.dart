import 'package:isar/isar.dart';
part 'models.g.dart';

@Collection()
class Party {
  Id id = Isar.autoIncrement;
  late String name;
  @Enumerated()
  PartyType type = PartyType.client;
  String? phone;
  double openingBalance = 0.0;
}

enum PartyType { client, supplier }

@Collection()
class Product {
  Id id = Isar.autoIncrement;
  late String name;
  String? barcode;
  double price = 0.0;
  double cost = 0.0;
  int stock = 0;
}

@Collection()
class TransactionEntry {
  Id id = Isar.autoIncrement;
  late DateTime date;
  late String description;
  @Enumerated()
  EntryType entryType = EntryType.invoiceSale;
  late double amount;
  int? partyId;
  String? invoiceNo;
}

enum EntryType { invoiceSale, invoicePurchase, receipt, payment }

@Collection()
class AppUser {
  Id id = Isar.autoIncrement;
  late String username;
  late String passwordHash;
  List<String> permissions = [];
}