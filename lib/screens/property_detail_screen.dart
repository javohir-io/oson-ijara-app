import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/property_store.dart';
import '../models/property.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/property_card.dart';
import '../widgets/rounded_chip.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late final PageController _pageController = PageController();
  int _page = 0;
  bool _expanded = false;

  Future<void> _toggleSave(int id) async {
    final error = await PropertyStore.instance.toggleSave(id);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    return Scaffold(
      body: ListenableBuilder(
        listenable: PropertyStore.instance,
        builder: (context, _) {
          final current = PropertyStore.instance.byId(p.id) ?? p;
          final photoCount = current.images.isEmpty ? 1 : current.images.length;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 260,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: photoCount,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (context, i) => PropertyPhoto(property: current, index: i, height: 260),
                      ),
                    ),
                    Positioned(
                      top: 48,
                      left: 16,
                      child: _circleIconButton(Icons.arrow_back, () => Navigator.of(context).pop()),
                    ),
                    Positioned(
                      top: 48,
                      right: 16,
                      child: _circleIconButton(
                        current.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        () => _toggleSave(current.id),
                      ),
                    ),
                    if (photoCount > 1) ...[
                      Positioned(
                        left: 6,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _circleIconButton(Icons.chevron_left, () {
                            if (_page > 0) _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.ease);
                          }, small: true),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _circleIconButton(Icons.chevron_right, () {
                            if (_page < photoCount - 1) {
                              _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.ease);
                            }
                          }, small: true),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(photoCount, (i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _page == i ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _page == i ? Colors.white : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(current.title, style: Theme.of(context).textTheme.headlineMedium)),
                          const SizedBox(width: 8),
                          Text(formatDate(current.createdAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.oceanBlue),
                          const SizedBox(width: 4),
                          Text(current.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Divider(),
                      const SizedBox(height: 14),
                      Text("Tavsif", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      Text(
                        current.description,
                        maxLines: _expanded ? null : 3,
                        overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _expanded ? "Kamroq ko'rsatish" : "Ko'proq ko'rsatish",
                            style: const TextStyle(color: AppColors.oceanBlue, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Icon(Icons.bed_outlined, color: AppColors.navy, size: 20),
                          const SizedBox(width: 6),
                          Text("${current.bedrooms} Yotoq Xonalar", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(width: 24),
                          const Icon(Icons.bathtub_outlined, color: AppColors.navy, size: 20),
                          const SizedBox(width: 6),
                          Text("${current.bathrooms} Hammom", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          DetailTag(
                            label: current.amenities.isEmpty
                                ? "Qulayliklar ko'rsatilmagan"
                                : "Qulayliklar: ${current.amenities.join(', ')}",
                          ),
                          DetailTag(label: "Ta'mir", value: current.renovation),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          DetailTag(icon: Icons.location_on_outlined, label: "Manzil", value: current.location),
                          DetailTag(label: "Qavat", value: '${current.floor}'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DetailTag(label: "Maydon", value: '${formatPrice(current.area)} m²'),
                      const SizedBox(height: 22),
                      Text("So'm ${formatPrice(current.price)} / ${current.priceUnit}",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.goldDark)),
                      const SizedBox(height: 22),
                      const Divider(),
                      const SizedBox(height: 14),
                      Text("Foydalanuvchi:", style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.oceanBlue.withOpacity(0.15),
                            backgroundImage: current.ownerAvatarUrl != null ? NetworkImage(current.ownerAvatarUrl!) : null,
                            child: current.ownerAvatarUrl == null
                                ? const Icon(Icons.person, color: AppColors.oceanBlue)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(current.ownerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                Text("Uy egasi", style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _toggleSave(current.id),
                            icon: Icon(
                              current.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: AppColors.navy,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _showContactSheet(context, current),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
                            child: const Text("Bog'lanish"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showContactSheet(BuildContext context, Property current) {
    final phone = current.ownerPhone;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            decoration: BoxDecoration(color: AppColors.ivory, borderRadius: BorderRadius.circular(22)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.oceanBlue.withOpacity(0.15),
                      backgroundImage: current.ownerAvatarUrl != null ? NetworkImage(current.ownerAvatarUrl!) : null,
                      child: current.ownerAvatarUrl == null
                          ? const Icon(Icons.person, color: AppColors.oceanBlue)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(current.ownerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                          const Text("Uy egasi", style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      const Icon(Icons.call_outlined, color: AppColors.navy, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(phone ?? "Telefon raqami ko'rsatilmagan",
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14.5)),
                      ),
                      if (phone != null)
                        TextButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: phone));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Raqam nusxalandi")),
                            );
                          },
                          child: const Text("Nusxalash"),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: phone == null
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("${current.ownerName}ga qo'ng'iroq qilinmoqda...")),
                                );
                              },
                        icon: const Icon(Icons.call, size: 18),
                        label: const Text("Qo'ng'iroq"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Xabar oynasi tez orada qo'shiladi")),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: const Text("Xabar"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap, {bool small = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: small ? 32 : 40,
        height: small ? 32 : 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: small ? 18 : 20),
      ),
    );
  }
}
