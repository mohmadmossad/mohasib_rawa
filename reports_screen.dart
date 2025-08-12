import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db.dart';
import '../models.dart';
import 'printer_helper.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late IsarService isarService;
  double totalSales = 0;
  double totalPurchases = 0;
  List<Party> parties = [];

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    isarService = Provider.of<IsarService>(context);
    _compute();
  }

  Future<void> _compute() async {
    final entries = await isarService.getAllEntries();
    setState(() {
      totalSales = entries.where((e) => e.entryType == EntryType.invoiceSale).fold(0.0, (a,b)=>a+b.amount);
      totalPurchases = entries.where((e) => e.entryType == EntryType.invoicePurchase).fold(0.0, (a,b)=>a+b.amount);
    });
    parties = await isarService.getAllParties();
  }

  Future<void> _exportExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['تقرير'];
    sheetObject.appendRow(['البيان','المبلغ','النوع']);
    final entries = await isarService.getAllEntries();
    for (var e in entries) {
      sheetObject.appendRow([e.description, e.amount, e.entryType.toString().split('.').last]);
    }
    final bytes = excel.encode();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(bytes!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حفظ الملف: ${file.path}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('التقارير')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('محاسب روعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ListTile(title: Text('الأصناف'), onTap: ()=>Navigator.pushNamed(context, '/products')),
            ListTile(title: Text('الفواتير'), onTap: ()=>Navigator.pushNamed(context, '/invoices')),
            ListTile(title: Text('إدارة المستخدمين'), onTap: ()=>Navigator.pushNamed(context, '/permissions')),
            ListTile(title: Text('النسخ الاحتياطي'), onTap: ()=>Navigator.pushNamed(context, '/backup')),
            ListTile(title: Text('الإعدادات'), onTap: ()=>Navigator.pushNamed(context, '/settings')),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(elevation: 4, child: ListTile(title: Text('إجمالي المبيعات: ${totalSales.toStringAsFixed(2)}'))),
            Card(elevation: 4, child: ListTile(title: Text('إجمالي المشتريات: ${totalPurchases.toStringAsFixed(2)}'))),
            SizedBox(height: 12),
            Row(children: [
              ElevatedButton.icon(onPressed: _exportExcel, icon: Icon(Icons.grid_on), label: Text('تصدير Excel')),
              SizedBox(width: 12),
              ElevatedButton.icon(onPressed: () async { await PrinterHelper.printSummary(totalSales, totalPurchases, parties); }, icon: Icon(Icons.print), label: Text('طباعة/تصدير PDF')),
            ]),
          ],
        ),
      ),
    );
  }
}