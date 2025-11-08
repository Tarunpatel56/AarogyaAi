// lib/logic/pose_utils.dart
import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:vector_math/vector_math.dart';

class PoseUtils {
  static PoseLandmark getLandmark(Pose pose, PoseLandmarkType type) {
    return pose.landmarks[type] ?? PoseLandmark(type: type, x: 0, y: 0, z: 0, likelihood: 0);
  }

  static double calculateAngle(PoseLandmark p1, PoseLandmark p2, PoseLandmark p3) {
    if (p1.likelihood < 0.5 || p2.likelihood < 0.5 || p3.likelihood < 0.5) {
      return 0.0;
    }
    try {
      final v1 = Vector2(p1.x, p1.y);
      final v2 = Vector2(p2.x, p2.y);
      final v3 = Vector2(p3.x, p3.y);
      final ba = v1 - v2;
      final bc = v3 - v2;
      double cosineAngle = ba.dot(bc) / (ba.length * bc.length);
      cosineAngle = cosineAngle.clamp(-1.0, 1.0);
      return degrees(acos(cosineAngle));
    } catch (e) {
      return 0.0;
    }
  }

  static Map<String, double> calculateAllAngles(Pose pose) {
    return {
      'left_shoulder': calculateAngle(
        getLandmark(pose, PoseLandmarkType.leftElbow),
        getLandmark(pose, PoseLandmarkType.leftShoulder),
        getLandmark(pose, PoseLandmarkType.leftHip),
      ),
      'right_shoulder': calculateAngle(
        getLandmark(pose, PoseLandmarkType.rightElbow),
        getLandmark(pose, PoseLandmarkType.rightShoulder),
        getLandmark(pose, PoseLandmarkType.rightHip),
      ),
      'left_elbow': calculateAngle(
        getLandmark(pose, PoseLandmarkType.leftShoulder),
        getLandmark(pose, PoseLandmarkType.leftElbow),
        getLandmark(pose, PoseLandmarkType.leftWrist),
      ),
      'right_elbow': calculateAngle(
        getLandmark(pose, PoseLandmarkType.rightShoulder),
        getLandmark(pose, PoseLandmarkType.rightElbow),
        getLandmark(pose, PoseLandmarkType.rightWrist),
      ),
      'left_hip': calculateAngle(
        getLandmark(pose, PoseLandmarkType.leftShoulder),
        getLandmark(pose, PoseLandmarkType.leftHip),
        getLandmark(pose, PoseLandmarkType.leftKnee),
      ),
      'right_hip': calculateAngle(
        getLandmark(pose, PoseLandmarkType.rightShoulder),
        getLandmark(pose, PoseLandmarkType.rightHip),
        getLandmark(pose, PoseLandmarkType.rightKnee),
      ),
      'left_knee': calculateAngle(
        getLandmark(pose, PoseLandmarkType.leftHip),
        getLandmark(pose, PoseLandmarkType.leftKnee),
        getLandmark(pose, PoseLandmarkType.leftAnkle),
      ),
      'right_knee': calculateAngle(
        getLandmark(pose, PoseLandmarkType.rightHip),
        getLandmark(pose, PoseLandmarkType.rightKnee),
        getLandmark(pose, PoseLandmarkType.rightAnkle),
      ),
    };
  }
}