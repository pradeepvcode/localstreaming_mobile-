
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../model/video_item.dart';


class VideoPlayerScreen extends StatefulWidget {
  final VideoItem video;

  const VideoPlayerScreen({
    super.key,
    required this.video,
  });

  @override
  State<VideoPlayerScreen> createState() =>
      _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final VideoPlayerController _controller;
  bool  _wasPlayingBeforeSeek = false;

  bool _hasError = false;
  bool _isSeeking = false;
  double _seekValue = 0;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
    );

    _initializePlayer();
  }

  // Future<void> _initializePlayer() async {
  //   try {
  //     await _controller.initialize();
  //
  //     if (!mounted) return;
  //
  //     setState(() {});
  //
  //     await _controller.play();
  //   } catch (_) {
  //     if (!mounted) return;
  //
  //     setState(() {
  //       _hasError = true;
  //     });
  //   }
  // }
  Future<void> _initializePlayer() async {
    try {
      await _controller.initialize();

      debugPrint('========== PLAYER INITIALIZED ==========');
      debugPrint('VIDEO URL: ${widget.video.videoUrl}');
      debugPrint('DURATION: ${_controller.value.duration}');
      debugPrint('SIZE: ${_controller.value.size}');
      debugPrint('IS INITIALIZED: ${_controller.value.isInitialized}');
      debugPrint('HAS ERROR: ${_controller.value.hasError}');
      debugPrint('ERROR: ${_controller.value.errorDescription}');
      debugPrint('========================================');

      if (!mounted) return;

      setState(() {});

      await _controller.play();
    } catch (e) {
      debugPrint('PLAYER INITIALIZATION ERROR: $e');

      if (!mounted) return;

      setState(() {
        _hasError = true;
      });
    }
  }
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _seekTo(double seconds) async {
    await _controller.seekTo(
      Duration(seconds: seconds.round()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.video.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: _buildVideo(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'On-demand video · MP4',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_hasError &&
                      _controller.value.isInitialized)
                    _buildPlaybackControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideo() {
    if (_hasError) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'Unable to play this video',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return const CircularProgressIndicator(
        color: Colors.white,
      );
    }

    return GestureDetector(
      onTap: () {
        if (_controller.value.isPlaying) {
          _controller.pause();
        } else {
          _controller.play();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              if (value.isPlaying) {
                return const SizedBox.shrink();
              }

              return Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        final duration = value.duration.inSeconds.toDouble();
        final position = value.position.inSeconds.toDouble();

        final maxDuration = duration > 0 ? duration : 1.0;

        final currentSliderValue = (_isSeeking ? _seekValue : position)
            .clamp(0.0, maxDuration);

        final bufferedEnd = value.buffered.fold<double>(
          0.0,
              (maxEnd, range) {
            final end = range.end.inSeconds.toDouble();
            return end > maxEnd ? end : maxEnd;
          },
        );

        final bufferedProgress = bufferedEnd
            .clamp(currentSliderValue, maxDuration);

        return Column(
          children: [
            // Slider(
            //   value: (_isSeeking ? _seekValue : position)
            //       .clamp(0.0, maxDuration),
            //   max: maxDuration,
            //   onChangeStart: (value) {
            //     _wasPlayingBeforeSeek = _controller.value.isPlaying;
            //
            //     setState(() {
            //       _isSeeking = true;
            //       _seekValue = position;
            //     });
            //   },
            //
            //   onChanged: (value) {
            //     setState(() {
            //       _seekValue = value;
            //     });
            //   },
            //
            //   onChangeEnd: (value) async {
            //     try {
            //       await _seekTo(value);
            //
            //       if (!mounted) return;
            //
            //       if (_wasPlayingBeforeSeek) {
            //         await _controller.play();
            //       }
            //
            //       if (!mounted) return;
            //
            //       setState(() {
            //         _isSeeking = false;
            //       });
            //     } catch (_) {
            //       if (!mounted) return;
            //
            //       setState(() {
            //         _isSeeking = false;
            //       });
            //     }
            //   },
            // ),
            Slider(
              value: currentSliderValue,
              max: maxDuration,

              // Grey track showing buffered media.
              secondaryTrackValue: bufferedProgress,
              secondaryActiveColor: Colors.grey.shade400,

              onChangeStart: (value) {
                _wasPlayingBeforeSeek = _controller.value.isPlaying;

                setState(() {
                  _isSeeking = true;
                  _seekValue = position;
                });
              },

              onChanged: (value) {
                setState(() {
                  _seekValue = value;
                });
              },

              onChangeEnd: (value) async {
                try {
                  await _seekTo(value);

                  if (!mounted) return;

                  if (_wasPlayingBeforeSeek) {
                    await _controller.play();
                  }

                  if (!mounted) return;

                  setState(() {
                    _isSeeking = false;
                  });
                } catch (_) {
                  if (!mounted) return;

                  setState(() {
                    _isSeeking = false;
                  });
                }
              },
            ),
            ElevatedButton(
              onPressed: () async {
                debugPrint('BEFORE: ${_controller.value.position}');

                await _controller.seekTo(
                  const Duration(minutes: 5),
                );

                debugPrint(
                  'IMMEDIATELY AFTER: ${_controller.value.position}',
                );

                await Future.delayed(
                  const Duration(seconds: 3),
                );

                final value = _controller.value;

                debugPrint('AFTER 3 SECONDS: ${value.position}');
                debugPrint('IS PLAYING: ${value.isPlaying}');
                debugPrint('IS BUFFERING: ${value.isBuffering}');
                debugPrint('DURATION: ${value.duration}');
                debugPrint('HAS ERROR: ${value.hasError}');
                debugPrint('ERROR: ${value.errorDescription}');
              },
              child: const Text('Test seek to 5 minutes'),
            ),
            Row(
              children: [
                Text(
                  _formatDuration(
                    _isSeeking
                        ? Duration(seconds: _seekValue.round())
                        : value.position,
                  ),
                ),
                const Spacer(),
                Text(_formatDuration(value.duration)),
              ],
            ),
            const SizedBox(height: 16),
            IconButton.filled(
              iconSize: 36,
              onPressed: () {
                if (value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              },
              icon: Icon(
                value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}
