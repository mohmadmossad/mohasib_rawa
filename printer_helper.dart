import 'dart:io';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models.dart';

class PrinterHelper {
  static Future<void> printSummary(double sales, double purchases, List<Party> parties) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (c) {
      return pw.Directionality(textDirection: pw.TextDirection.rtl, child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('تقرير ملخص', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('إجمالي المبيعات: ${sales.toStringAsFixed(2)}'),
          pw.Text('إجمالي المشتريات: ${purchases.toStringAsFixed(2)}'),
          pw.SizedBox(height: 8),
          pw.Text('أرصدة الأطراف:'),
          pw.Column(children: parties.map((p)=>pw.Text('${p.name} (${p.type.toString().split('.').last})')).toList()),
        ],
      ));
    }));
    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'report.pdf');
  }
}