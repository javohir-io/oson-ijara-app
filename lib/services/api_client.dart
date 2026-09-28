import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/picked_image.dart';
import 'api_exception.dart';

/// Thin wrapper around the OsonIjara backend's REST API.
///
/// Holds the current JWT (set by [AuthStore] after login/register) and
/// attaches it as a Bearer token to every request. All methods return
/// decoded JSON (Map or List) on success, or throw an [ApiException] with a
/// message that's safe to show directly to the user.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? token;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanQuery = (query ?? {})
      ..removeWhere((key, value) => value == null || value == '');
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: cleanQuery.isEmpty
          ? null
          : cleanQuery.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Map<String, String> get _authHeaders => {
        if (token != null) 'Authorization': 'Bearer $token',
      };

  /// The chat WebSocket URL, derived from [ApiConfig.baseUrl] (http -> ws,
  /// https -> wss) with the current JWT attached as a query param, since
  /// browsers can't set custom headers on a WebSocket handshake.
  Uri get chatWebSocketUri {
    final httpUri = Uri.parse(ApiConfig.baseUrl);
    final wsScheme = httpUri.scheme == 'https' ? 'wss' : 'ws';
    return httpUri.replace(scheme: wsScheme, path: '/messages/ws', queryParameters: {
      if (token != null) 'token': token!,
    });
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode == 204 || response.body.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      return null;
    }
  }

  String _extractErrorMessage(dynamic decoded, int statusCode) {
    if (decoded is Map && decoded['detail'] != null) {
      final detail = decoded['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) return first['msg'].toString();
      }
      return detail.toString();
    }
    return "So'rov bajarilmadi (kod: $statusCode)";
  }

  dynamic _handle(http.Response response) {
    final decoded = _decode(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw ApiException(_extractErrorMessage(decoded, response.statusCode), statusCode: response.statusCode);
  }

  Future<T> _guard<T>(Future<T> Function() action, {Duration timeout = const Duration(seconds: 20)}) async {
    try {
      return await action().timeout(timeout);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(
        "Serverga ulanib bo'lmadi. Backend ishga tushganini va manzilni (ApiConfig.baseUrl) tekshiring.",
      );
    } catch (e) {
      throw ApiException("Kutilmagan xatolik yuz berdi: $e");
    }
  }

  // ---------- Health check ----------

  /// Fire-and-forget request to wake up a sleeping backend (Render's free
  /// tier spins the container down after 15 minutes idle, and can take up
  /// to ~50s to wake back up). Call this as early as possible on app start
  /// so the real first request the user triggers doesn't have to eat that
  /// cold-start delay on top of its own timeout.
  Future<void> ping() async {
    try {
      await http.get(_uri('/')).timeout(const Duration(seconds: 60));
    } catch (_) {
      // Ignore — this is just a best-effort warm-up, not a real request.
    }
  }

  // ---------- Auth ----------

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) {
    return _guard(() async {
      final response = await http.post(
        _uri('/auth/register'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }),
      );
      return _handle(response) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) {
    return _guard(() async {
      final response = await http.post(
        _uri('/auth/login'),
        body: {'username': email, 'password': password},
      );
      return _handle(response) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> me() {
    return _guard(() async {
      final response = await http.get(_uri('/auth/me'), headers: _authHeaders);
      return _handle(response) as Map<String, dynamic>;
    });
  }

  // ---------- Users ----------

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? password,
  }) {
    return _guard(() async {
      final response = await http.put(
        _uri('/users/me'),
        headers: _jsonHeaders,
        body: jsonEncode({
          if (fullName != null) 'full_name': fullName,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          if (password != null && password.isNotEmpty) 'password': password,
        }),
      );
      return _handle(response) as Map<String, dynamic>;
    });
  }

  Future<List<dynamic>> mySaved() {
    return _guard(() async {
      final response = await http.get(_uri('/users/me/saved'), headers: _authHeaders);
      return _handle(response) as List<dynamic>;
    });
  }

  // ---------- Properties ----------

  Future<Map<String, dynamic>> listProperties({int skip = 0, int limit = 100}) {
    return _guard(() async {
      final response = await http.get(
        _uri('/properties', {'skip': skip, 'limit': limit}),
        headers: _authHeaders,
      );
      return _handle(response) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> getProperty(int id) {
    return _guard(() async {
      final response = await http.get(_uri('/properties/$id'), headers: _authHeaders);
      return _handle(response) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> createProperty(Map<String, dynamic> payload) {
    return _guard(() async {
      final response = await http.post(
        _uri('/properties'),
        headers: _jsonHeaders,
        body: jsonEncode(payload),
      );
      return _handle(response) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> updateProperty(int id, Map<String, dynamic> payload) {
    return _guard(() async {
      final response = await http.put(
        _uri('/properties/$id'),
        headers: _jsonHeaders,
        body: jsonEncode(payload),
      );
      return _handle(response) as Map<String, dynamic>;
    });
  }

  Future<void> deleteProperty(int id) {
    return _guard(() async {
      final response = await http.delete(_uri('/properties/$id'), headers: _authHeaders);
      _handle(response);
    });
  }

  Future<Map<String, dynamic>> toggleSave(int id) {
    return _guard(() async {
      final response = await http.post(_uri('/properties/$id/save'), headers: _authHeaders);
      return _handle(response) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> uploadPropertyImages(int propertyId, List<PickedImage> images) {
    return _guard(
      () async {
        final request = http.MultipartRequest('POST', _uri('/properties/$propertyId/images'));
        request.headers.addAll(_authHeaders);
        for (final image in images) {
          request.files.add(http.MultipartFile.fromBytes('files', image.bytes, filename: image.filename));
        }
        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);
        return _handle(response) as Map<String, dynamic>;
      },
      timeout: const Duration(seconds: 30),
    );
  }

  Future<Map<String, dynamic>> deletePropertyImage(int propertyId, int imageId) {
    return _guard(() async {
      final response = await http.delete(_uri('/properties/$propertyId/images/$imageId'), headers: _authHeaders);
      return _handle(response) as Map<String, dynamic>;
    });
  }

  // ---------- Avatar ----------

  Future<Map<String, dynamic>> uploadAvatar(PickedImage image) {
    return _guard(
      () async {
        final request = http.MultipartRequest('POST', _uri('/users/me/avatar'));
        request.headers.addAll(_authHeaders);
        request.files.add(http.MultipartFile.fromBytes('file', image.bytes, filename: image.filename));
        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);
        return _handle(response) as Map<String, dynamic>;
      },
      timeout: const Duration(seconds: 30),
    );
  }

  // ---------- Messages ----------

  Future<List<dynamic>> listConversations() {
    return _guard(() async {
      final response = await http.get(_uri('/messages/conversations'), headers: _authHeaders);
      return _handle(response) as List<dynamic>;
    });
  }

  Future<List<dynamic>> getConversationWith(int userId) {
    return _guard(() async {
      final response = await http.get(_uri('/messages/with/$userId'), headers: _authHeaders);
      return _handle(response) as List<dynamic>;
    });
  }

  Future<Map<String, dynamic>> sendMessage({
    required int receiverId,
    required String content,
    int? propertyId,
  }) {
    return _guard(() async {
      final response = await http.post(
        _uri('/messages'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'receiver_id': receiverId,
          'content': content,
          if (propertyId != null) 'property_id': propertyId,
        }),
      );
      return _handle(response) as Map<String, dynamic>;
    });
  }
}
