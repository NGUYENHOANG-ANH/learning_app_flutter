import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quiz_model.dart';
import '../services/quiz_adapter.dart';
import '../services/quiz_option_generator.dart';
import '../services/data_service.dart';

/// ✅ FIX: Thay vì StateNotifier cứng, dùng FutureProvider. family
final quizProvider = FutureProvider.family<List<Quiz>, String>(
  (ref, topicId) async {
    return await DataService().loadQuizzesForTopic(topicId);
  },
);

// ========== DEPRECATED:  Cách cũ (giữ lại nếu cần backward compatibility) ==========

@Deprecated('Use quizProvider.family instead')
final quizProviderOld = StateNotifierProvider<QuizProviderOld, List<Quiz>>(
  (ref) => QuizProviderOld(),
);

@Deprecated('Use quizProvider. family instead')
class QuizProviderOld extends StateNotifier<List<Quiz>> {
  QuizProviderOld() : super([]) {
    _loadQuizzes();
  }

  final _generator = QuizOptionGenerator({
    'alphabet': [
      'a',
      'b',
      'c',
      'd',
      'e',
      'f',
      'g',
      'h',
      'i',
      'j',
      'k',
      'l',
      'm',
      'n',
      'o',
      'p',
      'q',
      'r',
      's',
      't',
      'u',
      'v',
      'w',
      'x',
      'y',
      'z',
    ],
    'shapes': [
      'circle',
      'square',
      'rectangle',
      'triangle',
      'diamond',
      'star',
      'heart',
      'oval',
    ],
  });

  /// ✅ FIX: Dùng topicId động, không hardcode 'shapes_quizzes.json'
  Future<void> _loadQuizzes({String topicId = 'shapes'}) async {
    try {
      final fileMap = {
        'animals': 'assets/data/quizzes/animals_quizzes.json',
        'colors': 'assets/data/quizzes/colors_quizzes.json',
        'alphabet': 'assets/data/quizzes/alphabet_quizzes.json',
        'shapes': 'assets/data/quizzes/shapes_quizzes. json',
        'fruits': 'assets/data/quizzes/fruits_quizzes.json',
        'vehicles': 'assets/data/quizzes/vehicles_quizzes.json',
      };

      final filePath = fileMap[topicId];
      if (filePath == null) {
        print('❌ Unknown topic: $topicId');
        state = [];
        return;
      }

      final jsonStr = await rootBundle.loadString(filePath);
      final List data = json.decode(jsonStr);

      final quizzes = data.map<Quiz>((e) {
        // V1 (cũ): có field 'options'
        if (e.containsKey('options')) {
          return Quiz.fromJson(e);
        }
        // V2 (mới): sử dụng adapter + generator
        return QuizAdapter.fromV1Json(e, topicId, [], _generator);
      }).toList();

      state = quizzes;
    } catch (e) {
      print('❌ Error loading quizzes for $topicId: $e');
      state = [];
    }
  }
}
