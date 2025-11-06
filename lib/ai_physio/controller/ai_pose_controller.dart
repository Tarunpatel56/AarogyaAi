import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart'; // Make sure this is imported
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:aarogya/ai_physio/logic/exercise_logic.dart';
import 'package:aarogya/ai_physio/logic/feedback_engine.dart';
import 'package:aarogya/ai_physio/logic/pose_detector.dart';
import 'package:aarogya/ai_physio/model/keypoint.dart';

// --- IMPORT THE NEW HELPER ---
import 'package:aarogya/ai_physio/logic/image_utils.dart' as image_utils;

class AIPoseController extends GetxController {
  // --- Services
  final PoseDetector _poseDetector = PoseDetector();
  final ExerciseLogic exerciseLogic = ExerciseLogic();
  final FeedbackEngine _feedbackEngine = FeedbackEngine();

  // --- TFLite & Camera
  Interpreter? _interpreter;
  CameraController? cameraController;
  bool isCameraInitialized = false;
  bool isDetecting = false;
  List<CameraDescription> cameras = [];
  int _currentCameraIndex = 0;

  // --- Model Constants ---
  final int _inputWidth = 640;
  final int _inputHeight = 640;
  final int _keypointCount = 17;

  // --- Observable State (for the UI)
  String _currentExercise = "tree_pose";
  final List<String> availableExercises = [
    "tree_pose",
    "squat",
    "pushup",
    "jumping_jack"
  ];
  List<KeyPoint> _latestKeypoints = [];
  Map<String, double?> _latestAngles = {};
  int _formConfidence = 0;
  List<String> _formFeedback = ["Stand still to start."];

  // --- Getters for the UI
  String get currentExercise => _currentExercise;
  int get repCount => exerciseLogic.repCount;
  List<KeyPoint> get latestKeypoints => _latestKeypoints;
  int get formConfidence => _formConfidence;
  List<String> get formFeedback => _formFeedback;
  // Fixed to prevent divide-by-zero error
  Size get cameraSize =>
      cameraController?.value.previewSize ?? const Size(1, 1);

  @override
  void onInit() {
    super.onInit();
    _initLogFile();
    _loadModel();
    _initializeCamera();
  }

  @override
  void onClose() {
    _feedbackEngine.stop();
    cameraController?.stopImageStream(); // Stop the stream
    cameraController?.dispose();
    _interpreter?.close();
    super.onClose();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/yolov8n-pose.tflite');
      // Allocate tensors ONCE when the model is loaded
      _interpreter?.allocateTensors();
    } catch (e) {
      print("Error loading TFLite model: $e");
    }
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _currentCameraIndex = cameras.indexWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front);
    if (_currentCameraIndex == -1) _currentCameraIndex = 0;
    final camera = cameras[_currentCameraIndex];

    cameraController = CameraController(
      camera,
      ResolutionPreset.medium, // 640x480 is a good balance
      enableAudio: false,
    );

    try {
      await cameraController!.initialize();
      isCameraInitialized = true;
      // Start the stream
      cameraController!.startImageStream(_processCameraFrame);
      update(); // Update UI to show camera
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> flipCamera() async {
    if (cameras.isEmpty) return;
    try {
      isCameraInitialized = false;
      update();
      await cameraController?.stopImageStream();
      await cameraController?.dispose();

      _currentCameraIndex = (_currentCameraIndex + 1) % cameras.length;
      final nextCamera = cameras[_currentCameraIndex];

      cameraController = CameraController(
        nextCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await cameraController!.initialize();
      isCameraInitialized = true;
      cameraController!.startImageStream(_processCameraFrame);
      update();
    } catch (e) {
      print("Error flipping camera: $e");
    }
  }

  // --- UPDATED: THIS NOW RUNS THE REAL MODEL ---
  Future<void> _processCameraFrame(CameraImage image) async {
    if (_interpreter == null || isDetecting) return;
    isDetecting = true;

    try {
      // 1. Run inference on the image
      List<KeyPoint> kpts = await _runInference(image);

      // 2. Scale keypoints from 640x640 model output to camera preview size
      final double scaleX = cameraSize.width / _inputWidth;
      final double scaleY = cameraSize.height / _inputHeight;
      List<KeyPoint> scaledKeypoints = kpts.map((kp) {
        return KeyPoint(kp.x * scaleX, kp.y * scaleY, kp.confidence);
      }).toList();

      if (scaledKeypoints.isNotEmpty) {
        // 3. Calculate angles
        final angles = _poseDetector.calculateAllAngles(scaledKeypoints);

        // 4. Run exercise logic
        final formOk = exerciseLogic.checkForm(_currentExercise, angles);
        if (formOk) {
          final repCompleted =
              exerciseLogic.countReps(_currentExercise, angles);
          if (repCompleted) {
            _feedbackEngine
                .queueFeedback("Rep ${exerciseLogic.repCount} completed!");
            _logExerciseData(angles, "rep_completed");
          }
        }

        // 5. Update UI
        _updateDisplayInfo(angles, scaledKeypoints);
      } else {
        // No person detected
        _updateDisplayInfo({}, []);
      }
    } catch (e) {
      print("Error processing frame: $e");
    }

    isDetecting = false;
  }

  // --- NEW: THE REAL TFLITE INFERENCE FUNCTION ---
  Future<List<KeyPoint>> _runInference(CameraImage cameraImage) async {
    // 1. Preprocess the image
    // This runs on the main isolate. For a smoother experience, you'd use compute() or an Isolate.
    final Float32List inputTensor = image_utils.preprocessImage(cameraImage);

    // 2. Prepare Tensors
    // Input shape [1, 640, 640, 3]
    final input = inputTensor.reshape([1, _inputHeight, _inputWidth, 3]);
    // Output shape [1, 56, 8400]
    final output = List.filled(1 * 56 * 8400, 0.0).reshape([1, 56, 8400]);

    // 3. Run Interpreter
    try {
      _interpreter!.run(input, output);
    } catch (e) {
      print("Error running interpreter: $e");
      return [];
    }

    // 4. Parse the output
    final List<KeyPoint> keypoints = [];
    // The output list is [1, 56, 8400]. We get the [56, 8400] part.
    final List<List<double>> outputData = output[0].cast<List<double>>();
    
    // Transpose [56, 8400] to [8400, 56] for easier parsing
    // This is the most performance-intensive part
    final List<double> bestDetection = List.filled(56, 0.0);
    double maxConfidence = 0.0;
    
    for (int i = 0; i < 8400; i++) {
        // Object confidence is at row 4
        final double confidence = outputData[4][i]; 
        
        if (confidence > maxConfidence) {
            maxConfidence = confidence;
            // Store all 56 values for this detection
            for (int j = 0; j < 56; j++) {
                bestDetection[j] = outputData[j][i];
            }
        }
    }

    // 5. Extract keypoints from the single best detection
    if (maxConfidence > 0.5) { // Confidence threshold
      // We found a person
      for (int j = 0; j < _keypointCount; j++) {
        // Keypoints start at index 5 in our 'bestDetection' list
        final double x = bestDetection[j * 3 + 5];
        final double y = bestDetection[j * 3 + 6];
        final double conf = bestDetection[j * 3 + 7];

        keypoints.add(KeyPoint(x, y, conf));
      }
    }

    return keypoints;
  }

  // --- UPDATED: This now handles the "No person detected" case ---
  void _updateDisplayInfo(
      Map<String, double?> angles, List<KeyPoint> kpts) {
    if (kpts.isNotEmpty) {
      final (confidence, feedback) =
          exerciseLogic.getFormFeedback(_currentExercise, angles);
      _formConfidence = confidence;
      _formFeedback = feedback;
      _latestKeypoints = kpts;
      _latestAngles = angles;
    } else {
      // No person detected, clear the info
      _formConfidence = 0;
      _formFeedback = ["No person detected"];
      _latestKeypoints = [];
      _latestAngles = {};
    }
    update(); // This notifies the GetBuilder
  }

  void switchExercise() {
    int nextIndex = (availableExercises.indexOf(_currentExercise) + 1) %
        availableExercises.length;
    _currentExercise = availableExercises[nextIndex];
    exerciseLogic.reset();
    _feedbackEngine
        .queueFeedback("Switched to ${_currentExercise.replaceAll('_', ' ')}");
    _updateDisplayInfo({}, []);
  }

  // ... (Logging functions remain the same) ...
  Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/exercise_log.json');
  }

  Future<void> _initLogFile() async {
    try {
      final file = await _getLogFile();
      if (!await file.exists()) {
        await file.writeAsString(jsonEncode([]));
      } else {
        // ... (add corruption check if needed)
      }
    } catch (e) {
      print("Error initializing log file: $e");
    }
  }

  Future<void> _logExerciseData(
      Map<String, double?> angles, String status) async {
    try {
      final file = await _getLogFile();
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);

      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'exercise': _currentExercise,
        'rep_count': exerciseLogic.repCount,
        'status': status,
        'angles':
            angles.map((key, value) => MapEntry(key, value?.toStringAsFixed(2))),
      };

      data.add(logEntry);
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print("Error logging exercise data: $e");
    }
  }
}