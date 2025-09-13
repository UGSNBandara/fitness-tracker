import 'package:flutter/material.dart';

class ExerciseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exercise Routines')),
      body: Center(
        child: Text(
          'Exercise routines will be shown here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
