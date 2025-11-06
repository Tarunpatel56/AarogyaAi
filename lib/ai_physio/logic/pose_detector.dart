import 'dart:math';
import 'package:vector_math/vector_math.dart';
import '../model/keypoint.dart';

class PoseDetector {
  PoseDetector();

  /// Calculates the angle (in degrees) between three points (p1-p2-p3).
  double? calculateAngle(KeyPoint p1, KeyPoint p2, KeyPoint p3) {
    const double minConfidence = 0.5;

    if (p1.confidence < minConfidence || p2.confidence < minConfidence || p3.confidence < minConfidence) {
      return null;
    }

    final Vector2 a = Vector2(p1.x, p1.y);
    final Vector2 b = Vector2(p2.x, p2.y);
    final Vector2 c = Vector2(p3.x, p3.y);

    final Vector2 ba = a - b;
    final Vector2 bc = c - b;

    final double dotProduct = ba.dot(bc);
    final double magnitudeProduct = ba.length * bc.length;

    if (magnitudeProduct == 0) return null;

    double cosineAngle = dotProduct / magnitudeProduct;
    cosineAngle = cosineAngle.clamp(-1.0, 1.0);
    
    final double angle = degrees(acos(cosineAngle));
    return angle;
  }

  /// Calculates all relevant exercise angles from a list of 17 keypoints.
  Map<String, double?> calculateAllAngles(List<KeyPoint> keypoints) {
    if (keypoints.length < 17) return {};

    final k = keypoints;
    return {
      'left_shoulder': calculateAngle(k[7], k[5], k[11]),
      'right_shoulder': calculateAngle(k[8], k[6], k[12]),
      'left_elbow': calculateAngle(k[5], k[7], k[9]),
      'right_elbow': calculateAngle(k[6], k[8], k[10]),
      'left_hip': calculateAngle(k[5], k[11], k[13]),
      'right_hip': calculateAngle(k[6], k[12], k[14]),
      'left_knee': calculateAngle(k[11], k[13], k[15]),
      'right_knee': calculateAngle(k[12], k[14], k[16]),
    };
  }
}