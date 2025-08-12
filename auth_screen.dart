import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db.dart';
import '../services/auth_service.dart';
import '../models.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = true;
  late IsarService isar;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isar = Provider.of<IsarService>(context);
    _checkAuto();
  }

  Future<void> _checkAuto() async {
    final users = await isar.getAllUsers();
    setState(()=> _loading=false);
  }

  Future<void> _login() async {
    final username = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final users = await isar.getAllUsers();
    final match = users.firstWhere((u)=> u.username==username && u.passwordHash==pass, orElse: ()=>AppUser());
    if (match.username!=null && match.username!.isNotEmpty) {
      final auth = Provider.of<AuthService>(context, listen:false);
      await auth.login(match.username!, match.permissions);
      Navigator.pushReplacementNamed(context, '/reports');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل تسجيل الدخول')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text('تسجيل الدخول')),
      body: Padding(padding: EdgeInsets.all(12), child: Column(children: [
        TextField(controller: _userCtrl, decoration: InputDecoration(labelText: 'اسم المستخدم')),
        TextField(controller: _passCtrl, decoration: InputDecoration(labelText: 'كلمة المرور'), obscureText: true),
        SizedBox(height: 12),
        ElevatedButton(onPressed: _login, child: Text('دخول')),
      ],),),
    );
  }
}