import 'package:flutter/material.dart';
import '../data/database.dart';

class InstanceCard extends StatelessWidget {
  final Instance instance;
  final Map<String, String> thumbnailValues;
  final int? childCount;
  final VoidCallback onTap;

  const InstanceCard({
    super.key,
    required this.instance,
    required this.thumbnailValues,
    this.childCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(instance.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (thumbnailValues.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: thumbnailValues.entries.map((e) => Chip(label: Text('${e.key}: ${e.value}'))).toList(),
                ),
              if (childCount != null)
                Text('$childCount 套房子', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
