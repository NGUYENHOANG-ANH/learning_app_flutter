import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';
import '../services/data_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../models/topic_model.dart';
import '../providers/progress_provider.dart';

class TopicSelectionScreen extends ConsumerWidget {
  final String mode; // 'flashcard' or 'quiz'

  const TopicSelectionScreen({Key? key, required this.mode}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title =
        mode == 'flashcard' ? '📚 Chọn Chủ Đề Học' : '🎮 Chọn Chủ Đề Quiz';

    // ✅ Watch user progress for unlock status
    final userProgress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<List<Topic>>(
        future: DataService().loadTopics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          }

          final topics = snapshot.data ?? [];

          if (topics.isEmpty) {
            return const Center(
              child: Text('Không có topics'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];

              // ✅ Check if topic is unlocked based on stars
              final totalStars = userProgress.totalStars;
              final isUnlocked = totalStars >= topic.requiredStars;

              return _buildTopicCard(
                context,
                topic,
                mode,
                isUnlocked: isUnlocked,
                totalStars: totalStars,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTopicCard(
    BuildContext context,
    Topic topic,
    String mode, {
    required bool isUnlocked,
    required int totalStars,
  }) {
    final color = Color(int.parse(topic.color.replaceFirst('#', '0xff')));

    return GestureDetector(
      onTap: !isUnlocked
          ? () {
              // ✅ Show unlock requirement
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🔒 Cần ${topic.requiredStars} ⭐ để mở khóa (bạn có:  $totalStars ⭐)',
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          : () {
              if (mode == 'flashcard') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardScreen(topic: topic),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(topic: topic),
                  ),
                );
              }
            },
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? color : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? color.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: isUnlocked ? 1.0 : 0.5,
                  child: Text(
                    topic.name.split(' ')[0], // Just emoji
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    topic.name.split(' ').sublist(1).join(' '),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading3.copyWith(
                      color: isUnlocked ? Colors.white : Colors.grey[600],
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: isUnlocked ? 0.8 : 0.5,
                  child: Text(
                    '${topic.totalFlashcards} thẻ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isUnlocked ? Colors.white70 : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            // Lock icon or check
            if (!isUnlocked)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${topic.requiredStars}⭐',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.correctGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.correctGreen.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
