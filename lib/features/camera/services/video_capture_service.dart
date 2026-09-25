import 'dart:io';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/frame_preset.dart';
import '../domain/video_capture.dart';

class VideoCaptureService {
  Future<void> start(CameraController cameraController) {
    return cameraController.startVideoRecording();
  }

  Future<VideoCapture> stop({
    required CameraController cameraController,
    required FramePreset frame,
  }) async {
    final recordedFile = await cameraController.stopVideoRecording();
    final directory = await _captureDirectory();
    final recordedAt = DateTime.now();
    final baseName = 'video_${recordedAt.millisecondsSinceEpoch}';
    final originalPath = '${directory.path}/${baseName}_original.mp4';
    final exportPath = '${directory.path}/${baseName}_${frame.id}.mp4';

    await File(recordedFile.path).copy(originalPath);
    await File(originalPath).copy(exportPath);

    return VideoCapture(
      recordedAt: recordedAt,
      frame: frame,
      originalPath: originalPath,
      exportPath: exportPath,
    );
  }

  Future<Directory> _captureDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/captures');
    await directory.create(recursive: true);
    return directory;
  }
}