import 'package:flutter/material.dart';

/// Mock template editor illustration for tutorial Page 2
class MockTemplateEditor extends StatelessWidget {
  const MockTemplateEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.edit_note, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text('模板名称', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _MockDimensionRow(label: '朝向', type: '单选'),
        const SizedBox(height: 8),
        const _MockDimensionRow(label: '楼层', type: '数字'),
        const SizedBox(height: 8),
        const _MockDimensionRow(label: '户型', type: '文本'),
      ],
    );
  }
}

class _MockDimensionRow extends StatelessWidget {
  final String label;
  final String type;

  const _MockDimensionRow({required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(type, style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade700)),
          ),
        ],
      ),
    );
  }
}

/// Mock flow diagram for tutorial Page 3
class MockFlowDiagram extends StatelessWidget {
  const MockFlowDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _MockFlowCard('小区模板'),
        SizedBox(width: 8),
        Icon(Icons.arrow_forward, color: Colors.grey),
        SizedBox(width: 8),
        _MockFlowCard('房子列表\n(引用)', small: true),
        SizedBox(width: 8),
        Icon(Icons.arrow_forward, color: Colors.grey),
        SizedBox(width: 8),
        _MockFlowCard('房子模板'),
      ],
    );
  }
}

class _MockFlowCard extends StatelessWidget {
  final String text;
  final bool small;

  const _MockFlowCard(this.text, {this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: small ? 11 : 13,
          color: Colors.deepPurple.shade800,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Mock instance card for tutorial Page 4
class MockInstanceCard extends StatelessWidget {
  const MockInstanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('华润二十四城', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                _MockChip('成华区'),
                SizedBox(width: 6),
                _MockChip('是'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MockChip extends StatelessWidget {
  final String label;
  const _MockChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

/// Mock breadcrumb + instance list for tutorial Page 5
class MockBreadcrumbList extends StatelessWidget {
  const MockBreadcrumbList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Text('全部', style: TextStyle(color: Colors.grey)),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              Text('华润二十四城'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _MockInstanceListCard('7栋-1203'),
        const SizedBox(height: 8),
        const _MockInstanceListCard('8栋-1501'),
      ],
    );
  }
}

class _MockInstanceListCard extends StatelessWidget {
  final String name;
  const _MockInstanceListCard(this.name);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500))),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

/// Mock swipe-to-delete for tutorial Page 6
class MockSwipeCard extends StatelessWidget {
  const MockSwipeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ],
          ),
        ),
        Container(
          height: 60,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Row(
            children: [
              Expanded(child: Text('7栋-1203', style: TextStyle(fontWeight: FontWeight.w500))),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }
}
