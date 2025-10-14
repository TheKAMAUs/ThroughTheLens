import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class OrderModel extends Equatable {
  final String? orderId;
  final String? userId;
  final String? assignedEditorId;
  final String? paymentStatus; // pending, paid, failed
  final String? status; // pending, paid, failed
  final double? amount;
  final DateTime? orderedAt;
  final String? title;
  final String? description;
  final String? editedBy;
  final List<String> imageUrls;
  final List<String>? videoUrls;
  final List<String>? editedVideoUrls;
  final bool? complaint;
  final String? mpesaReceipt; // ✅ New field

  const OrderModel({
    required this.imageUrls,
    this.orderId,
    this.userId,
    this.assignedEditorId,
    this.paymentStatus,
    this.status,
    this.amount,
    this.orderedAt,
    this.title,
    this.description,
    this.editedBy,
    this.videoUrls,
    this.editedVideoUrls,
    this.complaint,
    this.mpesaReceipt, // ✅ Constructor
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      userId: map['userId'] ?? '',
      assignedEditorId: map['assignedEditorId'] ?? '',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      status: map['status'] ?? 'pending',
      amount: (map['amount'] ?? 0).toDouble(),
      orderedAt: (map['orderedAt'] as Timestamp).toDate(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      editedBy: map['editedBy'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      videoUrls: List<String>.from(map['videoUrls'] ?? []),
      editedVideoUrls: List<String>.from(map['editedVideoUrls'] ?? []),
      complaint: map['complaint'] ?? false,
      mpesaReceipt: map['mpesaReceipt'] ?? '', // ✅ From map
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'assignedEditorId': assignedEditorId,
      'paymentStatus': paymentStatus,
      'status': status,
      'amount': amount,
      'orderedAt': orderedAt,
      'title': title,
      'description': description,
      'editedBy': editedBy,
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
      'editedVideoUrls': editedVideoUrls,
      'complaint': complaint,
      'mpesaReceipt': mpesaReceipt, // ✅ to map
    };
  }

  OrderModel copyWith({
    String? orderId,
    String? userId,
    String? assignedEditorId,
    String? paymentStatus,
    String? status,
    double? amount,
    DateTime? orderedAt,
    String? title,
    String? description,
    String? editedBy,
    List<String>? imageUrls,
    List<String>? videoUrls,
    List<String>? editedVideoUrls,
    bool? complaint,
    String? mpesaReceipt, // ✅ copyWith
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      assignedEditorId: assignedEditorId ?? this.assignedEditorId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      orderedAt: orderedAt ?? this.orderedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      editedBy: editedBy ?? this.editedBy,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrls: videoUrls ?? this.videoUrls,
      editedVideoUrls: editedVideoUrls ?? this.editedVideoUrls,
      complaint: complaint ?? this.complaint,
      mpesaReceipt: mpesaReceipt ?? this.mpesaReceipt,
    );
  }

  @override
  List<Object?> get props => [
    orderId,
    userId,
    assignedEditorId,
    paymentStatus,
    status,
    amount,
    orderedAt,
    title,
    description,
    editedBy,
    imageUrls,
    videoUrls,
    editedVideoUrls,
    complaint,
    mpesaReceipt, // ✅ Equatable
  ];
}
