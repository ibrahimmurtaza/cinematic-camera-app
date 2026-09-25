import 'package:flutter_test/flutter_test.dart';

import 'package:cinematic_camera_app/features/camera/domain/frame_preset.dart';

void main() {
  test('frame catalog exposes the required cinematic presets', () {
    final names = FramePresetCatalog.values.map((frame) => frame.name).toList();

    expect(names, containsAll(['2.39:1', '2.00:1', '16:9', '4:3', '1:1', '9:16']));
    expect(FramePresetCatalog.values.first.aspectRatio, closeTo(2.39, 0.01));
    expect(FramePresetCatalog.values.last.aspectRatio, closeTo(9 / 16, 0.01));
  });

  test('frame presets keep their declared orientation and ratio', () {
    final portraitFrames = FramePresetCatalog.values
        .where((frame) => frame.orientation == CameraOrientation.portrait)
        .toList();
    final landscapeFrames = FramePresetCatalog.values
        .where((frame) => frame.orientation == CameraOrientation.landscape)
        .toList();

    expect(portraitFrames.map((frame) => frame.name), containsAll(['4:3', '1:1', '9:16']));
    expect(landscapeFrames.map((frame) => frame.name), containsAll(['2.39:1', '2.00:1', '16:9']));
    expect(portraitFrames.last.aspectRatio, lessThan(1));
    expect(landscapeFrames.first.aspectRatio, greaterThan(1));
  });
}
