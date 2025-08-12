import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  String? username;
  List<String> permissions = [];

  Future<void> login(String user, List<String> perms) async {
    username = user;
    permissions = perms;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged', true);
    await prefs.setString('username', user);
    notifyListeners();
  }

  Future<void> logout() async {
    username = null;
    permissions = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  bool can(String perm) {
    if (permissions.contains('all')) return true;
    return permissions.contains(perm);
  }
}