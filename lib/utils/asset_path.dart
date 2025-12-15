/// ✅ Centralized asset path management
class AssetPath {
  // ===== BASE PATHS =====
  static const String assetsBase = 'assets';
  static const String dataBase = 'data';

  // ===== IMAGES - FLASHCARDS =====
  static String flashcardImage({
    required String topicId,
    required String filename,
  }) =>
      '$assetsBase/images/flashcards/$topicId/$filename';

  // ===== AUDIO - FLASHCARDS =====
  static String flashcardAudio({
    required String topicId,
    required String filename,
  }) =>
      '$assetsBase/sounds/flashcards/$topicId/$filename';

  // ===== VIDEO - FLASHCARDS =====
  static String flashcardVideo({
    required String topicId,
    required String filename,
  }) =>
      '$assetsBase/videos/flashcards/$topicId/$filename';

  // ===== IMAGES - QUIZ =====
  static String quizImage({
    required String topicId,
    required String filename,
  }) =>
      '$assetsBase/images/quizzes/$topicId/$filename';

  // ===== AUDIO - QUIZ =====
  static String quizAudio({
    required String topicId,
    required String filename,
  }) =>
      '$assetsBase/sounds/quizzes/$topicId/$filename';

  // ===== IMAGES - OPTIONS =====
  static String optionImage({
    required String topicId,
    required String filename,
  }) =>
      '$assetsBase/images/options/$topicId/$filename';

  // ===== TOPIC ICONS =====
  static String topicIcon(String filename) =>
      '$assetsBase/images/topics/$filename';

  // ===== JSON DATA =====
  static String topicsJson() => '$dataBase/topics.json';

  static String rewardsJson() => '$dataBase/rewards.json';

  static String manifestJson() => '$dataBase/quizzes/manifest.json';

  static String flashcardsJson(String topicId) =>
      '$dataBase/flashcards/${topicId}_flashcards.json';

  static String quizzesJson(String topicId) =>
      '$dataBase/quizzes/${topicId}_quizzes.json';
}
