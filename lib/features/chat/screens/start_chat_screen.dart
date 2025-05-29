import 'package:flutter/material.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StartChatScreen extends StatefulWidget {
  final String shopId;
  final String shopName;
  final String shopLogoUrl;

  const StartChatScreen({Key? key, required this.shopId, required this.shopName, required this.shopLogoUrl}) : super(key: key);

  @override
  State<StartChatScreen> createState() => _StartChatScreenState();
}

class _StartChatScreenState extends State<StartChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('senderId', isEqualTo: user.uid)
        .where('receiverId', isEqualTo: widget.shopId)
        .orderBy('timestamp')
        .get();

    final shopSnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('senderId', isEqualTo: widget.shopId)
        .where('receiverId', isEqualTo: user.uid)
        .orderBy('timestamp')
        .get();

    List<QueryDocumentSnapshot> allMessages = [...snapshot.docs, ...shopSnapshot.docs];
    print('All Messages: $allMessages');

    allMessages.sort((a, b) {
      Timestamp timeA = a['timestamp'] as Timestamp;
      Timestamp timeB = b['timestamp'] as Timestamp;
      return timeA.compareTo(timeB);
    });

    List<ChatMessage> loadedMessages = [];
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final userData = userDoc.data() as Map<String, dynamic>?;

    for (var doc in allMessages) {
      final data = doc.data() as Map<String, dynamic>;
      bool isMe = data['senderId'] == user.uid;

      loadedMessages.add(ChatMessage(
        text: data['text'],
        isMe: isMe,
        userName: userData?['firstName'] ?? 'You',
        userPhotoUrl: userData?['photoURL'],
      ));
    }

    setState(() {
      _messages.addAll(loadedMessages);
    });
  }

  void _handleSubmitted(String text) async {
    _messageController.clear();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    bool isMe = true;
    String userName = userData?['firstName'] ?? 'You';
    String? userPhotoUrl = userData?['photoURL'];

    if (user.uid == widget.shopId) {
      isMe = false;
      userName = widget.shopName;
      userPhotoUrl = widget.shopLogoUrl;
    }

    ChatMessage message = ChatMessage(
      text: text,
      isMe: isMe,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
    );

    // Store the message in Firestore
    FirebaseFirestore.instance.collection('messages').add({
      'text': text,
      'senderId': user.uid,
      'receiverId': widget.shopId,
      'timestamp': DateTime.now(),
    });

    setState(() {
      _messages.insert(0, message);
    });
  }

  Widget _buildTextComposer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 3),
            blurRadius: 5,
            color: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _messageController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Send a message',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: BColors.primary),
            onPressed: () => _handleSubmitted(_messageController.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            widget.shopLogoUrl.isNotEmpty ? CircleAvatar(
              backgroundImage: NetworkImage(widget.shopLogoUrl),
            ) : const Icon(Icons.shop),
            const SizedBox(width: 8),
            Text(widget.shopName != null && widget.shopName.isNotEmpty ? widget.shopName : "Shop Name"),
          ],
        ),
        backgroundColor: BColors.primary,
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    Key? key,
    required this.text,
    required this.isMe,
    this.userName,
    this.userPhotoUrl,
  }) : super(key: key);
  final String text;
  final bool isMe;
  final String? userName;
  final String? userPhotoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text('Shop')),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(isMe ? userName ?? 'You' : 'Shop', style: Theme.of(context).textTheme.titleSmall),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(text),
                ),
              ],
            ),
          ),
          if (isMe)
            Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                backgroundImage: userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
                child: userPhotoUrl == null ? Text(userName?.substring(0, 1) ?? 'Me') : null,
              ),
            ),
        ],
      ),
    );
  }
}
