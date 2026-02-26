import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/flashcard_provider.dart';
import '../utils/app_scaffold.dart';

class FlashcardScreen extends ConsumerWidget {
  final String topicId;

  const FlashcardScreen({
    super.key,
    required this.topicId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcards = ref.watch(flashcardProvider(topicId));

    final currentIndex = ref.watch(currentFlashcardIndexProvider);

    /// tránh crash index
    if (flashcards.isEmpty || currentIndex >= flashcards.length) {
      return const Scaffold(
        body: Center(child: Text("No flashcards")),
      );
    }

    final currentFlashcard = flashcards[currentIndex];

    final progress = (currentIndex + 1) / flashcards.length;

    return AppScaffold(
      title: "Flashcards",
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withValues(alpha: 0.05),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      currentFlashcard.imageUrl,
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      currentFlashcard.word,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (currentIndex < flashcards.length - 1) {
                  ref
                      .read(
                        currentFlashcardIndexProvider.notifier,
                      )
                      .state++;
                }
              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
