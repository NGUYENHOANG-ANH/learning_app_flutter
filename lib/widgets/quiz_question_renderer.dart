import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// ✅ Render quiz question based on questionType
class QuizQuestionRenderer {
  static Widget renderQuestion({
    required String questionType,
    required String? imageUrl,
    required String? audioUrl,
    required String question,
    required VoidCallback? onAudioTap,
  }) {
    switch (questionType) {
      case 'image':
        return _buildImageQuestion(imageUrl, question);

      case 'audio':
        return _buildAudioQuestion(audioUrl, question, onAudioTap);

      case 'mixed':
        return _buildMixedQuestion(imageUrl, audioUrl, question, onAudioTap);

      default:
        return _buildTextQuestion(question);
    }
  }

  /// 🖼️ IMAGE ONLY
  static Widget _buildImageQuestion(String? imageUrl, String question) {
    return Column(
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder('Image not found');
                },
              ),
            ),
          )
        else
          _buildPlaceholder('No image available', 220),
      ],
    );
  }

  /// 🔊 AUDIO ONLY
  static Widget _buildAudioQuestion(
    String? audioUrl,
    String question,
    VoidCallback? onAudioTap,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onAudioTap,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.accentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentColor.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.volume_up,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '👂 Tap to listen',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 📱 MIXED (Image + Audio)
  static Widget _buildMixedQuestion(
    String? imageUrl,
    String? audioUrl,
    String question,
    VoidCallback? onAudioTap,
  ) {
    return Column(
      children: [
        // Image on left
        if (imageUrl != null && imageUrl.isNotEmpty)
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder('Image not found', 160);
                },
              ),
            ),
          )
        else
          _buildPlaceholder('No image', 160),

        const SizedBox(height: 20),

        // Audio button on right
        if (audioUrl != null && audioUrl.isNotEmpty)
          GestureDetector(
            onTap: onAudioTap,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.volume_up,
                color: Colors.white,
                size: 45,
              ),
            ),
          )
        else
          _buildPlaceholder('No audio', 100),

        const SizedBox(height: 12),
        Text(
          '👀 & 👂 Look and listen! ',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// 📝 TEXT ONLY (Fallback)
  static Widget _buildTextQuestion(String question) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        question,
        style: AppTextStyles.heading2,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// ⚠️ Placeholder widget
  static Widget _buildPlaceholder(String text, [double size = 220]) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[400]!,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              color: Colors.grey[500],
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
