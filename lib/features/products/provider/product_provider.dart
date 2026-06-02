import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  // 1. Fetch all products from the marketplace
  Future<void> fetchProducts() async {
    _setLoading(true);
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      _products = snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint("Error fetching products: $e");
    }
  }

  // 2. Create a new product listing
  Future<bool> createProduct({
    required String sellerUid,
    required String title,
    required String description,
    required double price,
    required String imageUrl,
  }) async {
    _setLoading(true);
    try {
      // Create a unique ID for this new item
      final newProductRef = _firestore.collection('products').doc();

      final product = ProductModel(
        productId: newProductRef.id,
        sellerUid: sellerUid,
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      // Save to Firebase
      await newProductRef.set(product.toMap());

      // Add it locally so the UI updates instantly without reloading everything
      _products.insert(0, product);

      _setLoading(false);
      return true; // Success!
    } catch (e) {
      _setLoading(false);
      debugPrint("Error creating product: $e");
      return false; // Failed
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}