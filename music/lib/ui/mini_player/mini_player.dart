import 'package:flutter/material.dart';
import '../../data/model/song.dart';

class MiniPlayer extends StatelessWidget {
  final Song? currentSong;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const MiniPlayer({
    Key? key,
    required this.currentSong,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onTap,
    required this.onClose,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (currentSong == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Album art
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'http://localhost:3000/api/image?url=${Uri.encodeComponent(currentSong!.image)}',
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 56,
                      height: 56,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.music_note,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Song info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentSong!.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentSong!.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Previous button
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 28),
                onPressed: onPrevious,
                color: Theme.of(context).colorScheme.primary,
              ),
              // Play/Pause button
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 28,
                ),
                onPressed: onPlayPause,
                color: Theme.of(context).colorScheme.primary,
              ),
              // Next button
              IconButton(
                icon: const Icon(Icons.skip_next, size: 28),
                onPressed: onNext,
                color: Theme.of(context).colorScheme.primary,
              ),
              // Close button
              IconButton(
                icon: const Icon(Icons.close, size: 24),
                onPressed: onClose,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
