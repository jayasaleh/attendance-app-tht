import 'package:flutter/material.dart';
import 'screen/login_screen.dart';
import 'screen/attendance_screen.dart';
import 'screen/history_screen.dart';
import 'services/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _resolveInitialRoute();
  }

  Future<void> _resolveInitialRoute() async {
    final name = await StorageService().getUserName();
    setState(() {
      _initialRoute = (name == null) ? '/' : '/attendance';
    });
  }

  @override
  Widget build(BuildContext context) {
    final route = _initialRoute;
    return MaterialApp(
      title: 'Absensi Lokasi + Kamera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const LoginScreen(),
        '/attendance': (context) => const AttendanceScreen(),
        '/history': (context) => const HistoryScreen(),
      },
      initialRoute: route ?? '/',
      debugShowCheckedModeBanner: false,
    );
  }
}
