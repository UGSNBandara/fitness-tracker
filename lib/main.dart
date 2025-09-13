import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/exercise_screen.dart';
import 'screens/food_screen.dart';
import 'screens/ai_monitor_screen.dart';
import 'screens/schedule_screen.dart';

void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    ExerciseScreen(),
    FoodScreen(),
    AiMonitorScreen(),
    ScheduleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Food'),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'AI Monitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
