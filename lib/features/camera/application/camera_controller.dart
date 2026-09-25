import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart' as camera_plugin;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/camera_state.dart';
import '../domain/frame_preset.dart';
import '../domain/photo_capture.dart';
import '../services/photo_capture_service.dart';

final cameraControllerProvider =
    StateNotifierProvider<CameraController, CameraUiState>((ref) {
  return CameraController();
});

class CameraController extends StateNotifier<CameraUiState> {
  CameraController({PhotoCaptureService? photoCaptureService})
      : _photoCaptureService = photoCaptureService ?? PhotoCaptureService(),
        super(const CameraUiState());

  final PhotoCaptureService _photoCaptureService;

  camera_plugin.CameraController? _nativeController;
  List<camera_plugin.CameraDescription> _cameras = const [];
  bool _isInitializing = false;

  camera_plugin.CameraController? get nativeController => _nativeController;

  Future<void> initialize() async {
    if (_nativeController != null || _isInitializing) return;

    _isInitializing = true;
    state = state.copyWith(
      status: CameraStatus.initializing,
      clearErrorMessage: true,
    );

    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        _setError('Camera permission is required to use the preview.');
        return;
      }

      _cameras = await camera_plugin.availableCameras();
      if (_cameras.isEmpty) {
        _setError('No camera was found on this device.');
        return;
      }

      await _initializeNativeController(_cameraForLens(state.lens));
    } on camera_plugin.CameraException catch (error) {
      _setError(_cameraErrorMessage(error));
    } catch (_) {
      _setError('Unable to initialize the camera.');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> switchLens() async {
    if (_cameras.isEmpty || _isInitializing) return;

    final nextLens = state.lens == CameraLens.back ? CameraLens.front : CameraLens.back;
    _isInitializing = true;
    state = state.copyWith(status: CameraStatus.initializing, lens: nextLens);

    try {
      await _initializeNativeController(_cameraForLens(nextLens));
    } on camera_plugin.CameraException catch (error) {
      _setError(_cameraErrorMessage(error));
    } catch (_) {
      _setError('Unable to switch cameras.');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> handleLifecycleChange(AppLifecycleState appState) async {
    if (appState == AppLifecycleState.inactive || appState == AppLifecycleState.paused) {
      await _nativeController?.dispose();
      _nativeController = null;
      if (mounted) state = state.copyWith(status: CameraStatus.initializing);
    } else if (appState == AppLifecycleState.resumed && _nativeController == null) {
      await initialize();
    }
  }

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
    unawaited(switchLens());
  }

  void toggleFlash() {
    state = state.copyWith(isFlashOn: !state.isFlashOn);
  }

  Future<PhotoCapture?> capturePhoto() async {
    final controller = _nativeController;
    if (controller == null || !controller.value.isInitialized || state.status != CameraStatus.ready) {
      return null;
    }

    state = state.copyWith(status: CameraStatus.capturing);
    try {
      final capture = await _photoCaptureService.capture(
        cameraController: controller,
        frame: state.selectedFrame,
      );
      if (mounted) state = state.copyWith(status: CameraStatus.ready);
      return capture;
    } catch (_) {
      _setError('Unable to capture the photo.');
      return null;
    }
  }

  void setStatus(CameraStatus status) {
    state = state.copyWith(status: status);
  }

  @override
  void dispose() {
    unawaited(_nativeController?.dispose());
    super.dispose();
  }

  Future<void> _initializeNativeController(
    camera_plugin.CameraDescription description,
  ) async {
    await _nativeController?.dispose();
    final controller = camera_plugin.CameraController(
      description,
      camera_plugin.ResolutionPreset.high,
      enableAudio: false,
    );
    _nativeController = controller;
    await controller.initialize();
    if (mounted) {
      state = state.copyWith(
        status: CameraStatus.ready,
        clearErrorMessage: true,
      );
    }
  }

  camera_plugin.CameraDescription _cameraForLens(CameraLens lens) {
    final desiredDirection = lens == CameraLens.back
        ? camera_plugin.CameraLensDirection.back
        : camera_plugin.CameraLensDirection.front;
    return _cameras.firstWhere(
      (camera) => camera.lensDirection == desiredDirection,
      orElse: () => _cameras.first,
    );
  }

  void _setError(String message) {
    _nativeController = null;
    if (mounted) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: message,
      );
    }
  }

  String _cameraErrorMessage(camera_plugin.CameraException error) {
    return switch (error.code) {
      'CameraAccessDenied' => 'Camera access was denied.',
      'CameraAccessDeniedWithoutPrompt' => 'Camera access is disabled in Settings.',
      'CameraAccessRestricted' => 'Camera access is restricted on this device.',
      _ => error.description ?? 'Unable to access the camera.',
    };
  }
}
