import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Pick image from gallery
  static Future<XFile?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  static Future<XFile?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Show bottom sheet to choose between camera and gallery
  static Future<XFile?> showImageSourcePicker(BuildContext context) async {
    return showModalBottomSheet<XFile?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Choose Image Source',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              // Camera option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await pickFromCamera();
                  if (context.mounted) {
                    Navigator.pop(context, image);
                  }
                },
              ),

              const SizedBox(height: 10),

              // Gallery option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.green),
                ),
                title: const Text('Gallery'),
                subtitle: const Text('Choose from your photos'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await pickFromGallery();
                  if (context.mounted) {
                    Navigator.pop(context, image);
                  }
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  /// Upload image to Supabase Storage (Product Images)
  static Future<String?> uploadProductImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'products/$fileName';

      await _supabase.storage.from('product-images').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final publicUrl = _supabase.storage
          .from('product-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading product image: $e');
      return null;
    }
  }

  /// Upload profile image to Supabase Storage
  static Future<String?> uploadProfileImage(
    XFile imageFile,
    String userId,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = 'profile.$fileExt';
      final filePath = '$userId/$fileName';

      // Delete old profile image if exists
      try {
        await _supabase.storage.from('profile-images').remove([filePath]);
      } catch (e) {
        // Ignore if file doesn't exist
      }

      await _supabase.storage.from('profile-images').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final publicUrl = _supabase.storage
          .from('profile-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  /// Delete image from Supabase Storage
  static Future<bool> deleteImage(String imageUrl, String bucket) async {
    try {
      // Extract file path from public URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final filePath = pathSegments.sublist(pathSegments.indexOf(bucket) + 1).join('/');

      await _supabase.storage.from(bucket).remove([filePath]);
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Compress image (helper for future optimization)
  static Future<Uint8List> compressImage(Uint8List bytes) async {
    // TODO: Implement image compression using image package
    // For now, return original bytes
    return bytes;
  }
}
