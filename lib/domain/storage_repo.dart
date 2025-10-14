import 'dart:typed_data';

abstract class StorageRepo {
  // Upload profile image (mobile)
  Future<String> uploadProfileImageMobile(String path, String fileName);

  // Upload profile image (web)
  Future<String> uploadProfileImageWeb(Uint8List fileBytes, String fileName);

  // Upload post image (mobile)
  Future<String> uploadPostImageMobile(String path, String fileName);

  // Upload post image (web)
  Future<String> uploadPostImageWeb(Uint8List fileBytes, String fileName);

  Future<String> uploadPostVideoMobile(String path, String fileName);

  Future<String> uploadPostEditedVideoMobile(String path, String fileName);

  Future<String> uploadPosteditorsVideoMobile(String path, String fileName);
}
