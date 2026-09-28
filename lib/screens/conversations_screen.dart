import 'package:flutter/material.dart';
import '../services/chat_store.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    ChatStore.instance.connect();
    ChatStore.instance.loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: const Text("Xabarlar"),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.navy,
          onRefresh: ChatStore.instance.loadConversations,
          child: ListenableBuilder(
            listenable: ChatStore.instance,
            builder: (context, _) {
              final store = ChatStore.instance;
              if (store.loadingConversations && store.conversations.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.navy));
              }
              if (store.conversations.isEmpty) {
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 30),
                      child: Column(
                        children: const [
                          Icon(Icons.chat_bubble_outline_rounded, size: 44, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text("Hali suhbatlar yo'q",
                              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          SizedBox(height: 6),
                          Text(
                            "Bir e'lon sahifasida \"Bog'lanish\" tugmasi orqali xabar yuboring",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: store.conversations.length,
                separatorBuilder: (context, i) => const Divider(height: 1, indent: 76),
                itemBuilder: (context, i) {
                  final c = store.conversations[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.oceanBlue.withOpacity(0.15),
                      backgroundImage: c.otherUser.avatarUrl != null ? NetworkImage(c.otherUser.avatarUrl!) : null,
                      child: c.otherUser.avatarUrl == null
                          ? const Icon(Icons.person, color: AppColors.oceanBlue)
                          : null,
                    ),
                    title: Text(c.otherUser.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                    subtitle: Text(
                      c.lastMessage.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.unreadCount > 0 ? AppColors.textPrimary : AppColors.textMuted,
                        fontWeight: c.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatListingDate(c.lastMessage.createdAt),
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        if (c.unreadCount > 0) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(10)),
                            child: Text('${c.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          otherUserId: c.otherUser.id,
                          otherUserName: c.otherUser.fullName,
                          otherAvatarUrl: c.otherUser.avatarUrl,
                        ),
                      )).then((_) => ChatStore.instance.loadConversations());
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
