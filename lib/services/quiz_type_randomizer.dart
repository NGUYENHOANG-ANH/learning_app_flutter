import 'dart:math';
import '../models/quiz_model.dart';

/// ✅ Randomize question types từ supported types
class QuizTypeRandomizer {
  static final Random _random = Random();

  /// ✅ Randomize question type từ supportedQuestionTypes
  static Quiz randomizeQuestionType(Quiz quiz) {
    // ✅ FIX: Xử lý null safety cho supportedQuestionTypes
    final rawSupportedTypes = quiz.supportedQuestionTypes;

    // Nếu null hoặc rỗng, dùng default
    final supportedTypes =
        (rawSupportedTypes != null && rawSupportedTypes.isNotEmpty)
            ? rawSupportedTypes
            : ['image', 'audio', 'mixed']; // Default fallback

    // ✅ Convert string → QuestionType enum
    final availableTypes = <QuestionType>[];
    for (final typeStr in supportedTypes) {
      final questionType = _stringToQuestionType(typeStr);
      availableTypes.add(questionType);
    }

    // ✅ Nếu không có available types, return original quiz
    if (availableTypes.isEmpty) {
      return quiz;
    }

    // ✅ Random chọn 1 type từ available
    final randomType = availableTypes[_random.nextInt(availableTypes.length)];

    // ✅ Tạo question dựa trên type
    final randomizedQuestion = _getRandomizedQuestion(randomType);

    // ✅ Return new Quiz với random type
    return Quiz(
      id: quiz.id,
      topicId: quiz.topicId,
      question: randomizedQuestion,
      questionType: randomType, // ✅ Set random type
      imageUrl: quiz.imageUrl,
      audioUrl: quiz.audioUrl,
      options: quiz.options,
      correctAnswerId: quiz.correctAnswerId,
      level: quiz.level,
      timeLimit: quiz.timeLimit,
      ttsText: quiz.ttsText,
      ttsSpeed: quiz.ttsSpeed,
      ttsLanguage: quiz.ttsLanguage,
      supportedQuestionTypes: supportedTypes, // ✅ Use processed list
    );
  }

  /// ✅ Convert string → QuestionType enum
  static QuestionType _stringToQuestionType(String typeStr) {
    if (typeStr.isEmpty) {
      return QuestionType.text; // Default if empty
    }

    final str = typeStr.toLowerCase().trim();

    switch (str) {
      case 'image':
        return QuestionType.image;
      case 'audio':
      case 'tts':
        return QuestionType.audio;
      case 'mixed':
        return QuestionType.mixed;
      case 'text':
      default:
        return QuestionType.text;
    }
  }

  /// ✅ Generate random question text dựa trên type
  static String _getRandomizedQuestion(QuestionType type) {
    // ✅ Define questions map với explicit type
    final Map<QuestionType, List<String>> questions = {
      QuestionType.image: [
        '📷 What animal is this?',
        '🖼️ Look at the picture.  Which one is it?',
        '🎨 What do you see? ',
      ],
      QuestionType.audio: [
        '🎧 Listen and choose',
        '🎤 What do you hear?',
        '👂 Listen carefully',
      ],
      QuestionType.mixed: [
        '🎬 Look and listen.  What is it?',
        '👀👂 Watch and listen',
        '🎥 Use both eyes and ears',
      ],
      QuestionType.text: [
        '📝 Which is correct?',
        '✍️ Choose the answer',
        '❓ What is this?',
      ],
    };

    // ✅ Get question list safely
    final questionList = questions[type];

    // ✅ Validate list exists and not empty
    if (questionList == null || questionList.isEmpty) {
      return 'What is this?'; // Safe fallback
    }

    // ✅ Return random question
    return questionList[_random.nextInt(questionList.length)];
  }

  /// ✅ Randomize tất cả quizzes
  static List<Quiz> randomizeAllQuizzes(List<Quiz> quizzes) {
    if (quizzes.isEmpty) {
      return quizzes; // Return empty list if input is empty
    }

    return quizzes.map((quiz) => randomizeQuestionType(quiz)).toList();
  }
}
