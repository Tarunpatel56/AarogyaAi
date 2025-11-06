import 'package:flutter/material.dart';
import '../model/keypoint.dart';

class PosePainter extends CustomPainter {
  final List<KeyPoint> keypoints;
  final Size cameraSize;

  PosePainter({required this.keypoints, required this.cameraSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (keypoints.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final circlePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    // Define skeleton connections (using indices 0-16)
    final skeleton = [
      (5, 7), (7, 9),     // Left arm
      (6, 8), (8, 10),    // Right arm
      (5, 6),             // Shoulders
      (5, 11), (6, 12),   // Spine
      (11, 12),           // Hips
      (11, 13), (13, 15), // Left leg
      (12, 14), (14, 16)  // Right leg
    ];

    // Rescale keypoints from model output size to screen size
    Offset rescale(KeyPoint kp) {
      // This is a simple stretch. You may need a more complex transform
      // depending on your model's output and the camera aspect ratio.
      final double x = kp.x * size.width / cameraSize.width;
      final double y = kp.y * size.height / cameraSize.height;
      return Offset(x, y);
    }

    // Draw lines
    for (final (start, end) in skeleton) {
      if (keypoints[start].confidence > 0.5 && keypoints[end].confidence > 0.5) {
        canvas.drawLine(rescale(keypoints[start]), rescale(keypoints[end]), paint);
      }
    }

    // Draw keypoints
    for (final kp in keypoints) {
      if (kp.confidence > 0.5) {
        canvas.drawCircle(rescale(kp), 5, circlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}