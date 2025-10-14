// order_cubit.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/data/firebase_storage_repo.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/model/ordermodel.dart';
import 'package:nanoid/nanoid.dart'; // or your generator

import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final FirebaseStorageRepo _storage;
  final OrderServiceRepo _firestore;

  OrderCubit(this._storage, this._firestore) : super(OrderInitial());

  final authService = AuthService();
  final List<String> _videoUrlList = [];
  List<String> _imageUrlList = [];
  List<File> _videoscubit = [];
  List<File> _imageFilescubit = [];

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
      EasyLoading.show(status: 'Uploading videos...');
      _videoUrlList.clear();
      emit(OrderUploadingvideos());

      for (File video in videos) {
        try {
          final fileName = _generateFileName();

          final downloadUrl = await _storage.uploadPostVideoMobile(
            video.path,
            fileName,
          );

          _videoUrlList.add(downloadUrl);
        } catch (e) {
          print('❌ Upload failed for individual video: $e');
        }
      }

      emit(OrderUploadedvideos());
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Videos uploaded successfully');
      return _videoUrlList;
    } catch (e, st) {
      EasyLoading.dismiss();
      print('❌ Unexpected error during video upload: $e\n$st');
      emit(OrderFailure("Unexpected error during video upload"));
      EasyLoading.showError('Video upload failed');
      return [];
    }
  }

  Future<void> createvideosOrder({
    String? assignedEditorId,
    required double? amount,
    required List<File> videos,
    required String title,
    required String mpesaReceiptNumber,
    required String desc,
  }) async {
    final order = await _firestore.getOrderByMpesaReceipt(mpesaReceiptNumber);

    if (order != null) {
      print("✅ Order found: ${order.orderId}");
      emit(OrderReceiptTaken());
    } else {
      print("❌ No order found with that Mpesa receipt");

      _videoscubit.addAll(videos);
      // Inside your Cubit method
      if (videos.isEmpty) {
        emit(OrderList("videos_empty"));
        return;
      }

      if (_imageFilescubit.isEmpty) {
        emit(OrderList("images_empty"));
        return;
      }

      try {
        final imageUrls = await uploadImages(_imageFilescubit);
        final videoUrls = await _uploadVideos(videos);

        final order = OrderModel(
          orderId: _generateOrderId(),
          userId: globalUserDoc?.userId,
          assignedEditorId: assignedEditorId,
          paymentStatus: 'pending',
          status: 'pending',
          title: title,
          description: desc,
          amount: amount,
          orderedAt: DateTime.now(),
          imageUrls: imageUrls,
          videoUrls: videoUrls,
        );

        await _firestore.createOrder(order);
        emit(OrderSuccess());
      } catch (e) {
        EasyLoading.dismiss();
        print('❌ Failed to create order: $e');
        emit(OrderFailure(e.toString()));
      }
    }
  }

  void submitWithoutVideos({
    String? assignedEditorId,
    required double? amount,
    required List<File> videos,
    required String title,
    required String mpesaReceiptNumber,
    required String desc,
  }) async {
    try {
      final imageUrls = await uploadImages(_imageFilescubit);

      final order = OrderModel(
        orderId: _generateOrderId(),
        userId: globalUserDoc?.userId,
        assignedEditorId: assignedEditorId,
        paymentStatus: 'pending',
        status: 'pending',
        title: title,
        description: desc,
        amount: amount,
        orderedAt: DateTime.now(),
        videoUrls: [],
        imageUrls: imageUrls,
      );

      await _firestore.createOrder(order);
      emit(OrderSuccess());
    } catch (e, st) {
      print("❌ Error in submitWithoutVideos: $e\n$st");
      emit(OrderFailure("Failed to submit order without videos."));
    }
  }

  void submitWithoutImages({
    String? assignedEditorId,
    required double? amount,
    required String title,
    required String mpesaReceiptNumber,
    required String desc,
  }) async {
    try {
      final videoUrls = await _uploadVideos(_videoscubit);

      final order = OrderModel(
        orderId: _generateOrderId(),
        userId: globalUserDoc?.userId,
        assignedEditorId: assignedEditorId,
        paymentStatus: 'pending',
        status: 'pending',
        title: title,
        description: desc,
        amount: amount,
        orderedAt: DateTime.now(),
        videoUrls: videoUrls,
        imageUrls: [],
      );

      await _firestore.createOrder(order);
      emit(OrderSuccess());
    } catch (e, st) {
      print("❌ Error in submitWithoutImages: $e\n$st");
      emit(OrderFailure("Failed to submit order without images."));
    }
  }

  Future<List<String>> uploadImages(List<File> images) async {
    try {
      EasyLoading.show(status: 'Uploading images...');
      _imageUrlList.clear();
      emit(OrderUploadingImages());

      for (File image in images) {
        try {
          final fileName = _generateFileName();

          final downloadUrl = await _storage.uploadPostImageMobile(
            image.path,
            fileName,
          );

          _imageUrlList.add(downloadUrl);
        } catch (e) {
          print('❌ Upload failed for individual image: $e');
        }
      }

      emit(OrderUploadedImages());
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Images uploaded successfully');
      return _imageUrlList;
    } catch (e, st) {
      EasyLoading.dismiss();
      print('❌ Unexpected error during image upload: $e\n$st');
      emit(OrderFailure("Unexpected error during image upload"));
      EasyLoading.showError('Image upload failed');
      return [];
    }
  }

  Future<void> createimagesOrder(
    String? assignedEditorId,
    double? amount, {
    required List<File> imageFiles,
  }) async {
    try {
      EasyLoading.show(status: 'Creating order...');

      // Step 1: Upload images
      _imageFilescubit.addAll(imageFiles);

      // (Optional: simulate delay or actual Firestore/Cloudinary work here)

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Images Saved successfully');
    } catch (e) {
      EasyLoading.dismiss();
      print('❌ Failed to create order: $e');
      EasyLoading.showError('Failed to create order');
    }
  }
}
