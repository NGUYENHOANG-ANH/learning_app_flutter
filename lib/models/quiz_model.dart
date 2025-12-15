/// ✅ Question type enum
enum QuestionType {
  text, // Plain text question
  image, // Image-based question
  audio, // Audio/TTS question
  mixed, // Combined image + audio
}

/// ✅ Quiz option model
class QuizOption {
  final String id;
  final String text;
  final String imageUrl;

  QuizOption({
    required this.id,
    required this.text,
    this.imageUrl = '',
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'imageUrl': imageUrl,
      };
}

/// ✅ Quiz model with TTS support
class Quiz {
  final String id;
  final String topicId;
  final String question;
  final QuestionType questionType;
  final String imageUrl;
  final String? audioUrl;
  final List<QuizOption> options;
  final String correctAnswerId;
  final int level;
  final int? timeLimit;
  final String? ttsText;
  final double? ttsSpeed;
  final String? ttsLanguage;
  final List<String>? supportedQuestionTypes;

  Quiz({
    required this.id,
    required this.topicId,
    required this.question,
    required this.questionType,
    required this.imageUrl,
    required this.audioUrl,
    required this.options,
    required this.correctAnswerId,
    required this.level,
    required this.timeLimit,
    this.ttsText,
    this.ttsSpeed = 0.8,
    this.ttsLanguage = 'en-US',
    this.supportedQuestionTypes = const ['image', 'audio', 'mixed'],
  });

  /// Check if should use TTS instead of audio file
  bool get useTTS => ttsText != null && ttsText!.isNotEmpty;

  factory Quiz.fromJson(
    Map<String, dynamic> json, {
    String? topicId,
  }) {
    final fcTopicId = topicId ?? json['topicId']?.toString();

    if (fcTopicId == null) {
      throw Exception('Quiz missing topicId');
    }

    return Quiz(
        id: json['id']?.toString() ?? '',
        topicId: fcTopicId,
        question: json['question']?.toString() ?? '',
        questionType: _parseQuestionType(json['questionType']),
        imageUrl: json['imageUrl']?.toString() ?? '',
        audioUrl: json['audioUrl']?.toString(),
        options: [],
        correctAnswerId: json['correctAnswerId']?.toString() ?? '',
        level: (json['level'] as int?) ?? 1,
        timeLimit: json['timeLimit'] as int?,
        ttsText: json['ttsText']?.toString(),
        ttsSpeed: (json['ttsSpeed'] as num?)?.toDouble() ?? 0.8,
        ttsLanguage: json['ttsLanguage']?.toString() ?? 'en-US',
        supportedQuestionTypes: List<String>.from(
            json['supportedQuestionTypes'] as List? ??
                ['image', 'audio', 'mixed']));
  }

  static QuestionType _parseQuestionType(dynamic type) {
    if (type is QuestionType) return type;

    final typeStr = type.toString().toLowerCase();
    if (typeStr.contains('image')) return QuestionType.image;
    if (typeStr.contains('audio') || typeStr.contains('tts')) {
      return QuestionType.audio;
    }
    if (typeStr.contains('mixed')) return QuestionType.mixed;
    return QuestionType.text;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'question': question,
        'questionType': questionType.toString(),
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'correctAnswerId': correctAnswerId,
        'level': level,
        'timeLimit': timeLimit,
        'ttsText': ttsText,
        'ttsSpeed': ttsSpeed,
        'ttsLanguage': ttsLanguage,
        'supportedQuestionTypes': supportedQuestionTypes,
      };
}
