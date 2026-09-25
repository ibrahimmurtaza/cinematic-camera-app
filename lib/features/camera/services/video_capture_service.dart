import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
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
    await _exportFrame(
      inputPath: originalPath,
      outputPath: exportPath,
      frame: frame,
    );

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

  Future<void> _exportFrame({
    required String inputPath,
    required String outputPath,
    required FramePreset frame,
  }) async {
    final ratio = frame.aspectRatio.toStringAsFixed(6);
    final cropExpression =
        'crop=if(gt(iw/ih,$ratio),ih*$ratio,iw):if(gt(iw/ih,$ratio),ih,iw/$ratio)';
    final session = await FFmpegKit.execute(
      '-y -i "${_escapePath(inputPath)}" '
      '-vf "$cropExpression" -c:v libx264 -c:a aac '
      '"${_escapePath(outputPath)}"',
    );
    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) {
      throw const FormatException('Video export failed.');
    }
  }

  String _escapePath(String path) => path.replaceAll('"', '\\"');
}