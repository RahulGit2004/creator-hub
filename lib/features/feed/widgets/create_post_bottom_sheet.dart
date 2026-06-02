import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/feed_provider.dart';

class CreatePostBottomSheet extends StatefulWidget {
  const CreatePostBottomSheet({super.key});

  @override
  State<CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final _textController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImageToCloudinary(File image) async {
    const cloudName = 'dymvpmblv';
    const uploadPreset = 'creator_preset';
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData)['secure_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitPost() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    setState(() => _isUploading = true);
    final uid = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).userModel?.uid;
    if (uid == null) return;

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImageToCloudinary(_selectedImage!);
      if (imageUrl == null) {
        setState(() => _isUploading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image upload failed.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    final success = await Provider.of<FeedProvider>(
      context,
      listen: false,
    ).createPost(uid: uid, text: text, imageUrl: imageUrl);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create post.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height *
            (keyboardOpen ? 0.85 : 0.60),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Create Post',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _textController,
                maxLines: 4,
                minLines: 4,
                decoration: InputDecoration(
                  hintText: 'What is on your mind?',
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: _selectedImage != null
                    ? Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.surface,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )
                    : const SizedBox(),
              ),

              const SizedBox(height: 16),

              const Divider(
                color: AppColors.border,
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed:
                      _isUploading ? null : _pickImage,
                      icon: const Icon(
                        Icons.add_photo_alternate,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      label: const Text(
                        'Add Image',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    ElevatedButton(
                      onPressed:
                      _isUploading ? null : _submitPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                      child: _isUploading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                        CircularProgressIndicator(
                          color:
                          AppColors.surface,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        'Publish',
                        style: TextStyle(
                          color:
                          AppColors.surface,
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
