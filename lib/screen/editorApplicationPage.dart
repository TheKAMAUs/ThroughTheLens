import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:image_picker/image_picker.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/data/firebase_storage_repo.dart';

import 'package:nanoid/nanoid.dart';
import 'package:video_player/video_player.dart';

class EditorApplicationPage extends StatefulWidget {
  const EditorApplicationPage({Key? key})
    : super(key: key); // ❌ remove const if needed

  @override
  State<EditorApplicationPage> createState() => _EditorApplicationPageState();
}

class _EditorApplicationPageState extends State<EditorApplicationPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  FirebaseStorageRepo _storage = FirebaseStorageRepo();

  final authService = AuthService();
  final ImagePicker picker = ImagePicker();

  List<File> _selectedVideos = [];
  List<VideoPlayerController> _controllers = [];
  List<String> _videoUrlList = [];

  Future<void> pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile == null) {
      print('No video picked');
      return;
    }

    final File videoFile = File(pickedFile.path);
    final controller = VideoPlayerController.file(videoFile);

    await controller.initialize();

    setState(() {
      _selectedVideos.add(videoFile);
      _controllers.add(controller);
    });
  }

  String _generateSampleId() {
    return customAlphabet('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ', 8);
  }

  String _generateFileName() {
    return customAlphabet(
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
      10,
    );
  }

  Future<List<String>> _uploadVideos(List<File> videos) async {
    try {
      // Show loading indicator
      EasyLoading.show(status: 'Uploading Videos');

      for (File video in videos) {
        try {
          // Generate a unique file name
          final fileName = _generateFileName();

          // Upload video to Firebase Storage
          final downloadUrl = await _storage.uploadPosteditorsVideoMobile(
            video.path,
            fileName,
          );

          // Add download URL to the list
          _videoUrlList.add(downloadUrl);
        } catch (e) {
          print('❌ Upload failed for video: $e');
        }
      }

      // Dismiss loading
      EasyLoading.dismiss();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample Videos uploaded successfully!'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Dismiss loading on error
      EasyLoading.dismiss();
      print('❌ Error during video upload: $e');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload videos'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }

    return _videoUrlList;
  }

  Future<void> uploadsamples({required List<File> videos}) async {
    if (_selectedVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload at least one sample video'),
        ),
      );
      return;
    }

    try {
      // Step 1: Upload the images
      final sampleUrls = await _uploadVideos(videos);
      print(sampleUrls);
      final updatedClient = globalUserDoc?.copyWith(
        sampleVideos: [...?globalUserDoc?.sampleVideos, ...sampleUrls],
      );
      await authService.updateClient(client: updatedClient);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application submitted!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to apply. Retry: $e'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final fullName = globalUserDoc?.name ?? '';
    final firstName = fullName.split(' ').first;
    final lastName =
        fullName.split(' ').length > 1
            ? fullName.split(' ').sublist(1).join(' ')
            : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Editor Application')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎬 Apply to Become an Editor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "$firstName's please upload 1–3 sample videos you have edited to demonstrate your skills.",
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedVideos.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 1,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: IconButton(
                      onPressed: pickVideo,
                      icon: const Icon(Icons.add, size: 32),
                    ),
                  );
                }

                final controller = _controllers[index - 1];
                return Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 500,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 2),
                          color: Colors.black,
                        ),
                        child: AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: VideoPlayer(controller),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              controller.value.isPlaying
                                  ? controller.pause()
                                  : controller.play();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),
            TextButton(
              onPressed: () async {
                uploadsamples(videos: _selectedVideos);
              },
              child: const Text('Upload Samples'),
            ),
          ],
        ),
      ),
    );
  }
}
