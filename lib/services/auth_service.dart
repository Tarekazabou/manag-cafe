import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final Uuid _uuid = Uuid();

  // Sign up a new employee
  Future<User?> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        // Store user info in Realtime Database
        await _db.child('users').child(user.uid).set({
          'email': email,
          'name': name,
          'role': 'employee',
          'status': 'pending',
        });
      }
      return user;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  // Sign in an employee
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
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
      final snapshot = await _db.child('shops').orderByChild('code').equalTo(shopCode).get();
      if (!snapshot.exists) {
        throw Exception('Invalid shop code');
      }

      // Get the shop ID
      final shopData = snapshot.value as Map<dynamic, dynamic>;
      final shopId = shopData.keys.first;

      // Add the request to the shop's pending requests
      await _db.child('shops').child(shopId).child('requests').child(userId).set({
        'status': 'pending',
        'timestamp': ServerValue.timestamp,
      });

      // Update user status
      await _db.child('users').child(userId).update({
        'status': 'pending',
        'shopId': shopId,
      });
    } catch (e) {
      print('Error requesting to join: $e');
      rethrow;
    }
  }

  // Owner approves or rejects a request
  Future<void> manageRequest(String shopId, String userId, bool approve) async {
    try {
      if (approve) {
        // Add user to the shop's employees list
        await _db.child('shops').child(shopId).child('employees').child(userId).set(true);
        // Update user status
        await _db.child('users').child(userId).update({
          'status': 'approved',
          'shopId': shopId,
        });
      } else {
        // Update user status to rejected
        await _db.child('users').child(userId).update({
          'status': 'rejected',
          'shopId': null,
        });
      }
      // Remove the request
      await _db.child('shops').child(shopId).child('requests').child(userId).remove();
    } catch (e) {
      print('Error managing request: $e');
      rethrow;
    }
  }

  // Generate a unique lifetime code for the coffee shop (called by the owner)
  Future<String> generateShopCode(String ownerId, String shopName) async {
    try {
      final shopId = _uuid.v4();
      final shopCode = _uuid.v4().substring(0, 8); // Shortened unique code
      await _db.child('shops').child(shopId).set({
        'name': shopName,
        'ownerId': ownerId,
        'code': shopCode,
        'createdAt': ServerValue.timestamp,
      });
      return shopCode;
    } catch (e) {
      print('Error generating shop code: $e');
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream to listen for user auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}