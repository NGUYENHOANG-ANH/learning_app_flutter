import 'dart:math';
import '../models/quiz_model.dart';
import 'quiz_type_randomizer.dart';

/// ✅ Shuffle quizzes + randomize types
class QuizShuffler {
  /// Shuffle quizzes order
  static List<Quiz> shuffle(List<Quiz> quizzes) {
    final shuffled = List<Quiz>.from(quizzes);
    shuffled.shuffle(Random());
    return shuffled;
  }

  /// Shuffle options in each quiz
  static List<Quiz> shuffleOptions(List<Quiz> quizzes) {
    return quizzes.map((quiz) {
      final options = List<QuizOption>.from(quiz.options);
      options.shuffle(Random());

      return Quiz(
        id: quiz.id,
        topicId: quiz.topicId,
        question: quiz.question,
        questionType: quiz.questionType,
        imageUrl: quiz.imageUrl,
        audioUrl: quiz.audioUrl,
        options: options,
        correctAnswerId: quiz.correctAnswerId,
        level: quiz.level,
        timeLimit: quiz.timeLimit,
        ttsText: quiz.ttsText,
        ttsSpeed: quiz.ttsSpeed,
        ttsLanguage: quiz.ttsLanguage,
        supportedQuestionTypes: quiz.supportedQuestionTypes,
      );
    }).toList();
  }

  /// ✅ Randomize question types
  static List<Quiz> randomizeTypes(List<Quiz> quizzes) {
    return QuizTypeRandomizer.randomizeAllQuizzes(quizzes);
  }

  /// ✅ Main:  Shuffle ALL (questions + options + types)
  static List<Quiz> shuffleAll(List<Quiz> quizzes) {
    // 1. Shuffle question order
    final shuffledQuizzes = shuffle(quizzes);

    // 2. Shuffle options in each quiz
    final withShuffledOptions = shuffleOptions(shuffledQuizzes);

    // 3. Randomize question types (image/audio/mixed)
    return randomizeTypes(withShuffledOptions);
  }
}
