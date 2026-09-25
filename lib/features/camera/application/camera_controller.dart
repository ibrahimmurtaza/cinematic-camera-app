import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/camera_state.dart';
import '../domain/frame_preset.dart';

final cameraControllerProvider =
    StateNotifierProvider<CameraController, CameraUiState>((ref) {
  return CameraController();
});

class CameraController extends StateNotifier<CameraUiState> {
  CameraController() : super(const CameraUiState());

  void setReady() {
    state = state.copyWith(status: CameraStatus.ready);
  }

  void selectFrame(FramePreset preset) {
    state = state.copyWith(
      selectedFrame: preset,
      status: CameraStatus.ready,
    );
  }

  void toggleMode() {
    final nextMode = state.mode == CameraMode.photo ? CameraMode.video : CameraMode.photo;
    state = state.copyWith(mode: nextMode);
  }

  void toggleLens() {
    final nextLens = state.lens == CameraLens.back ? CameraLens.front : CameraLens.back;
    state = state.copyWith(lens: nextLens);
  }

  void toggleFlash() {
    state = state.copyWith(isFlashOn: !state.isFlashOn);
  }

  void setStatus(CameraStatus status) {
    state = state.copyWith(status: status);
  }
}
