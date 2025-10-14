import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/data/firebase_storage_repo.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/data/payment_Repo.dart';
import 'package:memoriesweb/data/payment_Service.dart';
import 'package:memoriesweb/model/ordermodel.dart';
import 'package:memoriesweb/orderBloc/order_cubit.dart';
import 'package:memoriesweb/orderBloc/order_state.dart';
import 'package:memoriesweb/preferences_service.dart';
import 'package:nanoid/nanoid.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class VideosPage extends StatefulWidget {
  final String? assignedEditorId;
  final bool edited;
  final bool complaint; // New parameter
  final void Function(String path, String fileName)? onDone;
  final void Function(String path, String fileName)? onComplaint;
  const VideosPage({
    super.key,
    this.assignedEditorId,
    this.edited = false, // Default value set to false
    this.complaint = false, // Default value set to false
    this.onDone,
    this.onComplaint,
  });

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  FirebaseStorageRepo _storage = FirebaseStorageRepo();
  final OrderServiceRepo fire = OrderServiceRepo();
  MpesaDarajaApi mpesa = MpesaDarajaApi();

  final ImagePicker picker = ImagePicker();
  File? video;
  List<File> _videos = [];
  List<VideoPlayerController> _controllers = [];
  List<String> _videoUrlList = [];
  VideoPlayerController? _videoController;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  late final TextEditingController phoneController = TextEditingController();

  late final String mpesaReceiptNumber;

  Future<void> pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile == null) {
      print('No video picked');
      return;
    }

    final File videoFile = File(pickedFile.path);
    final controller =
        VideoPlayerController.file(videoFile)
          ..setLooping(true) // 🔁 Make video loop forever
          ..setVolume(1.0);
    final videocontroller =
        VideoPlayerController.file(videoFile)
          ..setLooping(true) // 🔁 Make video loop forever
          ..setVolume(1.0);
    await controller.initialize();
    await videocontroller.initialize();

    setState(() {
      _videos.add(videoFile);
      _controllers.add(controller);
      if (widget.edited || widget.complaint) {
        _videoController = videocontroller;
        video = videoFile;
      }
    });
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

  Future<List<String>> _uploadVideos(List<File> videos) async {
    try {
      // Show loading indicator
      EasyLoading.show(status: 'Uploading Videos');

      for (File video in videos) {
        try {
          // Generate a unique file name
          final fileName = _generateFileName();

          // Upload video to Firebase Storage
          final downloadUrl = await _storage.uploadPostVideoMobile(
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
          content: Text('Videos uploaded successfully!'),
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

  Future<void> createOrder(
    String? userId,
    String? assignedEditorId,
    double? amount, {
    required List<File> videos,
  }) async {
    try {
      // Step 1: Upload the images
      final imageUrls = await _uploadVideos(videos);

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
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }

    _videoController?.dispose();

    titleController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print(widget.complaint);

    print(' editor - ${widget.edited}');
    return BlocConsumer<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderUploadingImages) {
          EasyLoading.show(status: 'Uploading images...');
        } else if (state is OrderUploadedImages) {
          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('uploaded images successfully!')),
          );
        } else if (state is OrderUploadingvideos) {
          EasyLoading.show(status: 'Uploading videos...');
        } else if (state is OrderUploadedvideos) {
          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('uploaded videos successfully!')),
          );
        } else if (state is OrderSuccess) {
          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order uploaded successfully!')),
          );
        } else if (state is OrderFailure) {
          EasyLoading.dismiss();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('❌ ${state.message}')));
        } else if (state is OrderList) {
          if (state.message == "videos_empty") {
            _showConfirmDialog(
              context: context,
              title: "No Videos Selected",
              content:
                  "You haven’t selected any videos. Still submit the order?",
              onConfirm: () {
                // // Submit order anyway, maybe with empty videos
                // context.read<OrderCubit>().submitWithoutVideos(
                //   assignedEditorId: 'editor456',
                //   amount: 50.0,
                //   videos: _videos,
                // );

                final orderCubit = context.read<OrderCubit>();
                if (widget.assignedEditorId != null &&
                    widget.assignedEditorId!.isNotEmpty) {
                  orderCubit.submitWithoutVideos(
                    title: titleController.text.trim(),
                    desc: descriptionController.text.trim(),
                    assignedEditorId: widget.assignedEditorId,
                    amount: 50.0,
                    videos: _videos,
                    mpesaReceiptNumber: mpesaReceiptNumber,
                  );
                } else {
                  orderCubit.submitWithoutVideos(
                    title: titleController.text.trim(),
                    desc: descriptionController.text.trim(),
                    amount: 50.0,
                    videos: _videos,
                    mpesaReceiptNumber: mpesaReceiptNumber,
                  );
                }
              },
            );
          } else if (state.message == "images_empty") {
            _showConfirmDialog(
              context: context,
              title: "No Images Selected",
              content:
                  "You haven’t selected any images. Still submit the order?",
              onConfirm: () {
                // context.read<OrderCubit>().submitWithoutImages(
                //   assignedEditorId: 'editor456',
                //   amount: 50.0,
                // );

                final orderCubit = context.read<OrderCubit>();
                if (widget.assignedEditorId != null &&
                    widget.assignedEditorId!.isNotEmpty) {
                  orderCubit.submitWithoutImages(
                    title: titleController.text.trim(),
                    desc: descriptionController.text.trim(),
                    assignedEditorId: widget.assignedEditorId,
                    amount: 50.0,

                    mpesaReceiptNumber: mpesaReceiptNumber,
                  );
                } else {
                  orderCubit.submitWithoutImages(
                    title: titleController.text.trim(),
                    desc: descriptionController.text.trim(),
                    amount: 50.0,
                    mpesaReceiptNumber: mpesaReceiptNumber,
                  );
                }
              },
            );
          }
        } else if (state is OrderReceiptTaken) {
          print("✅ Order found:   and also paymentmanager cleared");
          PaymentManager().clear();

          _askPhoneNumber(initialRequest: false);
        }
      },
      builder: (context, state) {
        if (!widget.edited && !widget.complaint) {
          return Scaffold(
            appBar: AppBar(title: const Text('Upload Videos')),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // Title Field
                    TextField(
                      controller: titleController,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        // color:
                        //     Theme.of(context).brightness == Brightness.dark
                        //         ? Colors.white
                        //         : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: " Title - The best day of my life...",
                        hintStyle: TextStyle(
                          fontSize: 16,
                          // color:
                          //     Theme.of(context).brightness == Brightness.dark
                          //         ? Colors.white70
                          //         : Colors.black54,
                        ),
                        filled: true,
                        // fillColor:
                        //     Theme.of(context).brightness == Brightness.dark
                        //         ? Colors.grey[900]
                        //         : Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),

                        suffixIcon: Icon(
                          Icons.edit_note_rounded,
                          // color: Theme.of(context).brightness == Brightness.dark
                          //     ? Colors.white70
                          //     : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description Field
                    TextField(
                      controller: descriptionController,
                      maxLines: 5,
                      style: TextStyle(
                        fontSize: 16,
                        // color:
                        //     Theme.of(context).brightness == Brightness.dark
                        //         ? Colors.white
                        //         : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            "Description - I want this video to feel exciting and energetic, like a sports highlight reel. OR _I want it to look cinematic and emotional, like a movie trailer. ",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          // color:
                          //     Theme.of(context).brightness == Brightness.dark
                          //         ? Colors.white70
                          //         : Colors.black54,
                        ),
                        filled: true,
                        // fillColor:
                        //     Theme.of(context).brightness == Brightness.dark
                        //         ? Colors.grey[900]
                        //         : Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),

                        suffixIcon: Icon(
                          Icons.message,
                          // color: Theme.of(context).brightness == Brightness.dark
                          //     ? Colors.white70
                          //     : Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue, width: 1),
                      ),
                      child: const Text(
                        """📌 Before you upload:
If you have a specific idea of how you’d like your video to be, please describe it.

This helps our editors match your style and vision.

🎥 If you have an example video include it as the last item.""",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _videos.length + 1,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
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
                        final orderCubit = context.read<OrderCubit>();

                        // ✅ Await here, since getcheckoutId returns Future<String?>
                        final savedCheckout =
                            await PreferencesService().getcheckoutId();
                        print('latest saved $savedCheckout ');
                        // ✅ mpesaReceiptNumber must be nullable
                        final String? mpesaReceiptNumber =
                            await _askPhoneNumber(
                              savedCheckout: savedCheckout,
                              initialRequest: true,
                            );
                        print('latest saved mpesa $mpesaReceiptNumber ');
                        if (mpesaReceiptNumber == null) {
                          return; // user cancelled
                        }

                        if (widget.assignedEditorId != null &&
                            widget.assignedEditorId!.isNotEmpty) {
                          orderCubit.createvideosOrder(
                            title: titleController.text.trim(),
                            desc: descriptionController.text.trim(),
                            assignedEditorId: widget.assignedEditorId,
                            amount: 50.0,
                            videos: _videos,
                            mpesaReceiptNumber:
                                mpesaReceiptNumber, // ✅ safe now
                          );
                        } else {
                          orderCubit.createvideosOrder(
                            title: titleController.text.trim(),
                            desc: descriptionController.text.trim(),
                            amount: 50.0,
                            videos: _videos,
                            mpesaReceiptNumber: mpesaReceiptNumber,
                          );
                        }
                      },

                      child: const Text('Upload'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          249,
                          146,
                          82,
                        ), // Button background color
                      ),
                    ),

                    TextButton(
                      onPressed: () async {
                        await PreferencesService().clearAll();
                      },

                      child: const Text('CLEAR'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          193,
                          29,
                          29,
                        ), // Button background color
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.complaint ?? false
                    ? 'Upload a Sample Video'
                    : 'Upload Edited Videos',
              ),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // Show message only in complaint mode
                    if (widget.complaint ?? false)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        child: const Text(
                          """We sincerely apologize that your edited video did not meet your expectations.
We truly value your satisfaction and would like to make things right.
Kindly upload a sample video showcasing how you would like the final edit to look.
This will help us ensure we deliver a result that matches your vision.""",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Video preview / picker
                    SizedBox(
                      height: 300,
                      child:
                          video == null
                              ? Center(
                                child: IconButton(
                                  icon: const Icon(Icons.add, size: 40),
                                  onPressed: pickVideo,
                                ),
                              )
                              : Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      color: Colors.black,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: AspectRatio(
                                        aspectRatio:
                                            _videoController!.value.aspectRatio,
                                        child: VideoPlayer(_videoController!),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _videoController!.value.isPlaying
                                                ? _videoController!.pause()
                                                : _videoController!.play();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    ),

                    const SizedBox(height: 30),

                    // Upload button
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.complaint) {
                          if (widget.onComplaint != null && video != null) {
                            widget.onComplaint!(
                              video!.path,
                              _generateFileName(),
                            );
                          }
                        } else {
                          if (widget.onDone != null && video != null) {
                            widget.onDone!(video!.path, _generateFileName());
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          249,
                          146,
                          82,
                        ),
                      ),
                      child: const Text('Upload'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(), // Do nothing
            ),
            TextButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                onConfirm(); // Proceed
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent, // Button background color
              ),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Separate method to build the StreamBuilder widget
  // 🔹 UI Widget
  Widget buildPhoneNumberStream({
    String? savedCheckout,
    Map<String, dynamic>? response,
    required void Function(String phone) onSelected,
    bool? initialRequest,
    bool? alreadyTaken,
    required void Function(String MpesaReceipt) onContinue,
    required TextEditingController controller,
  }) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: recentPaymentsStream(
        initialRequest: initialRequest,
        savedCheckout: savedCheckout,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // ❌ No payments found → show TextField

          if (response != null && response.isNotEmpty) {
            // ✅ Show a custom message instead of TextField
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info, color: Colors.blue, size: 48),
                const SizedBox(height: 12),
                Text(
                  response?["msg"] ?? "No message", // ✅ null safe
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "No recent payments found.\nPlease enter your phone number:",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: "e.g. +1234567890",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    onSelected(controller.text.trim());
                  }
                },
                child: const Text("Pay"),
              ),
            ],
          );
        }

        final payments =
            snapshot.data!; // ✅ Payment found → show success message
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 12),
            const Text(
              "Payment successful!\nPress upload now",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                final receipt = payments[0]['mpesaReceiptNumber'] as String?;
                if (receipt != null) {
                  onContinue(receipt); // ✅ call only when pressed
                } else {
                  print("⚠️ mpesaReceiptNumber is missing in payment data");
                }
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Main dialog method
  Future<String?> _askPhoneNumber({
    bool? initialRequest,
    bool? alreadyTaken,
    String? savedCheckout,
  }) async {
    String? phoneNumber;
    Map<String, dynamic>? response; // make it nullable
    String? _mpesaReceiptNumber;

    await EasyLoading.show(status: 'Fetching info...');
    await Future.delayed(const Duration(milliseconds: 800)); // simulate loading
    EasyLoading.dismiss();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          // ✅ use StatefulBuilder for local setState
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Phone Number'),
              content: SizedBox(
                width: double.maxFinite,
                child: buildPhoneNumberStream(
                  onSelected: (phone) async {
                    phoneNumber = phone;

                    // ✅ Call Mpesa STK Push
                    final result = await mpesa.stkPushRequest(
                      phoneNumber: phoneNumber ?? '',
                      accountNumber: "174379",
                      amount: 1,
                    );

                    // ✅ Update local state with response
                    setState(() {
                      response = result;
                    });
                  },
                  controller: phoneController,
                  response: response, // pass response into widget
                  onContinue: (receipt) async {
                    setState(() {
                      _mpesaReceiptNumber = receipt; // ✅ save receipt to state
                    });
                    Navigator.of(ctx).pop(); // close dialog
                  },

                  initialRequest: initialRequest,
                  alreadyTaken: alreadyTaken,
                  savedCheckout: savedCheckout,
                ),
              ),
              // actions: [
              //   TextButton(
              //     onPressed: () {
              //       Navigator.of(ctx).pop();
              //     },
              //     child: const Text('Cancel'),
              //   ),
              //   if (phoneNumber != null)
              //     ElevatedButton(
              //       onPressed: () {
              //         Navigator.of(ctx).pop(); // confirm selection
              //       },
              //       child: const Text("Confirm"),
              //     ),
              // ],
            );
          },
        );
      },
    );
    print('mpesa : $_mpesaReceiptNumber');
    return _mpesaReceiptNumber;
  }

  /// Streams payments for the given phone number from the last 2 minutes.
  Stream<List<Map<String, dynamic>>> recentPaymentsStream({
    required initialRequest,

    String? savedCheckout,
  }) {
    print('stream rebuld ');
    // // Compute cutoff timestamp: current time minus 1 minute.
    // final cutoff = DateTime.now().subtract(const Duration(minutes: 1));
    // print('latest user info: $globalUserDoc');
    // print('latest user info: ${globalUserDoc?.phoneNumber}');

    // final payment = PaymentManager().globalPayment;
    // print('latest check info: ${payment?.checkoutRequestID}');
    // String? payCheckout = payment?.checkoutRequestID.trim();

    // if (payCheckout == null || payCheckout.isEmpty) {
    //   print("⚠️ No checkoutRequestID found yet → return empty stream");
    //   return Stream.value([]);
    // }

    // ✅ Handle initial request
    if (initialRequest) {
      if (savedCheckout == null || savedCheckout.isEmpty) {
        final payment = PaymentManager().globalPayment;
        print('latest saved is null check info: ${payment?.checkoutRequestID}');
        String? payCheckout = payment?.checkoutRequestID.trim();

        if (payCheckout == null || payCheckout.isEmpty) {
          print("⚠️ No checkoutRequestID found yet → return empty stream");
          return Stream.value([]);
        }
        return FirebaseFirestore.instance
            .collection('payments')
            .doc(payCheckout)
            .snapshots()
            .map((docSnap) {
              if (!docSnap.exists) return <Map<String, dynamic>>[];

              final data = docSnap.data()!;
              data['id'] = docSnap.id;

              print("📡 Payment fetched: $data");

              return [data]; // wrap in a list for consistency
            });
      } else {
        return FirebaseFirestore.instance
            .collection('payments')
            .doc(savedCheckout)
            .snapshots()
            .map((docSnap) {
              if (!docSnap.exists) return <Map<String, dynamic>>[];

              final data = docSnap.data()!;
              data['id'] = docSnap.id;

              print("📡 Payment fetched: $data");

              return [data]; // wrap in a list for consistency
            });
      }
    } else {
      final payment = PaymentManager().globalPayment;
      print('when initialrequest is false');
      print('latest check info: ${payment?.checkoutRequestID}');
      String? payCheckout = payment?.checkoutRequestID.trim();

      if (payCheckout == null || payCheckout.isEmpty) {
        print("⚠️ No checkoutRequestID found yet → return empty stream");
        return Stream.value([]);
      }
      // ✅ Always stream from Firestore
      return FirebaseFirestore.instance
          .collection('payments')
          .doc(payCheckout)
          .snapshots()
          .map((docSnap) {
            if (!docSnap.exists) return <Map<String, dynamic>>[];

            final data = docSnap.data()!;
            data['id'] = docSnap.id;

            print("📡 Payment fetched: $data");

            return [data]; // wrap in a list for consistency
          });
    }

    // // ✅ Always stream from Firestore
    // return FirebaseFirestore.instance
    //     .collection('payments')
    //     .doc(payCheckout)
    //     .snapshots()
    //     .map((docSnap) {
    //       if (!docSnap.exists) return <Map<String, dynamic>>[];

    //       final data = docSnap.data()!;
    //       data['id'] = docSnap.id;

    //       print("📡 Payment fetched: $data");

    //       return [data]; // wrap in a list for consistency
    //     });
  }
}
