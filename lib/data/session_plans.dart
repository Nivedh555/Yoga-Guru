import '../models/yoga_pose.dart';
import '../models/yoga_session.dart';
import 'pose_repository.dart';

abstract class SessionPlans {
  static final List<YogaSession> all = <YogaSession>[
    YogaSession(
      id: 'morning-energiser',
      title: 'Morning Energiser',
      subtitle: 'Wake up the body with gentle standing and backbend work.',
      poses: <YogaPose>[
        PoseRepository.byId('tadasana'),
        PoseRepository.byId('trikonasana'),
        PoseRepository.byId('vrikshasana'),
        PoseRepository.byId('bhujangasana'),
        PoseRepository.byId('sukhasana'),
      ],
    ),
    YogaSession(
      id: 'balance-builder',
      title: 'Balance Builder',
      subtitle: 'Steady standing poses to train focus and balance.',
      poses: <YogaPose>[
        PoseRepository.byId('tadasana'),
        PoseRepository.byId('vrikshasana'),
        PoseRepository.byId('trikonasana'),
        PoseRepository.byId('virbhadrasana'),
      ],
    ),
    YogaSession(
      id: 'evening-unwind',
      title: 'Evening Unwind',
      subtitle: 'Slow folds and soft breathing to close the day.',
      poses: <YogaPose>[
        PoseRepository.byId('sukhasana'),
        PoseRepository.byId('padhastasana'),
        PoseRepository.byId('bhujangasana'),
      ],
    ),
    YogaSession(
      id: 'strength-stability',
      title: 'Strength and Stability',
      subtitle: 'A stronger flow for the back, hips and legs.',
      poses: <YogaPose>[
        PoseRepository.byId('virbhadrasana'),
        PoseRepository.byId('ustrasana'),
        PoseRepository.byId('dhanurasana'),
        PoseRepository.byId('halasana'),
      ],
    ),
    YogaSession(
      id: 'full-body-flow',
      title: 'Full Body Flow',
      subtitle: 'Standing, backbends and a gentle inversion in one flow.',
      poses: <YogaPose>[
        PoseRepository.byId('tadasana'),
        PoseRepository.byId('virbhadrasana'),
        PoseRepository.byId('trikonasana'),
        PoseRepository.byId('ustrasana'),
        PoseRepository.byId('dhanurasana'),
        PoseRepository.byId('halasana'),
      ],
    ),
    YogaSession(
      id: 'advanced-balance',
      title: 'Advanced Balance',
      subtitle: 'Arm balances and inversions for experienced practitioners.',
      poses: <YogaPose>[
        PoseRepository.byId('bakasana'),
        PoseRepository.byId('mayurasana'),
        PoseRepository.byId('sirsasana'),
      ],
    ),
  ];

  static YogaSession byId(String id) =>
      all.firstWhere((YogaSession session) => session.id == id);

  static List<YogaSession> get featured => <YogaSession>[
    byId('morning-energiser'),
    byId('balance-builder'),
    byId('strength-stability'),
    byId('evening-unwind'),
  ];
}
