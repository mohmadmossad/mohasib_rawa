import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/scheduler.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool autoBackup = false;

  @override
  void initState() {
    super.initState();
    Scheduler.init(); // initialize scheduler (no-op in web)
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('الإعدادات')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          ListTile(title: Text('المستخدم الحالي'), subtitle: Text('${auth.username ?? '—'}')),
          SwitchListTile(title: Text('النسخ الاحتياطي التلقائي (يومي)'), value: autoBackup, onChanged: (v) {
            setState(()=>autoBackup=v);
            if (v) Scheduler.scheduleDailyBackup(); else Scheduler.cancelBackup();
          }),
          SizedBox(height:12),
          ElevatedButton(onPressed: ()=>Navigator.pushNamed(context, '/backup'), child: Text('النسخ الاحتياطي الآن')),
        ],),
      ),
    );
  }
}