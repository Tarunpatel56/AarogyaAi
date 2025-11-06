import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controller/ai_pose_controller.dart';
import 'pose_painter.dart';

class AIPoseTrainerScreen extends StatelessWidget {
  const AIPoseTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AIPoseController>(
      init: AIPoseController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('AI Physiotherapist'),
            actions: [
              IconButton(
                tooltip: 'Switch Exercise',
                onPressed: controller.switchExercise,
                icon: const Icon(Icons.swap_horiz_rounded),
              ),
              IconButton(
                tooltip: 'Flip Camera',
                onPressed: controller.flipCamera,
                icon: const Icon(Icons.cameraswitch_rounded),
              ),
            ],
          ),
          body: controller.isCameraInitialized
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    // Camera Feed
                    CameraPreview(controller.cameraController!),

                    // Skeleton Overlay
                    CustomPaint(
                      painter: PosePainter(
                        keypoints: controller.latestKeypoints,
                        cameraSize: controller.cameraSize,
                      ),
                    ),

                    // Top gradient & labels
                    _TopOverlay(controller: controller),

                    // Bottom panel
                    _BottomPanel(controller: controller),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _TopOverlay extends StatelessWidget {
  final AIPoseController controller;
  const _TopOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment(0, 0.3),
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                controller.currentExercise.replaceAll('_', ' ').toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                'REPS: ${controller.repCount}',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final AIPoseController controller;
  const _BottomPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final int score = controller.formConfidence;
    final Color scoreColor = score >= 80
        ? Colors.greenAccent
        : (score >= 50 ? Colors.amberAccent : Colors.redAccent);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0, -0.4),
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black87],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score bar
              Row(
                children: [
                  const Text('Form Score', style: TextStyle(color: Colors.white70)),
                  const SizedBox(width: 8),
                  Text('$score%', style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (score.clamp(0, 100)) / 100.0,
                  minHeight: 10,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              const SizedBox(height: 12),

              // Feedback chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.formFeedback
                    .map((msg) => Chip(
                          label: Text(
                            msg,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.white10,
                          shape: StadiumBorder(side: BorderSide(color: Colors.white24)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.switchExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: const Text('Next Exercise'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: controller.flipCamera,
                    tooltip: 'Flip Camera',
                    iconSize: 28,
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white10,
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(Icons.cameraswitch_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}