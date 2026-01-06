import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes_appcrew/services/auth_gate.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/notes_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthGate(), // ✅ clean & correct
      ),
    );
  }
}
