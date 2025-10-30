import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness App Home'),
        actions: [
          if (user != null)
            IconButton(
              tooltip: 'Sign out',
              onPressed: () async {
                await AuthService.instance.signOut();
              },
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome to Fitness App!\n\nUse the bottom navigation to explore features.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            if (user != null)
              Text(
                'Signed in as: ${user.email}',
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }
}
