import 'package:flutter/material.dart';
import 'package:learning_app/services/audio_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'flashcard_video_player.dart';
import 'tts_button.dart'; // ✅ IMPORT TTS BUTTON

class FlashcardWidget extends StatefulWidget {
  final String id; // ✅ Flashcard ID cho TTS tracking
  final String frontText; // Lion
  final String pronunciation; // LEE-UN
  final String vietnameseName; // Sư tử
  final String description; // Mô tả
  final String? imageUrl; // Ảnh 2D
  final String? videoPath; // Video
  final VoidCallback? onFlip;

  const FlashcardWidget({
    Key? key,
    required this.id,
    required this.frontText,
    required this.pronunciation,
    required this.vietnameseName,
    required this.description,
    this.imageUrl,
    this.videoPath,
    this.onFlip,
  }) : super(key: key);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

Widget _buildPlaceholder(String message) {
  return Center(
    child: Text(
      message,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
    ),
  );
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late final AudioService _audioService = AudioService();
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
    widget.onFlip?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 3.14159265359;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _isFlipped
                  ? _buildBackSide() // ⭐ VIDEO
                  : _buildFrontSide(), // ⭐ ẢNH + MÔ TẢ + TTS
            ),
          );
        },
      ),
    );
  }

  // ⭐ MẶT TRƯỚC - Ảnh + Phát âm + Mô tả + TTS BUTTON
  Widget _buildFrontSide() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Word Title + TTS Button (CHỈ CÓ TTS BUTTON NÀY)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    widget.frontText,
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // 🔊 TTS Button - Phát âm từ tiếng Anh
                TtsButton(
                  text: widget.frontText, // "Dog"
                  wordId: widget.id, // "fc_animal_003"
                  size: 45,
                  bgColor: AppColors.accentColor.withValues(alpha: 0.15),
                  iconColor: AppColors.accentColor,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ IMAGE (2D)
            if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  widget.imageUrl!, // Already full path from screen
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ Image load error: $error');
                    return _buildPlaceholder('Image not found');
                  },
                ),
              )
            else
              // Fallback:   Emoji
              const Text(
                '🖼️',
                style: TextStyle(fontSize: 80),
              ),

            const SizedBox(height: 20),

            // ✅ Pronunciation (KHÔNG CÓ TTS BUTTON)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '🎤 Phát âm',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.pronunciation,
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.accentColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Vietnamese Name
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '🇻🇳 Tiếng Việt',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.vietnameseName,
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Description
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '📖 Mô tả',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✅ Flip Hint
            Text(
              '👉 Tap to see video →',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ MẶT SAU - VIDEO (GIỮ NGUYÊN)
  Widget _buildBackSide() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159265359),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Title
            Text(
              'Watch & Learn',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.accentColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // ✅ VIDEO PLAYER
            if (widget.videoPath != null && widget.videoPath!.isNotEmpty)
              Expanded(
                child: FlashcardVideoPlayer(
                  videoPath: widget.videoPath!,
                  onVideoEnd: () {
                    print('${widget.frontText} video ended');
                  },
                ),
              )
            else
              // Fallback: No video available
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_library_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Video không có',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ✅ Flip Back Hint
            Text(
              '← Tap to go back',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
