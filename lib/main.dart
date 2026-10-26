import 'package:flutter/material.dart';
import 'pages/menu_page.dart';
import 'pages/welcom_page.dart';
import 'service/api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GATIX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<String?> _token;

  @override 
  void initState() {
    super.initState();
    _token = ApiService.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _token,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: CircularProgressIndicator()
          );
        }

        return snapshot.data != null ? MenuPage() : SplashPage();
      },
    );
  }
}
