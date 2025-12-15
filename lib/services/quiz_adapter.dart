import '../models/quiz_model.dart';
import '../models/flashcard_model.dart';
import 'quiz_option_generator.dart';

/// ✅ Convert V1 quiz format to V2 format
class QuizAdapter {
  /// Adapt V1 (old format with 'options' array) to V2 (new format with sourceFlashcardId)
  static Quiz adaptV1ToV2(
    Map<String, dynamic> v1Json,
    String topicId,
    List<Flashcard> flashcards,
    QuizOptionGenerator generator,
  ) {
    final id = v1Json['id']?.toString() ?? '';
    final question = v1Json['question']?.toString() ?? '';
    final questionTypeStr = v1Json['questionType']?.toString() ?? 'text';
    final imageUrl = v1Json['imageUrl']?.toString() ?? '';
    final audioUrl = v1Json['audioUrl']?.toString();
    final optionCount = (v1Json['optionCount'] as int?) ?? 3;
    final level = (v1Json['level'] as int?) ?? 1;
    final timeLimit = v1Json['timeLimit'] as int?;

    // ✅ TTS fields (optional in V1)
    final ttsText = v1Json['ttsText']?.toString();
    final ttsSpeed = (v1Json['ttsSpeed'] as num?)?.toDouble() ?? 0.8;
    final ttsLanguage = v1Json['ttsLanguage']?.toString() ?? 'en-US';

    // Parse question type
    final questionType = _parseQuestionType(questionTypeStr);

    // ✅ V1 format:  options array already provided
    final optionsJson = v1Json['options'] as List?;
    List<QuizOption> options = <QuizOption>[];

    if (optionsJson != null && optionsJson.isNotEmpty) {
      // ✅ CASE 1: Parse existing options from V1
      for (final optJson in optionsJson) {
        options.add(QuizOption.fromJson(optJson as Map<String, dynamic>));
      }
    } else {
      // ✅ CASE 2: No options in V1, generate from flashcards
      if (flashcards.isNotEmpty) {
        final sourceFlashcard = flashcards.first;

        // ✅ FIX: Gọi method generateOptions() (thay vì generateOptions không tồn tại)
        try {
          options = generator.generateOptions(
            flashcards, // Pass tất cả flashcards
            sourceFlashcard, // Pass source flashcard (flashcard đúng)
            optionCount, // optionCount từ quiz JSON (default 3)
          );
        } catch (e) {
          print('❌ Error generating options for quiz[$id]: $e');
          // Fallback:  tạo option từ source flashcard duy nhất
          options = [
            QuizOption(
              id: '${topicId}_${sourceFlashcard.word.toLowerCase()}_fallback',
              text: sourceFlashcard.word,
              imageUrl: sourceFlashcard.getFullImagePath(),
            ),
          ];
        }
      } else {
        throw Exception(
          'Cannot generate options: no flashcards available for topic "$topicId"',
        );
      }
    }

    // ✅ Find correct answer ID
    final correctAnswerId = v1Json['correctAnswerId']?.toString() ??
        (options.isNotEmpty ? options.first.id : '');

    return Quiz(
      id: id,
      topicId: topicId,
      question: question,
      questionType: questionType,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      options: options,
      correctAnswerId: correctAnswerId,
      level: level,
      timeLimit: timeLimit,
      ttsText: ttsText,
      ttsSpeed: ttsSpeed,
      ttsLanguage: ttsLanguage,
    );
  }

  /// ✅ Convert V2 quiz to JSON format
  static Map<String, dynamic> quizToV2Json(Quiz quiz) {
    return {
      'id': quiz.id,
      'topicId': quiz.topicId,
      'question': quiz.question,
      'questionType': quiz.questionType.toString().split('.').last,
      'imageUrl': quiz.imageUrl,
      'audioUrl': quiz.audioUrl,
      'level': quiz.level,
      'timeLimit': quiz.timeLimit,
      'ttsText': quiz.ttsText,
      'ttsSpeed': quiz.ttsSpeed,
      'ttsLanguage': quiz.ttsLanguage,
      'options': quiz.options.map((o) => o.toJson()).toList(),
      'correctAnswerId': quiz.correctAnswerId,
    };
  }

  /// ✅ Parse question type from string
  static QuestionType _parseQuestionType(String typeStr) {
    final str = typeStr.toLowerCase();
    if (str.contains('image')) return QuestionType.image;
    if (str.contains('audio') || str.contains('tts')) return QuestionType.audio;
    if (str.contains('mixed')) return QuestionType.mixed;
    return QuestionType.text;
  }

  /// ✅ NEW:  Load V1 quiz từ JSON và convert to V2
  static Quiz fromV1Json(
    Map<String, dynamic> v1Json,
    String topicId,
    List<Flashcard> flashcards,
    QuizOptionGenerator generator,
  ) {
    return adaptV1ToV2(v1Json, topicId, flashcards, generator);
  }

  /// ✅ NEW: Load V2 quiz từ JSON
  static Quiz fromV2Json(
    Map<String, dynamic> v2Json,
    String topicId,
  ) {
    final id = v2Json['id'] as String;
    final question = v2Json['question'] as String;
    final questionTypeStr = v2Json['questionType'] as String;
    final imageUrl = v2Json['imageUrl'] as String? ?? '';
    final audioUrl = v2Json['audioUrl'] as String?;
    final optionsJson = v2Json['options'] as List?;
    final correctAnswerId = v2Json['correctAnswerId'] as String;
    final level = (v2Json['level'] as int?) ?? 1;
    final timeLimit = v2Json['timeLimit'] as int?;
    final ttsText = v2Json['ttsText'] as String?;
    final ttsSpeed = (v2Json['ttsSpeed'] as num?)?.toDouble() ?? 0.8;
    final ttsLanguage = v2Json['ttsLanguage'] as String? ?? 'en-US';

    final questionType = _parseQuestionType(questionTypeStr);

    final options = (optionsJson ?? [])
        .map((opt) => QuizOption.fromJson(opt as Map<String, dynamic>))
        .toList();

    return Quiz(
      id: id,
      topicId: topicId,
      question: question,
      questionType: questionType,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      options: options,
      correctAnswerId: correctAnswerId,
      level: level,
      timeLimit: timeLimit,
      ttsText: ttsText,
      ttsSpeed: ttsSpeed,
      ttsLanguage: ttsLanguage,
    );
  }
}
