import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_check.dart';
import '../models/session_record.dart';
import '../models/yoga_pose.dart';
import '../services/app_scope.dart';
import '../services/app_state.dart';
import '../services/pose_analyzer.dart';
import '../utils/page_transitions.dart';
import '../widgets/pose_overlay_painter.dart';
import '../widgets/surface_card.dart';
import 'session_complete_screen.dart';

class PoseCameraScreen extends StatefulWidget {
  const PoseCameraScreen({super.key, required this.pose});

  final YogaPose pose;

  @override
  State<PoseCameraScreen> createState() => _PoseCameraScreenState();
}

class _PoseCameraScreenState extends State<PoseCameraScreen>
    with WidgetsBindingObserver {
  static const int _minimumSecondsToSave = 10;

  CameraController? _controller;
  PoseDetector? _detector;
  Timer? _holdTimer;
  bool _isBusy = false;
  bool _initializing = true;
  bool _isFrontCamera = true;
  bool _mirror = true;
  int _heldSeconds = 0;
  String? _error;
  Pose? _pose;
  PoseCheckResult? _result;
  Size? _imageSize;

  bool get _hasChecker => PoseAnalyzer.hasChecker(widget.pose.id);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _detector = PoseDetector(
      options: PoseDetectorOptions(
        model: PoseDetectionModel.base,
        mode: PoseDetectionMode.stream,
      ),
    );
    _holdTimer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => _tickHold(),
    );
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _holdTimer?.cancel();
    _holdTimer = null;
    _teardownCamera();
    _detector?.close();
    _detector = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _teardownCamera();
    } else if (state == AppLifecycleState.resumed &&
        _controller == null &&
        _error == null) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    if (!mounted || _controller != null) {
      return;
    }
    setState(() {
      _initializing = true;
      _error = null;
    });
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) {
        _setCameraError('No camera was found on this device.');
        return;
      }
      final CameraDescription camera = _preferredCamera(cameras);
      _isFrontCamera = camera.lensDirection == CameraLensDirection.front;
      _mirror = _isFrontCamera;

      final CameraController controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _controller = controller;
      setState(() => _initializing = false);
      await controller.startImageStream(_handleImage);
    } on CameraException catch (error) {
      if (error.code == 'CameraAccessDenied' ||
          error.code == 'CameraAccessDeniedWithoutPrompt') {
        _setCameraError(
          'Camera permission is required to check your pose. '
          'Grant camera access in Android settings and try again.',
        );
      } else {
        _setCameraError('Could not start the camera: ${error.description}');
      }
    } catch (error) {
      _setCameraError('Could not start the camera: $error');
    }
  }

  CameraDescription _preferredCamera(List<CameraDescription> cameras) {
    final Iterable<CameraDescription> front = cameras.where(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );
    return front.isNotEmpty ? front.first : cameras.first;
  }

  void _setCameraError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _error = message;
      _initializing = false;
    });
  }

  Future<void> _teardownCamera() async {
    final CameraController? controller = _controller;
    _controller = null;
    if (controller == null) {
      return;
    }
    try {
      await controller.stopImageStream();
    } catch (_) {}
    try {
      await controller.dispose();
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    final CameraController? controller = _controller;
    if (controller == null) {
      return;
    }
    try {
      final List<CameraDescription> cameras = await availableCameras();
      final CameraLensDirection wanted = _isFrontCamera
          ? CameraLensDirection.back
          : CameraLensDirection.front;
      final Iterable<CameraDescription> matches = cameras.where(
        (CameraDescription camera) => camera.lensDirection == wanted,
      );
      await _teardownCamera();
      if (matches.isEmpty || !mounted) {
        _initialize();
        return;
      }
      _isFrontCamera = matches.first.lensDirection == CameraLensDirection.front;
      _mirror = _isFrontCamera;
      final CameraController next = CameraController(
        matches.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await next.initialize();
      if (!mounted) {
        await next.dispose();
        return;
      }
      setState(() {
        _controller = next;
        _pose = null;
        _result = null;
      });
      await next.startImageStream(_handleImage);
    } catch (_) {
      _initialize();
    }
  }

  void _handleImage(CameraImage image) {
    if (_isBusy || !mounted) {
      return;
    }
    final PoseDetector? detector = _detector;
    if (detector == null) {
      return;
    }
    final InputImage? inputImage = _toInputImage(image);
    if (inputImage == null) {
      return;
    }
    _isBusy = true;
    detector
        .processImage(inputImage)
        .then((List<Pose> poses) {
          if (!mounted) {
            _isBusy = false;
            return;
          }
          final Pose? pose = poses.isEmpty ? null : poses.first;
          setState(() {
            _pose = pose;
            _result = PoseAnalyzer.analyze(widget.pose.id, pose);
            _imageSize = _rotatedImageSize(
              image,
              inputImage.metadata!.rotation,
            );
          });
          _isBusy = false;
        })
        .catchError((Object _) {
          _isBusy = false;
        });
  }

  InputImage? _toInputImage(CameraImage image) {
    try {
      final Uint8List bytes = _frameBytes(image);
      if (bytes.isEmpty) {
        return null;
      }
      final InputImageRotation rotation = _rotationFromOrientation(
        _controller?.value.deviceOrientation ?? DeviceOrientation.portraitUp,
      );
      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Uint8List _frameBytes(CameraImage image) {
    if (image.planes.length == 1) {
      return image.planes.first.bytes;
    }
    final Plane y = image.planes[0];
    final Plane u = image.planes[1];
    final Plane v = image.planes[2];
    final int width = image.width;
    final int height = image.height;
    final int uStep = u.bytesPerPixel ?? 1;
    final int vStep = v.bytesPerPixel ?? 1;
    final Uint8List out = Uint8List(width * height * 3 ~/ 2);
    int pos = 0;
    for (int row = 0; row < height; row++) {
      final int start = row * y.bytesPerRow;
      out.setRange(pos, pos + width, y.bytes, start);
      pos += width;
    }
    final int uvHeight = height ~/ 2;
    final int uvWidth = width ~/ 2;
    for (int row = 0; row < uvHeight; row++) {
      final int uRow = row * u.bytesPerRow;
      final int vRow = row * v.bytesPerRow;
      for (int col = 0; col < uvWidth; col++) {
        out[pos++] = v.bytes[vRow + col * vStep];
        out[pos++] = u.bytes[uRow + col * uStep];
      }
    }
    return out;
  }

  InputImageRotation _rotationFromOrientation(DeviceOrientation orientation) {
    switch (orientation) {
      case DeviceOrientation.portraitUp:
        return InputImageRotation.rotation90deg;
      case DeviceOrientation.portraitDown:
        return InputImageRotation.rotation270deg;
      case DeviceOrientation.landscapeLeft:
        return InputImageRotation.rotation0deg;
      case DeviceOrientation.landscapeRight:
        return InputImageRotation.rotation180deg;
    }
  }

  Size _rotatedImageSize(CameraImage image, InputImageRotation rotation) {
    final bool swap =
        rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;
    return swap
        ? Size(image.height.toDouble(), image.width.toDouble())
        : Size(image.width.toDouble(), image.height.toDouble());
  }

  Size? get _previewImageSize {
    final Size? measured = _imageSize;
    if (measured != null) {
      return measured;
    }
    final CameraController? controller = _controller;
    final Size? previewSize = controller?.value.previewSize;
    if (controller == null || previewSize == null) {
      return null;
    }
    final DeviceOrientation orientation = controller.value.deviceOrientation;
    final bool portrait =
        orientation == DeviceOrientation.portraitUp ||
        orientation == DeviceOrientation.portraitDown;
    return portrait
        ? Size(previewSize.height, previewSize.width)
        : Size(previewSize.width, previewSize.height);
  }

  void _tickHold() {
    if (!mounted) {
      return;
    }
    if (_result?.isPassing ?? false) {
      setState(() => _heldSeconds += 1);
    }
  }

  Future<void> _finish() async {
    if (_heldSeconds < _minimumSecondsToSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hold the pose with good form for at least 10 seconds to save.',
          ),
        ),
      );
      return;
    }
    final AppState state = AppScope.of(context);
    final SessionRecord record = SessionRecord(
      id: 'form-${DateTime.now().microsecondsSinceEpoch}',
      title: '${widget.pose.name} • form check',
      completedAt: DateTime.now(),
      seconds: _heldSeconds,
      poseCount: 1,
    );
    final bool saved = await state.addRecord(record);
    if (!mounted) {
      return;
    }
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this session.')),
      );
    }
    await _teardownCamera();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      FadeScaleRoute<void>(
        page: SessionCompleteScreen(
          record: record,
          poses: <YogaPose>[widget.pose],
          completedFully: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Form check • ${widget.pose.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: <Widget>[
          if (_controller != null && _isFrontCamera)
            IconButton(
              tooltip: 'Mirror overlay',
              icon: const Icon(Icons.flip),
              onPressed: () => setState(() => _mirror = !_mirror),
            ),
          if (_controller != null)
            IconButton(
              tooltip: 'Switch camera',
              icon: const Icon(Icons.cameraswitch_outlined),
              onPressed: _switchCamera,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(flex: 5, child: _buildPreview(theme)),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: _buildFeedback(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    final String? error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.no_photography_outlined,
                size: 42,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _initialize,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }
    final CameraController? controller = _controller;
    final Size? imageSize = _previewImageSize;
    if (controller == null || imageSize == null || imageSize.height == 0) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: imageSize.width / imageSize.height,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(controller),
                CustomPaint(
                  painter: PoseOverlayPainter(
                    pose: _pose,
                    imageSize: imageSize,
                    mirror: _mirror && _isFrontCamera,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback(ThemeData theme) {
    if (_error != null || _initializing) {
      return const SizedBox.shrink();
    }
    if (!_hasChecker) {
      return SurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.auto_awesome_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Live skeleton guide',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Automatic form scoring is available for Mountain Pose, '
              'Tree Pose and Warrior II. Use the moving skeleton as a mirror '
              'while you practise ${widget.pose.name}.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final PoseCheckResult? result = _result;
    if (_pose == null || result == null || !result.bodyVisible) {
      return SurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Icon(Icons.accessibility_new, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Step back so your whole body is visible in the frame, '
                'then hold ${widget.pose.name}.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    final bool passing = result.isPassing;
    final int percent = (result.score * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    passing ? 'Good form' : 'Keep adjusting',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: passing
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$percent%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: result.score,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 14),
              for (final PoseCheckItem item in result.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        item.passed
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                        size: 18,
                        color: item.passed
                            ? theme.colorScheme.primary
                            : const Color(0xFFC07A3E),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.timer_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Good-form hold',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$_heldSeconds s',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _finish,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Finish and save session'),
        ),
        const SizedBox(height: 8),
        Text(
          'Form scoring is geometry-based guidance, not medical advice. '
          'Stop if you feel pain.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
