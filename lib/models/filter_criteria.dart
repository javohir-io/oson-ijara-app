import 'package:flutter/material.dart';
import 'property.dart';

/// Holds the state a person can pick on the Filter screen, and knows how
/// to test whether a given [Property] matches it.
class FilterCriteria {
  final String location; // "Barchasi" = any
  final Set<String> amenities;
  final String floorRange; // "Barchasi" = any
  final String renovation; // "Barchasi" = any
  final String areaRange; // "Barchasi" = any
  final bool studentOnly;
  final RangeValues priceRange;
  final int minBedrooms;
  final int minBathrooms;

  const FilterCriteria({
    this.location = 'Barchasi',
    this.amenities = const {},
    this.floorRange = 'Barchasi',
    this.renovation = 'Barchasi',
    this.areaRange = 'Barchasi',
    this.studentOnly = false,
    this.priceRange = const RangeValues(150000, 90000000),
    this.minBedrooms = 1,
    this.minBathrooms = 1,
  });

  bool get isActive =>
      location != 'Barchasi' ||
      amenities.isNotEmpty ||
      floorRange != 'Barchasi' ||
      renovation != 'Barchasi' ||
      areaRange != 'Barchasi' ||
      studentOnly ||
      priceRange.start > 150000 ||
      priceRange.end < 90000000 ||
      minBedrooms > 1 ||
      minBathrooms > 1;

  bool _inFloorRange(int floor) {
    switch (floorRange) {
      case '1-3':
        return floor >= 1 && floor <= 3;
      case '4-6':
        return floor >= 4 && floor <= 6;
      case '7-10':
        return floor >= 7 && floor <= 10;
      case '10+':
        return floor > 10;
      default:
        return true;
    }
  }

  bool _inAreaRange(double area) {
    switch (areaRange) {
      case '0-100 m²':
        return area <= 100;
      case '100-300 m²':
        return area > 100 && area <= 300;
      case '300-600 m²':
        return area > 300 && area <= 600;
      case '600+ m²':
        return area > 600;
      default:
        return true;
    }
  }

  bool matches(Property p) {
    if (location != 'Barchasi' && p.location != location) return false;
    if (renovation != 'Barchasi' && p.renovation != renovation) return false;
    if (!_inFloorRange(p.floor)) return false;
    if (!_inAreaRange(p.area)) return false;

    if (p.price < priceRange.start || p.price > priceRange.end) return false;

    if (p.bedrooms < minBedrooms) return false;
    if (p.bathrooms < minBathrooms) return false;

    if (amenities.isNotEmpty) {
      final propertyAmenities = p.amenities.map((e) => e.toLowerCase()).toSet();
      final wanted = amenities.map((e) => e.toLowerCase());
      if (!wanted.every(propertyAmenities.contains)) return false;
    }

    if (studentOnly && !p.studentFriendly) return false;

    return true;
  }
}
