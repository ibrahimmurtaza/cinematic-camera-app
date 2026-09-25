import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../application/camera_controller.dart';
import '../domain/camera_state.dart';
import '../domain/frame_preset.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraControllerProvider);
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
                    final previewWidth = outerWidth * 0.92;
                    final previewHeight = previewWidth / selectedFrame.aspectRatio;

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
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: previewWidth,
                          height: previewHeight,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: AppTheme.accentColor.withValues(alpha: 0.85),
                              width: 2.5,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppTheme.accentColor),
                                left: BorderSide(color: AppTheme.accentColor),
                                right: BorderSide(color: AppTheme.accentColor),
                                bottom: BorderSide(color: AppTheme.accentColor),
                              ),
                            ),
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
                    onPressed: () => ref.read(cameraControllerProvider.notifier).toggleLens(),
                    backgroundColor: AppTheme.panelBackground,
                    child: const Icon(Icons.cameraswitch_outlined),
                  ),
                  FloatingActionButton(
                    onPressed: () => ref.read(cameraControllerProvider.notifier).toggleMode(),
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
