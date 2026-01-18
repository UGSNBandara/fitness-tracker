import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../models/user_level.dart';

class UserService {
  UserService._();
  static final instance = UserService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's profile from Firestore
  Future<User?> getCurrentUserProfile() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return _fromFirestore(firebaseUser.uid, data);
    } catch (e) {
      return null;
    }
  }

  /// Check if user profile is complete
  Future<bool> isProfileComplete() async {
    final profile = await getCurrentUserProfile();
    return profile != null;
  }

  /// Create or update user profile
  Future<void> saveUserProfile(User user) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) throw Exception('Not authenticated');

    await _db.collection('users').doc(firebaseUser.uid).set(
      _toFirestore(user),
      SetOptions(merge: true),
    );
  }

  /// Convert Firestore data to User model
  User _fromFirestore(String userId, Map<String, dynamic> data) {
    return User(
      userId: userId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      level: _parseUserLevel(data['level']),
      height: (data['height'] ?? 0).toDouble(),
      weight: (data['weight'] ?? 0).toDouble(),
      dob: (data['dob'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gender: data['gender'] ?? '',
    );
  }

  /// Convert User model to Firestore data
  Map<String, dynamic> _toFirestore(User user) {
    return {
      'name': user.name,
      'email': user.email,
      'level': user.level.toString().split('.').last,
      'height': user.height,
      'weight': user.weight,
      'dob': Timestamp.fromDate(user.dob),
      'gender': user.gender,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Parse UserLevel from string
  UserLevel _parseUserLevel(String? level) {
    switch (level) {
      case 'beginner':
        return UserLevel.beginner;
      case 'intermediate':
        return UserLevel.intermediate;
      case 'advanced':
        return UserLevel.advanced;
      default:
        return UserLevel.beginner;
    }
  }

  /// Calculate age from date of birth
  int calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}

