import 'package:cloud_firestore/cloud_firestore.dart';

class SyncService {
  SyncService._();
  static final instance = SyncService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> syncToCloud(dynamic entity) async {
    // TODO: Implement generic cloud sync
  }

  Future<void> offlineCache() async {
    // TODO: Implement offline caching
  }

  Future<void> createOrUpdateUser({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    final doc = _db.collection('users').doc(uid);
    await doc.set({
      'email': email,
      if (displayName != null) 'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) async {
    return _db.collection('users').doc(uid).get();
  }
}
