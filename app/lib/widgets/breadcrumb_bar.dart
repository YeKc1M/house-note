import 'package:flutter/material.dart';
import '../blocs/instance_list/state.dart';

class BreadcrumbBar extends StatelessWidget {
  final List<Breadcrumb> breadcrumbs;
  final void Function(int) onTap;

  const BreadcrumbBar({super.key, required this.breadcrumbs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onTap(-1),
          child: const Text('全部', style: TextStyle(color: Colors.blue)),
        ),
        ...breadcrumbs.asMap().entries.expand((e) => [
          const Text(' > '),
          GestureDetector(
            onTap: () => onTap(e.key),
            child: Text(e.value.name, style: const TextStyle(color: Colors.blue)),
          ),
        ]),
      ],
    );
  }
}
