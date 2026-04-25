import 'package:flutter/material.dart';

class TutorialPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget illustration;

  const TutorialPage({
    super.key,
    required this.title,
    required this.description,
    required this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(child: illustration),
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
