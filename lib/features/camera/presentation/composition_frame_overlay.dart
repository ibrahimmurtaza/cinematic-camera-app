import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/frame_preset.dart';

class CompositionFrameOverlay extends StatelessWidget {
  const CompositionFrameOverlay({
    required this.preset,
    required this.availableSize,
    super.key,
  });

  final FramePreset preset;
  final Size availableSize;

  @override
  Widget build(BuildContext context) {
    final maxWidth = availableSize.width * 0.92;
    final maxHeight = availableSize.height * 0.92;
    final width = math.min(maxWidth, maxHeight * preset.aspectRatio);
    final height = width / preset.aspectRatio;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      height: height,
      decoration: BoxDecoration(
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
    );
  }
}