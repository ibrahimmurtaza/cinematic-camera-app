enum MediaType { photo, video }

class MediaItem {
  const MediaItem({
    required this.path,
    required this.type,
    required this.capturedAt,
    required this.frameId,
  });

  final String path;
  final MediaType type;
  final DateTime capturedAt;
  final String frameId;
}