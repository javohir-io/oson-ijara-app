import 'package:flutter/material.dart';
import '../data/property_store.dart';
import '../models/filter_criteria.dart';
import '../theme/app_colors.dart';
import '../widgets/property_card.dart';
import 'filter_screen.dart';
import 'property_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  FilterCriteria _criteria = const FilterCriteria();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: PropertyStore.instance,
        builder: (context, _) {
          final store = PropertyStore.instance;
          final properties = store.all.where((p) {
            final matchesQuery = _query.isEmpty ||
                p.title.toLowerCase().contains(_query) ||
                p.location.toLowerCase().contains(_query);
            // Only apply filter criteria once the user has actually touched
            // the Filter screen — otherwise every listing gets silently
            // compared against the filter's default thresholds (e.g. a
            // 150,000 so'm price floor) even though nothing was "filtered".
            final matchesFilter = !_criteria.isActive || _criteria.matches(p);
            return matchesQuery && matchesFilter;
          }).toList();

          return RefreshIndicator(
            color: AppColors.navy,
            onRefresh: store.fetchAll,
            child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(colors: AppColors.heroGradient)
                                .createShader(bounds),
                            child: Text('OsonIjara',
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.ivory,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                                      decoration: const InputDecoration(
                                        hintText: "Manzil yoki sizga yaqin joyni qidiring",
                                        border: InputBorder.none,
                                        isCollapsed: true,
                                        filled: false,
                                      ),
                                      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                                    ),
                                  ),
                                  if (_query.isNotEmpty)
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        _searchController.clear();
                                        _query = '';
                                      }),
                                      child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.of(context)
                                  .push<FilterCriteria>(MaterialPageRoute(builder: (_) => FilterScreen(initial: _criteria)));
                              if (result != null) setState(() => _criteria = result);
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: AppColors.heroGradient),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: AppColors.navy.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  const Center(child: Icon(Icons.tune_rounded, color: Colors.white, size: 22)),
                                  if (_criteria.isActive)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_criteria.isActive) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.filter_alt_rounded, size: 16, color: AppColors.oceanBlue),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: Text("Filtrlar qo'llanildi", style: TextStyle(fontSize: 12.5, color: AppColors.oceanBlue, fontWeight: FontWeight.w600)),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _criteria = const FilterCriteria()),
                              child: const Text("Tozalash", style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
              if (store.isLoading && !store.hasLoadedOnce)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(child: CircularProgressIndicator(color: AppColors.navy)),
                  ),
                )
              else if (store.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 44, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(store.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 16),
                        OutlinedButton(onPressed: store.fetchAll, child: const Text("Qayta urinish")),
                      ],
                    ),
                  ),
                )
              else if (properties.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
                    child: Column(
                      children: store.all.isEmpty
                          ? const [
                              Icon(Icons.home_work_outlined, size: 44, color: AppColors.textMuted),
                              SizedBox(height: 12),
                              Text("Hozircha birorta ham e'lon yo'q",
                                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                              SizedBox(height: 6),
                              Text("Pastdagi + tugmasi orqali birinchi e'loningizni joylashtiring",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                            ]
                          : const [
                              Icon(Icons.search_off_rounded, size: 44, color: AppColors.textMuted),
                              SizedBox(height: 12),
                              Text("Hech narsa topilmadi", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                            ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.builder(
                    itemCount: properties.length,
                    itemBuilder: (context, i) {
                      final p = properties[i];
                      return PropertyCard(
                        property: p,
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p))),
                        onToggleSave: () async {
                          final error = await store.toggleSave(p.id);
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
            ),
          );
        },
      ),
    );
  }
}
