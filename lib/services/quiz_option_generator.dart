import '../models/quiz_model.dart';
import '../models/flashcard_model.dart';

class QuizOptionGenerator {
  final Map<String, List<String>> pools;

  QuizOptionGenerator(this.pools);

  /// ✅ NEW METHOD: Generate options từ list flashcards (dùng cho adapter)
  /// Nhận danh sách tất cả flashcards + flashcard đúng → trả về options
  List<QuizOption> generateOptions(
    List<Flashcard> allFlashcards,
    Flashcard sourceFlashcard,
    int optionCount,
  ) {
    // 1️⃣ Lấy topic từ source flashcard
    final topicId = sourceFlashcard.topicId;

    // 2️⃣ Build pool từ flashcards nếu chưa có
    if (!pools.containsKey(topicId) || pools[topicId]!.isEmpty) {
      final flashcardWords =
          allFlashcards.map((fc) => fc.word.toLowerCase()).toList();

      if (flashcardWords.isEmpty) {
        throw Exception(
          'Cannot generate options:  no flashcards available for topic "$topicId"',
        );
      }

      pools[topicId] = flashcardWords;
    }

    // 3️⃣ Dùng method generate() hiện tại
    return generate(
      topicId: topicId,
      correctValue: sourceFlashcard.word,
      optionCount: optionCount,
      assetBasePath: sourceFlashcard.assetBase ?? '',
    );
  }

  /// ✅ EXISTING METHOD (giữ nguyên logic cũ)
  List<QuizOption> generate({
    required String topicId,
    required String correctValue,
    required int optionCount,
    required String assetBasePath,
  }) {
    // 🔴 FIX: Validate topic exists
    final pool = pools[topicId];
    if (pool == null || pool.isEmpty) {
      throw Exception(
        'Topic "$topicId" not found in pools.  Available:  ${pools.keys.toList()}',
      );
    }

    // 🔴 FIX: Validate correctValue exists in pool
    if (!pool.contains(correctValue.toLowerCase())) {
      throw Exception(
        'Correct answer "$correctValue" not in pool for topic "$topicId".  '
        'Available values: $pool',
      );
    }

    // 🔴 FIX: Check optionCount validity
    if (optionCount < 2) {
      throw Exception('optionCount must be at least 2, got $optionCount');
    }
    if (optionCount > pool.length) {
      throw Exception(
        'optionCount ($optionCount) exceeds pool size (${pool.length})',
      );
    }

    final Set<String> selectedValues = {correctValue.toLowerCase()};

    final poolShuffled = [...pool]..shuffle();
    for (final value in poolShuffled) {
      if (selectedValues.length >= optionCount) break;
      final valueLower = value.toLowerCase();
      if (valueLower != correctValue.toLowerCase()) {
        selectedValues.add(valueLower);
      }
    }

    // ✅ Final validation
    assert(selectedValues.length == optionCount,
        'Failed to generate $optionCount unique options');
    assert(selectedValues.contains(correctValue.toLowerCase()),
        'Correct answer missing from options');

    final optionsList = selectedValues.toList()..shuffle();

    return optionsList.map((value) {
      return QuizOption(
        id: '${topicId}_${value}_${DateTime.now().millisecondsSinceEpoch}',
        text: _capitalize(value),
        imageUrl: '$assetBasePath/${value}_small.png',
      );
    }).toList();
  }

  String _capitalize(String v) {
    if (v.isEmpty) return v;
    return v[0].toUpperCase() + v.substring(1);
  }

  /// ✅ Helper:  Check if pool has enough options
  bool canGenerateOptions(String topicId, int optionCount) {
    final pool = pools[topicId];
    return pool != null && pool.length >= optionCount;
  }
}
