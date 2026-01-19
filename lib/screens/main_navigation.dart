import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'exercise_screen.dart';
import 'food_screen.dart';
import 'profile_screen.dart';
import '../services/user_service.dart';
import '../providers/exercise_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _screens = const [
    HomeScreen(),
    ExerciseScreen(),
    FoodScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load user profile and set their fitness level in ExerciseProvider
    _initializeUserLevel();
  }

  Future<void> _initializeUserLevel() async {
    try {
      final user = await UserService.instance.getCurrentUserProfile();
      if (user != null && mounted) {
        // Set user's fitness level in exercise provider
        context.read<ExerciseProvider>().setUserLevel(user.level);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void changeTab(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: changeTab,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Food'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
