class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime createdAt;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
  });

  // 1. Convert raw Firestore data into a Dart Object
  factory MessageModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MessageModel(
      messageId: documentId,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',

      // Convert Firebase Timestamp to a standard Dart DateTime
      createdAt: (map['createdAt'] != null)
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  // 2. Convert Dart Object back into a Map to save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'createdAt': createdAt,
    };
  }
}