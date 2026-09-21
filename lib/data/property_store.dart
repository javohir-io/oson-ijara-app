import 'package:flutter/foundation.dart';

import '../models/picked_image.dart';
import '../models/property.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Holds the property list fetched from the backend and keeps it in sync
/// as the user creates, edits, and bookmarks listings.
class PropertyStore extends ChangeNotifier {
  PropertyStore._internal();
  static final PropertyStore instance = PropertyStore._internal();

  List<Property> _properties = [];
  bool isLoading = false;
  String? error;
  bool _hasLoadedOnce = false;

  List<Property> get all => List.unmodifiable(_properties);
  List<Property> get saved => _properties.where((p) => p.isSaved).toList();
  bool get hasLoadedOnce => _hasLoadedOnce;

  Property? byId(int id) {
    try {
      return _properties.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clears everything — call this on logout so the next login starts clean.
  void reset() {
    _properties = [];
    isLoading = false;
    error = null;
    _hasLoadedOnce = false;
    notifyListeners();
  }

  Future<void> fetchAll() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final data = await ApiClient.instance.listProperties(limit: 200);
      final items = (data['items'] as List<dynamic>? ?? [])
          .map((e) => Property.fromJson(e as Map<String, dynamic>))
          .toList();
      _properties = items;
      _hasLoadedOnce = true;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Optimistically flips the bookmark locally, then confirms with the
  /// server; rolls back if the request fails. Returns an error message on
  /// failure, or null on success.
  Future<String?> toggleSave(int id) async {
    final index = _properties.indexWhere((e) => e.id == id);
    if (index == -1) return null;

    final previous = _properties[index].isSaved;
    _properties[index].isSaved = !previous;
    notifyListeners();

    try {
      final result = await ApiClient.instance.toggleSave(id);
      _properties[index].isSaved = result['saved'] as bool? ?? !previous;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _properties[index].isSaved = previous; // roll back
      notifyListeners();
      return e.message;
    }
  }

  /// Returns the created property on success, or throws [ApiException].
  Future<Property> addProperty(Map<String, dynamic> payload) async {
    final data = await ApiClient.instance.createProperty(payload);
    final created = Property.fromJson(data);
    _properties.insert(0, created);
    notifyListeners();
    return created;
  }

  /// Returns the updated property on success, or throws [ApiException].
  Future<Property> updateProperty(int id, Map<String, dynamic> payload) async {
    final data = await ApiClient.instance.updateProperty(id, payload);
    final updated = Property.fromJson(data);
    final index = _properties.indexWhere((e) => e.id == id);
    if (index != -1) {
      _properties[index] = updated;
    } else {
      _properties.insert(0, updated);
    }
    notifyListeners();
    return updated;
  }

  Future<void> deleteProperty(int id) async {
    await ApiClient.instance.deleteProperty(id);
    _properties.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Uploads one or more picked photos for [propertyId] and merges the
  /// resulting property (with its full images list) back into the cache.
  Future<Property> uploadImages(int propertyId, List<PickedImage> images) async {
    final data = await ApiClient.instance.uploadPropertyImages(propertyId, images);
    final updated = Property.fromJson(data);
    final index = _properties.indexWhere((e) => e.id == propertyId);
    if (index != -1) {
      _properties[index] = updated;
    } else {
      _properties.insert(0, updated);
    }
    notifyListeners();
    return updated;
  }

  Future<Property> deleteImage(int propertyId, int imageId) async {
    final data = await ApiClient.instance.deletePropertyImage(propertyId, imageId);
    final updated = Property.fromJson(data);
    final index = _properties.indexWhere((e) => e.id == propertyId);
    if (index != -1) {
      _properties[index] = updated;
    }
    notifyListeners();
    return updated;
  }
}
