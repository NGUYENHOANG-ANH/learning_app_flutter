import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../utils/app_colors.dart';

class FlashcardVideoPlayer extends StatefulWidget {
  final String videoPath; // assets/videos/animals/lion_demo.mp4
  final String? videoUrl;
  final Duration autoPlayDuration;
  final VoidCallback? onVideoEnd;

  const FlashcardVideoPlayer({
    Key? key,
    this.videoPath = '',
    this.videoUrl,
    this.autoPlayDuration = const Duration(seconds: 3),
    this.onVideoEnd,
  }) : super(key: key);

  @override
  State<FlashcardVideoPlayer> createState() => _FlashcardVideoPlayerState();
}

class _FlashcardVideoPlayerState extends State<FlashcardVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  Duration? _lastPosition; // ✅ FIX onVideoEnd với looping

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (widget.videoPath.isNotEmpty) {
        _controller = VideoPlayerController.asset(widget.videoPath);
      } else if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
        _controller = VideoPlayerController.network(widget.videoUrl!);
      } else {
        _hasError = true;
        _isLoading = false;
        setState(() {});
        return;
      }

      await _controller.initialize();

      _controller
        ..setLooping(true)
        ..play();

      // ✅ FIX: listener an toàn khi looping
      _controller.addListener(() {
        if (!_controller.value.isInitialized) return;

        final position = _controller.value.position;
        final duration = _controller.value.duration;

        if (_lastPosition != null &&
            _lastPosition! < duration &&
            position == Duration.zero) {
          widget.onVideoEnd?.call();
        }

        _lastPosition = position;
      });

      _isLoading = false;
      setState(() {});
    } catch (e) {
      debugPrint('Video init error: $e');
      _hasError = true;
      _isLoading = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoading();
    }

    if (_hasError || !_controller.value.isInitialized) {
      return _buildError();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// ✅ FIX: aspectRatio luôn > 0
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio > 0
                  ? _controller.value.aspectRatio
                  : 16 / 9,
              child: VideoPlayer(_controller),
            ),
          ),

          // Play / Pause overlay
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),

          // Progress bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppColors.accentColor,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.black26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.accentColor,
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              'Video không tìm thấy',
              style: TextStyle(color: Colors.red[700]),
            ),
          ],
        ),
      ),
    );
  }
}
