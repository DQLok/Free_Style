import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_style/camera/widgets/detector.dart';
import 'package:free_style/camera/widgets/pose_painter.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePage extends StatefulWidget {
  const PosePage({super.key});

  @override
  State<StatefulWidget> createState() => _PosePageState();
}

class _PosePageState extends State<PosePage> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  String _more = '';
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    _text = '';
    _more = '';
  }

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Pose Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
      _more = '';
    });
    final poses = await _poseDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      int index = 0;
      for (var element in poses) {
        for (var el in element.landmarks.keys) {
          index += 1;
          _more +=
              '\n$index)${el.name} - ${element.landmarks[el]!.type.name} - ${element.landmarks[el]!.likelihood}';
        }
      }
      _text = 'Poses found: ${poses.length}\n\n$_more';

      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
