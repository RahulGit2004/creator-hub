import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart'; // Reusing your premium text field!
import '../../auth/provider/auth_provider.dart';
import '../provider/product_provider.dart';

class CreateProductBottomSheet extends StatefulWidget {
  const CreateProductBottomSheet({super.key});

  @override
  State<CreateProductBottomSheet> createState() =>
      _CreateProductBottomSheetState();
}

class _CreateProductBottomSheetState extends State<CreateProductBottomSheet> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  File? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
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
        final jsonMap = json.decode(responseData);
        return jsonMap['secure_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitProduct() async {
    final title = _titleController.text.trim();
    final priceText = _priceController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty ||
        priceText.isEmpty ||
        desc.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and add an image.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price number.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    final uid = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).userModel?.uid;
    if (uid == null) return;

    final imageUrl = await _uploadImageToCloudinary(_selectedImage!);
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

    final success = await Provider.of<ProductProvider>(context, listen: false)
        .createProduct(
          sellerUid: uid,
          title: title,
          description: desc,
          price: price,
          imageUrl: imageUrl,
        );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to list product.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. THIS IS THE FIX: A Container with AppColors.surface and strict height bounds
    return Container(
      height:
          MediaQuery.of(context).size.height *
          0.85, // Takes up 85% of the screen
      decoration: const BoxDecoration(
        color: AppColors.surface, // Gives it the solid background!
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
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
            'Sell a Product',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Scrollable Form Area so it doesn't break when keyboard opens
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Image Picker
                  GestureDetector(
                    onTap: _isUploading ? null : _pickImage,
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border.all(color: AppColors.border, width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap to add product image',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reusing Custom Text Fields
                  CustomTextField(
                    controller: _titleController,
                    labelText: 'Product Title',
                    prefixIcon: const Icon(
                      Icons.title,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _priceController,
                    labelText: 'Price',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _descController,
                    labelText: 'Description',
                    maxLines: 4,
                    prefixIcon: const Icon(
                      Icons.description_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Action Buttons Fixed at the Bottom
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submitProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.surface,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'List Product',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
