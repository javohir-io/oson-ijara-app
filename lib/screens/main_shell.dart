import 'package:flutter/material.dart';
import '../data/property_store.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'saved_screen.dart';
import 'add_listing_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  final _pages = const [
    HomeScreen(),
    SavedScreen(),
    AddListingScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Safety net: if this screen is ever reached without login/register
    // having already triggered a fetch, load the feed now.
    if (!PropertyStore.instance.hasLoadedOnce && !PropertyStore.instance.isLoading) {
      PropertyStore.instance.fetchAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
