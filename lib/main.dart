
/// ---------------- lib/main.dart ----------------
import 'package:flutter/material.dart';
import 'config/backend_config.dart';
import 'screens/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackendConfig.initParse();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo Back4App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LoginView(),
    );
  }
}
