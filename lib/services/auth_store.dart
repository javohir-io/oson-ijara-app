import 'package:flutter/foundation.dart';

import '../models/picked_image.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Holds the logged-in user's session in memory for the lifetime of the app.
///
/// Note: this does NOT persist across app restarts (no shared_preferences /
/// secure storage wired up yet) — closing and reopening the app will land
/// back on the Login screen. That's a reasonable next enhancement once the
/// core flows are solid.
class AuthStore extends ChangeNotifier {
  AuthStore._();
  static final AuthStore instance = AuthStore._();

  AppUser? currentUser;
  bool get isLoggedIn => currentUser != null;

  /// Returns null on success, or an error message to show the user.
  Future<String?> login({required String email, required String password}) async {
    try {
      final data = await ApiClient.instance.login(email: email, password: password);
      ApiClient.instance.token = data['access_token'] as String;
      currentUser = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final data = await ApiClient.instance.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );
      ApiClient.instance.token = data['access_token'] as String;
      currentUser = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> updateProfile({String? fullName, String? email, String? phone, String? password}) async {
    try {
      final data = await ApiClient.instance.updateProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      currentUser = AppUser.fromJson(data);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> uploadAvatar(PickedImage image) async {
    try {
      final data = await ApiClient.instance.uploadAvatar(image);
      currentUser = AppUser.fromJson(data);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  void logout() {
    currentUser = null;
    ApiClient.instance.token = null;
    notifyListeners();
  }
}
