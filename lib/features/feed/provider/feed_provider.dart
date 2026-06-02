import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class FeedProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<PostModel> _posts = [];
  bool _isLoading = false;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  // 1. Fetch all posts from Firestore, newest first
  Future<void> fetchPosts() async {
    _setLoading(true);
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      _posts = snapshot.docs.map((doc) {
        return PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint("Error fetching posts: $e");
    }
  }

  // 2. Create a new post and save it to Firestore
  Future<bool> createPost({
    required String uid,
    required String text,
    String? imageUrl,
  }) async {
    _setLoading(true);
    try {
      // Generate a new unique ID for the document
      final newPostRef = _firestore.collection('posts').doc();

      final post = PostModel(
        postId: newPostRef.id,
        uid: uid,
        text: text,
        imageUrl: imageUrl,
        likes: [],
        createdAt: DateTime.now(),
      );

      // Save to database
      await newPostRef.set(post.toMap());

      // Insert at the top of our local list so the UI updates instantly
      // without needing to re-fetch the entire database
      _posts.insert(0, post);

      _setLoading(false);
      return true; // Success
    } catch (e) {
      _setLoading(false);
      debugPrint("Error creating post: $e");
      return false; // Failed
    }
  }

  // 3. Handle Liking and Unliking a post
  Future<void> toggleLike(String postId, String uid) async {
    // Find the post locally
    final postIndex = _posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final post = _posts[postIndex];
    final isLiked = post.likes.contains(uid);

    // Optimistic UI Update: Change the UI immediately before the network call finishes
    if (isLiked) {
      post.likes.remove(uid);
    } else {
      post.likes.add(uid);
    }
    notifyListeners();

    // Update Firebase in the background
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': isLiked
            ? FieldValue.arrayRemove([uid])
            : FieldValue.arrayUnion([uid])
      });
    } catch (e) {
      // If the network fails, revert the UI back to normal
      if (isLiked) {
        post.likes.add(uid);
      } else {
        post.likes.remove(uid);
      }
      notifyListeners();
      debugPrint("Error toggling like: $e");
    }
  }

  // --- ADD THESE TO YOUR FEED PROVIDER ---

  Future<bool> deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      // Remove from local list to update UI instantly without reloading
      _posts.removeWhere((post) => post.postId == postId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> editPostText(String postId, String newText) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'text': newText,
      });
      // Update local list for instant UI refresh
      final index = _posts.indexWhere((post) => post.postId == postId);
      if (index != -1) {
        _posts[index] = _posts[index].copyWith(
          text: newText,
        );

        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}