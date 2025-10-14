import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/model/ordermodel.dart';

class OrderServiceRepo {
  final FirebaseFirestore fire = FirebaseFirestore.instance;
  List<OrderModel> allOrders = []; // Holds all orders fetched

  Future<void> createOrder(OrderModel order) async {
    final docRef = fire.collection('orders').doc(order.orderId);

    final newOrder = order.copyWith(orderedAt: DateTime.now());

    final updatedClient = globalUserDoc?.copyWith(
      orders: [...?globalUserDoc?.orders, newOrder.orderId ?? ""],
    );

    if (updatedClient != null) {
      // 2. Save the updated client to Firestore
      await fire
          .collection('clients')
          .doc(globalUserDoc?.userId)
          .set(updatedClient.toMap());
    }
    await docRef.set(newOrder.toMap());
  }

  Stream<List<OrderModel>> streamOrders() {
    return fire
        .collection('orders')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  Future<List<OrderModel>> fetchOrders() async {
    final orderIds = globalUserDoc?.orders;
    if (orderIds == null || orderIds.isEmpty) return [];

    final snapshot =
        await fire
            .collection('orders')
            .where(FieldPath.documentId, whereIn: orderIds)
            .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await fire.collection('orders').doc(orderId).get();

    if (doc.exists) {
      return OrderModel.fromMap(doc.data()!, doc["orderid"]);
    } else {
      return null;
    }
  }

  Future<List<OrderModel>> getOrderByAssignedEditorId(
    String assignedEditorId,
  ) async {
    allOrders.clear(); // Ensure old data is cleared

    final querySnapshot =
        await fire
            .collection('orders')
            .where('assignedEditorId', isEqualTo: assignedEditorId)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Add the first matching order
      final doc = querySnapshot.docs.first;
      final mainOrder = OrderModel.fromMap(doc.data(), doc.id);
      allOrders.add(mainOrder);

      // Add all complaint orders
      final complaintOrders = await getOrderwithcomplaints(assignedEditorId);
      allOrders.addAll(complaintOrders);
    }

    return allOrders; // Return the combined list
  }

  Future<List<OrderModel>> getOrderwithcomplaints(
    String assignedEditorId,
  ) async {
    final querySnapshot =
        await fire
            .collection('orders')
            .where('editedBy', isEqualTo: assignedEditorId)
            .where('complaint', isEqualTo: true)
            .get();

    return querySnapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<String>> fetchAllVideoUrlsFromOrders() async {
    final orders = await fetchOrders();

    final allVideoUrls =
        orders
            .expand((order) => (order.videoUrls ?? []).cast<String>())
            .toList();

    return allVideoUrls;
  }

  Future<List<OrderModel>> getOrderWithUrl(String targetUrl) async {
    print('Fetching orders with video URL: $targetUrl');

    final snapshot =
        await FirebaseFirestore.instance
            .collection('orders')
            .where('editedVideoUrls', arrayContains: targetUrl)
            .get();

    print('Query completed. Found ${snapshot.docs.length} orders.');

    if (snapshot.docs.isNotEmpty) {
      final orders =
          snapshot.docs.map((doc) {
            print('Order found: ${doc.id} -> ${doc.data()}');
            return OrderModel.fromMap(doc.data(), doc.id);
          }).toList();
      return orders;
    } else {
      print('No orders found for URL: $targetUrl');
      return [];
    }
  }

  /// ✅ Check if an order exists with this mpesaReceipt
  Future<OrderModel?> getOrderByMpesaReceipt(String mpesaReceipt) async {
    final query =
        await fire
            .collection('orders')
            .where('mpesaReceipt', isEqualTo: mpesaReceipt)
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      return null; // no order found
    }

    final doc = query.docs.first;
    return OrderModel.fromMap(doc.data(), doc.id);
  }
}
