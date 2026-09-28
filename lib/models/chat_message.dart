class ChatMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final int? propertyId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.propertyId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      senderId: json['sender_id'] as int,
      receiverId: json['receiver_id'] as int,
      propertyId: json['property_id'] as int?,
      content: json['content'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class ChatParticipant {
  final int id;
  final String fullName;
  final String? phone;
  final String? avatarUrl;

  ChatParticipant({required this.id, required this.fullName, this.phone, this.avatarUrl});

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? 'Foydalanuvchi',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class Conversation {
  final ChatParticipant otherUser;
  final ChatMessage lastMessage;
  final int unreadCount;

  Conversation({required this.otherUser, required this.lastMessage, required this.unreadCount});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      otherUser: ChatParticipant.fromJson(json['other_user'] as Map<String, dynamic>),
      lastMessage: ChatMessage.fromJson(json['last_message'] as Map<String, dynamic>),
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}
