import 'package:flutter/foundation.dart';
import '../models/topic_model.dart';
import '../models/flashcard_model.dart';
import '../models/quiz_model.dart';
import '../models/validators.dart';
import 'quiz_option_generator.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class DataService {
  static final DataService _instance = DataService._internal();

  factory DataService() {
    return _instance;
  }

  DataService._internal();

  // ===== FLASHCARDS =====

  /// ✅ Load flashcards for topic with full validation
  Future<List<Flashcard>> loadFlashcardsForTopic(
    String topicId, {
    bool validateSchema = true,
    bool verbose = false,
  }) async {
    try {
      final fileMap = {
        'animals': 'assets/data/flashcards/animals_flashcards.json',
        'colors': 'assets/data/flashcards/colors_flashcards.json',
        'alphabet': 'assets/data/flashcards/alphabet_flashcards.json',
        'shapes': 'assets/data/flashcards/shapes_flashcards.json',
        'fruits': 'assets/data/flashcards/fruits_flashcards.json',
        'vehicles': 'assets/data/flashcards/vehicles_flashcards.json',
      };

      final filePath = fileMap[topicId];
      if (filePath == null) {
        debugPrint('❌ DataService: Unknown topic "$topicId"');
        return [];
      }

      // 1️⃣ Load JSON
      final jsonString = await rootBundle.loadString(filePath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // 2️⃣ Validate schema
      if (validateSchema) {
        final errors = FlashcardValidator.validateJson(jsonData);
        if (errors.isNotEmpty) {
          debugPrint('⚠️ Validation issues in $filePath:');
          for (final error in errors) {
            debugPrint('  $error');
          }

          // Check if critical errors exist
          final criticalErrors =
              errors.where((e) => !e.startsWith('⚠️')).toList();
          if (criticalErrors.isNotEmpty && !verbose) {
            debugPrint('❌ Critical errors found!  Returning empty list.');
            return [];
          }
        } else {
          if (verbose) debugPrint('✅ $filePath schema is valid');
        }
      }

      // 3️⃣ Extract metadata
      final rootTopicId = jsonData['topicId'] as String? ?? topicId;
      final assetBase = jsonData['assetBase'] as Map<String, dynamic>? ?? {};
      final imageBase = assetBase['image']?.toString() ?? '';

      // 4️⃣ Parse flashcards
      final flashcardsJson = (jsonData['flashcards'] as List?) ?? [];
      final flashcards = <Flashcard>[];
      int failedCount = 0;

      for (int i = 0; i < flashcardsJson.length; i++) {
        try {
          final flashcard = Flashcard.fromJson(
            flashcardsJson[i] as Map<String, dynamic>,
            topicId: rootTopicId,
            assetBase: imageBase,
          );
          flashcards.add(flashcard);
        } catch (e) {
          debugPrint('❌ Error parsing flashcard[$i] in $topicId:  $e');
          failedCount++;
        }
      }

      if (verbose) {
        debugPrint(
          '✅ Loaded ${flashcards.length} flashcards for "$topicId" '
          '(${failedCount > 0 ? '$failedCount failed' : 'all success'})',
        );
      }

      return flashcards;
    } catch (e) {
      debugPrint('❌ DataService. loadFlashcardsForTopic($topicId) error: $e');
      return [];
    }
  }

  /// ✅ Load all flashcards
  Future<List<Flashcard>> loadAllFlashcards({bool verbose = false}) async {
    try {
      final topics = await loadTopics();
      final allFlashcards = <Flashcard>[];

      for (final topic in topics) {
        final flashcards = await loadFlashcardsForTopic(
          topic.id,
          verbose: verbose,
        );
        allFlashcards.addAll(flashcards);
      }

      if (verbose) {
        debugPrint('✅ Loaded ${allFlashcards.length} total flashcards');
      }

      return allFlashcards;
    } catch (e) {
      debugPrint('❌ DataService.loadAllFlashcards() error: $e');
      return [];
    }
  }

  // ===== QUIZZES =====

  /// ✅ Load quizzes for topic with full validation + option generation
  Future<List<Quiz>> loadQuizzesForTopic(
    String topicId, {
    bool validateSchema = true,
    bool verbose = false,
  }) async {
    try {
      final fileMap = {
        'animals': 'assets/data/quizzes/animals_quizzes.json',
        'colors': 'assets/data/quizzes/colors_quizzes.json',
        'alphabet': 'assets/data/quizzes/alphabet_quizzes.json',
        'shapes': 'assets/data/quizzes/shapes_quizzes.json',
        'fruits': 'assets/data/quizzes/fruits_quizzes.json',
        'vehicles': 'assets/data/quizzes/vehicles_quizzes.json',
      };

      final filePath = fileMap[topicId];
      if (filePath == null) {
        debugPrint('❌ DataService: Unknown topic "$topicId"');
        return [];
      }

      // 1️⃣ Load JSON
      final jsonString = await rootBundle.loadString(filePath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // 2️⃣ Validate schema
      if (validateSchema) {
        final errors = QuizValidator.validateJson(jsonData, topicId);
        if (errors.isNotEmpty) {
          debugPrint('⚠️ Validation issues in $filePath:');
          for (final error in errors) {
            debugPrint('  $error');
          }

          final criticalErrors =
              errors.where((e) => !e.startsWith('⚠️')).toList();
          if (criticalErrors.isNotEmpty && !verbose) {
            debugPrint('❌ Critical errors found! Returning empty list.');
            return [];
          }
        } else {
          if (verbose) debugPrint('✅ $filePath schema is valid');
        }
      }

      // 3️⃣ Load flashcards (needed for option generation)
      final topicFlashcards = await loadFlashcardsForTopic(topicId);
      if (topicFlashcards.isEmpty) {
        debugPrint('⚠️ No flashcards found for topic "$topicId"');
        return [];
      }

      if (verbose) {
        debugPrint(
            '✅ Loaded ${topicFlashcards.length} flashcards for option generation');
      }

      // 4️⃣ Build option generator pool
      final pool = {
        topicId: topicFlashcards.map((fc) => fc.word.toLowerCase()).toList(),
      };
      final generator = QuizOptionGenerator(pool);

      // 5️⃣ Parse quizzes
      final quizzesJson = (jsonData['quizzes'] as List?) ?? [];
      final quizzes = <Quiz>[];
      int failedCount = 0;

      for (int i = 0; i < quizzesJson.length; i++) {
        try {
          final quizJson = quizzesJson[i] as Map<String, dynamic>;

          // Determine version and load accordingly
          final version = jsonData['version'] ?? 1;

          Quiz quiz;
          if (version == 2) {
            quiz = _loadQuizV2(
              quizJson,
              topicId,
              topicFlashcards,
              generator,
            );
          } else {
            quiz = Quiz.fromJson(quizJson, topicId: topicId); // V1 fallback
          }

          quizzes.add(quiz);
        } catch (e) {
          debugPrint('❌ Error parsing quiz[$i] in $topicId: $e');
          failedCount++;
        }
      }

      if (verbose) {
        debugPrint(
          '✅ Loaded ${quizzes.length} quizzes for "$topicId" '
          '(${failedCount > 0 ? '$failedCount failed' : 'all success'})',
        );
      }

      return quizzes;
    } catch (e) {
      debugPrint('❌ DataService.loadQuizzesForTopic($topicId) error: $e');
      return [];
    }
  }

  /// ✅ Load single Quiz V2 with validation + option generation
  Quiz _loadQuizV2(
    Map<String, dynamic> quizJson,
    String topicId,
    List<Flashcard> topicFlashcards,
    QuizOptionGenerator generator,
  ) {
    try {
      // Extract fields
      final id = quizJson['id'] as String?;
      final question = quizJson['question'] as String?;
      final questionType = quizJson['questionType'] as String?;
      final sourceFlashcardId = quizJson['sourceFlashcardId'] as String?;
      final imageUrl = quizJson['imageUrl'] as String?;
      final audioUrl = quizJson['audioUrl'] as String?;
      final optionCount = (quizJson['optionCount'] as int?) ?? 3;
      final level = (quizJson['level'] as int?) ?? 1;
      final timeLimit = quizJson['timeLimit'] as int?;

      // ✅ TTS fields (optional)
      final ttsText = quizJson['ttsText'] as String?;
      final ttsSpeed = (quizJson['ttsSpeed'] as num?)?.toDouble() ?? 0.8;
      final ttsLanguage = quizJson['ttsLanguage'] as String? ?? 'en-US';

      // ✅ NEW: Supported question types
      final supportedQuestionTypes = List<String>.from(
        quizJson['supportedQuestionTypes'] as List? ??
            ['image', 'audio', 'mixed'],
      );

      // Validate required fields
      if (id == null || id.isEmpty) {
        throw Exception('Quiz missing id');
      }

      if (question == null || question.isEmpty) {
        throw Exception('Quiz[$id] missing question');
      }

      if (questionType == null ||
          !['image', 'audio', 'mixed', 'text'].contains(questionType)) {
        throw Exception('Quiz[$id] invalid questionType: $questionType');
      }

      if (sourceFlashcardId == null || sourceFlashcardId.isEmpty) {
        throw Exception('Quiz[$id] missing sourceFlashcardId');
      }

      // Find source flashcard
      final sourceFlashcard = topicFlashcards.firstWhere(
        (fc) => fc.id.toLowerCase() == sourceFlashcardId.toLowerCase(),
        orElse: () => throw Exception(
          'Quiz[$id] sourceFlashcardId "$sourceFlashcardId" not found in topic "$topicId"',
        ),
      );

      // ✅ FIX: Sử dụng generateOptions() từ QuizOptionGenerator
      List<QuizOption> options = <QuizOption>[];

      try {
        options = generator.generateOptions(
          topicFlashcards,
          sourceFlashcard,
          optionCount,
        );

        if (options.isEmpty) {
          throw Exception('No options generated for quiz[$id]');
        }
      } catch (e) {
        debugPrint('❌ Error generating options for quiz[$id]: $e');
        throw Exception('Failed to generate options:  $e');
      }

      // Find correct option ID
      final correctOptionId = options
          .firstWhere(
            (opt) =>
                opt.text.toLowerCase() == sourceFlashcard.word.toLowerCase(),
            orElse: () => throw Exception(
              'Correct answer "${sourceFlashcard.word}" not found in generated options',
            ),
          )
          .id;

      return Quiz(
        id: id,
        topicId: topicId,
        question: question,
        questionType: _stringToQuestionType(questionType),
        imageUrl: imageUrl ?? '',
        audioUrl: audioUrl ?? '',
        options: options,
        correctAnswerId: correctOptionId,
        level: level,
        timeLimit: timeLimit,
        ttsText: ttsText,
        ttsSpeed: ttsSpeed,
        ttsLanguage: ttsLanguage,
        supportedQuestionTypes: supportedQuestionTypes,
      );
    } catch (e) {
      debugPrint('❌ Error in _loadQuizV2: $e');
      rethrow;
    }
  }

  /// ✅ Helper:  Convert string to QuestionType enum
  QuestionType _stringToQuestionType(String typeStr) {
    final str = typeStr.toLowerCase();
    if (str.contains('image')) return QuestionType.image;
    if (str.contains('audio') || str.contains('tts')) return QuestionType.audio;
    if (str.contains('mixed')) return QuestionType.mixed;
    return QuestionType.text;
  }

  /// ✅ Load all quizzes
  Future<List<Quiz>> loadAllQuizzes({bool verbose = false}) async {
    try {
      final topics = await loadTopics();
      final allQuizzes = <Quiz>[];

      for (final topic in topics) {
        final quizzes = await loadQuizzesForTopic(
          topic.id,
          verbose: verbose,
        );
        allQuizzes.addAll(quizzes);
      }

      if (verbose) {
        debugPrint('✅ Loaded ${allQuizzes.length} total quizzes');
      }

      return allQuizzes;
    } catch (e) {
      debugPrint('❌ DataService.loadAllQuizzes() error: $e');
      return [];
    }
  }

  // ===== TOPICS =====

  /// ✅ Load topics with validation
  Future<List<Topic>> loadTopics({
    bool validateSchema = true,
    bool verbose = false,
  }) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/topics.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate
      if (validateSchema) {
        final errors = TopicValidator.validateJson(jsonData);
        if (errors.isNotEmpty) {
          debugPrint('⚠️ Validation issues in topics.json:');
          for (final error in errors) {
            debugPrint('  $error');
          }
        }
      }

      // Parse
      final topics = (jsonData['topics'] as List?)
              ?.map((item) => Topic.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      if (verbose) {
        debugPrint('✅ Loaded ${topics.length} topics');
      }

      return topics;
    } catch (e) {
      debugPrint('❌ DataService.loadTopics() error: $e');
      return [];
    }
  }

  // ===== MANIFEST =====

  /// ✅ Load quiz manifest (lightweight)
  Future<Map<String, dynamic>> getQuizManifest() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/quizzes/manifest.json');
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ DataService.getQuizManifest() error: $e');
      return {};
    }
  }

  // ===== VALIDATION & DIAGNOSTICS =====

  /// ✅ Run full diagnostic on all JSON files
  Future<void> runFullDiagnostics({bool verbose = true}) async {
    debugPrint('\n🔍 RUNNING FULL DIAGNOSTICS.. .\n');

    // 1. Topics
    debugPrint('📌 Validating topics.json...');
    await loadTopics(validateSchema: true, verbose: verbose);

    // 2. Flashcards
    debugPrint('\n📚 Validating flashcards.. .');
    final flashcardTopics = [
      'animals',
      'colors',
      'alphabet',
      'shapes',
      'fruits',
      'vehicles',
    ];
    for (final topic in flashcardTopics) {
      await loadFlashcardsForTopic(
        topic,
        validateSchema: true,
        verbose: verbose,
      );
    }

    // 3. Quizzes
    debugPrint('\n🎮 Validating quizzes.. .');
    for (final topic in flashcardTopics) {
      await loadQuizzesForTopic(
        topic,
        validateSchema: true,
        verbose: verbose,
      );
    }

    debugPrint('\n✅ DIAGNOSTICS COMPLETE\n');
  }

  /// ✅ Get schema validation report
  Future<String> getValidationReport() async {
    final buffer = StringBuffer();
    buffer.writeln('📋 JSON SCHEMA VALIDATION REPORT');
    buffer.writeln('━' * 70);
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('');

    // Topics
    try {
      final jsonString = await rootBundle.loadString('assets/data/topics.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final errors = TopicValidator.validateJson(jsonData);

      buffer.writeln('📌 topics.json');
      if (errors.isEmpty) {
        buffer.writeln('  ✅ VALID');
      } else {
        for (final error in errors) {
          buffer.writeln('  $error');
        }
      }
      buffer.writeln('');
    } catch (e) {
      buffer.writeln('❌ Error loading topics.json: $e\n');
    }

    // Flashcards
    buffer.writeln('📚 Flashcards: ');
    final flashcardTopics = [
      'animals',
      'colors',
      'alphabet',
      'shapes',
      'fruits',
      'vehicles',
    ];

    for (final topic in flashcardTopics) {
      try {
        final fileMap = {
          'animals': 'assets/data/flashcards/animals_flashcards.json',
          'colors': 'assets/data/flashcards/colors_flashcards.json',
          'alphabet': 'assets/data/flashcards/alphabet_flashcards.json',
          'shapes': 'assets/data/flashcards/shapes_flashcards.json',
          'fruits': 'assets/data/flashcards/fruits_flashcards.json',
          'vehicles': 'assets/data/flashcards/vehicles_flashcards.json',
        };

        final filePath = fileMap[topic]!;
        final jsonString = await rootBundle.loadString(filePath);
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        final errors = FlashcardValidator.validateJson(jsonData);

        if (errors.isEmpty) {
          buffer.writeln('  ✅ $topic');
        } else {
          final criticalCount = errors.where((e) => !e.startsWith('⚠️')).length;
          buffer.writeln('  ❌ $topic ($criticalCount errors)');
        }
      } catch (e) {
        buffer.writeln('  ❌ $topic (load error:  $e)');
      }
    }
    buffer.writeln('');

    // Quizzes
    buffer.writeln('🎮 Quizzes:');
    for (final topic in flashcardTopics) {
      try {
        final fileMap = {
          'animals': 'assets/data/quizzes/animals_quizzes.json',
          'colors': 'assets/data/quizzes/colors_quizzes.json',
          'alphabet': 'assets/data/quizzes/alphabet_quizzes.json',
          'shapes': 'assets/data/quizzes/shapes_quizzes.json',
          'fruits': 'assets/data/quizzes/fruits_quizzes.json',
          'vehicles': 'assets/data/quizzes/vehicles_quizzes.json',
        };

        final filePath = fileMap[topic]!;
        final jsonString = await rootBundle.loadString(filePath);
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        final errors = QuizValidator.validateJson(jsonData, topic);

        if (errors.isEmpty) {
          buffer.writeln('  ✅ $topic');
        } else {
          final criticalCount = errors.where((e) => !e.startsWith('⚠️')).length;
          buffer.writeln('  ❌ $topic ($criticalCount errors)');
        }
      } catch (e) {
        buffer.writeln('  ❌ $topic (load error: $e)');
      }
    }

    buffer.writeln('\n━' * 70);

    return buffer.toString();
  }

  // ===== HELPER METHODS =====

  /// ✅ Check if topic exists
  Future<bool> topicExists(String topicId) async {
    final topics = await loadTopics(validateSchema: false);
    return topics.any((t) => t.id == topicId);
  }

  /// ✅ Get topic by ID
  Future<Topic?> getTopicById(String topicId) async {
    final topics = await loadTopics(validateSchema: false);
    try {
      return topics.firstWhere((t) => t.id == topicId);
    } catch (e) {
      return null;
    }
  }

  /// ✅ Get flashcard count for topic
  Future<int> getFlashcardCount(String topicId) async {
    final flashcards = await loadFlashcardsForTopic(
      topicId,
      validateSchema: false,
    );
    return flashcards.length;
  }

  /// ✅ Get quiz count for topic
  Future<int> getQuizCount(String topicId) async {
    final quizzes = await loadQuizzesForTopic(
      topicId,
      validateSchema: false,
    );
    return quizzes.length;
  }
}
