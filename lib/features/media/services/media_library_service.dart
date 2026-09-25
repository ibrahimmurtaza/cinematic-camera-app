import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/media_item.dart';

class MediaLibraryService {
  Future<List<MediaItem>> loadItems() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/captures');
    if (!await directory.exists()) return const [];

    final files = await directory.list().where((entity) => entity is File).toList();
    final items = files
        .whereType<File>()
        .where((file) => !_isOriginal(file.path))
        .map(_toMediaItem)
        .toList();
    items.sort((left, right) => right.capturedAt.compareTo(left.capturedAt));
    return items;
  }

  bool _isOriginal(String path) => path.contains('_original.');

  MediaItem _toMediaItem(File file) {
    final name = file.uri.pathSegments.last;
    final type = name.endsWith('.mp4') ? MediaType.video : MediaType.photo;
    final frameId = name
        .split('_')
        .last
        .replaceFirst(RegExp(r'\.(jpg|mp4)$'), '');
    final timestamp = int.tryParse(name.split('_')[1]) ?? 0;
    return MediaItem(
      path: file.path,
      type: type,
      capturedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      frameId: frameId,
    );
  }
}