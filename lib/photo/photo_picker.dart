import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class PhotoPicker {
  const PhotoPicker({
    required this.imagePicker,
  });

  final ImagePicker imagePicker;

  /// Picks an image using the camera and returns the image as a byte array.
  Future<Uint8List> takePhoto() async {
    try {
      // Prompt user to pick an image using the camera
      final photo = await imagePicker.pickImage(source: ImageSource.camera);

      // If no photo is picked, throw a custom exception
      if (photo == null) throw PhotoPickerException("No photo selected.");

      // Read and return the photo as a byte array
      return await photo.readAsBytes();
    } on PhotoPickerException {
      // Re-throw PhotoPickerException for better clarity
      rethrow;
    } on Exception catch (e) {
      // Catch any other exception and wrap it in PhotoPickerException
      throw PhotoPickerException("An error occurred: $e");
    }
  }
}

/// A custom exception for handling photo picker errors.
class PhotoPickerException implements Exception {
  final String message;

  const PhotoPickerException(this.message);

  @override
  String toString() => "PhotoPickerException: $message";
}
