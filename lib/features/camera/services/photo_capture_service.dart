import 'dart:io';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as image;
import 'package:path_provider/path_provider.dart';

import '../domain/frame_preset.dart';
import '../domain/photo_capture.dart';

class PhotoCaptureService {
  Future<PhotoCapture> capture({
    required CameraController cameraController,
    required FramePreset frame,
  }) async {
    final capturedFile = await cameraController.takePicture();
    final directory = await _captureDirectory();
    final capturedAt = DateTime.now();
    final baseName = 'photo_${capturedAt.millisecondsSinceEpoch}';
    final originalPath = '${directory.path}/${baseName}_original.jpg';
    final exportPath = '${directory.path}/${baseName}_${frame.id}.jpg';

    await File(capturedFile.path).copy(originalPath);
    await _exportFrame(
      inputPath: originalPath,
      outputPath: exportPath,
      frame: frame,
    );

    return PhotoCapture(
      capturedAt: capturedAt,
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
    final source = image.decodeImage(await File(inputPath).readAsBytes());
    if (source == null) throw const FormatException('Captured image could not be decoded.');

    final sourceRatio = source.width / source.height;
    final cropWidth = sourceRatio > frame.aspectRatio
        ? (source.height * frame.aspectRatio).round()
        : source.width;
    final cropHeight = sourceRatio > frame.aspectRatio
        ? source.height
        : (source.width / frame.aspectRatio).round();
    final cropped = image.copyCrop(
      source,
      x: (source.width - cropWidth) ~/ 2,
      y: (source.height - cropHeight) ~/ 2,
      width: cropWidth,
      height: cropHeight,
    );
    await File(outputPath).writeAsBytes(image.encodeJpg(cropped, quality: 92));
  }
}