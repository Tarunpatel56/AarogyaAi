import 'dart:math';

class ExerciseLogic {
  final Map<String, dynamic> thresholds = {
    'tree_pose': {
      'knee_bend': 25.0,
      'balance_duration': 1.5,
      'hip_variance': 20.0
    },
    'squat': {'down': 100.0, 'up': 130.0, 'knee_alignment': 30.0},
    'pushup': {'down': 100.0, 'up': 150.0, 'hip_variance': 20.0},
    'jumping_jack': {'down': 30.0, 'up': 90.0}
  };

  String _exerciseState = "start";
  int repCount = 0;
  int? _poseStartTime;
  int? _lastPoseEndTime;

  ExerciseLogic();

  void reset() {
    repCount = 0;
    _exerciseState = "start";
    _poseStartTime = null;
    _lastPoseEndTime = null;
  }

  bool checkForm(String exercise, Map<String, double?> angles) {
    return true;
  }

  bool countReps(String exercise, Map<String, double?> angles) {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (exercise == 'tree_pose') {
      final rightKnee = angles['right_knee'];
      final leftKnee = angles['left_knee'];
      final rightHip = angles['right_hip'];
      final leftHip = angles['left_hip'];

      if (rightKnee != null && leftKnee != null &&
          rightHip != null && leftHip != null) {
        final kneeDiff = (rightKnee - leftKnee).abs();
        final hipDiff = (rightHip - leftHip).abs();
        final isInPose = (kneeDiff > thresholds['tree_pose']['knee_bend'] &&
            hipDiff < thresholds['tree_pose']['hip_variance']);

        if (isInPose) {
          if (_exerciseState == 'start') {
            _poseStartTime = now;
            _exerciseState = 'holding';
          } else if (_exerciseState == 'holding') {
            if (now - _poseStartTime! >=
                thresholds['tree_pose']['balance_duration'] * 1000) {
              if (_lastPoseEndTime == null || now - _lastPoseEndTime! > 1000) {
                repCount++;
                _lastPoseEndTime = now;
                _exerciseState = 'start';
                return true;
              }
            }
          }
        } else {
          _exerciseState = 'start';
          _poseStartTime = null;
        }
      }
    } else if (exercise == 'squat') {
      final rightKnee = angles['right_knee'];
      final leftKnee = angles['left_knee'];
      if (rightKnee != null && leftKnee != null) {
        final kneeAngle = (rightKnee + leftKnee) / 2;
        if ((_exerciseState == 'up' || _exerciseState == 'start') &&
            kneeAngle < thresholds['squat']['down']) {
          _exerciseState = 'down';
        } else if (_exerciseState == 'down' &&
            kneeAngle > thresholds['squat']['up']) {
          _exerciseState = 'up';
          repCount++;
          return true;
        }
      }
    } else if (exercise == 'pushup') {
      final rightElbow = angles['right_elbow'];
      final leftElbow = angles['left_elbow'];
      if (rightElbow != null && leftElbow != null) {
        final elbowAngle = (rightElbow + leftElbow) / 2;
        if ((_exerciseState == 'up' || _exerciseState == 'start') &&
            elbowAngle < thresholds['pushup']['down']) {
          _exerciseState = 'down';
        } else if (_exerciseState == 'down' &&
            elbowAngle > thresholds['pushup']['up']) {
          _exerciseState = 'up';
          repCount++;
          return true;
        }
      }
    } else if (exercise == 'jumping_jack') {
      final rightShoulder = angles['right_shoulder'];
      final leftShoulder = angles['left_shoulder'];
      if (rightShoulder != null && leftShoulder != null) {
        final shoulderAngle = (rightShoulder + leftShoulder) / 2;
        if ((_exerciseState == 'up' || _exerciseState == 'start') &&
            shoulderAngle > thresholds['jumping_jack']['up']) {
          _exerciseState = 'down';
        } else if (_exerciseState == 'down' &&
            shoulderAngle < thresholds['jumping_jack']['down']) {
          _exerciseState = 'up';
          repCount++;
          return true;
        }
      }
    }
    return false;
  }

  (int, List<String>) getFormFeedback(
      String exercise, Map<String, double?> angles) {
    int confidence = 0;
    List<String> feedback = [];

    if (exercise == 'squat') {
      final rightKnee = angles['right_knee'];
      final leftKnee = angles['left_knee'];
      if (rightKnee != null && leftKnee != null) {
        final kneeAngle = (rightKnee + leftKnee) / 2;
        final kneeDiff = (rightKnee - leftKnee).abs();
        final double downThreshold = thresholds['squat']['down'] as double;
        final double alignmentThreshold =
            thresholds['squat']['knee_alignment'] as double;

        final depthScore = min(
            100.0, (200.0 - kneeAngle) / (200.0 - downThreshold) * 100.0);
        final alignmentScore =
            max(0.0, 100.0 - (kneeDiff / alignmentThreshold) * 100.0);
        confidence =
            ((depthScore.clamp(0.0, 100.0) + alignmentScore) / 2).toInt();

        if (kneeAngle > downThreshold) feedback.add("Squat deeper");
        if (kneeDiff > alignmentThreshold) feedback.add("Keep knees aligned");
      }
    }

    if (feedback.isEmpty) feedback.add("Form looks good!");
    return (confidence.clamp(0, 100), feedback);
  }
}