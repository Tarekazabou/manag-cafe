import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../screens/inventory_screen.dart';

class ManageRequestsScreen extends StatefulWidget {
  const ManageRequestsScreen({super.key});

  @override
  State<ManageRequestsScreen> createState() => _ManageRequestsScreenState();
}

class _ManageRequestsScreenState extends State<ManageRequestsScreen> {
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);
    final shopId = appProvider.shopId;

    if (shopId == null) {
      return Center(child: Text(localizations.shopNotFound));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(shopId!),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizations.signOutSuccess)),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(localizations.signOutError(e.toString()))),
                );
              }
            },
            tooltip: localizations.signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('shops')
                  .doc(shopId)
                  .collection('joinRequests')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(localizations.errorLoadingRequests));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text(localizations.noRequestsFound));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final request = snapshot.data!.docs[index];
                    final userId = request.id;
                    final userData = request.data() as Map<String, dynamic>;
                    final user = FirebaseAuth.instance.currentUser;

                    return ListTile(
                      title: Text(userData['email'] ?? localizations.unknownUser),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => approveRequest(
                                context, shopId, userId, user!.email!),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () =>
                                denyRequest(context, shopId, userId, user!.email!),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> approveRequest(
      BuildContext context, String shopId, String userId, String email) async {
    final localizations = AppLocalizations.of(context)!;
    final userRef = FirebaseFirestore.instance
        .collection('shops')
        .doc(shopId)
        .collection('users')
        .doc(userId);
    await userRef.set({
      'email': email,
      'status': 'accepted',
      'timestamp': DateTime.now().toIso8601String(),
    });

    final userSnapshot = await userRef.get();
    if (userSnapshot.exists && userSnapshot.data()!['status'] == 'accepted') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InventoryScreen()),
      );
    } else {
      setState(() {
        errorMessage = localizations.requestSentWaitingApproval;
      });
    }
  }

  Future<void> denyRequest(
      BuildContext context, String shopId, String userId, String email) async {
    final localizations = AppLocalizations.of(context)!;
    final userRef = FirebaseFirestore.instance
        .collection('shops')
        .doc(shopId)
        .collection('users')
        .doc(userId);
    await userRef.set({
      'email': email,
      'status': 'denied',
      'timestamp': DateTime.now().toIso8601String(),
    });

    setState(() {
      errorMessage = localizations.requestDenied;
    });
  }
}