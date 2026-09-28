import 'dart:async';

import 'package:flutter/material.dart';
import '../data/property_store.dart';
import '../services/auth_store.dart';
import '../services/chat_store.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Barcha maydonlarni to'ldiring")),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Parol kamida 6 ta belgidan iborat bo'lishi kerak")),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Parollar mos kelmadi")),
      );
      return;
    }

    setState(() => _loading = true);
    final error = await AuthStore.instance.register(
      fullName: name,
      email: email,
      password: password,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    unawaited(PropertyStore.instance.fetchAll());
    ChatStore.instance.connect();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ro'yxatdan o'tish", style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              const Text("Hisobingizni yarating va uy qidirishni boshlang",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
              const SizedBox(height: 32),
              CustomTextField(hint: "To'liq ismingiz", icon: Icons.badge_outlined, controller: _nameController),
              CustomTextField(
                hint: "Elektron pochta",
                icon: Icons.mail_outline,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              CustomTextField(
                hint: "Telefon raqami (ixtiyoriy)",
                icon: Icons.phone_outlined,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              CustomTextField(hint: "Parol", icon: Icons.lock_outline, obscureText: true, controller: _passwordController),
              CustomTextField(
                hint: "Parolni tasdiqlash",
                icon: Icons.lock_outline,
                obscureText: true,
                controller: _confirmController,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                    : const Text("RO'YXATDAN O'TISH"),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
