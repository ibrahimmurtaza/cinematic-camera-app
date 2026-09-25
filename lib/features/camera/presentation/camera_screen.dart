import 'package:camera/camera.dart' as camera_plugin;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../application/camera_controller.dart';
import '../domain/camera_state.dart';
import '../domain/frame_preset.dart';
import 'composition_frame_overlay.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future<void>.microtask(
      () => ref.read(cameraControllerProvider.notifier).initialize(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(cameraControllerProvider.notifier).handleLifecycleChange(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraControllerProvider);
    final nativeController = ref.read(cameraControllerProvider.notifier).nativeController;
    final selectedFrame = cameraState.selectedFrame;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Cinematic Camera',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.06,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.photo_library_outlined),
                    color: AppTheme.textPrimary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final outerWidth = constraints.maxWidth;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: outerWidth,
                          height: constraints.maxHeight,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: nativeController != null && nativeController.value.isInitialized
                                ? camera_plugin.CameraPreview(nativeController)
                                : _PreviewStatus(cameraState: cameraState),
                          ),
                        ),
                        CompositionFrameOverlay(
                          preset: selectedFrame,
                          availableSize: Size(
                            outerWidth,
                            constraints.maxHeight,
                          ),
                        ),
                        Positioned(
                          top: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              cameraState.mode.name.toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 18,
                          child: Text(
                            '${selectedFrame.name} • ${selectedFrame.description}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: FramePresetCatalog.values.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final preset = FramePresetCatalog.values[index];
                    final isSelected = preset == cameraState.selectedFrame;

                    return ChoiceChip(
                      label: Text(preset.name),
                      selected: isSelected,
                      onSelected: (_) => ref.read(cameraControllerProvider.notifier).selectFrame(preset),
                      avatar: null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton.small(
                    onPressed: cameraState.status == CameraStatus.initializing
                        ? null
                        : () => ref.read(cameraControllerProvider.notifier).toggleLens(),
                    backgroundColor: AppTheme.panelBackground,
                    child: const Icon(Icons.cameraswitch_outlined),
                  ),
                  FloatingActionButton(
                    onPressed: cameraState.status == CameraStatus.ready && cameraState.mode == CameraMode.photo
                        ? () => ref.read(cameraControllerProvider.notifier).capturePhoto()
                        : () => ref.read(cameraControllerProvider.notifier).toggleMode(),
                    backgroundColor: AppTheme.accentColor,
                    child: Icon(
                      cameraState.mode == CameraMode.photo ? Icons.photo_camera : Icons.videocam,
                    ),
                  ),
                  FloatingActionButton.small(
                    onPressed: () => ref.read(cameraControllerProvider.notifier).toggleFlash(),
                    backgroundColor: AppTheme.panelBackground,
                    child: Icon(
                      cameraState.isFlashOn ? Icons.flash_on : Icons.flash_off,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewStatus extends StatelessWidget {
  const _PreviewStatus({required this.cameraState});

  final CameraUiState cameraState;

  @override
  Widget build(BuildContext context) {
    final isError = cameraState.status == CameraStatus.error;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.no_photography_outlined : Icons.camera_outlined,
              color: AppTheme.textSecondary,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              cameraState.errorMessage ?? 'Preparing camera preview...',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
