import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

const List<List<PoseLandmarkType>> poseConnections = <List<PoseLandmarkType>>[
  <PoseLandmarkType>[PoseLandmarkType.nose, PoseLandmarkType.leftShoulder],
  <PoseLandmarkType>[PoseLandmarkType.nose, PoseLandmarkType.rightShoulder],
  <PoseLandmarkType>[
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder,
  ],
  <PoseLandmarkType>[PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
  <PoseLandmarkType>[PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
  <PoseLandmarkType>[
    PoseLandmarkType.rightShoulder,
    PoseLandmarkType.rightElbow,
  ],
  <PoseLandmarkType>[PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
  <PoseLandmarkType>[PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
  <PoseLandmarkType>[PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
  <PoseLandmarkType>[PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
  <PoseLandmarkType>[PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
  <PoseLandmarkType>[PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
  <PoseLandmarkType>[PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
  <PoseLandmarkType>[PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
];

class PoseOverlayPainter extends CustomPainter {
  PoseOverlayPainter({
    required this.pose,
    required this.imageSize,
    required this.mirror,
    required this.color,
  });

  final Pose? pose;
  final Size imageSize;
  final bool mirror;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Pose? currentPose = pose;
    if (currentPose == null || imageSize.width <= 0 || imageSize.height <= 0) {
      return;
    }

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    bool isVisible(PoseLandmarkType type) {
      final PoseLandmark? landmark = currentPose.landmarks[type];
      return landmark != null && landmark.likelihood >= 0.5;
    }

    Offset pointFor(PoseLandmarkType type) {
      final PoseLandmark landmark = currentPose.landmarks[type]!;
      double x = landmark.x * scaleX;
      final double y = landmark.y * scaleY;
      if (mirror) {
        x = size.width - x;
      }
      return Offset(x, y);
    }

    final Paint lineShadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withValues(alpha: 0.35);
    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = color;
    final Paint jointFill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    final Paint jointStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = color;

    for (final List<PoseLandmarkType> connection in poseConnections) {
      if (isVisible(connection[0]) && isVisible(connection[1])) {
        final Offset a = pointFor(connection[0]);
        final Offset b = pointFor(connection[1]);
        canvas.drawLine(a, b, lineShadow);
        canvas.drawLine(a, b, linePaint);
      }
    }

    for (final PoseLandmarkType type in currentPose.landmarks.keys) {
      if (!isVisible(type)) {
        continue;
      }
      final Offset point = pointFor(type);
      canvas.drawCircle(point, 6, jointFill);
      canvas.drawCircle(point, 6, jointStroke);
    }
  }

  @override
  bool shouldRepaint(covariant PoseOverlayPainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.mirror != mirror ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.color != color;
  }
}
