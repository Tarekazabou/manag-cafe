import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'manage_requests_screen.dart';

class OwnerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Owner Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coffee Shop Code:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            provider.shopCode != null
                ? Text(
                    provider.shopCode!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                : CircularProgressIndicator(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageRequestsScreen()),
                );
              },
              child: Text('Manage Employee Requests'),
            ),
          ],
        ),
      ),
    );
  }
}