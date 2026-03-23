import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_exception.dart';

class ErrorHandler {
  static String getErrorMessage(Object error, [BuildContext? context]) {
    if (error is AppException) {
      return error.message;
    }

    if (error is FirebaseException) {
      return _handleFirebaseError(error);
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    return 'An unexpected error occurred';
  }

  static String _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action';
      case 'not-found':
        return 'Resource not found';
      case 'already-exists':
        return 'Resource already exists';
      case 'invalid-argument':
        return 'Invalid input provided';
      case 'unauthenticated':
        return 'Please sign in to continue';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return 'Firebase error: ${e.message}';
    }
  }

  static void showErrorSnackBar(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getErrorMessage(error, context)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
        ),
      ),
    );
  }

  static Future<T?> showErrorDialog<T>(BuildContext context, Object error) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(getErrorMessage(error, context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
