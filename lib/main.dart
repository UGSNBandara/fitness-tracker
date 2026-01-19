import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'providers/exercise_provider.dart';
// Screens are imported indirectly by the AuthGate as needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ExerciseProvider())],
      child: MaterialApp(
        title: 'Fitness App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthGate(),
      ),
    );
  }
}
