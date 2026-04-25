import 'package:flutter/material.dart';

class TutorialSpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final double borderRadius;
  final Color overlayColor;
  final Color borderColor;

  TutorialSpotlightPainter({
    required this.targetRect,
    this.borderRadius = 12,
    this.overlayColor = const Color(0xBF000000),
    this.borderColor = const Color(0x80673AB7),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          targetRect,
          Radius.circular(borderRadius),
        ),
      );

    final path = Path.combine(PathOperation.difference, overlayPath, cutoutPath);

    canvas.drawPath(
      path,
      Paint()..color = overlayColor,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        targetRect,
        Radius.circular(borderRadius),
      ),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant TutorialSpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.borderColor != borderColor;
  }
}
