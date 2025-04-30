Coffee Shop Manager
Overview
Coffee Shop Manager is a Flutter-based mobile application designed to help coffee shop owners and employees manage inventory, track sales, and monitor daily operations efficiently. The app integrates with Firebase for real-time data synchronization, authentication, and cloud storage. It supports both online and offline modes by using a local SQLite database for data persistence.
Key Features

User Authentication: Secure sign-up and sign-in using Firebase Authentication.
Shop Management: Owners can create shops, generate unique shop codes, and manage employee join requests.
Inventory Management: Add, update, and delete inventory items with real-time syncing to Firestore.
Sales Tracking: Record sales, calculate profits, and analyze session-based sales stats.
Inventory Snapshots: Record inventory snapshots at specific time slots to track stock changes.
Offline Support: Local SQLite database ensures the app works offline, with data syncing when online.
Role-Based Access: Separate permissions for shop owners and employees.

Tech Stack

Frontend: Flutter (Dart)
Backend: Firebase
Firebase Authentication: For user sign-up and sign-in.
Firestore: For real-time database operations.
Firebase Cloud Messaging (FCM): For push notifications.


Local Storage: SQLite (via sqflite package)
State Management: Provider (ChangeNotifier)

Prerequisites
Before setting up the project, ensure you have the following installed:

Flutter SDK: Version 3.0.0 or higher
Dart: Included with Flutter
Android Studio or VS Code with Flutter and Dart plugins
Firebase Account: For backend services
A physical Android/iOS device or emulator for testing

Setup Instructions
1. Clone the Repository
git clone https://github.com/yourusername/coffee-shop-manager.git
cd coffee-shop-manager

2. Install Dependencies
Run the following command to install all required packages:
flutter pub get

3. Configure Firebase

Create a new project in the Firebase Console.
Add an Android app to your Firebase project:
Package name: com.example.manag_cafe
Download the google-services.json file and place it in the android/app directory.


Add an iOS app (if targeting iOS):
Download the GoogleService-Info.plist file and place it in the ios/Runner directory.


Enable Firebase Authentication (Email/Password provider).
Enable Firestore and set up the following security rules:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /shops/{shopId} {
      allow read: if request.auth != null && (
        resource.data.ownerId == request.auth.uid ||
        exists(/databases/$(database)/documents/shops/$(shopId)/users/$(request.auth.uid))
      );
      allow write: if request.auth != null && resource.data.ownerId == request.auth.uid;

      match /inventory/{itemId} {
        allow read, write: if request.auth != null && (
          get(/databases/$(database)/documents/shops/$(shopId)).data.ownerId == request.auth.uid ||
          exists(/databases/$(database)/documents/shops/$(shopId)/users/$(request.auth.uid))
        );
      }

      match /sales/{saleId} {
        allow read, write: if request.auth != null && (
          get(/databases/$(database)/documents/shops/$(shopId)).data.ownerId == request.auth.uid ||
          exists(/databases/$(database)/documents/shops/$(shopId)/users/$(request.auth.uid))
        );
      }

      match /snapshots/{snapshotId} {
        allow read, write: if request.auth != null && (
          get(/databases/$(database)/documents/shops/$(shopId)).data.ownerId == request.auth.uid ||
          exists(/databases/$(database)/documents/shops/$(shopId)/users/$(request.auth.uid))
        );
      }

      match /joinRequests/{userId} {
        allow read: if request.auth != null && get(/databases/$(database)/documents/shops/$(shopId)).data.ownerId == request.auth.uid;
        allow write: if request.auth != null && request.auth.uid == userId;
      }

      match /users/{userId} {
        allow read, write: if request.auth != null && (
          get(/databases/$(database)/documents/shops/$(shopId)).data.ownerId == request.auth.uid ||
          request.auth.uid == userId
        );
      }
    }
  }
}


Enable Firebase Cloud Messaging (FCM) for push notifications (optional).

4. Run the App

Ensure an emulator or physical device is connected.
Run the app:

flutter run

Project Structure
lib/
├── models/
│   ├── inventory_item.dart   # Model for inventory items
│   ├── sale.dart            # Model for sales
│   └── inventory_snapshot.dart # Model for inventory snapshots
├── providers/
│   └── app_provider.dart    # Main provider for app state management
├── screens/
│   ├── home_screen.dart     # Main dashboard screen
│   └── login_screen.dart    # Sign-up and sign-in screen
├── services/
│   ├── auth_service.dart    # Handles authentication and shop management
│   ├── firebase_service.dart # Handles Firestore operations
│   └── database_helper.dart # Handles SQLite operations
└── main.dart                # Entry point of the app

Usage
1. Sign Up / Sign In

Launch the app and sign up with an email and password.
If you already have an account, switch to "Se connecter" to sign in.
If the email is already in use, the app will prompt you to sign in instead.

2. Create or Join a Shop

Owners: After signing in, create a new shop using the "Generate Shop Code" feature. Share the generated code with employees.
Employees: Use the shop code provided by the owner to request to join the shop. The owner must approve the request.

3. Manage Inventory

Add new inventory items (e.g., coffee beans, sugar) with details like quantity, buy price, and sell price.
Update or delete items as needed.
Record deliveries to update stock levels.

4. Track Sales

Record sales manually or let the app calculate sales based on inventory snapshots.
View session-based sales stats (e.g., morning vs. afternoon).

5. Monitor Operations

Use inventory snapshots to track stock levels at different times (e.g., 00:00 and 14:00).
Analyze discrepancies between expected and actual usage to detect issues like wastage or theft.

Troubleshooting

"User data not found" Error: Ensure the user document exists in Firestore after sign-up. Check the AuthService’s signUp method.
"Permission Denied" in Firestore: Verify that your Firestore security rules match the ones provided above.
App Slow on Emulator: Test on a physical device for better performance.
Offline Mode Issues: Ensure the SQLite database is properly initialized and synced with Firestore when online.

Future Improvements

Add a UI for shop creation in LoginScreen.
Implement push notifications for join request approvals.
Add more detailed analytics for sales and inventory trends.
Improve offline support with better conflict resolution for data syncing.

Contributing
Contributions are welcome! Please fork the repository, create a new branch, and submit a pull request with your changes.
License
This project is licensed under the MIT License - see the LICENSE file for details.
