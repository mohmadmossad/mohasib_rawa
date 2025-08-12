import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'db.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/backup_settings.dart';
import 'screens/products_screen.dart';
import 'screens/invoices_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarService = await Db.openIsar();
  runApp(MyApp(isarService: isarService));
}

class MyApp extends StatelessWidget {
  final IsarService isarService;
  MyApp({required this.isarService});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorSchemeSeed: Colors.teal,
      useMaterial3: true,
      textTheme: GoogleFonts.cairoTextTheme(),
    );
    return MultiProvider(
      providers: [
        Provider<IsarService>.value(value: isarService),
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'محاسب روعة',
        theme: theme,
        home: Directionality(textDirection: TextDirection.rtl, child: AuthScreen()),
        routes: {
          '/reports': (_) => Directionality(textDirection: TextDirection.rtl, child: ReportsScreen()),
          '/permissions': (_) => Directionality(textDirection: TextDirection.rtl, child: PermissionsScreen()),
          '/backup': (_) => Directionality(textDirection: TextDirection.rtl, child: BackupSettingsScreen()),
          '/products': (_) => Directionality(textDirection: TextDirection.rtl, child: ProductsScreen()),
          '/invoices': (_) => Directionality(textDirection: TextDirection.rtl, child: InvoicesScreen()),
          '/settings': (_) => Directionality(textDirection: TextDirection.rtl, child: SettingsScreen()),
        },
      ),
    );
  }
}