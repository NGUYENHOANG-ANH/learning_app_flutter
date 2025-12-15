import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/topic_model.dart';
import '../models/quiz_attempt_result.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../services/data_service.dart';
import 'quiz_screen.dart'; // ✅ THÊM IMPORT NÀY

class ResultScreen extends ConsumerWidget {
  final String topicId;
  final QuizAttemptResult result;
  final Topic topic;

  const ResultScreen({
    Key? key,
    required this.topicId,
    required this.result,
    required this.topic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicColor = Color(
      int.parse(topic.color.replaceFirst('#', '0xff')),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Kết Quả'),
        backgroundColor: topicColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== HEADER SECTION =====
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    topicColor,
                    topicColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    // Celebration emoji
                    const Text(
                      '🎉',
                      style: TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hoàn Thành!  ',
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${topic.name} Quiz',
                      style: AppTextStyles.heading3.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== SCORE CARD =====
            Padding(
              padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Score/Accuracy
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildScoreStat(
                          label: 'Trả Lời Đúng',
                          value: result.correct.toString(),
                          icon: '✅',
                          color: AppColors.correctGreen,
                        ),
                        _buildScoreStat(
                          label: 'Tổng Câu',
                          value: result.total.toString(),
                          icon: '📝',
                          color: AppColors.primaryColor,
                        ),
                        _buildScoreStat(
                          label: 'Tỷ Lệ',
                          value:
                              '${((result.correct / result.total) * 100).toStringAsFixed(0)}%',
                          icon: '📊',
                          color: topicColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Divider(
                      color: Colors.grey[300],
                      thickness: 2,
                    ),

                    const SizedBox(height: 24),

                    // Stars earned
                    Column(
                      children: [
                        Text(
                          'Sao Kiếm Được',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ..._buildStars(result.starsEarned),
                            const SizedBox(width: 8),
                            Text(
                              '${result.starsEarned} / ${result.total} ⭐',
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.starColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Perfect badge
                    if (result.isPerfect)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.correctGreen.withOpacity(0.2),
                          border: Border.all(
                            color: AppColors.correctGreen,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.starColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Trả Lời Hoàn Hảo!  ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.correctGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ===== NEXT TOPIC SUGGESTION =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FutureBuilder<List<Topic>>(
                future: DataService().loadTopics(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final allTopics = snapshot.data!;
                  final nextTopic = _getNextTopic(allTopics);

                  if (nextTopic == null) {
                    return const SizedBox.shrink();
                  }

                  final nextColor = Color(
                    int.parse(nextTopic.color.replaceFirst('#', '0xff')),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📚 Chủ Đề Tiếp Theo',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        // ✅ FIX: Add proper onTap logic
                        onTap: nextTopic.isLocked
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Mở khóa sau khi đạt ${nextTopic.requiredStars} ⭐',
                                    ),
                                  ),
                                );
                              }
                            : () {
                                // ✅ NAVIGATE TO NEXT TOPIC QUIZ
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        QuizScreen(topic: nextTopic),
                                  ),
                                );
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            color: nextColor.withOpacity(
                              nextTopic.isLocked ? 0.6 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: nextColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Text(
                                nextTopic.name.split(' ')[0],
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nextTopic.name
                                          .split(' ')
                                          .sublist(1)
                                          .join(' '),
                                      style: AppTextStyles.heading3.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      nextTopic.description,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white70,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (nextTopic.isLocked)
                                Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                  size: 24,
                                )
                              else
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // ===== ACTION BUTTONS =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // Home button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Về Trang Chủ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPastel,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Retry button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context, 'retry');
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Làm Lại'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: topicColor,
                        side: BorderSide(color: topicColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual score stat
  Widget _buildScoreStat({
    required String label,
    required String value,
    required String icon,
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
          style: AppTextStyles.heading2.copyWith(
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  /// Build star widgets
  List<Widget> _buildStars(int count) {
    return List.generate(
      count,
      (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(
          Icons.star,
          color: AppColors.starColor,
          size: 28,
        ),
      ),
    );
  }

  /// Get next recommended topic
  Topic? _getNextTopic(List<Topic> allTopics) {
    // Get current topic index
    final currentIndex = allTopics.indexWhere((t) => t.id == topicId);

    if (currentIndex == -1 || currentIndex >= allTopics.length - 1) {
      return null; // No next topic
    }

    // Return next topic
    return allTopics[currentIndex + 1];
  }
}
