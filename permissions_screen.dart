import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db.dart';
import '../models.dart';
import '../services/auth_service.dart';

final allPermissions = [
  'clients_add','clients_edit','clients_delete',
  'suppliers_add','suppliers_edit','suppliers_delete',
  'invoices_add','invoices_edit','invoices_delete','invoices_view',
  'reports_view','backup_use','printers_use'
];

class PermissionsScreen extends StatefulWidget {
  @override
  _PermissionsScreenState createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  late IsarService isar;
  List<AppUser> users = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isar = Provider.of<IsarService>(context);
    _load();
  }

  Future<void> _load() async {
    users = await isar.getAllUsers();
    setState(() {});
  }

  Future<void> _addUser() async {
    final u = AppUser()..username='user${DateTime.now().millisecondsSinceEpoch}'..passwordHash='123'..permissions=['invoices_view'];
    await isar.addUser(u);
    await _load();
  }

  void _edit(AppUser u) {
    showDialog(context: context, builder: (ctx) {
      final selected = Set<String>.from(u.permissions);
      return AlertDialog(
        title: Text('تعديل صلاحيات ${u.username}'),
        content: SingleChildScrollView(child: Column(
          children: allPermissions.map((p) => CheckboxListTile(value: selected.contains(p), title: Text(p), onChanged: (v){ setState(()=> v==true? selected.add(p): selected.remove(p)); })).toList(),
        )),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(ctx), child: Text('إلغاء')),
          ElevatedButton(onPressed: () async {
            u.permissions = selected.toList();
            await isar.addUser(u);
            await _load();
            Navigator.pop(ctx);
          }, child: Text('حفظ')),
        ],
      );
    });
  }

  void _delete(AppUser u) async {
    await isar.isar.writeTxn(() async { await isar.isar.appUsers.delete(u.id); });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('إدارة المستخدمين والصلاحيات')),
      body: ListView(children: [
        ...users.map((u) => Card(child: ListTile(title: Text(u.username), subtitle: Text(u.permissions.join(', ')),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: Icon(Icons.edit), onPressed: ()=>_edit(u)),
            IconButton(icon: Icon(Icons.delete), onPressed: ()=>_delete(u)),
          ]),
        ))),
        SizedBox(height:12),
        ElevatedButton(onPressed: _addUser, child: Text('إضافة مستخدم')),
      ],),
    );
  }
}