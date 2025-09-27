import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/import_page.dart';
import 'pages/all_cases_page.dart';
import 'services/notifications.dart';
import 'services/tz.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initTz();
  await NotiService().init();
  await NotiService().scheduleDailySummary(hour: 7, minute: 30);
  runApp(const VetcareApp());
}

class VetcareApp extends StatelessWidget {
  const VetcareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetCare Post‑Op',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF0BA360)),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/import': (_) => const ImportPage(),
        '/all': (_) => const AllCasesPage(),
      },
    );
  }
}
