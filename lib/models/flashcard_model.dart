import '../utils/asset_path.dart';

class Flashcard {
  final String id;
  final String word;
  final String pronunciation;
  final String imageUrl; // filename only
  final String audioUrl; // filename only
  final String? soundUrl;
  final String topicId;
  final String? vietnameseName;
  final String videoPath; // filename only
  final String? description;
  final int difficulty;
  final String? assetBase; // ✅ From parent JSON

  Flashcard({
    required this.id,
    required this.word,
    required this.pronunciation,
    required this.imageUrl,
    required this.audioUrl,
    required this.topicId,
    required this.videoPath,
    this.soundUrl,
    this.vietnameseName,
    this.description,
    this.difficulty = 1,
    this.assetBase,
  });

  /// ✅ Get full image path
  String getFullImagePath() {
    return AssetPath.flashcardImage(
      topicId: topicId,
      filename: imageUrl,
    );
  }

  /// ✅ Get full audio path
  String getFullAudioPath() {
    return AssetPath.flashcardAudio(
      topicId: topicId,
      filename: audioUrl,
    );
  }

  /// ✅ Get full video path
  String getFullVideoPath() {
    return AssetPath.flashcardVideo(
      topicId: topicId,
      filename: videoPath,
    );
  }

  factory Flashcard.fromJson(
    Map<String, dynamic> json, {
    String? topicId,
    String? assetBase,
  }) {
    final fcTopicId = topicId ?? json['topicId']?.toString();
    final word = json['word']?.toString();

    if (fcTopicId == null || word == null) {
      throw Exception('Flashcard missing topicId or word:  $json');
    }

    return Flashcard(
      id: json['id']?.toString() ?? '',
      word: word,
      pronunciation: json['pronunciation']?.toString() ?? '',
      imageUrl: json['image']?.toString() ??
          json['imageUrl']?.toString() ??
          '${word.toLowerCase()}.png',
      audioUrl: json['audio']?.toString() ??
          json['audioUrl']?.toString() ??
          '${word.toLowerCase()}.mp3',
      soundUrl: json['soundUrl']?.toString() ?? json['sound']?.toString(),
      topicId: fcTopicId,
      vietnameseName:
          json['vietnameseName']?.toString() ?? json['vn']?.toString(),
      description: json['description']?.toString() ?? json['desc']?.toString(),
      difficulty: json['difficulty'] as int? ?? 1,
      videoPath: json['video']?.toString() ??
          json['videoUrl']?.toString() ??
          '${word.toLowerCase()}.mp4',
      assetBase: assetBase,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'word': word,
        'pronunciation': pronunciation,
        'image': imageUrl,
        'audio': audioUrl,
        'soundUrl': soundUrl,
        'topicId': topicId,
        'video': videoPath,
        'vietnameseName': vietnameseName,
        'description': description,
        'difficulty': difficulty,
      };
}
