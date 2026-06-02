class ProductModel {
  final String productId;
  final String sellerUid;     // ID of the creator selling it
  final String title;         // Name of the product
  final String description;   // Product details
  final double price;         // The cost
  final String imageUrl;      // The Cloudinary image link
  final DateTime createdAt;   // When it was listed

  ProductModel({
    required this.productId,
    required this.sellerUid,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.createdAt,
  });

  // 1. Convert raw Firestore data into a Dart Object
  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      productId: documentId,
      sellerUid: map['sellerUid'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',

      // Safely parse the price, whether Firestore stored it as an int or double
      price: (map['price'] ?? 0).toDouble(),

      imageUrl: map['imageUrl'] ?? '',

      // Convert Firebase Timestamp to standard Dart DateTime
      createdAt: (map['createdAt'] != null)
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  // 2. Convert Dart Object back into a Map to save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'sellerUid': sellerUid,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': createdAt, // Firestore automatically handles Dart DateTime objects
    };
  }
}