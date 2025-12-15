/// ✅ Flashcard JSON Validator
class FlashcardValidator {
  /// Validate entire flashcard JSON file
  static List<String> validateJson(Map<String, dynamic> json) {
    final errors = <String>[];

    // ===== ROOT LEVEL =====
    if (!json.containsKey('topicId')) {
      errors.add('❌ Missing root key: topicId');
      return errors; // Early exit
    }

    if (!json.containsKey('assetBase')) {
      errors.add('❌ Missing root key: assetBase');
      return errors;
    }

    if (!json.containsKey('flashcards')) {
      errors.add('❌ Missing root key: flashcards');
      return errors;
    }

    // ===== VALIDATE assetBase =====
    final assetBase = json['assetBase'];
    if (assetBase is! Map<String, dynamic>) {
      errors.add('❌ assetBase must be an object');
      return errors;
    }

    final requiredAssetKeys = ['image', 'audio', 'video'];
    for (final key in requiredAssetKeys) {
      if (!assetBase.containsKey(key)) {
        errors.add('❌ assetBase missing key: $key');
      } else if (assetBase[key] is! String) {
        errors.add('❌ assetBase.$key must be a string');
      }
    }

    // ===== VALIDATE flashcards array =====
    final flashcards = json['flashcards'];
    if (flashcards is! List) {
      errors.add('❌ flashcards must be an array');
      return errors;
    }

    if (flashcards.isEmpty) {
      errors.add('⚠️ flashcards array is empty');
    }

    final seenIds = <String>{};
    for (int i = 0; i < flashcards.length; i++) {
      final fc = flashcards[i];

      // Check if it's a map
      if (fc is! Map<String, dynamic>) {
        errors.add('❌ Flashcard[$i] must be an object');
        continue;
      }

      // Check required fields
      final id = fc['id']?.toString();
      final word = fc['word']?.toString();
      final image = fc['image']?.toString();
      final audio = fc['audio']?.toString();
      final video = fc['video']?.toString();

      if (id == null || id.isEmpty) {
        errors.add('❌ Flashcard[$i] missing or empty:  id');
      } else {
        // Check for duplicate IDs
        if (seenIds.contains(id)) {
          errors.add('❌ Flashcard[$i] duplicate id: $id');
        }
        seenIds.add(id);
      }

      if (word == null || word.isEmpty) {
        errors.add('❌ Flashcard[$i] missing or empty: word');
      }

      if (image == null || image.isEmpty) {
        errors.add('⚠️ Flashcard[$i] missing or empty: image');
      }

      if (audio == null || audio.isEmpty) {
        errors.add('⚠️ Flashcard[$i] missing or empty: audio');
      }

      if (video == null || video.isEmpty) {
        errors.add('⚠️ Flashcard[$i] missing or empty: video');
      }

      // Check optional fields
      final pronunciation = fc['pronunciation']?.toString();
      if (pronunciation == null || pronunciation.isEmpty) {
        errors.add('⚠️ Flashcard[$i] missing:  pronunciation');
      }

      final vietnameseName = fc['vietnameseName']?.toString();
      if (vietnameseName == null || vietnameseName.isEmpty) {
        errors.add('⚠️ Flashcard[$i] missing: vietnameseName');
      }

      // Check for deprecated keys
      if (fc.containsKey('topicId')) {
        errors.add(
            '⚠️ Flashcard[$i] has deprecated key: topicId (use root topicId)');
      }

      if (fc.containsKey('vn')) {
        errors.add(
            '⚠️ Flashcard[$i] has deprecated key: vn (use vietnameseName)');
      }

      if (fc.containsKey('desc')) {
        errors
            .add('⚠️ Flashcard[$i] has deprecated key: desc (use description)');
      }

      // Validate difficulty
      final difficulty = fc['difficulty'];
      if (difficulty is! int || difficulty < 1 || difficulty > 3) {
        errors.add(
            '❌ Flashcard[$i] invalid difficulty: $difficulty (must be 1-3)');
      }
    }

    return errors;
  }

  /// Quick check if JSON is valid
  static bool isValid(Map<String, dynamic> json) {
    return validateJson(json).isEmpty;
  }

  /// Check if has critical errors only (warnings don't count)
  static bool isValidIgnoringWarnings(Map<String, dynamic> json) {
    final errors = validateJson(json);
    // Filter out warnings (⚠️)
    final criticalErrors = errors.where((e) => !e.startsWith('⚠️')).toList();
    return criticalErrors.isEmpty;
  }
}

// ============= QUIZ VALIDATOR =============

/// ✅ Quiz JSON Validator (V2 Schema)
class QuizValidator {
  /// Validate single quiz file
  static List<String> validateJson(
    Map<String, dynamic> json,
    String expectedTopicId,
  ) {
    final errors = <String>[];

    // ===== ROOT LEVEL =====
    if (json['version'] != 2) {
      errors.add('⚠️ Expected version 2, got ${json['version']}');
    }

    if (json['topicId'] != expectedTopicId) {
      errors.add(
        '❌ topicId mismatch: "${json['topicId']}" != "$expectedTopicId"',
      );
    }

    if (!json.containsKey('quizzes')) {
      errors.add('❌ Missing root key: quizzes');
      return errors;
    }

    // ===== VALIDATE quizzes array =====
    final quizzes = json['quizzes'];
    if (quizzes is! List) {
      errors.add('❌ quizzes must be an array');
      return errors;
    }

    if (quizzes.isEmpty) {
      errors.add('⚠️ quizzes array is empty');
    }

    final seenIds = <String>{};
    for (int i = 0; i < quizzes.length; i++) {
      final quiz = quizzes[i];

      if (quiz is! Map<String, dynamic>) {
        errors.add('❌ Quiz[$i] must be an object');
        continue;
      }

      // Required fields
      final id = quiz['id']?.toString();
      final question = quiz['question']?.toString();
      final questionType = quiz['questionType']?.toString();
      final sourceFlashcardId = quiz['sourceFlashcardId']?.toString();

      if (id == null || id.isEmpty) {
        errors.add('❌ Quiz[$i] missing or empty: id');
      } else {
        if (seenIds.contains(id)) {
          errors.add('❌ Quiz[$i] duplicate id: $id');
        }
        seenIds.add(id);
      }

      if (question == null || question.isEmpty) {
        errors.add('❌ Quiz[$i] missing or empty: question');
      }

      if (questionType == null || questionType.isEmpty) {
        errors.add('❌ Quiz[$i] missing or empty: questionType');
      } else {
        final validTypes = ['image', 'audio', 'mixed', 'text'];
        if (!validTypes.contains(questionType)) {
          errors.add(
            '❌ Quiz[$i] invalid questionType: "$questionType" '
            '(must be one of: $validTypes)',
          );
        }
      }

      if (sourceFlashcardId == null || sourceFlashcardId.isEmpty) {
        errors.add('❌ Quiz[$i] missing or empty: sourceFlashcardId');
      }

      // Validate optionCount
      final optionCount = quiz['optionCount'];
      if (optionCount is! int || optionCount < 2) {
        errors.add(
          '❌ Quiz[$i] optionCount must be an integer >= 2, got $optionCount',
        );
      }

      // Validate level
      final level = quiz['level'];
      if (level is! int || level < 1 || level > 3) {
        errors.add('❌ Quiz[$i] invalid level: $level (must be 1-3)');
      }

      // Validate reward
      final reward = quiz['reward'];
      if (reward is Map) {
        if (reward['baseStars'] is! int) {
          errors.add('❌ Quiz[$i] reward. baseStars must be an integer');
        }
        if (reward['perfectBonus'] is! int) {
          errors.add('❌ Quiz[$i] reward.perfectBonus must be an integer');
        }
      } else {
        errors.add('⚠️ Quiz[$i] missing reward structure');
      }

      // ✅ Validate TTS fields
      if (quiz['ttsText'] != null) {
        final ttsText = quiz['ttsText']?.toString();
        if (ttsText == null || ttsText.isEmpty) {
          errors.add(
              '⚠️ Quiz[$i] empty ttsText (should be null or valid string)');
        }

        final ttsSpeed = quiz['ttsSpeed'];
        if (ttsSpeed != null &&
            (ttsSpeed is! num || ttsSpeed < 0.5 || ttsSpeed > 2.0)) {
          errors.add('⚠️ Quiz[$i] ttsSpeed should be 0.5-2.0, got $ttsSpeed');
        }

        final ttsLanguage = quiz['ttsLanguage'];
        if (ttsLanguage != null && ttsLanguage is! String) {
          errors.add('⚠️ Quiz[$i] ttsLanguage must be string');
        }
      } else {
        errors.add('❌ Quiz[$i] missing ttsText (required for TTS)');
      }

      // ✅ Validate supportedQuestionTypes
      final supportedQuestionTypes = quiz['supportedQuestionTypes'];
      if (supportedQuestionTypes != null) {
        if (supportedQuestionTypes is! List) {
          errors.add('⚠️ Quiz[$i] supportedQuestionTypes must be an array');
        } else {
          final validTypes = ['image', 'audio', 'mixed', 'text'];
          for (final type in supportedQuestionTypes) {
            if (!validTypes.contains(type.toString().toLowerCase())) {
              errors.add(
                '⚠️ Quiz[$i] invalid supported type: "$type" '
                '(must be one of: $validTypes)',
              );
            }
          }
          if (supportedQuestionTypes.isEmpty) {
            errors.add('⚠️ Quiz[$i] supportedQuestionTypes is empty');
          }
        }
      } else {
        errors.add(
            '⚠️ Quiz[$i] missing supportedQuestionTypes (will use default)');
      }
    }

    return errors;
  }

  /// Quick check if JSON is valid
  static bool isValid(Map<String, dynamic> json, String expectedTopicId) {
    return validateJson(json, expectedTopicId).isEmpty;
  }

  /// Check if has critical errors only
  static bool isValidIgnoringWarnings(
    Map<String, dynamic> json,
    String expectedTopicId,
  ) {
    final errors = validateJson(json, expectedTopicId);
    final criticalErrors = errors.where((e) => !e.startsWith('⚠️')).toList();
    return criticalErrors.isEmpty;
  }
}

// ============= TOPIC VALIDATOR =============

/// ✅ Topic JSON Validator
class TopicValidator {
  static List<String> validateJson(Map<String, dynamic> json) {
    final errors = <String>[];

    if (!json.containsKey('topics')) {
      errors.add('❌ Missing root key: topics');
      return errors;
    }

    final topics = json['topics'];
    if (topics is! List) {
      errors.add('❌ topics must be an array');
      return errors;
    }

    final seenIds = <String>{};
    for (int i = 0; i < topics.length; i++) {
      final topic = topics[i];

      if (topic is! Map<String, dynamic>) {
        errors.add('❌ Topic[$i] must be an object');
        continue;
      }

      final id = topic['id']?.toString();
      final name = topic['name']?.toString();

      if (id == null || id.isEmpty) {
        errors.add('❌ Topic[$i] missing or empty: id');
      } else {
        if (seenIds.contains(id)) {
          errors.add('❌ Topic[$i] duplicate id: $id');
        }
        seenIds.add(id);
      }

      if (name == null || name.isEmpty) {
        errors.add('❌ Topic[$i] missing or empty: name');
      }

      if (topic['description'] == null) {
        errors.add('⚠️ Topic[$i] missing: description');
      }

      if (topic['color'] == null) {
        errors.add('⚠️ Topic[$i] missing: color');
      }

      if (topic['totalFlashcards'] is! int) {
        errors.add('❌ Topic[$i] totalFlashcards must be an integer');
      }

      if (topic['totalQuizzes'] is! int) {
        errors.add('❌ Topic[$i] totalQuizzes must be an integer');
      }
    }

    return errors;
  }

  static bool isValid(Map<String, dynamic> json) {
    return validateJson(json).isEmpty;
  }
}
