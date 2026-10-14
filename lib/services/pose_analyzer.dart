import 'dart:math' as math;

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_check.dart';

abstract class PoseAnalyzer {
  static const Set<String> supportedPoseIds = <String>{
    'tadasana',
    'vrikshasana',
    'virbhadrasana',
  };

  static bool hasChecker(String poseId) => supportedPoseIds.contains(poseId);

  static PoseCheckResult? analyze(String poseId, Pose? pose) {
    if (!hasChecker(poseId)) {
      return null;
    }
    if (pose == null) {
      return PoseCheckResult.hidden;
    }
    final _Body body = _Body(pose.landmarks);
    return switch (poseId) {
      'tadasana' => _checkMountain(body),
      'vrikshasana' => _checkTree(body),
      'virbhadrasana' => _checkWarriorTwo(body),
      _ => null,
    };
  }

  static PoseCheckResult _checkMountain(_Body body) {
    final PoseLandmark? ls = body.leftShoulder;
    final PoseLandmark? rs = body.rightShoulder;
    final PoseLandmark? lh = body.leftHip;
    final PoseLandmark? rh = body.rightHip;
    final PoseLandmark? lk = body.leftKnee;
    final PoseLandmark? rk = body.rightKnee;
    final PoseLandmark? la = body.leftAnkle;
    final PoseLandmark? ra = body.rightAnkle;
    final PoseLandmark? lw = body.leftWrist;
    final PoseLandmark? rw = body.rightWrist;
    if (ls == null ||
        rs == null ||
        lh == null ||
        rh == null ||
        lk == null ||
        rk == null ||
        la == null ||
        ra == null ||
        lw == null ||
        rw == null) {
      return PoseCheckResult.hidden;
    }

    final double torso = body.torsoLength;
    final double shoulderWidth = _distance(ls, rs);
    final bool armsDown = lw.y > lh.y && rw.y > rh.y;
    final bool armsNearSides =
        (lw.x - ls.x).abs() < shoulderWidth * 0.8 &&
        (rw.x - rs.x).abs() < shoulderWidth * 0.8;
    final double spineTilt = _tiltFromVertical(_mid(ls, rs), _mid(lh, rh));

    return _resultFor(<PoseCheckItem>[
      PoseCheckItem(
        label: 'Keep both legs straight',
        passed: _angle(lh, lk, la) > 155 && _angle(rh, rk, ra) > 155,
      ),
      PoseCheckItem(
        label: 'Keep your shoulders level',
        passed: (ls.y - rs.y).abs() < torso * 0.08,
      ),
      PoseCheckItem(
        label: 'Let your arms rest by your sides',
        passed: armsDown && armsNearSides,
      ),
      PoseCheckItem(
        label: 'Stand tall with an upright spine',
        passed: spineTilt < 14,
      ),
    ]);
  }

  static PoseCheckResult _checkTree(_Body body) {
    final PoseLandmark? ls = body.leftShoulder;
    final PoseLandmark? rs = body.rightShoulder;
    final PoseLandmark? lh = body.leftHip;
    final PoseLandmark? rh = body.rightHip;
    final PoseLandmark? lk = body.leftKnee;
    final PoseLandmark? rk = body.rightKnee;
    final PoseLandmark? la = body.leftAnkle;
    final PoseLandmark? ra = body.rightAnkle;
    final PoseLandmark? lw = body.leftWrist;
    final PoseLandmark? rw = body.rightWrist;
    final PoseLandmark? nose = body.nose;
    if (ls == null ||
        rs == null ||
        lh == null ||
        rh == null ||
        lk == null ||
        rk == null ||
        la == null ||
        ra == null ||
        lw == null ||
        rw == null ||
        nose == null) {
      return PoseCheckResult.hidden;
    }

    final double torso = body.torsoLength;
    final double kneeL = _angle(lh, lk, la);
    final double kneeR = _angle(rh, rk, ra);
    final bool leftIsStanding = kneeL >= kneeR;
    final double standingKneeAngle = leftIsStanding ? kneeL : kneeR;
    final double bentKneeAngle = leftIsStanding ? kneeR : kneeL;
    final PoseLandmark standingKnee = leftIsStanding ? lk : rk;
    final PoseLandmark bentAnkle = leftIsStanding ? ra : la;
    final double footToKnee = _distance(bentAnkle, standingKnee);

    final bool handsRaised = lw.y < nose.y && rw.y < nose.y;
    final bool wristsTogether = _distance(lw, rw) < torso * 0.5;
    final bool handsAtChest =
        wristsTogether &&
        lw.y > _mid(ls, rs).y &&
        lw.y < _mid(lh, rh).y + torso * 0.25;

    return _resultFor(<PoseCheckItem>[
      PoseCheckItem(
        label: 'Stand tall on one straight leg',
        passed: standingKneeAngle > 155,
      ),
      PoseCheckItem(
        label: 'Bend the other knee out to the side',
        passed: bentKneeAngle < 140,
      ),
      PoseCheckItem(
        label: 'Rest the foot on the inner calf or thigh',
        passed: footToKnee < torso * 0.75,
      ),
      PoseCheckItem(
        label: 'Bring your hands together or above your head',
        passed: handsRaised || handsAtChest,
      ),
    ]);
  }

  static PoseCheckResult _checkWarriorTwo(_Body body) {
    final PoseLandmark? ls = body.leftShoulder;
    final PoseLandmark? rs = body.rightShoulder;
    final PoseLandmark? le = body.leftElbow;
    final PoseLandmark? re = body.rightElbow;
    final PoseLandmark? lw = body.leftWrist;
    final PoseLandmark? rw = body.rightWrist;
    final PoseLandmark? lh = body.leftHip;
    final PoseLandmark? rh = body.rightHip;
    final PoseLandmark? lk = body.leftKnee;
    final PoseLandmark? rk = body.rightKnee;
    final PoseLandmark? la = body.leftAnkle;
    final PoseLandmark? ra = body.rightAnkle;
    if (ls == null ||
        rs == null ||
        le == null ||
        re == null ||
        lw == null ||
        rw == null ||
        lh == null ||
        rh == null ||
        lk == null ||
        rk == null ||
        la == null ||
        ra == null) {
      return PoseCheckResult.hidden;
    }

    final double torso = body.torsoLength;
    final double kneeL = _angle(lh, lk, la);
    final double kneeR = _angle(rh, rk, ra);
    final double elbowL = _angle(ls, le, lw);
    final double elbowR = _angle(rs, re, rw);
    final double stanceWidth = (la.x - ra.x).abs();
    final double bentKnee = math.min(kneeL, kneeR);

    final bool armsLevel =
        (lw.y - ls.y).abs() < torso * 0.3 &&
        (rw.y - rs.y).abs() < torso * 0.3 &&
        elbowL > 150 &&
        elbowR > 150;

    return _resultFor(<PoseCheckItem>[
      PoseCheckItem(
        label: 'Take a wide stance',
        passed: stanceWidth > torso * 1.1,
      ),
      PoseCheckItem(
        label: 'Bend your front knee toward a right angle',
        passed: bentKnee >= 65 && bentKnee <= 125,
      ),
      PoseCheckItem(
        label: 'Keep your back leg straight',
        passed: math.max(kneeL, kneeR) > 150,
      ),
      PoseCheckItem(
        label: 'Stretch both arms out at shoulder height',
        passed: armsLevel,
      ),
    ]);
  }

  static PoseCheckResult _resultFor(List<PoseCheckItem> items) {
    final int passed = items.where((PoseCheckItem i) => i.passed).length;
    return PoseCheckResult(
      score: items.isEmpty ? 0 : passed / items.length,
      items: items,
    );
  }

  static double _angle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final double abx = a.x - b.x;
    final double aby = a.y - b.y;
    final double cbx = c.x - b.x;
    final double cby = c.y - b.y;
    final double dot = abx * cbx + aby * cby;
    final double mag =
        math.sqrt(abx * abx + aby * aby) * math.sqrt(cbx * cbx + cby * cby);
    if (mag == 0) {
      return 180;
    }
    return math.acos((dot / mag).clamp(-1.0, 1.0)) * 180 / math.pi;
  }

  static double _distance(PoseLandmark a, PoseLandmark b) {
    final double dx = a.x - b.x;
    final double dy = a.y - b.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  static PoseLandmark _mid(PoseLandmark a, PoseLandmark b) {
    return PoseLandmark(
      type: a.type,
      x: (a.x + b.x) / 2,
      y: (a.y + b.y) / 2,
      z: 0,
      likelihood: 1,
    );
  }

  static double _tiltFromVertical(PoseLandmark top, PoseLandmark bottom) {
    final double dx = (top.x - bottom.x).abs();
    final double dy = (top.y - bottom.y).abs();
    if (dy == 0) {
      return dx == 0 ? 0 : 90;
    }
    return math.atan(dx / dy) * 180 / math.pi;
  }
}

class _Body {
  _Body(this._landmarks);

  static const double _visibilityThreshold = 0.5;

  final Map<PoseLandmarkType, PoseLandmark> _landmarks;

  PoseLandmark? _lm(PoseLandmarkType type) {
    final PoseLandmark? value = _landmarks[type];
    if (value == null || value.likelihood < _visibilityThreshold) {
      return null;
    }
    return value;
  }

  PoseLandmark? get nose => _lm(PoseLandmarkType.nose);

  PoseLandmark? get leftShoulder => _lm(PoseLandmarkType.leftShoulder);

  PoseLandmark? get rightShoulder => _lm(PoseLandmarkType.rightShoulder);

  PoseLandmark? get leftElbow => _lm(PoseLandmarkType.leftElbow);

  PoseLandmark? get rightElbow => _lm(PoseLandmarkType.rightElbow);

  PoseLandmark? get leftWrist => _lm(PoseLandmarkType.leftWrist);

  PoseLandmark? get rightWrist => _lm(PoseLandmarkType.rightWrist);

  PoseLandmark? get leftHip => _lm(PoseLandmarkType.leftHip);

  PoseLandmark? get rightHip => _lm(PoseLandmarkType.rightHip);

  PoseLandmark? get leftKnee => _lm(PoseLandmarkType.leftKnee);

  PoseLandmark? get rightKnee => _lm(PoseLandmarkType.rightKnee);

  PoseLandmark? get leftAnkle => _lm(PoseLandmarkType.leftAnkle);

  PoseLandmark? get rightAnkle => _lm(PoseLandmarkType.rightAnkle);

  double get torsoLength {
    final PoseLandmark? ls = leftShoulder;
    final PoseLandmark? rs = rightShoulder;
    final PoseLandmark? lh = leftHip;
    final PoseLandmark? rh = rightHip;
    if (ls == null || rs == null || lh == null || rh == null) {
      return 1;
    }
    final double shoulderX = (ls.x + rs.x) / 2;
    final double shoulderY = (ls.y + rs.y) / 2;
    final double hipX = (lh.x + rh.x) / 2;
    final double hipY = (lh.y + rh.y) / 2;
    final double dx = shoulderX - hipX;
    final double dy = shoulderY - hipY;
    final double length = math.sqrt(dx * dx + dy * dy);
    return length < 1 ? 1 : length;
  }
}
