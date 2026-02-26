import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/topic_model.dart';
import '../models/quiz_attempt_result.dart';
import '../models/flashcard_model.dart';
import '../services/data_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'quiz_screen.dart';

class ResultScreen extends ConsumerWidget {
  final String topicId;
  final QuizAttemptResult result;
  final Topic topic;

  const ResultScreen({
    super.key,
    required this.topicId,
    required this.result,
    required this.topic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicColor = Color(int.parse(topic.color.replaceFirst('#', '0xff')));

    return Scaffold(
      appBar: AppBar(
        title: const Text("🏆 Kết quả"),
        backgroundColor: topicColor,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Điểm số: ${result.correct}/${result.total}",
              style: AppTextStyles.heading2,
            ),

            const SizedBox(height: 30),

            /// 🔥 PLAY AGAIN
            ElevatedButton(
              onPressed: () async {
                final flashcards =
                    await DataService().loadFlashcardsForTopic(topicId);

                /// convert Flashcard → Quiz question
                final questions = flashcards.map((Flashcard card) {
                  return {
                    "question": card.word,
                    "options": [
                      card.word,
                      "Option A",
                      "Option B",
                      "Option C",
                    ],
                    "answer": 0,
                  };
                }).toList();

                if (!context.mounted) return;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      questions: questions,
                    ),
                  ),
                );
              },
              child: const Text("Làm lại"),
            ),

            const SizedBox(height: 12),

            /// HOME
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (_) => false,
                );
              },
              child: const Text("Trang chủ"),
            ),
          ],
        ),
      ),
    );
  }
}
