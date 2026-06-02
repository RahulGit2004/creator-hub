class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String profilePic;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profilePic = '',
  });

  // Convert Firebase Firestore document data to our App Model
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      profilePic: map['profilePic'] ?? '',
    );
  }

  // Convert to Map to save into Firestore database
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profilePic': profilePic,
    };
  }
}