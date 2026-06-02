class PostModel {
  final String postId;
  final String uid;
  final String text;
  final String? imageUrl;
  final List<String> likes;
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.uid,
    required this.text,
    this.imageUrl,
    required this.likes,
    required this.createdAt,
  });

  PostModel copyWith({
    String? postId,
    String? uid,
    String? text,
    String? imageUrl,
    List<String>? likes,
    DateTime? createdAt,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      uid: uid ?? this.uid,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory PostModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PostModel(
      postId: documentId,
      uid: map['uid'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],

      likes: List<String>.from(map['likes'] ?? []),

      createdAt: (map['createdAt'] != null)
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'text': text,
      'imageUrl': imageUrl,
      'likes': likes,
      'createdAt': createdAt,
    };
  }
}