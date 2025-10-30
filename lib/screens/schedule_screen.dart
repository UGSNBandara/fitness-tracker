import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Schedule')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Today\'s Exercise Routine',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.fitness_center, color: Colors.blue),
              title: Text('Push Ups'),
              subtitle: Text('3 sets x 15 reps'),
              trailing: Icon(Icons.check_circle_outline),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.directions_run, color: Colors.green),
              title: Text('Jogging'),
              subtitle: Text('20 minutes'),
              trailing: Icon(Icons.check_circle_outline),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Today\'s Food Routine',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.breakfast_dining, color: Colors.orange),
              title: Text('Breakfast'),
              subtitle: Text('Oatmeal, Banana, Eggs'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.lunch_dining, color: Colors.red),
              title: Text('Lunch'),
              subtitle: Text('Grilled Chicken, Rice, Salad'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.dinner_dining, color: Colors.purple),
              title: Text('Dinner'),
              subtitle: Text('Fish, Quinoa, Veggies'),
            ),
          ),
        ],
      ),
    );
  }
}
