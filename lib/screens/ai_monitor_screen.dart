import 'package:flutter/material.dart';

class AiMonitorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Monitor')),
      body: Center(
        child: Text(
          'AI monitoring features will be shown here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
