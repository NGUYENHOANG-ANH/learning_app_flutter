import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tts_provider.dart';
import '../utils/app_colors.dart';

/// ✅ Nút phát âm - Reusable widget
class TtsButton extends ConsumerWidget {
  final String text; // Từ hoặc IPA cần phát (VD: "Cat" hoặc "/kæt/")
  final String wordId; // ID flashcard để track trạng thái
  final double? size; // Kích thước nút (default 48)
  final Color? bgColor; // Màu nền (default accentColor mờ)
  final Color? iconColor; // Màu icon (default accentColor)

  const TtsButton({
    Key? key,
    required this.text,
    required this.wordId,
    this.size = 48,
    this.bgColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsState = ref.watch(ttsProvider);
    final ttsNotifier = ref.read(ttsProvider.notifier);

    // ✅ Check xem từ này đang phát âm không
    final isPlayingThisWord =
        ttsState.isPlaying && ttsState.currentWordId == wordId;

    return GestureDetector(
      onTap: () async {
        if (isPlayingThisWord) {
          // Nếu đang phát, dừng
          await ttsNotifier.stop();
        } else {
          // Phát âm từ
          await ttsNotifier.speak(text, wordId);
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.accentColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: isPlayingThisWord
              ? Border.all(color: AppColors.accentColor, width: 2)
              : null,
        ),
        child: Center(
          child: AnimatedScale(
            scale: isPlayingThisWord ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isPlayingThisWord ? Icons.volume_up : Icons.volume_up_outlined,
              color: iconColor ?? AppColors.accentColor,
              size: (size ?? 48) * 0.55,
            ),
          ),
        ),
      ),
    );
  }
}
