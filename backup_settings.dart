import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/drive_service.dart';
import '../db.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

class BackupSettingsScreen extends StatefulWidget {
  @override
  _BackupSettingsScreenState createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  final DriveService _drive = DriveService();
  bool _busy = false;

  Future<File> _createZip(IsarService isar) async {
    final dir = await getApplicationSupportDirectory();
    final encoder = ZipFileEncoder();
    final zipPath = '${dir.path}/backup_${DateTime.now().millisecondsSinceEpoch}.zip';
    encoder.create(zipPath);
    final d = Directory(dir.path);
    d.listSync().forEach((f) {
      if (f is File) encoder.addFile(f);
    });
    encoder.close();
    return File(zipPath);
  }

  Future<void> _backup() async {
    setState(()=>_busy=true);
    final isar = Provider.of<IsarService>(context, listen:false);
    final zip = await _createZip(isar);
    final ok = await _drive.signIn();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل تسجيل الدخول إلى Google')));
      setState(()=>_busy=false);
      return;
    }
    final file = await _drive.uploadFile(zip);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم رفع النسخة: ${file?.name ?? '—'}')));
    setState(()=>_busy=false);
  }

  Future<void> _restore() async {
    // For demo: restoration requires listing files and downloading the archive then replacing isar files.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ميزة الاستعادة: تحتاج تنفيذ تنزيل الملف واستخراج المحتوى')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('النسخ الاحتياطي إلى Google Drive')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Text('حفظ نسخة احتياطية من قاعدة البيانات على Google Drive', style: TextStyle(fontSize: 16)),
          SizedBox(height: 12),
          ElevatedButton.icon(onPressed: _busy?null:_backup, icon: Icon(Icons.backup), label: Text('إنشاء ورفع نسخة')),
          SizedBox(height: 8),
          ElevatedButton.icon(onPressed: _busy?null:_restore, icon: Icon(Icons.restore), label: Text('استعادة نسخة')),
          if (_busy) Padding(padding: EdgeInsets.only(top:12), child: CircularProgressIndicator()),
        ],),
      ),
    );
  }
}