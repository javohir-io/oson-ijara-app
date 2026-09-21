import 'dart:async';

import 'package:flutter/material.dart';
import '../data/property_store.dart';
import '../services/auth_store.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'main_shell.dart';

void _showResetPasswordDialog(BuildContext context) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.ivory,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text("Parolni tiklash"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Elektron pochtangizni kiriting, biz tiklash havolasini yuboramiz.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Elektron pochta"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Bekor qilish")),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(controller.text.trim().isEmpty
                  ? "Elektron pochta kiritilmadi"
                  : "Tiklash havolasi ${controller.text.trim()} manziliga yuborildi")),
            );
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
          child: const Text("Yuborish"),
        ),
      ],
    ),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Elektron pochta va parolni kiriting")),
      );
      return;
    }

    setState(() => _loading = true);
    final error = await AuthStore.instance.login(email: email, password: password);
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    unawaited(PropertyStore.instance.fetchAll());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppColors.heroGradient),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: AppColors.navy.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: const Icon(Icons.villa_outlined, color: AppColors.gold, size: 36),
                    ),
                    const SizedBox(height: 20),
                    Text('OsonIjara',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    const Text("Hayotingizni yanada oson qiladi!",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              CustomTextField(
                hint: "Elektron pochtangizni kiriting",
                icon: Icons.person_outline,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              CustomTextField(
                hint: "Parolni kiriting",
                icon: Icons.lock_outline,
                obscureText: true,
                controller: _passwordController,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showResetPasswordDialog(context),
                  style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
                  child: const Text("Parolni unutdingizmi?"),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                    : const Text("TIZIMGA KIRISH"),
              ),
              const SizedBox(height: 22),
              Center(
                child: Text("Akkaunt yo'qmi?", style: TextStyle(color: AppColors.textMuted.withOpacity(0.8))),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.mist,
                  side: BorderSide.none,
                ),
                child: const Text("RO'YXATDAN O'TISH"),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
