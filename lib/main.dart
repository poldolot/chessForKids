import 'package:flutter/material.dart';

void main() {
  runApp(const ChessForKidsApp());
}

class ChessForKidsApp extends StatelessWidget {
  const ChessForKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Chess for Kids',
      home: Scaffold(body: Center(child: Text('Chess for Kids'))),
    );
  }
}
