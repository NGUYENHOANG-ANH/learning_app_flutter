import '../models/flashcard_model.dart';

extension FlashcardExtension on Flashcard {
  /// Auto-generate video path từ word + topicId
  /// Example: "Lion" + "animals" → "assets/videos/animals/lion_demo.mp4"
  String get videoPath {
    final fileName = word.toLowerCase().replaceAll(' ', '_');
    return 'assets/videos/$topicId/${fileName}_demo.mp4';
  }

  /// Auto-generate audio path từ word + topicId
  /// Example: "Lion" + "animals" → "assets/audios/animals/lion.mp3"
  String get audioPath {
    final fileName = word.toLowerCase().replaceAll(' ', '_');
    return 'assets/audios/$topicId/$fileName.mp3';
  }

  /// Auto-generate image path (fallback)
  String get imagePath {
    final fileName = word.toLowerCase().replaceAll(' ', '_');
    return 'assets/images/flashcards/$topicId/$fileName.png';
  }
}
