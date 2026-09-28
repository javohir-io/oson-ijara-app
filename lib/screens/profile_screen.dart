import 'package:flutter/material.dart';
import '../data/property_store.dart';
import '../services/auth_store.dart';
import '../services/chat_store.dart';
import '../theme/app_colors.dart';
import '../widgets/property_card.dart';
import 'add_listing_screen.dart';
import 'conversations_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: Listenable.merge([PropertyStore.instance, AuthStore.instance]),
        builder: (context, _) {
          final user = AuthStore.instance.currentUser;
          final myListings = user == null
              ? <dynamic>[]
              : PropertyStore.instance.all.where((p) => p.ownerId == user.id).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            child: Column(
              children: [
                Text('Profil', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 22),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: AppColors.heroGradient),
                    boxShadow: [
                      BoxShadow(color: AppColors.navy.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: user?.avatarUrl != null
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
                      : const Icon(Icons.person, color: Colors.white, size: 46),
                ),
                const SizedBox(height: 16),
                Text((user?.fullName ?? '').toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                        child: const Text("Profilni tahrirlash"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ConversationsScreen())),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: const Text("Xabarlar"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("E'lonlar:", style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 14),
                if (myListings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("Hali e'lon joylashtirmadingiz",
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  )
                else
                  Row(
                    children: myListings.take(2).map((p) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              PropertyPhoto(
                                property: p,
                                height: 100,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (_) => AddListingScreen(editing: p))),
                                child: const Text("Tahrirlash"),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 30),
                TextButton.icon(
                  onPressed: () {
                    AuthStore.instance.logout();
                    PropertyStore.instance.reset();
                    ChatStore.instance.disconnect();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.textMuted),
                  label: const Text("Chiqish", style: TextStyle(color: AppColors.textMuted)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
