import 'package:flutter/material.dart';
import 'data/database.dart';

class HouseNoteApp extends StatelessWidget {
  final AppDatabase database;

  const HouseNoteApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'House Note',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('House Note')),
      ),
    );
  }
}
