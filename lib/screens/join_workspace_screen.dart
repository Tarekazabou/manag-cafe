import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../screens/inventory_screen.dart';

class JoinWorkSpace extends StatefulWidget {
  const JoinWorkSpace({super.key});

  @override
  State<JoinWorkSpace> createState() => _JoinWorkSpaceState();
}

class _JoinWorkSpaceState extends State<JoinWorkSpace> {
  final TextEditingController shopCodeController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  Future<void> _joinShop() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.requestToJoinShop(shopCodeController.text.trim());
      setState(() {
        errorMessage = AppLocalizations.of(context)!.requestSentSuccess;
      });
    } catch (e) {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.joinShopError(e.toString());
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);
    final shopId = appProvider.shopId;

    if (shopId == null) {
      return Center(child: Text(localizations.shopNotFound));
    }

    return Scaffold(
      body: Column(
        children: [
          // Search Bar (for entering shop code)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: shopCodeController,
              decoration: InputDecoration(
                labelText: localizations.shopCode,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _joinShop,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(localizations.joinShop),
                  ),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          AppBar(
            title: Text(shopId),
            actions: const [],
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

    // Check if already approved
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

