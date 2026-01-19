import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfilePictureService {
  ProfilePictureService._();
  static final instance = ProfilePictureService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Upload profile picture to Firebase Storage
  Future<String> uploadProfilePicture(File imageFile) async {
    if (_userId == null) throw Exception('Not authenticated');

    try {
      final ref = _storage.ref().child('profile_pictures/$_userId.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      // Save URL to Firestore
      await _db.collection('users').doc(_userId).set({
        'profilePictureUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Upload profile picture from bytes (for web platform)
  Future<String> uploadProfilePictureFromBytes(
    Uint8List imageBytes,
    String fileName,
  ) async {
    if (_userId == null) throw Exception('Not authenticated');

    try {
      final ref = _storage.ref().child('profile_pictures/$_userId.jpg');
      await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await ref.getDownloadURL();

      // Save URL to Firestore
      await _db.collection('users').doc(_userId).set({
        'profilePictureUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Get profile picture URL from Firestore
  Future<String?> getProfilePictureUrl() async {
    if (_userId == null) return null;

    try {
      final doc = await _db.collection('users').doc(_userId).get();
      if (!doc.exists) return null;
      return doc.data()?['profilePictureUrl'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Delete profile picture
  Future<void> deleteProfilePicture() async {
    if (_userId == null) throw Exception('Not authenticated');

    try {
      // Delete from Storage
      final ref = _storage.ref().child('profile_pictures/$_userId.jpg');
      await ref.delete();

      // Remove URL from Firestore
      await _db.collection('users').doc(_userId).set({
        'profilePictureUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to delete profile picture: $e');
    }
  }
}
