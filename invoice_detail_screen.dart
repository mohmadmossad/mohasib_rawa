import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db.dart';
import '../models.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final bool isSale;
  InvoiceDetailScreen({this.isSale = true});
  @override
  _InvoiceDetailScreenState createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late IsarService isar;
  List<Product> allProducts = [];
  List<Map<String,dynamic>> items = []; // {product, qty, price, discount, tax}
  double total = 0;
  int? selectedPartyId;
  String payType = 'نقدي';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isar = Provider.of<IsarService>(context);
    _load();
  }

  Future<void> _load() async {
    allProducts = await isar.getAllProducts();
    setState(() {});
  }

  Future<void> _scanBarcode() async {
    String barcode = await FlutterBarcodeScanner.scanBarcode('#FF0000', 'إلغاء', true, ScanMode.DEFAULT);
    if (barcode != '-1') {
      final p = await isar.findProductByBarcode(barcode);
      if (p != null) _addProductToItems(p, 1);
    }
  }

  void _addProductToItems(Product p, int qty) {
    items.add({'product':p, 'qty':qty, 'price':p.price, 'discount':0.0, 'tax':0.0});
    _recalc();
  }

  void _recalc() {
    total = items.fold(0.0, (s, it) {
      final sub = (it['price'] * it['qty']) - it['discount'];
      final withTax = sub + (sub * (it['tax']/100));
      return s + withTax;
    });
    setState(() {});
  }

  Future<void> _saveInvoice() async {
    final invoiceNo = 'INV-${DateTime.now().millisecondsSinceEpoch}';
    final entry = TransactionEntry()
      ..date = DateTime.now()
      ..description = widget.isSale ? 'فاتورة مبيعات $invoiceNo' : 'فاتورة مشتريات $invoiceNo'
      ..entryType = widget.isSale ? EntryType.invoiceSale : EntryType.invoicePurchase
      ..amount = total
      ..invoiceNo = invoiceNo
      ..partyId = selectedPartyId;
    await isar.addEntry(entry);
    // تحديث المخزون
    await isar.isar.writeTxn(() async {
      for (var it in items) {
        final Product p = it['product'];
        final int qty = it['qty'];
        final prod = await isar.isar.products.get(p.id);
        if (prod != null) {
          prod.stock = prod.stock - qty;
          await isar.isar.products.put(prod);
        }
      }
    });
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isSale ? 'إصدار فاتورة مبيعات' : 'إصدار فاتورة مشتريات')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Row(children: [
            Expanded(child: DropdownButtonFormField<int>(value: selectedPartyId, items: [DropdownMenuItem(child: Text('اختر طرفاً'), value: null)], onChanged: (v){ selectedPartyId = v; })),
            SizedBox(width: 8),
            DropdownButton<String>(value: payType, items: ['نقدي','آجل'].map((s)=>DropdownMenuItem(child: Text(s), value: s)).toList(), onChanged: (v){ payType = v!; setState((){}); }),
          ]),
          SizedBox(height: 8),
          Row(children: [
            ElevatedButton(onPressed: ()=>_addProductManually(context), child: Text('أضف صنف')),
            SizedBox(width: 8),
            ElevatedButton(onPressed: _scanBarcode, child: Text('مسح باركود')),
          ]),
          SizedBox(height: 8),
          Expanded(child: ListView(children: items.map((it) => ListTile(
            title: Text(it['product'].name),
            subtitle: Text('سعر: ${it['price']} | كمية: ${it['qty']}'),
            trailing: Text('${(it['price']*it['qty']).toStringAsFixed(2)}'),
          )).toList())),
          SizedBox(height: 8),
          Text('الإجمالي: ${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ElevatedButton(onPressed: _saveInvoice, child: Text('حفظ الفاتورة')),
        ],),
      ),
    );
  }

  void _addProductManually(BuildContext ctx) {
    showDialog(context: ctx, builder: (_) {
      Product? selected;
      int qty = 1;
      return AlertDialog(
        title: Text('أضف صنف'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButton<Product>(items: allProducts.map((p)=>DropdownMenuItem(child: Text(p.name), value: p)).toList(), onChanged: (v){ selected = v; }),
          TextField(decoration: InputDecoration(labelText: 'الكمية'), keyboardType: TextInputType.number, onChanged: (v){ qty = int.tryParse(v) ?? 1; }),
        ]),
        actions: [TextButton(onPressed: ()=>Navigator.pop(ctx), child: Text('إلغاء')),
        ElevatedButton(onPressed: (){ if (selected!=null) _addProductToItems(selected!, qty); Navigator.pop(ctx); }, child: Text('إضافة'))],
      );
    });
  }
}