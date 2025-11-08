// TODO Implement this library.
// lib/features/physio_trainer/widgets/skeleton_painter.dart
import 'dart:math'; // Import for min/max
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class SkeletonPainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final bool
  mirror; // whether to horizontally mirror coordinates (front camera)

  SkeletonPainter({
    required this.poses,
    required this.imageSize,
    this.mirror = false,
  });

  final Paint pointPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill
    ..strokeWidth = 6;
  final Paint linePaint = Paint()
    ..color = Colors.green
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.width == 0 || imageSize.height == 0) return;

    // --- THIS IS THE CORRECTED SCALING LOGIC FOR BoxFit.cover ---
    final double hRatio = size.width / imageSize.width;
    final double vRatio = size.height / imageSize.height;
    // Use max to "cover" the screen, matching the FittedBox
    final ratio = max(hRatio, vRatio);

    // Calculate padding to center the scaled image
    final double hPadding = (size.width - imageSize.width * ratio) / 2;
    final double vPadding = (size.height - imageSize.height * ratio) / 2;
    // --- END OF CORRECTION ---

    Offset scalePoint(PoseLandmark landmark) {
      double lx = landmark.x;
      if (mirror) {
        // mirror x around image width
        lx = imageSize.width - landmark.x;
      }
      final double x = lx * ratio + hPadding;
      final double y = landmark.y * ratio + vPadding;
      // clamp to the canvas area to avoid extreme coordinates
      final double cx = x.clamp(0.0, size.width);
      final double cy = y.clamp(0.0, size.height);
      return Offset(cx, cy);
    }

    for (final pose in poses) {
      final connections = [
        (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow),
        (PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist),
        (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow),
        (PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist),
        (
          PoseLandmarkType.leftShoulder,
          PoseLandmarkType.rightShoulder,
        ), // Corrected typo
        (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip),
        (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip),
        (PoseLandmarkType.leftHip, PoseLandmarkType.rightHip),
        (PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee),
        (PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle),
        (PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee),
        (PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle),
      ];

      // Draw lines
      for (final pair in connections) {
        final p1 = pose.landmarks[pair.$1];
        final p2 = pose.landmarks[pair.$2];
        if (p1 != null &&
            p2 != null &&
            p1.likelihood > 0.5 &&
            p2.likelihood > 0.5 &&
            p1.x.isFinite &&
            p1.y.isFinite &&
            p2.x.isFinite &&
            p2.y.isFinite) {
          canvas.drawLine(scalePoint(p1), scalePoint(p2), linePaint);
        }
      }

      // Draw points
      for (final landmark in pose.landmarks.values) {
        if (landmark.likelihood > 0.5 &&
            landmark.x.isFinite &&
            landmark.y.isFinite) {
          canvas.drawCircle(scalePoint(landmark), 4, pointPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) {
    return oldDelegate.poses != poses ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.mirror != mirror;
  }
}
