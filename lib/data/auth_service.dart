import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memoriesweb/model/clientmodel.dart';

Client? globalUserDoc;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Client? _client; // 👈 private cached client

  /// Getter to access the client
  Client? get client => _client;

  /// Fetch the client from the 'clients' collection and cache it
  Future<Client?> fetchClient({String? uid}) async {
    try {
      final userUId = uid ?? _auth.currentUser?.uid;

      if (userUId == null) {
        print("⚠️ No authenticated user or UID provided.");
        return null;
      }

      final snapshot =
          await _firestore.collection('clients').doc(userUId).get();

      if (snapshot.exists && snapshot.data() != null) {
        _client = Client.fromMap(snapshot.data()!); // 👈 cache the client
        print("✅ Raw data: ${snapshot.data()}");
        print("✅ Parsed Client: $_client");
        globalUserDoc = _client;
        return _client;
      } else {
        print("⚠️ Client document not found.");
        return null;
      }
    } catch (e, st) {
      print("❌ Error fetching client: $e\n$st");
      return null;
    }
  }

  Future<void> updateClient({Client? client}) async {
    if (client != null) {
      globalUserDoc = client;
      await _firestore
          .collection('clients')
          .doc(client.userUId) // safer than using globalUserDoc again
          .update(client.toMap());
    }
  }

  Future<List<Client>> getEditors() async {
    final querySnapshot =
        await _firestore
            .collection('clients')
            .where('editor', isEqualTo: true)
            .get();

    // Create a map: Client -> averageRating
    final List<Client> editorsWithRatings = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      final client = Client.fromMap(data);

      // Ratings list (cast to double list safely)
      final List<dynamic> ratingsRaw = data['rating'] ?? [];
      final List<double> ratings =
          ratingsRaw.map((r) => (r as num).toDouble()).toList();

      // Calculate average rating
      double avgRating = 0.0;
      if (ratings.isNotEmpty) {
        final total = ratings.reduce((a, b) => a + b);
        avgRating = total / ratings.length;
      }

      final updatedEditor = client.copyWith(rating: [avgRating]);
      editorsWithRatings.add(updatedEditor);
    }

    return editorsWithRatings;
  }

  /// Sign out the user and clear cached client
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _client = null;
      print("👋 User signed out and client cache cleared.");
    } catch (e, st) {
      print("❌ Error during sign out: $e\n$st");
    }
  }
}
