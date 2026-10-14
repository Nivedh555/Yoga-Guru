import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yoga_guru/data/pose_repository.dart';
import 'package:yoga_guru/data/session_plans.dart';
import 'package:yoga_guru/models/yoga_pose.dart';
import 'package:yoga_guru/models/yoga_session.dart';

void main() {
  group('PoseRepository', () {
    test('contains at least 8 poses with unique ids', () {
      expect(PoseRepository.all.length, greaterThanOrEqualTo(8));
      final Set<String> ids = PoseRepository.all
          .map((YogaPose pose) => pose.id)
          .toSet();
      expect(ids.length, PoseRepository.all.length);
    });

    test('every pose has complete instructional content', () {
      for (final YogaPose pose in PoseRepository.all) {
        expect(pose.name, isNotEmpty);
        expect(pose.sanskritName, isNotEmpty);
        expect(pose.description, isNotEmpty);
        expect(pose.cue, isNotEmpty);
        expect(pose.safety, isNotEmpty);
        expect(pose.focus, isNotEmpty);
        expect(pose.steps.length, greaterThanOrEqualTo(3));
        expect(pose.benefits.length, greaterThanOrEqualTo(3));
        expect(pose.holdSeconds, greaterThanOrEqualTo(15));
      }
    });

    test('every pose image asset exists on disk', () {
      for (final YogaPose pose in PoseRepository.all) {
        expect(
          File(pose.imageAsset).existsSync(),
          isTrue,
          reason: 'Missing image asset: ${pose.imageAsset}',
        );
      }
    });

    test('covers all difficulty levels', () {
      for (final PoseDifficulty difficulty in PoseDifficulty.values) {
        expect(
          PoseRepository.byDifficulty(difficulty),
          isNotEmpty,
          reason: 'No poses for ${difficulty.label}',
        );
      }
    });

    test('search matches name and sanskrit name', () {
      expect(PoseRepository.search('tree').single.id, 'vrikshasana');
      expect(PoseRepository.search('vriksha').single.id, 'vrikshasana');
      expect(PoseRepository.search('').length, PoseRepository.all.length);
      expect(PoseRepository.search('no-such-pose'), isEmpty);
    });
  });

  group('SessionPlans', () {
    test('all plans have at least two poses and a positive duration', () {
      for (final YogaSession session in SessionPlans.all) {
        expect(session.poses.length, greaterThanOrEqualTo(2));
        expect(session.totalSeconds, greaterThan(0));
        expect(session.minutes, greaterThan(0));
      }
    });

    test('session ids are unique and featured plans are valid', () {
      final Set<String> ids = SessionPlans.all
          .map((YogaSession session) => session.id)
          .toSet();
      expect(ids.length, SessionPlans.all.length);
      expect(SessionPlans.featured, isNotEmpty);
      for (final YogaSession session in SessionPlans.featured) {
        expect(SessionPlans.all.contains(session), isTrue);
      }
    });
  });
}
