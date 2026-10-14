import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:yoga_guru/models/pose_check.dart';
import 'package:yoga_guru/services/pose_analyzer.dart';

PoseLandmark _lm(PoseLandmarkType type, double x, double y) {
  return PoseLandmark(type: type, x: x, y: y, z: 0, likelihood: 0.9);
}

Map<PoseLandmarkType, PoseLandmark> _mountainLandmarks() {
  return <PoseLandmarkType, PoseLandmark>{
    PoseLandmarkType.nose: _lm(PoseLandmarkType.nose, 240, 80),
    PoseLandmarkType.leftShoulder: _lm(PoseLandmarkType.leftShoulder, 200, 150),
    PoseLandmarkType.rightShoulder: _lm(
      PoseLandmarkType.rightShoulder,
      280,
      150,
    ),
    PoseLandmarkType.leftWrist: _lm(PoseLandmarkType.leftWrist, 196, 350),
    PoseLandmarkType.rightWrist: _lm(PoseLandmarkType.rightWrist, 284, 350),
    PoseLandmarkType.leftHip: _lm(PoseLandmarkType.leftHip, 215, 320),
    PoseLandmarkType.rightHip: _lm(PoseLandmarkType.rightHip, 265, 320),
    PoseLandmarkType.leftKnee: _lm(PoseLandmarkType.leftKnee, 215, 440),
    PoseLandmarkType.rightKnee: _lm(PoseLandmarkType.rightKnee, 265, 440),
    PoseLandmarkType.leftAnkle: _lm(PoseLandmarkType.leftAnkle, 213, 560),
    PoseLandmarkType.rightAnkle: _lm(PoseLandmarkType.rightAnkle, 267, 560),
  };
}

Map<PoseLandmarkType, PoseLandmark> _treeLandmarks() {
  return <PoseLandmarkType, PoseLandmark>{
    PoseLandmarkType.nose: _lm(PoseLandmarkType.nose, 240, 80),
    PoseLandmarkType.leftShoulder: _lm(PoseLandmarkType.leftShoulder, 200, 150),
    PoseLandmarkType.rightShoulder: _lm(
      PoseLandmarkType.rightShoulder,
      280,
      150,
    ),
    PoseLandmarkType.leftWrist: _lm(PoseLandmarkType.leftWrist, 238, 200),
    PoseLandmarkType.rightWrist: _lm(PoseLandmarkType.rightWrist, 242, 200),
    PoseLandmarkType.leftHip: _lm(PoseLandmarkType.leftHip, 215, 320),
    PoseLandmarkType.rightHip: _lm(PoseLandmarkType.rightHip, 265, 320),
    PoseLandmarkType.leftKnee: _lm(PoseLandmarkType.leftKnee, 215, 440),
    PoseLandmarkType.leftAnkle: _lm(PoseLandmarkType.leftAnkle, 215, 560),
    PoseLandmarkType.rightKnee: _lm(PoseLandmarkType.rightKnee, 300, 430),
    PoseLandmarkType.rightAnkle: _lm(PoseLandmarkType.rightAnkle, 235, 400),
  };
}

Map<PoseLandmarkType, PoseLandmark> _warriorLandmarks() {
  return <PoseLandmarkType, PoseLandmark>{
    PoseLandmarkType.nose: _lm(PoseLandmarkType.nose, 240, 100),
    PoseLandmarkType.leftShoulder: _lm(PoseLandmarkType.leftShoulder, 200, 170),
    PoseLandmarkType.rightShoulder: _lm(
      PoseLandmarkType.rightShoulder,
      290,
      170,
    ),
    PoseLandmarkType.leftElbow: _lm(PoseLandmarkType.leftElbow, 165, 171),
    PoseLandmarkType.rightElbow: _lm(PoseLandmarkType.rightElbow, 325, 169),
    PoseLandmarkType.leftWrist: _lm(PoseLandmarkType.leftWrist, 140, 172),
    PoseLandmarkType.rightWrist: _lm(PoseLandmarkType.rightWrist, 350, 168),
    PoseLandmarkType.leftHip: _lm(PoseLandmarkType.leftHip, 215, 325),
    PoseLandmarkType.rightHip: _lm(PoseLandmarkType.rightHip, 275, 335),
    PoseLandmarkType.leftKnee: _lm(PoseLandmarkType.leftKnee, 170, 410),
    PoseLandmarkType.leftAnkle: _lm(PoseLandmarkType.leftAnkle, 120, 500),
    PoseLandmarkType.rightKnee: _lm(PoseLandmarkType.rightKnee, 360, 345),
    PoseLandmarkType.rightAnkle: _lm(PoseLandmarkType.rightAnkle, 360, 440),
  };
}

Pose _pose(Map<PoseLandmarkType, PoseLandmark> landmarks) =>
    Pose(landmarks: landmarks);

void main() {
  group('PoseAnalyzer support', () {
    test('has checkers for the supported poses only', () {
      expect(PoseAnalyzer.hasChecker('tadasana'), isTrue);
      expect(PoseAnalyzer.hasChecker('vrikshasana'), isTrue);
      expect(PoseAnalyzer.hasChecker('virbhadrasana'), isTrue);
      expect(PoseAnalyzer.hasChecker('bakasana'), isFalse);
    });

    test('returns null for poses without a checker', () {
      expect(
        PoseAnalyzer.analyze('bakasana', _pose(_mountainLandmarks())),
        isNull,
      );
    });

    test('returns a hidden result when no pose is detected', () {
      final PoseCheckResult? result = PoseAnalyzer.analyze('tadasana', null);
      expect(result, isNotNull);
      expect(result!.bodyVisible, isFalse);
      expect(result.isPassing, isFalse);
    });

    test('returns a hidden result when landmarks are missing', () {
      final Pose pose = _pose(<PoseLandmarkType, PoseLandmark>{
        PoseLandmarkType.nose: _lm(PoseLandmarkType.nose, 240, 80),
        PoseLandmarkType.leftShoulder: _lm(
          PoseLandmarkType.leftShoulder,
          200,
          150,
        ),
      });
      final PoseCheckResult? result = PoseAnalyzer.analyze('tadasana', pose);
      expect(result!.bodyVisible, isFalse);
    });
  });

  group('Mountain Pose checks', () {
    test('good form scores full marks', () {
      final PoseCheckResult? result = PoseAnalyzer.analyze(
        'tadasana',
        _pose(_mountainLandmarks()),
      );
      expect(result!.score, 1.0);
      expect(result.isPassing, isTrue);
      expect(result.items.length, 4);
    });

    test('arms raised fails the arms check', () {
      final Map<PoseLandmarkType, PoseLandmark> landmarks =
          _mountainLandmarks();
      landmarks[PoseLandmarkType.leftWrist] = _lm(
        PoseLandmarkType.leftWrist,
        200,
        40,
      );
      landmarks[PoseLandmarkType.rightWrist] = _lm(
        PoseLandmarkType.rightWrist,
        280,
        40,
      );
      final PoseCheckResult? result = PoseAnalyzer.analyze(
        'tadasana',
        _pose(landmarks),
      );
      expect(result!.score, lessThan(1.0));
      final PoseCheckItem arms = result.items.firstWhere(
        (PoseCheckItem item) => item.label.contains('arms'),
      );
      expect(arms.passed, isFalse);
    });
  });

  group('Tree Pose checks', () {
    test('good form scores full marks', () {
      final PoseCheckResult? result = PoseAnalyzer.analyze(
        'vrikshasana',
        _pose(_treeLandmarks()),
      );
      expect(result!.score, 1.0);
      expect(result.isPassing, isTrue);
    });

    test('hands raised above the head also passes', () {
      final Map<PoseLandmarkType, PoseLandmark> landmarks = _treeLandmarks();
      landmarks[PoseLandmarkType.leftWrist] = _lm(
        PoseLandmarkType.leftWrist,
        230,
        40,
      );
      landmarks[PoseLandmarkType.rightWrist] = _lm(
        PoseLandmarkType.rightWrist,
        250,
        40,
      );
      final PoseCheckResult? result = PoseAnalyzer.analyze(
        'vrikshasana',
        _pose(landmarks),
      );
      expect(result!.isPassing, isTrue);
      expect(result.score, 1.0);
    });

    test('straight legs fail the bending check', () {
      final Map<PoseLandmarkType, PoseLandmark> landmarks = _treeLandmarks();
      landmarks[PoseLandmarkType.rightKnee] = _lm(
        PoseLandmarkType.rightKnee,
        265,
        440,
      );
      landmarks[PoseLandmarkType.rightAnkle] = _lm(
        PoseLandmarkType.rightAnkle,
        267,
        560,
      );
      final PoseCheckResult? result = PoseAnalyzer.analyze(
        'vrikshasana',
        _pose(landmarks),
      );
      expect(result!.score, lessThan(1.0));
      final PoseCheckItem bend = result.items.firstWhere(
        (PoseCheckItem item) => item.label.contains('Bend'),
      );
      expect(bend.passed, isFalse);
    });
  });

  group('Warrior II checks', () {
    test('good form scores full marks', () {
      final PoseCheckResult? result = PoseAnalyzer.analyze(
        'virbhadrasana',
        _pose(_warriorLandmarks()),
      );
      expect(result!.score, 1.0);
      expect(result.isPassing, isTrue);
    });

    test('arms lowered fails the arm check', () {
      final Map<PoseLandmarkType, PoseLandmark> landmarks = _warriorLandmarks();
      landmarks[PoseLandmarkType.leftWrist] = _lm(
        PoseLandmarkType.leftWrist,
        190,
        330,
      );
      landmarks[PoseLandmarkType.rightWrist] = _lm(
        PoseLandmarkType.rightWrist,
        300,
        330,
      );
      final PoseCheckResult? result = PoseAnalyzer.analyze(
        'virbhadrasana',
        _pose(landmarks),
      );
      expect(result!.score, lessThan(1.0));
      final PoseCheckItem arms = result.items.firstWhere(
        (PoseCheckItem item) => item.label.contains('arms'),
      );
      expect(arms.passed, isFalse);
    });

    test('narrow stance fails the stance check', () {
      final Map<PoseLandmarkType, PoseLandmark> landmarks = _warriorLandmarks();
      landmarks[PoseLandmarkType.leftAnkle] = _lm(
        PoseLandmarkType.leftAnkle,
        280,
        500,
      );
      final PoseCheckResult? result = PoseAnalyzer.analyze(
        'virbhadrasana',
        _pose(landmarks),
      );
      final PoseCheckItem stance = result!.items.firstWhere(
        (PoseCheckItem item) => item.label.contains('stance'),
      );
      expect(stance.passed, isFalse);
    });
  });
}
