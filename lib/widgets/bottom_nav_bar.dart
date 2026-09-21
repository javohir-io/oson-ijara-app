import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  static const _icons = [
    Icons.home_outlined,
    Icons.bookmark_border_rounded,
    Icons.add,
    Icons.person_outline,
  ];
  static const _iconsSelected = [
    Icons.home_rounded,
    Icons.bookmark_rounded,
    Icons.add,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ivory,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_icons.length, (i) {
              final selected = currentIndex == i;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.navyTint : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selected ? _iconsSelected[i] : _icons[i],
                    color: selected ? AppColors.navy : AppColors.textMuted,
                    size: 24,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
