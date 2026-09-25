enum CameraOrientation { portrait, landscape }

class FramePreset {
  const FramePreset({
    required this.id,
    required this.name,
    required this.aspectRatio,
    required this.description,
    required this.orientation,
  });

  final String id;
  final String name;
  final double aspectRatio;
  final String description;
  final CameraOrientation orientation;

  String get displayLabel => name;

  String get ratioLabel => '${aspectRatio.toStringAsFixed(2)}:1';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FramePreset &&
        other.id == id &&
        other.name == name &&
        other.aspectRatio == aspectRatio;
  }

  @override
  int get hashCode => Object.hash(id, name, aspectRatio);
}

class FramePresetCatalog {
  const FramePresetCatalog();

  static const List<FramePreset> values = [
    FramePreset(
      id: 'cinematic-239',
      name: '2.39:1',
      aspectRatio: 2.39,
      description: 'Wide theatrical framing',
      orientation: CameraOrientation.landscape,
    ),
    FramePreset(
      id: 'cinematic-2',
      name: '2.00:1',
      aspectRatio: 2.0,
      description: 'Balanced wide composition',
      orientation: CameraOrientation.landscape,
    ),
    FramePreset(
      id: 'wide-169',
      name: '16:9',
      aspectRatio: 16 / 9,
      description: 'Standard cinematic widescreen',
      orientation: CameraOrientation.landscape,
    ),
    FramePreset(
      id: 'legacy-43',
      name: '4:3',
      aspectRatio: 4 / 3,
      description: 'Classic stills framing',
      orientation: CameraOrientation.portrait,
    ),
    FramePreset(
      id: 'square-11',
      name: '1:1',
      aspectRatio: 1,
      description: 'Balanced square composition',
      orientation: CameraOrientation.portrait,
    ),
    FramePreset(
      id: 'vertical-916',
      name: '9:16',
      aspectRatio: 9 / 16,
      description: 'Vertical social-first framing',
      orientation: CameraOrientation.portrait,
    ),
  ];
}
