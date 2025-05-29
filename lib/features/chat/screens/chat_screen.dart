import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebazaar/features/chat/screens/start_chat_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    // Fetch all messages where the user is either the sender or the receiver
    final snapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('senderId', isEqualTo: user.uid)
        .get();

    final shopSnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: user.uid)
        .get();

    List<QueryDocumentSnapshot> allMessages = [...snapshot.docs, ...shopSnapshot.docs];

    // Extract unique shop IDs from the messages
    Set<String> shopIds = {};
    for (var doc in allMessages) {
      final data = doc.data() as Map<String, dynamic>;
      String shopId = data['senderId'] == user.uid ? data['receiverId'] : data['senderId'];
      shopIds.add(shopId);
    }

    List<Conversation> loadedConversations = [];
    for (String shopId in shopIds) {
      // Fetch shop data
      final shopDoc = await FirebaseFirestore.instance.collection('shops').doc(shopId).get();
      final shopData = shopDoc.data() as Map<String, dynamic>?;

      // Fetch last message
      final lastMessageSnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('senderId', isEqualTo: user.uid)
          .where('receiverId', isEqualTo: shopId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final shopLastMessageSnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('senderId', isEqualTo: shopId)
          .where('receiverId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      QueryDocumentSnapshot? lastMessageDoc;

      if (lastMessageSnapshot.docs.isNotEmpty) {
        lastMessageDoc = lastMessageSnapshot.docs.first;
      } else if (shopLastMessageSnapshot.docs.isNotEmpty) {
        lastMessageDoc = shopLastMessageSnapshot.docs.first;
      }

      String lastMessage = lastMessageDoc != null ? (lastMessageDoc.data() as Map<String, dynamic>)['text'] : '';

      loadedConversations.add(Conversation(
        shopId: shopId,
        shopName: shopData?['name'] ?? 'Shop Name',
        shopLogoUrl: shopData?['logoUrl'] ?? '',
        lastMessage: lastMessage,
      ));
    }

    setState(() {
      _conversations = loadedConversations;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context);
    final bool isEmpty = _conversations.isEmpty;

    return Scaffold(
      appBar: null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF4285F4), Color(0xFFEEF7FE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          BTexts.chatTitle,
                          style: const TextStyle(
                            fontFamily: 'BebasNeue',
                            color: BColors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Optionally add actions here in the future
                  ],
                ),
              ),
              Expanded(
                child: isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/lottie/no-messages.json',
                              width: BHelperFunctions.screenWidth() * 0.6,
                            ),
                            const SizedBox(height: BSizes.spaceBtwItems),
                            Text(
                              BTexts.chatEmpty,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: BSizes.spaceBtwSections),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = _conversations[index];
                          return ConversationCard(conversation: conversation);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Conversation {
  final String shopId;
  final String shopName;
  final String shopLogoUrl;
  final String lastMessage;

  Conversation({
    required this.shopId,
    required this.shopName,
    required this.shopLogoUrl,
    required this.lastMessage,
  });
}

class ConversationCard extends StatelessWidget {
  const ConversationCard({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => StartChatScreen(
                  shopId: conversation.shopId,
                  shopName: conversation.shopName,
                  shopLogoUrl: conversation.shopLogoUrl,
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: conversation.shopLogoUrl.isNotEmpty ? NetworkImage(conversation.shopLogoUrl) : null,
                child: conversation.shopLogoUrl.isEmpty ? const Icon(Icons.shop) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.shopName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      conversation.lastMessage,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
