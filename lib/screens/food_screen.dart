import 'package:flutter/material.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Food Routines')),
      body: Center(
        child: Text(
          'Food routines will be shown here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
