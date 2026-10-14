import 'dart:async';

import 'package:flutter/material.dart';

import '../models/session_record.dart';
import '../models/yoga_pose.dart';
import '../services/app_scope.dart';
import '../services/app_state.dart';
import '../utils/formatters.dart';
import '../utils/page_transitions.dart';
import '../widgets/surface_card.dart';
import 'session_complete_screen.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, required this.title, required this.poses});

  final String title;
  final List<YogaPose> poses;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  static const int _minimumSecondsToSave = 10;

  Timer? _timer;
  AppState? _appState;
  int _poseIndex = 0;
  int _remainingSeconds = 0;
  int _elapsedSeconds = 0;
  int _completedPoses = 0;
  bool _isRunning = false;
  bool _hasStarted = false;
  bool _isFinishing = false;

  YogaPose get _currentPose => widget.poses[_poseIndex];

  bool get _hasNextPose => _poseIndex + 1 < widget.poses.length;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _currentPose.holdSeconds;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appState = AppScope.of(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => _tick(),
    );
  }

  void _tick() {
    if (!mounted || !_isRunning) {
      return;
    }
    bool finished = false;
    setState(() {
      _elapsedSeconds += 1;
      _remainingSeconds -= 1;
      if (_remainingSeconds <= 0) {
        _completedPoses += 1;
        if (_hasNextPose) {
          _poseIndex += 1;
          _remainingSeconds = _currentPose.holdSeconds;
        } else {
          _isRunning = false;
          _timer?.cancel();
          _timer = null;
          finished = true;
        }
      }
    });
    if (finished) {
      _finishSession(completed: true);
    }
  }

  void _toggleRunning() {
    if (!_hasStarted) {
      setState(() {
        _hasStarted = true;
        _isRunning = true;
      });
      _startTimer();
      return;
    }
    setState(() {
      _isRunning = !_isRunning;
    });
    if (_isRunning) {
      _startTimer();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _resetCurrentPose() {
    setState(() {
      _remainingSeconds = _currentPose.holdSeconds;
    });
  }

  void _skipPose() {
    if (!_hasNextPose) {
      _finishSession(completed: true);
      return;
    }
    setState(() {
      _poseIndex += 1;
      _remainingSeconds = _currentPose.holdSeconds;
    });
  }

  Future<void> _finishSession({required bool completed}) async {
    if (_isFinishing) {
      return;
    }
    _isFinishing = true;
    _timer?.cancel();
    _timer = null;

    final bool shouldSave = _elapsedSeconds >= _minimumSecondsToSave;
    SessionRecord? record;
    if (shouldSave) {
      record = SessionRecord(
        id: 'session-${DateTime.now().microsecondsSinceEpoch}',
        title: widget.title,
        completedAt: DateTime.now(),
        seconds: _elapsedSeconds,
        poseCount: completed
            ? widget.poses.length
            : _completedPoses.clamp(0, 999),
      );
      final AppState? state = _appState;
      final bool saved = state == null ? false : await state.addRecord(record);
      if (!mounted) {
        return;
      }
      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session finished, but progress could not be saved.'),
          ),
        );
      }
    }

    if (!mounted) {
      return;
    }
    if (record == null) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      FadeScaleRoute<void>(
        page: SessionCompleteScreen(
          record: record,
          poses: widget.poses,
          completedFully: completed,
        ),
      ),
    );
  }

  Future<void> _requestEnd() async {
    if (!_hasStarted || _elapsedSeconds < _minimumSecondsToSave) {
      Navigator.of(context).pop();
      return;
    }
    final bool end =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('End session?'),
            content: Text(
              'You have practiced ${formatDurationLabel(_elapsedSeconds)}. '
              'End this session and save your progress?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Keep going'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('End and save'),
              ),
            ],
          ),
        ) ??
        false;
    if (end) {
      await _finishSession(completed: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double poseProgress = _currentPose.holdSeconds == 0
        ? 0
        : _remainingSeconds / _currentPose.holdSeconds;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        _requestEnd();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            tooltip: 'End session',
            icon: const Icon(Icons.close),
            onPressed: _requestEnd,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        'Pose ${_poseIndex + 1} of ${widget.poses.length}',
                        style: theme.textTheme.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.timer_outlined,
                      size: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Elapsed ${formatClock(_elapsedSeconds)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          child: Container(
                            key: ValueKey<String>(_currentPose.id),
                            height: 150,
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.asset(
                              _currentPose.imageAsset,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (
                                    BuildContext context,
                                    Object error,
                                    StackTrace? stackTrace,
                                  ) => Icon(
                                    Icons.self_improvement,
                                    size: 64,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _currentPose.name,
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentPose.sanskritName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: 210,
                          height: 210,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              SizedBox.expand(
                                child: CircularProgressIndicator(
                                  value: poseProgress.clamp(0.0, 1.0),
                                  strokeWidth: 14,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor:
                                      theme.colorScheme.outlineVariant,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    formatClock(_remainingSeconds),
                                    key: const ValueKey<String>(
                                      'sessionTimerText',
                                    ),
                                    style: TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -1,
                                      color: theme.colorScheme.onSurface,
                                      fontFeatures: const <FontFeature>[
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _isRunning
                                        ? 'remaining'
                                        : _hasStarted
                                        ? 'paused'
                                        : 'ready',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        SurfaceCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.spa_outlined,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      _currentPose.focus,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentPose.cue,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _hasNextPose
                              ? 'Up next: ${widget.poses[_poseIndex + 1].name}'
                              : 'Final pose of this session',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildControls(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    if (!_hasStarted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FilledButton.icon(
            onPressed: _toggleRunning,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start session'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton.filledTonal(
              tooltip: 'Reset pose timer',
              onPressed: _resetCurrentPose,
              icon: const Icon(Icons.restart_alt),
              iconSize: 26,
            ),
            const SizedBox(width: 22),
            SizedBox(
              width: 76,
              height: 76,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                ),
                onPressed: _toggleRunning,
                child: Icon(
                  _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(width: 22),
            IconButton.filledTonal(
              tooltip: _hasNextPose ? 'Skip pose' : 'Finish session',
              onPressed: _skipPose,
              icon: Icon(
                _hasNextPose ? Icons.skip_next_rounded : Icons.check_rounded,
              ),
              iconSize: 26,
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextButton(onPressed: _requestEnd, child: const Text('Finish session')),
      ],
    );
  }
}
