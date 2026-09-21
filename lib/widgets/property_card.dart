import 'package:flutter/material.dart';
import '../models/property.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class PropertyPhotoPlaceholder extends StatelessWidget {
  final List<Color> gradient;
  final IconData icon;
  final double height;
  final BorderRadius? borderRadius;

  const PropertyPhotoPlaceholder({
    super.key,
    required this.gradient,
    this.icon = Icons.villa_outlined,
    this.height = 180,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(icon, size: 130, color: Colors.white.withOpacity(0.14)),
            ),
            Center(
              child: Icon(icon, size: 46, color: Colors.white.withOpacity(0.85)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a property's real uploaded photo at [index] when one exists,
/// falling back to a deterministic gradient placeholder otherwise (and on
/// load error/while loading).
class PropertyPhoto extends StatelessWidget {
  final Property property;
  final int index;
  final double height;
  final BorderRadius? borderRadius;

  const PropertyPhoto({
    super.key,
    required this.property,
    this.index = 0,
    this.height = 180,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = PropertyPhotoPlaceholder(
      gradient: property.placeholderGradient,
      icon: property.placeholderIcon,
      height: height,
      borderRadius: borderRadius,
    );

    if (index >= property.images.length) return placeholder;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        property.images[index].url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return placeholder;
        },
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.navy.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                PropertyPhoto(property: property, height: 180),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onToggleSave,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        property.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 18,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(property.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text(formatListingDate(property.createdAt),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 15, color: AppColors.oceanBlue),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(property.location,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      Text("So'm ${formatPrice(property.price)} / ${property.priceUnit}",
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.goldDark, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
