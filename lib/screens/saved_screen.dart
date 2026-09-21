import 'package:flutter/material.dart';
import '../data/property_store.dart';
import '../theme/app_colors.dart';
import '../widgets/property_card.dart';
import 'property_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: PropertyStore.instance,
        builder: (context, _) {
          final saved = PropertyStore.instance.saved;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("SARALANGAN\nUYLAR",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 14),
                      if (saved.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Column(
                            children: [
                              const Icon(Icons.bookmark_border_rounded, size: 44, color: AppColors.textMuted),
                              const SizedBox(height: 14),
                              const Text(
                                "BU YERDA SIZNI QIZIQTIRGAN\nBARCHA UYLAR SAQLANADI",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.5),
                              ),
                              const SizedBox(height: 22),
                              const Divider(),
                              const SizedBox(height: 18),
                              Text.rich(
                                TextSpan(
                                  style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 13),
                                  children: [
                                    const TextSpan(text: "O'ZINGIZGA YOQQAN UYDAGI "),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(Icons.bookmark_rounded, size: 15, color: AppColors.navy),
                                    ),
                                    const TextSpan(text: " BELGISI USTIGA BOSING VA ULAR SHU YERDA PAYDO BO'LADI"),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.builder(
                  itemCount: saved.length,
                  itemBuilder: (context, i) {
                    final p = saved[i];
                    return PropertyCard(
                      property: p,
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p))),
                      onToggleSave: () async {
                        final error = await PropertyStore.instance.toggleSave(p.id);
                        if (error != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                        }
                      },
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }
}
