import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'services/api_client.dart';

void main() {
  // Best-effort warm-up ping, fired the moment the app launches — matters
  // most against a backend on a free-tier host (e.g. Render) that spins
  // down when idle, so it starts waking up before the person even reaches
  // the login button.
  ApiClient.instance.ping();
  runApp(const OsonIjaraApp());
}

class OsonIjaraApp extends StatelessWidget {
  const OsonIjaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OsonIjara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}
