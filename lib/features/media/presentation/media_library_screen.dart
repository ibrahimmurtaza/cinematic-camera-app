import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/media_item.dart';
import '../services/media_library_service.dart';

class MediaLibraryScreen extends StatefulWidget {
  const MediaLibraryScreen({super.key});

  @override
  State<MediaLibraryScreen> createState() => _MediaLibraryScreenState();
}

class _MediaLibraryScreenState extends State<MediaLibraryScreen> {
  late Future<List<MediaItem>> _items;

  @override
  void initState() {
    super.initState();
    _items = MediaLibraryService().loadItems();
  }

  void _reload() {
    setState(() => _items = MediaLibraryService().loadItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: AppTheme.scaffoldBackground,
        actions: [
          IconButton(
            onPressed: _reload,
            tooltip: 'Refresh library',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<MediaItem>>(
        future: _items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const _LibraryMessage('Unable to load captured media.');
          }
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const _LibraryMessage('Captured photos and videos will appear here.');
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => _MediaTile(item: items[index]),
          );
        },
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => _MediaPreview(item: item)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.type == MediaType.photo
                      ? Image.file(File(item.path), fit: BoxFit.cover)
                      : Container(
                          color: Colors.black,
                          child: const Icon(Icons.play_circle_outline, size: 48),
                        ),
                  if (item.type == MediaType.video)
                    const Positioned(
                      right: 8,
                      top: 8,
                      child: Icon(Icons.videocam_outlined),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.frameId} • ${_formatDate(item.capturedAt)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: item.type == MediaType.photo
            ? InteractiveViewer(child: Image.file(File(item.path)))
            : _VideoPreview(path: item.path),
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({required this.path});

  final String path;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) return const CircularProgressIndicator();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        IconButton(
          onPressed: () => setState(() => _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play()),
          icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
        ),
      ],
    );
  }
}

class _LibraryMessage extends StatelessWidget {
  const _LibraryMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
    );
  }
}

String _formatDate(DateTime date) => '${date.month}/${date.day}/${date.year}';