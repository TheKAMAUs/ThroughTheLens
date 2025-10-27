import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Client extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String profileImageUrl;
  final String role;
  final bool editor;
  final String bio;
  final int? phoneNumber; // <-- new field
  final List<String>? sampleVideos;
  final List<String>? editedVideos;
  final List<double>? rating;
  final int? totalEdits;
  final DateTime createdAt;
  final List<String>? orders;

  const Client({
    required this.userId,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.role,
    this.editor = false,
    this.bio = '',
    this.phoneNumber, // <-- new field
    this.sampleVideos,
    this.editedVideos,
    this.rating,
    this.totalEdits,
    this.orders,
    required this.createdAt,
  });

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      role: map['role'] ?? 'user',
      editor: map['editor'] ?? false,
      bio: map['bio'] ?? '',
      phoneNumber: map['phoneNumber'], // <-- new field
      sampleVideos:
          map['sampleVideos'] != null
              ? List<String>.from(map['sampleVideos'])
              : null,
      editedVideos:
          map['editedVideos'] != null
              ? List<String>.from(map['editedVideos'])
              : null,
      rating:
          map['rating'] != null
              ? List<double>.from(
                (map['rating'] as List).map((e) => (e as num).toDouble()),
              )
              : null,
      totalEdits: map['totalEdits'],
      orders: map['orders'] != null ? List<String>.from(map['orders']) : null,
      createdAt:
          map['createdAt'] != null
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'editor': editor,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'sampleVideos': sampleVideos,
      'editedVideos': editedVideos,
      'rating': rating,
      'totalEdits': totalEdits,
      'orders': orders,
      'createdAt': createdAt,
    };
  }

  Client copyWith({
    String? userId,
    String? name,
    String? email,
    String? profileImageUrl,
    String? role,
    bool? editor,
    String? bio,
    int? phoneNumber, // <-- new field
    List<String>? sampleVideos,
    List<String>? editedVideos,
    List<double>? rating,
    int? totalEdits,
    List<String>? orders,
    DateTime? createdAt,
  }) {
    return Client(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      editor: editor ?? this.editor,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber, // <-- new field
      sampleVideos: sampleVideos ?? this.sampleVideos,
      editedVideos: editedVideos ?? this.editedVideos,
      rating: rating ?? this.rating,
      totalEdits: totalEdits ?? this.totalEdits,
      orders: orders ?? this.orders,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    name,
    email,
    profileImageUrl,
    role,
    editor,
    bio,
    phoneNumber, // <-- new field
    sampleVideos,
    editedVideos,
    rating,
    totalEdits,
    orders,
    createdAt,
  ];
}
