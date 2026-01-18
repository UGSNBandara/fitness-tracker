import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'login_screen.dart';
import 'main_navigation.dart';
import 'onboarding_screen.dart';
import '../services/user_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          // Check if user profile is complete
          return FutureBuilder<bool>(
            future: UserService.instance.isProfileComplete(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (profileSnapshot.data == true) {
                return const MainNavigation();
              }
              return const OnboardingScreen();
            },
          );
        }
        return const LoginScreen();
      },
    );
  }
}
