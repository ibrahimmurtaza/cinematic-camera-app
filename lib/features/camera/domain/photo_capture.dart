import 'frame_preset.dart';

class PhotoCapture {
  const PhotoCapture({
    required this.capturedAt,
    required this.frame,
    required this.originalPath,
    required this.exportPath,
  });

  final DateTime capturedAt;
  final FramePreset frame;
  final String originalPath;
  final String exportPath;
}