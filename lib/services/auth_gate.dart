import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Screens/login_screen.dart';
import '../Screens/notes_list_screen.dart';



class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Logged in
        if (snapshot.hasData) {
          return const NotesListScreen();
        }

        // ❌ Logged out
        return const LoginScreen();
      },
    );
  }
}
