import 'frame_preset.dart';

enum CameraStatus {
  initializing,
  ready,
  capturing,
  recording,
  processing,
  error,
}

enum CameraMode {
  photo,
  video,
}

enum CameraLens {
  back,
  front,
}

class CameraUiState {
  const CameraUiState({
    this.status = CameraStatus.initializing,
    this.errorMessage,
    this.mode = CameraMode.photo,
    this.lens = CameraLens.back,
    this.isFlashOn = false,
    this.selectedFrame = const FramePreset(
      id: 'wide-169',
      name: '16:9',
      aspectRatio: 16 / 9,
      description: 'Standard cinematic widescreen',
      orientation: CameraOrientation.landscape,
    ),
  });

  final CameraStatus status;
  final String? errorMessage;
  final CameraMode mode;
  final CameraLens lens;
  final bool isFlashOn;
  final FramePreset selectedFrame;

  CameraUiState copyWith({
    CameraStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    CameraMode? mode,
    CameraLens? lens,
    bool? isFlashOn,
    FramePreset? selectedFrame,
  }) {
    return CameraUiState(
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      mode: mode ?? this.mode,
      lens: lens ?? this.lens,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      selectedFrame: selectedFrame ?? this.selectedFrame,
    );
  }
}
