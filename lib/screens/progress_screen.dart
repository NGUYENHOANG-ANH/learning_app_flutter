import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/topic_model.dart';
import '../models/user_progress_model.dart';
import '../services/data_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProgress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Tiến Độ Học'),
        backgroundColor: AppColors.accentColor,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<List<Topic>>(
        future: DataService().loadTopics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final topics = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header - Total Stats
                _buildHeaderStats(userProgress, topics),

                // Topics Progress List
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📚 Tiến Độ Từng Chủ Đề',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 16),
                      ...topics.map((topic) {
                        final topicProgress =
                            userProgress.topicProgress[topic.id];
                        final isUnlocked =
                            userProgress.totalStars >= topic.requiredStars;

                        return _buildTopicProgressCard(
                          context,
                          topic,
                          topicProgress,
                          isUnlocked: isUnlocked,
                          totalStars: userProgress.totalStars,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderStats(UserProgress userProgress, List<Topic> topics) {
    final totalTopics = topics.length;
    final unlockedTopics =
        topics.where((t) => userProgress.totalStars >= t.requiredStars).length;
    final completedTopics = topics
        .where((t) =>
            userProgress.topicProgress[t.id]?.starsEarned != null &&
            userProgress.topicProgress[t.id]!.starsEarned > 0)
        .length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentColor,
            AppColors.accentColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Total Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                icon: '⭐',
                label: 'Tổng Sao',
                value: '${userProgress.totalStars}',
                color: Colors.amber,
              ),
              _buildStatCard(
                icon: '🔓',
                label: 'Chủ Đề Mở',
                value: '$unlockedTopics/$totalTopics',
                color: Colors.blue,
              ),
              _buildStatCard(
                icon: '✅',
                label: 'Hoàn Thành',
                value: '$completedTopics',
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Overall progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tiến Độ Tổng Thể',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: totalTopics > 0 ? completedTopics / totalTopics : 0,
                  minHeight: 12,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicProgressCard(
    BuildContext context,
    Topic topic,
    TopicProgress? topicProgress, {
    required bool isUnlocked,
    required int totalStars,
  }) {
    final topicColor = Color(
      int.parse(topic.color.replaceFirst('#', '0xff')),
    );

    final starsEarned = topicProgress?.starsEarned ?? 0;
    final flashcardsReviewed = topicProgress?.flashcardsReviewed ?? 0;

    final progressPercent = topic.totalFlashcards > 0
        ? (flashcardsReviewed / topic.totalFlashcards) * 100
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(
          isUnlocked ? 255 : 153, // 153 ≈ 0.6
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic name + lock/unlock status
            Row(
              children: [
                Expanded(
                  child: Text(
                    topic.name,
                    style: AppTextStyles.heading3,
                  ),
                ),
                if (!isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '🔒 Cần ${topic.requiredStars}⭐',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.correctGreen.withOpacity(0.2),
                      border: Border.all(
                        color: AppColors.correctGreen,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '✅ Mở Khóa',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.correctGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgressStat(
                  icon: '📖',
                  label: 'Flashcards',
                  value: '$flashcardsReviewed/${topic.totalFlashcards}',
                ),
                _buildProgressStat(
                  icon: '🎮',
                  label: 'Sao Kiếm',
                  value: '$starsEarned⭐',
                ),
                _buildProgressStat(
                  icon: '✨',
                  label: 'Trạng Thái',
                  value: starsEarned > 0 ? 'Đã Học' : 'Chưa',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến độ',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${progressPercent.toStringAsFixed(0)}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: topicColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progressPercent / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(topicColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
