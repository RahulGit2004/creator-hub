import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Generate a unique, consistent Room ID for any two users
  String _getChatRoomId(String userId1, String userId2) {
    // By sorting the UIDs alphabetically, User A and User B will always
    // generate the exact same room ID, no matter who messages who first!
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  // 2. Send a new message
  Future<void> sendMessage({
    required String currentUserId,
    required String receiverId,
    required String text,
  }) async {
    try {
      final String roomId = _getChatRoomId(currentUserId, receiverId);

      // Create the message object
      final MessageModel newMessage = MessageModel(
        messageId: '', // Firestore will generate this
        senderId: currentUserId,
        receiverId: receiverId,
        text: text,
        createdAt: DateTime.now(),
      );

      // Save it inside the specific Chat Room collection
      await _firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .add(newMessage.toMap());

    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  // 3. Listen to messages in REAL-TIME
  Stream<List<MessageModel>> getMessagesStream(String currentUserId, String receiverId) {
    final String roomId = _getChatRoomId(currentUserId, receiverId);

    // .snapshots() creates a live websocket connection to this exact collection
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: false) // Oldest at top, newest at bottom
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}