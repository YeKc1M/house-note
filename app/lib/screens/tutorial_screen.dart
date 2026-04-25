import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  final bool isFirstRun;
  const TutorialScreen({super.key, this.isFirstRun = false});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Tutorial')));
  }
}
