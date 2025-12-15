/// ✅ Single source of truth for asset paths
class AssetPathBuilder {
  static const String baseAssetsPath = 'assets';

  /// Build flashcard image path
  static String flashcardImage({
    required String topicId,
    required String filename,
    String? assetBase,
  }) {
    if (assetBase != null && assetBase.isNotEmpty) {
      return '$assetBase$filename';
    }
    return '$baseAssetsPath/images/flashcards/$topicId/$filename';
  }

  /// Build flashcard audio path
  static String flashcardAudio({
    required String topicId,
    required String filename,
    String? assetBase,
  }) {
    if (assetBase != null && assetBase.isNotEmpty) {
      return '$assetBase$filename';
    }
    return '$baseAssetsPath/sounds/flashcards/$topicId/$filename';
  }

  /// Build flashcard video path
  static String flashcardVideo({
    required String topicId,
    required String filename,
    String? assetBase,
  }) {
    if (assetBase != null && assetBase.isNotEmpty) {
      return '$assetBase$filename';
    }
    return '$baseAssetsPath/videos/flashcards/$topicId/$filename';
  }

  /// Build quiz option image path
  static String quizOption({
    required String topicId,
    required String filename,
  }) {
    return '$baseAssetsPath/images/options/$topicId/$filename';
  }

  /// Build quiz image path
  static String quizImage({
    required String topicId,
    required String filename,
  }) {
    return '$baseAssetsPath/images/quizzes/$topicId/$filename';
  }
}
