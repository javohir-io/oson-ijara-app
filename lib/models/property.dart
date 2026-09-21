import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PropertyImage {
  final int id;
  final String url;

  PropertyImage({required this.id, required this.url});

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(id: json['id'] as int, url: json['url'] as String);
  }
}

class Property {
  final int id;
  final String title;
  final String description;
  final String location;
  final double price;
  final String priceUnit; // "Kun" | "Oy"
  final int bedrooms;
  final int bathrooms;
  final int floor;
  final double area;
  final String renovation;
  final List<String> amenities;
  final bool studentFriendly;
  final DateTime createdAt;
  final int ownerId;
  final String ownerName;
  final String? ownerPhone;
  final String? ownerAvatarUrl;
  final List<PropertyImage> images;
  bool isSaved;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.priceUnit,
    required this.bedrooms,
    required this.bathrooms,
    required this.floor,
    required this.area,
    required this.renovation,
    required this.amenities,
    required this.studentFriendly,
    required this.createdAt,
    required this.ownerId,
    required this.ownerName,
    this.ownerPhone,
    this.ownerAvatarUrl,
    this.images = const [],
    this.isSaved = false,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>? ?? {};
    return Property(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      priceUnit: json['price_unit'] as String? ?? 'Oy',
      bedrooms: json['bedrooms'] as int? ?? 1,
      bathrooms: json['bathrooms'] as int? ?? 1,
      floor: json['floor'] as int? ?? 1,
      area: (json['area'] as num?)?.toDouble() ?? 0,
      renovation: json['renovation'] as String? ?? "O'rtacha",
      amenities: (json['amenities'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      studentFriendly: json['student_friendly'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      ownerId: owner['id'] as int? ?? 0,
      ownerName: owner['full_name'] as String? ?? 'Foydalanuvchi',
      ownerPhone: owner['phone'] as String?,
      ownerAvatarUrl: owner['avatar_url'] as String?,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => PropertyImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      isSaved: json['is_saved'] as bool? ?? false,
    );
  }

  /// A stable, good-looking gradient derived from the id, used as a photo
  /// placeholder until the listing has real uploaded photos.
  List<Color> get placeholderGradient {
    const palettes = [
      [AppColors.navy, AppColors.oceanBlue],
      [AppColors.darkBlue, AppColors.skyBlue],
      [AppColors.oceanBlue, AppColors.gold],
      [AppColors.navy, AppColors.darkBlue],
    ];
    return palettes[id % palettes.length];
  }

  IconData get placeholderIcon {
    const icons = [
      Icons.villa_outlined,
      Icons.house_outlined,
      Icons.apartment_outlined,
      Icons.holiday_village_outlined,
    ];
    return icons[id % icons.length];
  }
}
