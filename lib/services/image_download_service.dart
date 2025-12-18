import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageDownloadService {
  static Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ uses READ_MEDIA_IMAGES (Permission.photos)
      // Older versions use WRITE_EXTERNAL_STORAGE (Permission.storage)
      // Try photos first (Android 13+)
      try {
        final photosStatus = await Permission.photos.status;
        if (photosStatus.isDenied) {
          final result = await Permission.photos.request();
          return result.isGranted;
        }
        if (photosStatus.isGranted) {
          return true;
        }
      } catch (_) {
        // Fall through to try storage permission
      }
      
      // Try storage permission for older Android versions
      try {
        final storageStatus = await Permission.storage.status;
        if (storageStatus.isDenied) {
          final result = await Permission.storage.request();
          return result.isGranted;
        }
        return storageStatus.isGranted;
      } catch (_) {
        // If both fail, return false
        return false;
      }
    } else if (Platform.isIOS) {
      // iOS uses photosAddOnly for adding photos
      final status = await Permission.photosAddOnly.status;
      if (status.isDenied) {
        final result = await Permission.photosAddOnly.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return true;
  }

  static Future<void> downloadAndSaveImage(
    String imageUrl,
    Function(int current, int total)? onProgress,
  ) async {
    try {
      // Request permissions first
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        // Even if permission request fails, try to save - gal might handle it
        // Some versions of gal handle permissions internally
      }

      // Download image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      // Save to gallery - gal package will request permissions if needed
      await Gal.putImageBytes(
        response.bodyBytes,
        name: 'slideshow_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    } on GalException catch (e) {
      // Handle gal-specific errors
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('permission') || errorMsg.contains('denied')) {
        throw Exception('Permission denied: Please grant photo library access in your device settings.');
      }
      throw Exception('Error saving image: $e');
    } catch (e) {
      // Re-throw with more context if it's a permission error
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('permission') || 
          errorString.contains('denied') ||
          errorString.contains('access')) {
        throw Exception('Permission denied: Please grant photo library access in your device settings.');
      }
      throw Exception('Error saving image: $e');
    }
  }

  static Future<void> downloadAllImages(
    List<String> imageUrls,
    Function(int current, int total) onProgress,
  ) async {
    // Request permissions once at the start
    await _requestPermissions();

    for (int i = 0; i < imageUrls.length; i++) {
      await downloadAndSaveImage(imageUrls[i], onProgress);
      onProgress(i + 1, imageUrls.length);
    }
  }
}

