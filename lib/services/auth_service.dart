import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up a new employee
  Future<User?> signUp(String email, String password) async {
    try {
      // Validate email format
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        throw Exception('Invalid email format');
      }

      // Validate password (Firebase requires at least 6 characters)
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        // Store user info in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': 'employee',
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('This email is already in use.');
        case 'invalid-email':
          throw Exception('Invalid email format.');
        case 'weak-password':
          throw Exception('The password is too weak.');
        default:
          throw Exception('Sign-up failed: ${e.message} (${e.code})');
      }
    } catch (e) {
      throw Exception('Sign-up failed: $e');
    }
  }

  // Sign in an employee
  Future<User?> signIn(String email, String password) async {
    try {
      // Validate email format
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        throw Exception('Invalid email format');
      }

      // Validate password (Firebase requires at least 6 characters)
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found for that email.');
        case 'wrong-password':
          throw Exception('Incorrect password.');
        case 'invalid-email':
          throw Exception('Invalid email format.');
        case 'user-disabled':
          throw Exception('This user account has been disabled.');
        case 'too-many-requests':
          throw Exception('Too many requests. Try again later.');
        default:
          throw Exception('Sign-in failed: ${e.message} (${e.code})');
      }
    } catch (e) {
      throw Exception('Sign-in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Request to join a coffee shop using the unique code
  Future<void> requestToJoin(String userId, String shopCode) async {
    try {
      // Find the shop with the given code
      final shopSnapshot = await _firestore
          .collection('shops')
          .where('shopCode', isEqualTo: shopCode)
          .get();

      if (shopSnapshot.docs.isEmpty) {
        throw Exception('Invalid shop code');
      }

      final shopId = shopSnapshot.docs.first.id;

      // Add the request to the shop's pending requests
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('joinRequests')
          .doc(userId)
          .set({
        'email': _auth.currentUser?.email,
        'userId': userId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update user status
      await _firestore.collection('users').doc(userId).update({
        'status': 'pending',
        'shopId': shopId,
      });
    } catch (e) {
      throw Exception('Error requesting to join: $e');
    }
  }

  // Owner approves or rejects a request
  Future<void> manageRequest(String shopId, String userId, bool approve) async {
    try {
      if (approve) {
        // Add user to the shop's employees list
        await _firestore
            .collection('shops')
            .doc(shopId)
            .collection('users')
            .doc(userId)
            .set({
          'email': _auth.currentUser?.email,
          'status': 'accepted',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Update user status
        await _firestore.collection('users').doc(userId).update({
          'status': 'approved',
          'shopId': shopId,
        });
      } else {
        // Update user status to rejected
        await _firestore.collection('users').doc(userId).update({
          'status': 'rejected',
          'shopId': null,
        });
      }

      // Remove the request
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('joinRequests')
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Error managing request: $e');
    }
  }

  // Generate a unique lifetime code for the coffee shop (called by the owner)
  Future<String> generateShopCode(String ownerId, String shopName) async {
    try {
      final shopId = _firestore.collection('shops').doc().id;
      final shopCode = shopId.substring(0, 8); // Use part of the Firestore doc ID as the code
      await _firestore.collection('shops').doc(shopId).set({
        'name': shopName,
        'ownerId': ownerId,
        'shopCode': shopCode,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return shopCode;
    } catch (e) {
      throw Exception('Error generating shop code: $e');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream to listen for user auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}