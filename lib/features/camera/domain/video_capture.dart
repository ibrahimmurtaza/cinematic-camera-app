import 'frame_preset.dart';

class VideoCapture {
  const VideoCapture({
    required this.recordedAt,
    required this.frame,
    required this.originalPath,
    required this.exportPath,
  });

  final DateTime recordedAt;
  final FramePreset frame;
  final String originalPath;
  final String exportPath;
}