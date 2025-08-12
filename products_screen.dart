import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db.dart';
import '../models.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late IsarService isar;
  List<Product> products = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isar = Provider.of<IsarService>(context);
    _load();
  }

  Future<void> _load() async {
    products = await isar.getAllProducts();
    setState(() {});
  }

  Future<void> _add() async {
    final p = Product()..name='منتج ${DateTime.now().millisecondsSinceEpoch}'..barcode='b${DateTime.now().millisecondsSinceEpoch}'..price=50..cost=30..stock=10;
    await isar.addProduct(p);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الأصناف')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 3,
          children: products.map((p) => Card(child: ListTile(title: Text(p.name), subtitle: Text('سعر: ${p.price} | مخزون: ${p.stock}')))).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _add, child: Icon(Icons.add)),
    );
  }
}