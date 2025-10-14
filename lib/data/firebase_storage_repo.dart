import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:memoriesweb/domain/storage_repo.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Upload profile image (mobile)
  @override
  Future<String> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, "profile_images");
  }

  // Upload profile image (web)
  @override
  Future<String> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, "profile_images");
  }

  // Upload post image (mobile)
  @override
  Future<String> uploadPostImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, "post_images");
  }

  // Upload post image (web)
  @override
  Future<String> uploadPostImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, "post_images");
  }

  @override
  Future<String> uploadPostVideoMobile(String path, String fileName) {
    return _uploadVideo(path, fileName, "clientsRawvideos");
  }

  @override
  Future<String> uploadPostEditedVideoMobile(String path, String fileName) {
    return _uploadVideo(path, fileName, "clientsEditedvideos");
  }

  @override
  Future<String> uploadPosteditorsVideoMobile(String path, String fileName) {
    return _uploadVideo(path, fileName, "videos");
  }

  // 🔹 Upload video (with compression)
  Future<String> _uploadVideo(
    String videoPath,
    String fileName,
    String folder,
  ) async {
    print('Uploading video from path: $videoPath');
    final compressedFile = await _compressVideo(videoPath);
    if (compressedFile == null) {
      throw Exception('Video compression failed.');
    }

    print('Compressed file path: ${compressedFile.path}');
    Reference ref = storage.ref().child('$folder/$fileName');
    print('Reference path: ${ref.fullPath}');
    UploadTask uploadTask = ref.putFile(compressedFile);
    print('Starting file upload...');
    TaskSnapshot snap = await uploadTask;
    print('Upload complete. Getting download URL...');
    String downloadUrl = await snap.ref.getDownloadURL();
    print('Download URL: $downloadUrl');
    return downloadUrl;
  }

  // 🔹 Compress video before upload
  Future<File?> _compressVideo(String videoPath) async {
    print('Starting video compression...');
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.LowQuality,
    );
    if (compressedVideo == null) {
      print('Video compression failed.');
    } else {
      print('Video compression successful: ${compressedVideo.file?.path}');
    }
    return compressedVideo?.file;
  }

  // 🔹 Private helper for mobile uploads
  Future<String> _uploadFile(
    String path,
    String fileName,
    String folder,
  ) async {
    try {
      final file = File(path);
      final ref = storage.ref().child('$folder/$fileName');
      final task = await ref.putFile(file);
      return await task.ref.getDownloadURL();
    } catch (e) {
      print("File upload error: $e");
      rethrow;
    }
  }

  // 🔹 Private helper for web uploads
  Future<String> _uploadFileBytes(
    Uint8List fileBytes,
    String fileName,
    String folder,
  ) async {
    try {
      final ref = storage.ref().child('$folder/$fileName');
      final task = await ref.putData(fileBytes);
      return await task.ref.getDownloadURL();
    } catch (e) {
      print("Byte upload error: $e");
      rethrow;
    }
  }
}
