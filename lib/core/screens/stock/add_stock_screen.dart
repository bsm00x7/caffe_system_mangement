import 'dart:io';
import 'package:flutter/material.dart';
import 'package:herfay/core/theme/theme_config.dart';
import 'package:herfay/core/utils/image_picker_helper.dart';
import 'package:herfay/core/utils/widgets/text_form_field.dart';
import 'package:image_picker/image_picker.dart';  
import 'package:provider/provider.dart';

import '../controller/stock_controller.dart';
import '../../../data/db/data.dart';

class AddStockScreen extends StatefulWidget {
  const AddStockScreen({super.key});

  @override
  State<AddStockScreen> createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  XFile? _selectedImage;
  bool _isUploading = false;
  String? _uploadedImageUrl;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return ChangeNotifierProvider(
      create: (_) => StockController(),
      builder: (providerContext, child) {
        return Consumer<StockController>(
          builder: (context, controller, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: AppTheme.spacingL),
                  // Header
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      boxShadow: AppTheme.shadowMD,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add New Product',
                                style: AppTheme.headingLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add items with photos to your inventory',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingL),

                  // Error Message
                  if (controller.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(color: AppTheme.errorColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppTheme.errorColor),
                          const SizedBox(width: AppTheme.spacingM),
                          Expanded(
                            child: Text(
                              controller.errorMessage!,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: AppTheme.errorColor,
                            onPressed: () {
                              controller.errorMessage = null;
                              controller.notifyListeners();
                            },
                          ),
                        ],
                      ),
                    ),

                  // Form Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      boxShadow: AppTheme.shadowSM,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Picker Section
                          Text('Product Image', style: AppTheme.bodyLarge),
                          const SizedBox(height: AppTheme.spacingS),
                          InkWell(
                            onTap: _isUploading ? null : () => _pickImage(context, controller),
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                                border: Border.all(
                                  color: AppTheme.textLight,
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: _buildImagePreview(),
                            ),
                          ),

                          const SizedBox(height: AppTheme.spacingL),

                          // Item Name Field
                          TextFormFieldWidget(
                            controller: controller.itemName,
                            labelText: 'Item Name',
                            hintText: 'Enter item name (e.g., Espresso)',
                            prefixIcon: const Icon(
                              Icons.coffee,
                              color: AppTheme.primaryColor,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter item name';
                              }
                              if (value.length < 2) {
                                return 'Item name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppTheme.spacingL),

                          // Stock Quantity Field
                          TextFormFieldWidget(
                            controller: controller.stock,
                            labelText: 'Stock Quantity',
                            hintText: 'Enter quantity (e.g., 100)',
                            prefixIcon: const Icon(
                              Icons.inventory,
                              color: AppTheme.primaryColor,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter stock quantity';
                              }
                              final number = int.tryParse(value);
                              if (number == null) {
                                return 'Please enter a valid number';
                              }
                              if (number < 0) {
                                return 'Stock cannot be negative';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppTheme.spacingXL),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: (controller.isLoading || _isUploading)
                                  ? null
                                  : () => _submitForm(formKey, controller),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: (controller.isLoading || _isUploading)
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Processing...'),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.add_circle_outline, size: 24),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Add to Stock',
                                          style: AppTheme.button.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: AppTheme.spacingM),

                          // Clear Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: (controller.isLoading || _isUploading)
                                  ? null
                                  : () {
                                      controller.clearFields();
                                      setState(() {
                                        _selectedImage = null;
                                        _uploadedImageUrl = null;
                                      });
                                      formKey.currentState!.reset();
                                    },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.clear),
                                  SizedBox(width: 8),
                                  Text('Clear Form'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingL),

                  // Info Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: Text(
                            'Tap the image area to upload a photo from your camera or gallery.',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXXL),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImagePreview() {
    if (_isUploading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppTheme.spacingM),
          Text('Uploading image...'),
        ],
      );
    }

    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Image.file(
          File(_selectedImage!.path),
          fit: BoxFit.cover,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 64,
          color: AppTheme.textLight,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          'Tap to add product image',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          'Camera or Gallery',
          style: AppTheme.caption,
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context, StockController controller) async {
    final XFile? image = await ImagePickerHelper.showImageSourcePicker(context);

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isUploading = true;
      });

      try {
        // Read image bytes
        debugPrint('Starting image upload...');
        final bytes = await image.readAsBytes();
        debugPrint('Image size: ${bytes.length} bytes');
        
        // Generate unique filename
        final fileExt = image.path.split('.').last.toLowerCase();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        debugPrint('Filename: $fileName');
        
        // Upload to Supabase using Data.uploadProductImage
        final String imageUrl = await Data.uploadProductImage(fileName, bytes);
        debugPrint('Upload complete. Image URL: $imageUrl');

        setState(() {
          _isUploading = false;
          _uploadedImageUrl = imageUrl;
          controller.imageUrl.text = imageUrl;
          debugPrint('Set controller imageUrl to: ${controller.imageUrl.text}');
        });
      } catch (e) {
        debugPrint('Error uploading image: $e');
        setState(() {
          _isUploading = false;
          controller.errorMessage = 'Failed to upload image: ${e.toString()}';
          controller.notifyListeners();
          _selectedImage = null;
        });
      }
    }
  }

  Future<void> _submitForm(
    GlobalKey<FormState> formKey,
    StockController controller,
  ) async {
    if (formKey.currentState!.validate()) {
      final success = await controller.addItem();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Item added successfully!'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Clear form and image
        setState(() {
          _selectedImage = null;
          _uploadedImageUrl = null;
        });
        formKey.currentState!.reset();
      }
    }
  }
}
