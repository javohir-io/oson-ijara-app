import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/picked_image.dart';
import '../services/auth_store.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _nameController = TextEditingController(text: AuthStore.instance.currentUser?.fullName ?? '');
  late final _emailController = TextEditingController(text: AuthStore.instance.currentUser?.email ?? '');
  late final _phoneController = TextEditingController(text: AuthStore.instance.currentUser?.phone ?? '');
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _uploadingAvatar = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    final file = result?.files.first;
    if (file?.bytes == null) return;

    setState(() => _uploadingAvatar = true);
    final error = await AuthStore.instance.uploadAvatar(
      PickedImage(bytes: file!.bytes!, filename: file.name),
    );
    if (!mounted) return;
    setState(() => _uploadingAvatar = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rasm yangilandi")));
    }
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final error = await AuthStore.instance.updateProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.isEmpty ? null : _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil yangilandi")),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthStore.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: const Text("Profilni tahrirlash"),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: AppColors.heroGradient),
                    ),
                    child: _uploadingAvatar
                        ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                        : (user?.avatarUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  user!.avatarUrl!,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person, color: Colors.white, size: 46),
                                ),
                              )
                            : const Icon(Icons.person, color: Colors.white, size: 46)),
                  ),
                  GestureDetector(
                    onTap: _uploadingAvatar ? null : _pickAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 16, color: AppColors.navy),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _uploadingAvatar ? null : _pickAvatar,
                child: const Text("Rasmni o'zgartirish"),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: CustomTextField(
                  label: "Foydalanuvchi nomi",
                  hint: "To'liq ismingiz",
                  controller: _nameController,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: CustomTextField(
                  label: "Elektron pochta",
                  hint: "Elektron pochtangiz",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: CustomTextField(
                  label: "Telefon raqami",
                  hint: "+998 90 123 45 67",
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  icon: Icons.phone_outlined,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: CustomTextField(
                  label: "Parol",
                  hint: "O'zgartirish uchun yangi parol kiriting",
                  obscureText: true,
                  controller: _passwordController,
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
                    : const Text("Yangilash"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
