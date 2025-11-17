import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:memoriesweb/responsive/constrained_scaffold.dart';

import 'package:nanoid/nanoid.dart';

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:image_picker/image_picker.dart';
import 'package:memoriesweb/data/firebase_storage_repo.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/model/ordermodel.dart';
import 'package:memoriesweb/orderBloc/order_cubit.dart';

class UploadPage extends StatelessWidget {
  final String? assignedEditorId;

  const UploadPage({super.key, this.assignedEditorId = ''});

  @override
  Widget build(BuildContext context) {
    return _ImagesPage(assignedEditorId: assignedEditorId);
  }
}

class _ImagesPage extends StatefulWidget {
  final String? assignedEditorId;

  const _ImagesPage({super.key, this.assignedEditorId});

  @override
  State<_ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends State<_ImagesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final ImagePicker picker = ImagePicker();

  final FirebaseStorageRepo _storage = FirebaseStorageRepo();

  final OrderServiceRepo fire = OrderServiceRepo();
  List<File> _images = [];

  List<String> _imageUrlList = [];

  chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      print('no image picked');
    } else {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  int calculateImagesValue() {
    int count = _images.length;
    int result = count * 100;
    return result;
  }

  String _generateOrderId() {
    return customAlphabet('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ', 8);
  }

  String _generateFileName() {
    return customAlphabet(
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
      10,
    );
  }

  Future<List<String>> uploadImages(List<File> images) async {
    for (File image in images) {
      try {
        final fileName = _generateFileName();

        final downloadUrl = await _storage.uploadPostImageMobile(
          image.path,
          fileName,
        );

        _imageUrlList.add(downloadUrl);
      } catch (e) {
        print('Upload failed for image: $e');
      }
    }

    return _imageUrlList;
  }

  Future<void> createOrder(
    String? userUId,
    String? assignedEditorId,
    double? amount, {
    required List<File> imageFiles,
  }) async {
    try {
      // Step 1: Upload the images
      final imageUrls = await uploadImages(imageFiles);

      // Step 2: Generate order data
      final order = OrderModel(
        orderId: _generateOrderId(), // or use Firestore auto ID
        userUId: userUId,
        assignedEditorId: assignedEditorId,
        paymentStatus: 'pending',
        amount: amount,
        orderedAt: DateTime.now(),
        imageUrls: imageUrls,
        videoUrls: [], // optional
      );

      // Step 3: Save to Firestore
      await fire.createOrder(order);

      print('Order saved successfully!');
    } catch (e) {
      print('Failed to create order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ConstrainedScaffold(
      appBar: AppBar(title: const Text('Upload images')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        physics: const BouncingScrollPhysics(), // 👈 Added this
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Disable GridView scroll
              itemCount: _images.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                childAspectRatio: 3 / 3,
              ),
              itemBuilder: (context, index) {
                return index == 0
                    ? Center(
                      child: IconButton(
                        onPressed: () {
                          chooseImage();
                        },
                        icon: const Icon(Icons.add),
                      ),
                    )
                    : Container(
                      height: 300,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                        color: Colors.black,
                        image: DecorationImage(
                          image: FileImage(_images[index - 1]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
              },
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () async {
                // final userUId = FirebaseAuth.instance.currentUser?.uid;
                // print('User ID: $userUId');

                // print('Number of selected images: ${_images.length}');
                // print('Starting image order creation...');

                context.read<OrderCubit>().createimagesOrder(
                  'editor_123', // Or null if no editor is assigned yet
                  49.99, // Your calculated amount
                  imageFiles: _images,
                );

                print(
                  'Image order creation called. Navigating to nested upload page...',
                );

                if (widget.assignedEditorId != null &&
                    widget.assignedEditorId!.isNotEmpty) {
                  final replacedRoute = RoutesEnum.nestedWithEditor.path
                      .replaceFirst(
                        ':assignedEditorId',
                        widget.assignedEditorId!,
                      );

                  print('✅ Navigating to: $replacedRoute');

                  context.push(replacedRoute);
                } else {
                  print(
                    '⚠️ assignedEditorId is null or empty. Navigating to default videos route.',
                  );

                  print('${widget.assignedEditorId}');
                  context.push(
                    RoutesEnum.nestedNormalUpload.path,
                    extra: {'imagesAmount': calculateImagesValue()},
                  );
                }

                print('Navigation complete. Showing snackbar...');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Images uploaded successfully!'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },

              child: const Text('Images Upload'),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent, // Button background color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
