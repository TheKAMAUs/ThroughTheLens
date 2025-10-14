import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/data/firebase_storage_repo.dart';
import 'package:memoriesweb/model/clientmodel.dart';
import 'package:memoriesweb/model/ordermodel.dart';
import 'package:nanoid/nanoid.dart';

class TransServiceRepo {
  final FirebaseFirestore fire = FirebaseFirestore.instance;
  final authService = AuthService();
  final FirebaseStorageRepo storage = FirebaseStorageRepo();

  Future<void> acceptOrder(String? orderId) async {
    final user = globalUserDoc?.userId;
    if (user == null) throw Exception('User not logged in');

    final docRef = fire.collection('orders').doc(orderId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final order = OrderModel.fromMap(docSnapshot.data()!, docSnapshot.id);

      final updatedOrder = order.copyWith(assignedEditorId: user);

      await docRef.set(updatedOrder.toMap());
    } else {
      throw Exception('Order not found');
    }
  }

  Future<void> editedOrder({
    OrderModel? order,
    required String path,
    required String fileName,
  }) async {
    final user = globalUserDoc?.userId;
    if (user == null) throw Exception('User not logged in');

    try {
      EasyLoading.show(status: 'Uploading video...');

      // update the order

      final downloadUrl = await storage.uploadPostEditedVideoMobile(
        path,
        fileName,
      );

      final updatedOrder = order?.copyWith(
        editedVideoUrls: [...?order.editedVideoUrls, downloadUrl],
        status: 'completed',
        editedBy: user,
        assignedEditorId: null,
      );

      final docRef = fire.collection('orders').doc(order?.orderId);

      await docRef.set(updatedOrder!.toMap());

      // update the client

      final clientRef = fire.collection('clients').doc(order?.userId);

      await clientRef.update({
        'editedVideos': FieldValue.arrayUnion([downloadUrl]),
      });

      // update editor
      final updatedEditor = globalUserDoc?.copyWith(
        sampleVideos: [...?globalUserDoc?.sampleVideos, downloadUrl],
      );

      final editorRef = fire.collection('clients').doc(user);

      await editorRef.set(updatedEditor!.toMap());

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Video uploaded successfully');
    } catch (e, st) {
      EasyLoading.dismiss();
      print('❌ Unexpected error during video upload: $e\n$st');

      EasyLoading.showError('Video upload failed');
    }
  }

  Future<List<OrderModel>> getOrderWithUrl(String targetUrl) async {
    print('Searching for orders with targetUrl: $targetUrl');

    final snapshot =
        await FirebaseFirestore.instance
            .collection('orders')
            .where('editedVideoUrls', arrayContains: targetUrl)
            .get();

    print('Query returned ${snapshot.docs.length} documents');

    if (snapshot.docs.isNotEmpty) {
      final orders =
          snapshot.docs.map((doc) {
            print('Found order with ID: ${doc.id}');
            return OrderModel.fromMap(doc.data(), doc.id);
          }).toList();

      print('Mapped ${orders.length} orders to OrderModel');
      return orders;
    } else {
      print('No orders found for the given URL');
      return [];
    }
  }

  Future<void> updateOrder({
    String? targetUrl,
    double? newRating,
    String? path,
    String? fileName,
  }) async {
    try {
      // =========================
      // 1. Validate target URL first (used in all flows)
      // =========================
      if (targetUrl == null || targetUrl.isEmpty) {
        print("❌ No target URL provided.");
        return;
      }

      EasyLoading.show(status: 'Processing...');

      // =========================
      // 2. Get the order
      // =========================
      final orders = await getOrderWithUrl(targetUrl);
      if (orders.isEmpty) {
        print("❌ No order found for this URL: $targetUrl");
        EasyLoading.dismiss();
        return;
      }
      final order = orders.first;

      // =========================
      // 3. If path & fileName are provided → Upload video & mark complaint
      // =========================
      if ((path != null && path.isNotEmpty) &&
          (fileName != null && fileName.isNotEmpty)) {
        print("📤 Uploading complaint video...");

        final downloadUrl = await storage.uploadPostVideoMobile(path, fileName);

        if (downloadUrl == null || downloadUrl.isEmpty) {
          print("❌ Failed to get download URL after upload.");
          EasyLoading.dismiss();
          return;
        }

        final updatedOrder = order.copyWith(
          videoUrls: [...?order.videoUrls, downloadUrl],
          complaint: true,
        );

        await fire
            .collection('orders')
            .doc(order.orderId)
            .set(updatedOrder.toMap());

        print("✅ Complaint video added to order ${order.orderId}");
      }

      // =========================
      // 4. If newRating is provided → Update editor rating
      // =========================
      if (newRating != null) {
        print("⭐ Updating editor rating...");

        final updatedOrder = order.copyWith(complaint: false);

        final assignedEditorId = order.editedBy;
        if (assignedEditorId == null || assignedEditorId.isEmpty) {
          print("❌ Order has no assigned editor.");
          EasyLoading.dismiss();
          return;
        }

        await fire
            .collection('orders')
            .doc(order.orderId)
            .set(updatedOrder.toMap());

        final clientDocRef = FirebaseFirestore.instance
            .collection('clients')
            .doc(assignedEditorId);
        final clientDoc = await clientDocRef.get();

        if (!clientDoc.exists) {
          print("❌ Client not found for assignedEditorId: $assignedEditorId");
          EasyLoading.dismiss();
          return;
        }

        final editor = Client.fromMap(clientDoc.data()!);
        final updatedRatingList =
            [...(editor.rating ?? []), newRating].cast<double>();

        final updatedEditor = editor.copyWith(
          rating: updatedRatingList,
          totalEdits: (editor.totalEdits ?? 0) + 1,
        );

        await clientDocRef.update({
          'rating': updatedEditor.rating,
          'totalEdits': updatedEditor.totalEdits,
        });

        print("✅ Rating added successfully for editor: $assignedEditorId");
      }

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Update completed successfully');
    } catch (e) {
      EasyLoading.dismiss();
      print("🔥 Error updating order: $e");
    }
  }
}







  // Future<void> updateUserPhone(String phoneNumber) async {
  //   try {
  //     // Convert to int
  //     final phoneInt = int.parse(phoneNumber);
  //     print("✅ Formatted phone number: $phoneNumber");

  //     final clientDocRef = FirebaseFirestore.instance
  //         .collection('clients')
  //         .doc(globalUserDoc?.userId);

  //     await clientDocRef.update({'phoneNumber': phoneInt});

  //     // 🔹 Update in-memory user
  //     globalUserDoc = globalUserDoc?.copyWith(phoneNumber: phoneInt);

  //     final auth = AuthService();
  //     await auth.fetchClient();

  //     print("✅ Phone number updated in Firestore & local memory: $phoneNumber");
  //   } catch (e) {
  //     print("❌ Failed to update Firestore phone: $e");
  //   }
  // }