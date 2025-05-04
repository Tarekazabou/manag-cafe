# Coffee Shop Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

Coffee Shop Manager is a Flutter-based mobile application designed to help coffee shop owners and employees manage inventory, track sales, and monitor daily operations efficiently. The app integrates with Firebase for real-time data synchronization, authentication, and cloud storage. It supports both online and offline modes by using a local SQLite database for data persistence.

## Key Features

*   **User Authentication:** Secure sign-up and sign-in using Firebase Authentication.
*   **Shop Management:** Owners can create shops, generate unique shop codes, and manage employee join requests.
*   **Inventory Management:** Add, update, and delete inventory items with real-time syncing to Firestore.
*   **Sales Tracking:** Record sales, calculate profits, and analyze session-based sales stats.
*   **Inventory Snapshots:** Record inventory snapshots at specific time slots to track stock changes.
*   **Offline Support:** Local SQLite database ensures the app works offline, with data syncing when online.
*   **Role-Based Access:** Separate permissions for shop owners and employees.

## Tech Stack

*   **Frontend:** Flutter (Dart)
*   **Backend:** Firebase
    *   **Firebase Authentication:** For user sign-up and sign-in.
    *   **Firestore:** For real-time database operations.
    *   **Firebase Cloud Messaging (FCM):** For push notifications.
*   **Local Storage:** SQLite (via `sqflite` package)
*   **State Management:** Provider (`ChangeNotifier`)

## Prerequisites

Before setting up the project, ensure you have the following installed:

*   Flutter SDK: Version 3.0.0 or higher
*   Dart: Included with Flutter
*   Android Studio or VS Code with Flutter and Dart plugins
*   Firebase Account: For backend services
*   A physical Android/iOS device or emulator for testing

## Setup Instructions

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/yourusername/coffee-shop-manager.git
    cd coffee-shop-manager
    ```
    *(Replace `yourusername` with the actual GitHub username if applicable)*

2.  **Install Dependencies**
    Run the following command in the project root directory to install all required packages:
    ```bash
    flutter pub get
    ```

3.  **Configure Firebase**

    *   Create a new project in the [Firebase Console](https://console.firebase.google.com/).
    *   **Add an Android app** to your Firebase project:
        *   Use the package name: `com.example.manag_cafe`
        *   Download the `google-services.json` file.
        *   Place the downloaded `google-services.json` file in the `android/app/` directory of your Flutter project.
    *   **Add an iOS app** (if targeting iOS):
        *   Follow the Firebase instructions to add an iOS app.
        *   Download the `GoogleService-Info.plist` file.
        *   Place the downloaded `GoogleService-Info.plist` file in the `ios/Runner/` directory using Xcode.
    *   **Enable Firebase Authentication:**
        *   Go to the Authentication section in the Firebase Console.
        *   Enable the "Email/Password" sign-in provider.
    *   **Enable Firestore:**
        *   Go to the Firestore Database section in the Firebase Console.
        *   Create a database (choose Native mode).
        *   Select a location.
        *   Go to the "Rules" tab and paste the following security rules:

        ```rules
        rules_version = '2';
        service cloud.firestore {
          match /databases/{database}/documents {
            // User profile data (only accessible by the user themselves)
            match /users/{userId} {
              allow read, write: if request.auth != null && request.auth.uid == userId;
            }

            // Shop data
            match /shops/{shopId} {
              // Allow read if owner or member of the shop
              allow read: if request.auth != null && (
                resource.data.ownerId == request.auth.uid ||
                exists(/databases/$(database)/documents/shops/$(shopId)/users/$(request.auth.uid))
              );
              // Allow write only if owner
              allow write: if request.auth != null && resource.data.ownerId == request.auth.uid;

              // Inventory items within a shop
              match /inventory/{itemId} {
                allow read, write: if request.auth != null && (
                  get(/databases/$(database)/documents/shops/$(shopId)).data.ownerId == request.auth.uid ||
                  exists(/databases/$(database)/documents/shops/$(shopId)/users/$(request.auth.uid))
                );
              }

              // Sales records within a shop
              match /sales/{saleId} {
                allow read, write: if request.auth != null && (
                  get(/databases/$(database)/documents/shops/$(shopId)).data.ownerId == request.auth.uid ||
                  exists(/databases/$(database)/documents/shops/$(shopId)/users/$(request.auth.uid))
                );
              }

              // Inventory snapshots within a shop
              match /snapshots/{snapshotId} {
                allow read, write: if request.auth != null && (
                  get(/databases/$(database)/documents/shops/$(shopId)).data.ownerId == request.auth.uid ||
                  exists(/databases/$(database)/documents/shops/$(shopId)/users/$(request.auth.uid))
                );
              }

              // Join requests for a shop
              match /joinRequests/{userId} {
                // Owner can read all requests for their shop
                allow read: if request.auth != null && get(/databases/$(database)/documents/shops/$(shopId)).data.ownerId == request.auth.uid;
                // Any authenticated user can create their own join request
                allow write: if request.auth != null && request.auth.uid == userId;
                // Note: Deletion/Update might need specific rules (e.g., only owner can delete/update status)
              }

              // User roles/membership within a shop
              match /users/{userId} {
                 // Allow read/write if owner (to manage members) or if it's the user's own membership record
                allow read, write: if request.auth != null && (
                  get(/databases/$(database)/documents/shops/$(shopId)).data.ownerId == request.auth.uid ||
                  request.auth.uid == userId
                );
              }
            }
          }
        }
        ```
        *   Publish the rules.
    *   **(Optional) Enable Firebase Cloud Messaging (FCM):**
        *   Follow the Firebase documentation to set up FCM for push notifications if needed.

4.  **Run the App**

    *   Ensure an emulator is running or a physical device is connected.
    *   Run the app using the following command:
        ```bash
        flutter run
        ```

## Project Structure
lib/
├── models/
│ ├── inventory_item.dart # Model for inventory items
│ ├── sale.dart # Model for sales
│ └── inventory_snapshot.dart # Model for inventory snapshots
├── providers/
│ └── app_provider.dart # Main provider for app state management
├── screens/
│ ├── home_screen.dart # Main dashboard screen
│ └── login_screen.dart # Sign-up and sign-in screen
├── services/
│ ├── auth_service.dart # Handles authentication and shop management
│ ├── firebase_service.dart # Handles Firestore operations
│ └── database_helper.dart # Handles SQLite operations
└── main.dart # Entry point of the app

## Usage

1.  **Sign Up / Sign In**
    *   Launch the app and sign up with an email and password.
    *   If you already have an account, switch to the "Sign In" option.
    *   If the email is already in use during sign-up, the app will prompt you to sign in instead.

2.  **Create or Join a Shop**
    *   **Owners:** After signing in, you'll likely be prompted to create a shop or see an option to do so. Use the "Generate Shop Code" feature within the app. Share the generated code with your employees.
    *   **Employees:** After signing in, use the shop code provided by the owner to request to join the shop. The owner needs to approve your request (check the shop management/requests section in their app).

3.  **Manage Inventory**
    *   Navigate to the inventory section.
    *   Add new inventory items (e.g., coffee beans, milk, sugar) including details like current quantity, buy price, and sell price.
    *   Update existing item details or quantities (e.g., after a delivery).
    *   Delete items that are no longer stocked.

4.  **Track Sales**
    *   Record sales transactions as they happen. This might involve selecting items from the inventory, which automatically decrements stock.
    *   The app may calculate sales based on the difference between inventory snapshots.
    *   View session-based sales statistics (e.g., morning vs. afternoon) to understand peak times and profitability.

5.  **Monitor Operations**
    *   Use the inventory snapshot feature to record stock levels at specific times (e.g., start of day at 00:00, mid-day at 14:00).
    *   Compare snapshots and sales data to analyze discrepancies between expected stock usage (based on sales) and actual stock usage. This can help identify potential issues like wastage or theft.

## Troubleshooting

*   **"User data not found" Error:** Ensure the user document is being created correctly in the `/users/{userId}` path in Firestore immediately after successful sign-up. Check the `signUp` method in `AuthService`.
*   **"Permission Denied" in Firestore:** Double-check that your Firestore security rules in the Firebase Console exactly match the ones provided in the Setup section. Ensure the user is authenticated and accessing data according to the rules (e.g., owner vs. employee).
*   **App Slow on Emulator:** Emulators can sometimes be slower than physical devices, especially with network operations. Testing on a physical device is recommended for performance evaluation.
*   **Offline Mode Issues:** Verify that the `DatabaseHelper` (SQLite) is correctly initialized. Check the logic for caching data locally and syncing it back to Firestore when the network connection is restored. Ensure error handling is in place for failed sync attempts.

## Future Improvements

*   [ ] Add a dedicated UI flow for shop creation directly within the `LoginScreen` or immediately after the first sign-in for a new user.
*   [ ] Implement push notifications (using FCM) to alert owners about new employee join requests and to notify employees when their request is approved/rejected.
*   [ ] Develop more detailed analytics and reports for sales trends, inventory turnover, and profit margins over different time periods.
*   [ ] Enhance offline support with more robust conflict resolution strategies for data syncing when multiple users make changes offline.

## Contributing

Contributions are welcome! If you'd like to contribute, please:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/YourFeatureName`).
3.  Make your changes.
4.  Commit your changes (`git commit -m 'Add some feature'`).
5.  Push to the branch (`git push origin feature/YourFeatureName`).
6.  Open a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
*(Ensure you have a LICENSE file in your repository, or remove this link if not)*
