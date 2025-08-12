import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db.dart';
import '../models.dart';
import 'invoice_detail_screen.dart';

class InvoicesScreen extends StatefulWidget {
  @override
  _InvoicesScreenState createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  late IsarService isar;
  List<TransactionEntry> entries = [];

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    isar = Provider.of<IsarService>(context);
    _load();
  }

  Future<void> _load() async {
    entries = await isar.getAllEntries();
    setState(() {});
  }

  Future<void> _openNew(bool isSale) async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => InvoiceDetailScreen(isSale: isSale)));
    if (res == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الفواتير والسندات')),
      body: ListView(children: entries.map((e)=>Card(child: ListTile(title: Text(e.description), subtitle: Text('${e.amount}')))).toList()),
      floatingActionButton: Column(mainAxisSize: MainAxisSize.min, children: [
        FloatingActionButton.extended(onPressed: ()=>_openNew(true), label: Text('فاتورة مبيعات')),
        SizedBox(height: 8),
        FloatingActionButton.extended(onPressed: ()=>_openNew(false), label: Text('فاتورة مشتريات')),
      ],),
    );
  }
}