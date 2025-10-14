import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memoriesweb/data/firebase_storage_repo.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/model/ordermodel.dart';
import 'package:memoriesweb/orderBloc/order_cubit.dart';
import 'package:nanoid/nanoid.dart';

class ImagesPage extends StatefulWidget {
  const ImagesPage({super.key});

  @override
  State<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage>
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
    String? userId,
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
        userId: userId,
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

    return SingleChildScrollView(
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
              context.read<OrderCubit>().createimagesOrder(
                FirebaseAuth.instance.currentUser?.uid,
                // 'editor_123', // Or null if no editor is assigned yet
                49.99, // Your calculated amount
                imageFiles: _images,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('IMAGES read successfully!'),
                  duration: Duration(seconds: 3),
                ),
              );

              // EasyLoading.show(status: 'Saving Images');

              //         try {
              //           for (var img in _image) {
              //             Reference ref =
              //                 _storage.uploadPostImageMobile(path, fileName)

              //             await ref.putFile(img).whenComplete(() async {
              //               await ref.getDownloadURL().then((value) {
              //                 setState(() {
              //                   _imageUrlList.add(value);
              //                 });
              //               });
              //             });
              //           }

              //           setState(() {
              //             _productProvider.getFormData(imageUrlList: _imageUrlList);
              //             EasyLoading.dismiss();

              //             // Use ScaffoldMessenger to show Snackbar
              //             ScaffoldMessenger.of(context).showSnackBar(
              //               SnackBar(
              //                 content: Text(
              //                     'Your images have been uploaded, you can now go back'),
              //                 padding: const EdgeInsets.all(15),
              //                 duration: Duration(
              //                     seconds: 7), // Display the snackbar for 7 seconds
              //               ),
              //             );
              //           });
              //         } catch (e) {
              //           EasyLoading.dismiss();

              //           // Use ScaffoldMessenger to show an error Snackbar
              //           ScaffoldMessenger.of(context).showSnackBar(
              //             SnackBar(
              //               content: Text('Failed to upload images'),
              //               padding: const EdgeInsets.all(15),
              //               backgroundColor: Colors.red,
              //               duration: Duration(seconds: 7),
              //               behavior: SnackBarBehavior.floating,
              //             ),
              //           );
              //         }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}
