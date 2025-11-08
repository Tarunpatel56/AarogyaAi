// lib/logic/exercise_logic.dart
import 'dart:math';

class ExerciseLogic {
  final Map<String, Map<String, double>> thresholds = {
    'tree_pose': {
      'knee_bend': 25.0,
      'balance_duration': 1.5,
      'hip_variance': 20.0,
    },
    'squat': {
      'down': 100.0,
      'up': 130.0,
      'knee_alignment': 30.0,
    },
    'pushup': {
      'down': 100.0,
      'up': 150.0,
      'hip_variance': 20.0,
    },
    'jumping_jack': {
      'down': 30.0,
      'up': 90.0,
    }
  };

  String exerciseState = "up"; // Default to 'up' or 'start'
  int repCount = 0;
  DateTime? poseStartTime;
  DateTime? lastPoseEndTime;

  double _getAngle(Map<String, double> angles, String name) {
    return angles[name] ?? 0.0;
  }

  void reset() {
    repCount = 0;
    exerciseState = "up"; // Reset to 'up'
    poseStartTime = null;
    lastPoseEndTime = null;
  }

  bool countReps(String exercise, Map<String, double> angles) {
    DateTime currentTime = DateTime.now();
    bool repCompleted = false;

    switch (exercise) {
      case 'tree_pose':
        double rightKnee = _getAngle(angles, 'right_knee');
        double leftKnee = _getAngle(angles, 'left_knee');
        double rightHip = _getAngle(angles, 'right_hip');
        double leftHip = _getAngle(angles, 'left_hip');

        if (rightKnee > 0 && leftKnee > 0 && rightHip > 0 && leftHip > 0) {
          double kneeDiff = (rightKnee - leftKnee).abs();
          double hipDiff = (rightHip - leftHip).abs();

          if (kneeDiff > thresholds['tree_pose']!['knee_bend']! && hipDiff < thresholds['tree_pose']!['hip_variance']!) {
            if (exerciseState == 'up') {
              poseStartTime = currentTime;
              exerciseState = 'holding';
            } else if (exerciseState == 'holding') {
              double duration = currentTime.difference(poseStartTime!).inMilliseconds / 1000.0;
              if (duration >= thresholds['tree_pose']!['balance_duration']!) {
                if (lastPoseEndTime == null || currentTime.difference(lastPoseEndTime!).inSeconds > 1) {
                  repCount++;
                  repCompleted = true;
                  lastPoseEndTime = currentTime;
                  exerciseState = 'up'; // Reset for next rep
                }
              }
            }
          } else {
            if (exerciseState == 'holding') {
              exerciseState = 'up';
            }
            poseStartTime = null;
          }
        }
        break;
      case 'squat':
        double rightKnee = _getAngle(angles, 'right_knee');
        double leftKnee = _getAngle(angles, 'left_knee');
        if (rightKnee > 0 && leftKnee > 0) {
          double kneeAngle = (rightKnee + leftKnee) / 2;
          if (exerciseState == 'up' && kneeAngle < thresholds['squat']!['down']!) {
            exerciseState = 'down';
          } else if (exerciseState == 'down' && kneeAngle > thresholds['squat']!['up']!) {
            exerciseState = 'up';
            repCount++;
            repCompleted = true;
          }
        }
        break;
      case 'pushup':
        double rightElbow = _getAngle(angles, 'right_elbow');
        double leftElbow = _getAngle(angles, 'left_elbow');
        if (rightElbow > 0 && leftElbow > 0) {
          double elbowAngle = (rightElbow + leftElbow) / 2;
          if (exerciseState == 'up' && elbowAngle < thresholds['pushup']!['down']!) {
            exerciseState = 'down';
          } else if (exerciseState == 'down' && elbowAngle > thresholds['pushup']!['up']!) {
            exerciseState = 'up';
            repCount++;
            repCompleted = true;
          }
        }
        break;
      case 'jumping_jack':
        double rightShoulder = _getAngle(angles, 'right_shoulder');
        double leftShoulder = _getAngle(angles, 'left_shoulder');
        if (rightShoulder > 0 && leftShoulder > 0) {
          double shoulderAngle = (rightShoulder + leftShoulder) / 2;
          if (exerciseState == 'up' && shoulderAngle > thresholds['jumping_jack']!['up']!) {
            exerciseState = 'down'; // Arms are up
          } else if (exerciseState == 'down' && shoulderAngle < thresholds['jumping_jack']!['down']!) {
            exerciseState = 'up'; // Arms are down
            repCount++;
            repCompleted = true;
          }
        }
        break;
    }
    return repCompleted;
  }

  Map<String, dynamic> getFormFeedback(String exercise, Map<String, double> angles) {
    int confidence = 0;
    List<String> feedback = [];

    void addFeedback(String msg) {
      if (!feedback.contains(msg)) {
        feedback.add(msg);
      }
    }

    switch (exercise) {
      case 'tree_pose':
        double rightKnee = _getAngle(angles, 'right_knee');
        double leftKnee = _getAngle(angles, 'left_knee');
        double rightHip = _getAngle(angles, 'right_hip');
        double leftHip = _getAngle(angles, 'left_hip');
        if (rightKnee > 0 || leftKnee > 0) {
          double kneeDiff = (rightKnee - leftKnee).abs();
          double hipDiff = (rightHip - leftHip).abs();
          if (kneeDiff < thresholds['tree_pose']!['knee_bend']!) {
            addFeedback("Raise your knee higher");
          }
          if (hipDiff > thresholds['tree_pose']!['hip_variance']!) {
            addFeedback("Keep your hips level");
          }
          double kneeScore = min(100, (kneeDiff / thresholds['tree_pose']!['knee_bend']!) * 100);
          double hipScore = max(0, 100 - (hipDiff / thresholds['tree_pose']!['hip_variance']!) * 100);
          confidence = ((kneeScore + hipScore) / 2).round();
        }
        break;
      case 'squat':
        double rightKnee = _getAngle(angles, 'right_knee');
        double leftKnee = _getAngle(angles, 'left_knee');
        if (rightKnee > 0 && leftKnee > 0) {
          double kneeAngle = (rightKnee + leftKnee) / 2;
          double kneeDiff = (rightKnee - leftKnee).abs();
          if (exerciseState == 'down' || kneeAngle < thresholds['squat']!['up']!) {
            if (kneeAngle > thresholds['squat']!['down']!) {
              addFeedback("Squat deeper");
            }
            if (kneeDiff > thresholds['squat']!['knee_alignment']!) {
              addFeedback("Keep knees aligned");
            }
          }
          double depthScore = 100 - ((kneeAngle - thresholds['squat']!['down']!) / (thresholds['squat']!['up']! - thresholds['squat']!['down']!)) * 100;
          double alignScore = max(0, 100 - (kneeDiff / thresholds['squat']!['knee_alignment']!) * 100);
          confidence = (depthScore.clamp(0, 100) + alignScore) ~/ 2;
        }
        break;
      case 'pushup':
        double rightElbow = _getAngle(angles, 'right_elbow');
        double leftElbow = _getAngle(angles, 'left_elbow');
        double rightHip = _getAngle(angles, 'right_hip');
        double leftHip = _getAngle(angles, 'left_hip');
        if (rightElbow > 0 && leftElbow > 0) {
          double elbowAngle = (rightElbow + leftElbow) / 2;
          double hipDiff = (rightHip - leftHip).abs();
          if (exerciseState == 'down' || elbowAngle < thresholds['pushup']!['up']!) {
            if (elbowAngle > thresholds['pushup']!['down']!) {
              addFeedback("Lower your chest");
            }
            if (hipDiff > thresholds['pushup']!['hip_variance']!) {
              addFeedback("Keep your body straight");
            }
          }
          double depthScore = 100 - ((elbowAngle - thresholds['pushup']!['down']!) / (thresholds['pushup']!['up']! - thresholds['pushup']!['down']!)) * 100;
          double hipScore = max(0, 100 - (hipDiff / thresholds['pushup']!['hip_variance']!) * 100);
          confidence = (depthScore.clamp(0, 100) + hipScore) ~/ 2;
        }
        break;
      case 'jumping_jack':
        double rightShoulder = _getAngle(angles, 'right_shoulder');
        double leftShoulder = _getAngle(angles, 'left_shoulder');
        if (rightShoulder > 0 && leftShoulder > 0) {
          double shoulderAngle = (rightShoulder + leftShoulder) / 2;
          if (exerciseState == 'down' || shoulderAngle > thresholds['jumping_jack']!['down']!) {
             if (shoulderAngle < thresholds['jumping_jack']!['up']!) {
               addFeedback("Raise arms higher");
             }
          }
          confidence = min(100, (shoulderAngle / thresholds['jumping_jack']!['up']!) * 100).round();
        }
        break;
    }

    if (feedback.isEmpty) {
      addFeedback("Form looks good!");
      if (confidence == 0 && (exerciseState == 'up' || exerciseState == 'start')) confidence = 100;
    }

    return {'confidence': confidence, 'feedback': feedback};
  }
}