import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readmore/readmore.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/provider/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../provider/feed_provider.dart';
import '../models/post_model.dart';
import '../widgets/create_post_bottom_sheet.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedProvider>(context, listen: false).fetchPosts();
    });
  }

  void _openCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePostBottomSheet(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of your account?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid =
        Provider.of<AuthProvider>(context, listen: false).userModel?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Creator Hub',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.border.withOpacity(0.5),
            height: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          if (feedProvider.isLoading && feedProvider.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (feedProvider.posts.isEmpty) {
            return const Center(
              child: Text(
                'No posts yet.\nBe the first to create one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              await feedProvider.fetchPosts();
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: feedProvider.posts.length,
              itemBuilder: (context, index) {
                final post = feedProvider.posts[index];
                return _PostItem(post: post, currentUserUid: currentUserUid);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _openCreatePostSheet,
        child: const Icon(Icons.add, color: AppColors.surface),
      ),
    );
  }
}

// ============================================================================
// REDESIGNED PREMIUM POST ITEM
// ============================================================================
class _PostItem extends StatefulWidget {
  final PostModel post;
  final String currentUserUid;

  const _PostItem({required this.post, required this.currentUserUid});

  @override
  State<_PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<_PostItem> {
  bool _isHeartAnimating = false;

  void _handleLike(FeedProvider provider, bool currentlyLiked) {
    provider.toggleLike(widget.post.postId, widget.currentUserUid);
    if (!currentlyLiked) {
      setState(() => _isHeartAnimating = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _isHeartAnimating = false);
      });
    }
  }

  // --- DELETE CONFIRMATION DIALOG ---
  void _showDeleteDialog(BuildContext context, FeedProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this post? This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deletePost(widget.post.postId);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- EDIT TEXT DIALOG ---
  void _showEditDialog(BuildContext context, FeedProvider provider) {
    final TextEditingController editController = TextEditingController(
      text: widget.post.text,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Caption',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: editController,
          maxLines: 4,
          minLines: 1,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
            ),
            onPressed: () async {
              final newText = editController.text.trim();
              if (newText.isNotEmpty) {
                Navigator.pop(ctx);
                await provider.editPostText(widget.post.postId, newText);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final isLiked = widget.post.likes.contains(widget.currentUserUid);
    final isMyPost =
        widget.post.uid ==
        widget.currentUserUid; // Check if user is the creator

    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER (Avatar + Name + Edit/Delete Menu)
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.post.uid)
                .get(),
            builder: (context, snapshot) {
              String authorName = "Loading...";
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                authorName = snapshot.data!.get('displayName') ?? 'Creator';
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        authorName[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    // ONLY SHOW THE 3-DOT MENU IF IT IS THE USER'S POST
                    // (Else condition removed entirely, so no icon shows for other users)
                    if (isMyPost)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: AppColors.textSecondary,
                        ),
                        color: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(context, feedProvider);
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, feedProvider);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.textPrimary,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),

          // 2. EDGE-TO-EDGE IMAGE WITH DOUBLE TAP TO LIKE
          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
            GestureDetector(
              onDoubleTap: () => _handleLike(feedProvider, isLiked),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 500),
                    width: double.infinity,
                    child: Image.network(
                      widget.post.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 350,
                          color: AppColors.border.withOpacity(0.3),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: AppColors.background,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isHeartAnimating)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.5, end: 1.2),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Icon(
                            Icons.favorite,
                            color: Colors.white.withOpacity(0.9),
                            size: 100,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

          // 3. MODERN ACTION BAR (Left-Aligned - Chat and Share Icons Removed)
          Padding(
            padding: const EdgeInsets.only(
              left: 12.0,
              right: 16.0,
              top: 12.0,
              bottom: 4.0,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _handleLike(feedProvider, isLiked),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? AppColors.error : AppColors.textPrimary,
                      size: 28,
                    ),
                  ),
                ),
                // Chat and Send icons have been completely removed from here
              ],
            ),
          ),

          // 4. LIKES COUNT & PERFECT INLINE READ MORE
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.post.likes.length} likes',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),

                if (widget.post.text.isNotEmpty)
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.post.uid)
                        .get(),
                    builder: (context, snapshot) {
                      String authorName = "Creator";
                      if (snapshot.hasData)
                        authorName =
                            snapshot.data!.get('displayName') ?? 'Creator';

                      return ReadMoreText(
                        // The text combines the username and the post description
                        '$authorName ${widget.post.text}',
                        trimLines: 3,
                        // Truncates exactly at 3 lines!
                        colorClickableText: AppColors.textSecondary,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: ' more...',
                        trimExpandedText: ' less',
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                        moreStyle: const TextStyle(
                          fontSize: 14.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w900,
                        ),
                        lessStyle: const TextStyle(
                          fontSize: 14.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w900,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.border.withOpacity(0.5)),
        ],
      ),
    );
  }
}
