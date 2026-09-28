import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/chat_message.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'auth_store.dart';

/// Manages the live chat WebSocket connection plus cached conversation /
/// message state. REST endpoints (via [ApiClient]) back the same data for
/// initial loads and as a fallback when the socket isn't connected;
/// incoming/outgoing messages over the socket update this store's cache
/// directly so open chat screens update live without polling.
class ChatStore extends ChangeNotifier {
  ChatStore._();
  static final ChatStore instance = ChatStore._();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final Map<int, List<ChatMessage>> _messagesByUser = {};
  List<Conversation> conversations = [];
  bool loadingConversations = false;

  bool get isConnected => _channel != null;

  void connect() {
    if (_channel != null) return;
    try {
      _channel = WebSocketChannel.connect(ApiClient.instance.chatWebSocketUri);
      _subscription = _channel!.stream.listen(
        _onData,
        onDone: _resetConnection,
        onError: (_) => _resetConnection(),
        cancelOnError: true,
      );
    } catch (_) {
      _channel = null;
    }
  }

  void _resetConnection() {
    _channel = null;
    _subscription = null;
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _resetConnection();
    _messagesByUser.clear();
    conversations = [];
  }

  void _onData(dynamic raw) {
    if (raw is! String) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['type'] != 'message') return;

      final message = ChatMessage.fromJson(data);
      final myId = AuthStore.instance.currentUser?.id;
      if (myId == null) return;

      final otherId = message.senderId == myId ? message.receiverId : message.senderId;
      _appendMessage(otherId, message);
      loadConversations();
    } catch (_) {
      // Ignore malformed frames rather than crash the listener.
    }
  }

  void _appendMessage(int otherId, ChatMessage message) {
    final list = _messagesByUser.putIfAbsent(otherId, () => []);
    if (!list.any((m) => m.id == message.id)) {
      list.add(message);
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    notifyListeners();
  }

  List<ChatMessage> messagesFor(int otherUserId) =>
      List.unmodifiable(_messagesByUser[otherUserId] ?? const []);

  Future<void> loadHistory(int otherUserId) async {
    try {
      final data = await ApiClient.instance.getConversationWith(otherUserId);
      _messagesByUser[otherUserId] = data.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } on ApiException {
      // Leave whatever was cached; the chat screen can retry via pull-to-refresh.
    }
  }

  Future<void> loadConversations() async {
    loadingConversations = true;
    notifyListeners();
    try {
      final data = await ApiClient.instance.listConversations();
      conversations = data.map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException {
      // Keep the previous list rather than clearing it on a transient failure.
    } finally {
      loadingConversations = false;
      notifyListeners();
    }
  }

  /// Sends over the live socket when connected (fastest, and the server's
  /// echo is what actually lands in the cache — see [_onData]); falls back
  /// to a plain REST call otherwise.
  Future<String?> sendMessage({required int receiverId, required String content, int? propertyId}) async {
    if (isConnected) {
      _channel!.sink.add(jsonEncode({
        'receiver_id': receiverId,
        'content': content,
        if (propertyId != null) 'property_id': propertyId,
      }));
      return null;
    }

    try {
      final data = await ApiClient.instance.sendMessage(
        receiverId: receiverId,
        content: content,
        propertyId: propertyId,
      );
      _appendMessage(receiverId, ChatMessage.fromJson(data));
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
