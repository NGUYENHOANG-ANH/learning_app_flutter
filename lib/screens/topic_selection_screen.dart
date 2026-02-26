import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/topic_model.dart';
import '../models/flashcard_model.dart';
import '../services/data_service.dart';
import '../providers/progress_provider.dart';
import '../utils/app_colors.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';

class TopicSelectionScreen extends ConsumerWidget {
  final String mode;

  const TopicSelectionScreen({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          mode == 'flashcard' ? "📚 Chọn Flashcard" : "🎮 Chọn Quiz",
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<List<Topic>>(
        future: DataService().loadTopics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final topics = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: topics.length,
            itemBuilder: (_, index) {
              final topic = topics[index];
              final unlocked = progress.totalStars >= topic.requiredStars;

              return GestureDetector(
                onTap: !unlocked
                    ? null
                    : () async {
                        /// =================
                        /// FLASHCARD MODE
                        /// =================
                        if (mode == "flashcard") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FlashcardScreen(
                                topicId: topic.id,
                              ),
                            ),
                          );
                        } else {
                          /// =================
                          /// QUIZ MODE
                          /// =================

                          final flashcards = await DataService()
                              .loadFlashcardsForTopic(topic.id);

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

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                questions: questions,
                              ),
                            ),
                          );
                        }
                      },
                child: Card(
                  color: unlocked ? Colors.blue : Colors.grey,
                  child: Center(
                    child: Text(
                      topic.name,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
